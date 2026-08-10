@{
    ProjectRoots = @(
        (Join-Path $HOME 'Projects')
        (Join-Path $HOME 'Repos')
    )
    ContainerRoots = @()
    ActiveProjects = @(
        (Join-Path $HOME 'Projects\ai-engineering-setup')
    )
    AgentCommand = 'codex'
}
