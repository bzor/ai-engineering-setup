; extends

; encompass360 convention: GLSL source lives in template literals hinted by a
; /* glsl */ block comment, e.g.  export const particlesVert = /* glsl */ `...`
;
; injection.include-children is REQUIRED: by default Neovim excludes child-node
; ranges from an injection, and a template_string's actual text lives in child
; nodes (string_fragment / template_substitution) — without this only the
; backtick delimiters get injected and nothing highlights.
(
  (comment) @_hint
  .
  (template_string) @injection.content
  (#lua-match? @_hint "^/%*%s*[gG][lL][sS][lL]%s*%*/$")
  (#set! injection.language "glsl")
  (#set! injection.include-children)
)

; also support the tagged-template form:  glsl`...`
(
  (call_expression
    function: (identifier) @_fn (#eq? @_fn "glsl")
    arguments: (template_string) @injection.content)
  (#set! injection.language "glsl")
  (#set! injection.include-children)
)
