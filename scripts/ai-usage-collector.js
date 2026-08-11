#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const { spawn } = require('child_process');

const installedDataPath = path.join(process.env.USERPROFILE || '', '.glzr', 'zebar', 'ai-usage-bar', 'usage.json');
const repositoryDataPath = path.resolve(__dirname, '..', 'configs', 'zebar', 'ai-usage-bar', 'usage.json');
const dataPath = fs.existsSync(path.dirname(installedDataPath)) ? installedDataPath : repositoryDataPath;

function readState() {
  try { return JSON.parse(fs.readFileSync(dataPath, 'utf8')); }
  catch { return { schemaVersion: 1, codex: null, claude: null }; }
}

function writeState(patch) {
  const state = { ...readState(), ...patch, schemaVersion: 1 };
  const temporary = `${dataPath}.${process.pid}.tmp`;
  fs.mkdirSync(path.dirname(dataPath), { recursive: true });
  fs.writeFileSync(temporary, `${JSON.stringify(state, null, 2)}\n`, 'utf8');
  fs.renameSync(temporary, dataPath);
}

const sessionTtlMs = 10 * 60_000;

function normalizeContextWindow(value) {
  if (!value) return null;
  const size = Number(value.context_window_size ?? value.contextWindowSize);
  const inputTokens = Number(value.total_input_tokens ?? value.totalInputTokens ?? 0);
  const usedPercent = Number(value.used_percentage ?? value.usedPercent);
  return {
    usedPercent: Number.isFinite(usedPercent) ? usedPercent
      : Number.isFinite(size) && size ? (inputTokens / size) * 100
      : null,
    inputTokens: Number.isFinite(inputTokens) ? inputTokens : 0,
    contextWindowSize: Number.isFinite(size) && size ? size : null,
  };
}

// Every Claude Code session writes through the same file, so context is kept
// per session and stale entries are dropped once a session stops rendering.
function mergeSessions(previous, sessionId, entry) {
  const now = Date.now();
  const sessions = { ...(previous ?? {}) };
  for (const [id, value] of Object.entries(sessions)) {
    const age = now - new Date(value?.updatedAt ?? 0).getTime();
    if (!Number.isFinite(age) || age > sessionTtlMs) delete sessions[id];
  }
  if (entry) sessions[sessionId] = entry;
  return sessions;
}

function normalizeClaudeWindow(value, durationMinutes) {
  if (!value) return null;
  const resetsAtValue = value.resets_at ?? value.resetsAt;
  const resetsAt = typeof resetsAtValue === 'string'
    ? Math.floor(new Date(resetsAtValue).getTime() / 1000)
    : Number(resetsAtValue);
  return {
    usedPercent: Number(value.used_percentage ?? value.usedPercent ?? 0),
    resetsAt: Number.isFinite(resetsAt) ? resetsAt : null,
    windowDurationMins: durationMinutes,
  };
}

function formatTokens(count) {
  if (!Number.isFinite(count)) return null;
  if (count < 1_000) return String(count);
  const thousands = Math.round(count / 1_000);
  if (thousands < 1_000) return `${thousands}k`;
  const millions = count / 1_000_000;
  return `${millions.toFixed(millions >= 10 ? 0 : 1).replace(/\.0$/, '')}M`;
}

async function captureClaudeStatusLine() {
  let input = '';
  for await (const chunk of process.stdin) input += chunk;
  try {
    const payload = JSON.parse(input);
    const limits = payload.rate_limits ?? payload.rateLimits ?? {};
    const context = normalizeContextWindow(payload.context_window ?? payload.contextWindow);
    const sessionId = String(payload.session_id ?? payload.sessionId ?? 'session');
    const workingDirectory = payload.workspace?.current_dir ?? payload.workspace?.currentDir ?? payload.cwd ?? '';
    const model = payload.model?.display_name ?? payload.model?.displayName ?? null;
    const claude = {
      fiveHour: normalizeClaudeWindow(limits.five_hour ?? limits.fiveHour, 300),
      sevenDay: normalizeClaudeWindow(limits.seven_day ?? limits.sevenDay, 10080),
      sessions: mergeSessions(readState().claude?.sessions, sessionId, context && {
        ...context,
        directory: path.basename(workingDirectory) || null,
        model,
        updatedAt: new Date().toISOString(),
      }),
      updatedAt: new Date().toISOString(),
    };
    writeState({ claude });
    // Rate-limit windows stay in usage.json for the Zebar widget; the status
    // line only shows context.
    const parts = [];
    if (context?.usedPercent != null) {
      const used = formatTokens(context.inputTokens);
      const total = formatTokens(context.contextWindowSize);
      const tokens = used && total ? ` · ${used}/${total}` : used ? ` · ${used}` : '';
      parts.push(`ctx ${Math.round(context.usedPercent)}%${tokens}`);
    }
    const label = model ?? 'Claude';
    process.stdout.write(parts.length ? `${label} · ${parts.join(' · ')}` : `${label} · usage unavailable`);
  } catch (error) {
    process.stdout.write('Claude usage unavailable');
    process.stderr.write(`ai-usage-collector: ${error.message}\n`);
  }
}

function queryCodex() {
  return new Promise((resolve, reject) => {
    const child = spawn('codex', ['app-server', '--stdio'], {
      windowsHide: true,
      stdio: ['pipe', 'pipe', 'pipe'],
    });
    let buffer = '';
    let stderr = '';
    let complete = false;
    const timer = setTimeout(() => finish(new Error('Codex usage query timed out')), 15000);

    function finish(error, result) {
      if (complete) return;
      complete = true;
      clearTimeout(timer);
      child.kill();
      if (error) reject(error); else resolve(result);
    }

    child.stderr.on('data', chunk => { stderr += chunk; });
    child.on('error', finish);
    child.on('exit', code => {
      if (!complete) finish(new Error(stderr.trim() || `Codex app-server exited with ${code}`));
    });
    child.stdout.on('data', chunk => {
      buffer += chunk;
      let newline;
      while ((newline = buffer.indexOf('\n')) >= 0) {
        const line = buffer.slice(0, newline).trim();
        buffer = buffer.slice(newline + 1);
        if (!line) continue;
        let message;
        try { message = JSON.parse(line); } catch { continue; }
        if (message.id === 1) {
          child.stdin.write(`${JSON.stringify({ method: 'initialized' })}\n`);
          child.stdin.write(`${JSON.stringify({ id: 2, method: 'account/rateLimits/read' })}\n`);
        } else if (message.id === 2) {
          if (message.error) finish(new Error(message.error.message || 'Codex usage query failed'));
          else finish(null, message.result);
        }
      }
    });
    child.stdin.write(`${JSON.stringify({
      id: 1,
      method: 'initialize',
      params: {
        clientInfo: { name: 'ai-usage-widget', version: '1.0.0' },
        capabilities: { experimentalApi: true },
      },
    })}\n`);
  });
}

async function updateCodex() {
  try {
    const response = await queryCodex();
    const snapshot = response.rateLimitsByLimitId?.codex ?? response.rateLimits;
    writeState({
      codex: {
        primary: snapshot?.primary ?? null,
        secondary: snapshot?.secondary ?? null,
        updatedAt: new Date().toISOString(),
      },
      codexError: null,
    });
  } catch (error) {
    writeState({ codexError: error.message, codexErrorAt: new Date().toISOString() });
  }
}

async function watch() {
  await updateCodex();
  setInterval(updateCodex, 60_000);
}

if (process.argv.includes('--claude-status-line')) captureClaudeStatusLine();
else if (process.argv.includes('--once')) updateCodex();
else watch();
