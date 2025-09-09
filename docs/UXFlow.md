# Connectome UX Flow Document

Below is a detailed **User Experience (UX) Flow** document for the Connectome system, reflecting the setup, repository recognition, daemon operation, indexing, and integration scenarios you described. Each stage is designed to be intuitive, cross-platform, and robust, ensuring flexibility for both automated and manual workflows.[1]

***

## 1. Initial Setup

- **User installs Connectome on Linux or macOS** using the provided installation instructions
and setup scripts.
- **User executes initial configuration** via a CLI tool or guided wizard:
    - Chooses/configures Neo4j connection (local instance, remote URL, credentials).
    - Specifies the root project directory that may contain multiple repositories,
    worktrees, and submodules.
    - Optionally chooses whether to enable background daemon launch at system login
    (service registration).

***

## 2. Daemon Configuration & Launch

- **User optionally enables daemon auto-start:**
    - On Linux: Registers `systemd` service.
    - On macOS: Registers `launchd` plist.
    - On both: Provides step-by-step instructions or an automated setup script.
- **Daemon launches** and reads the configuration, scanning the designated project directory for:
    - Git repositories.
    - Active worktrees and submodules.
    - Each recognized repo/worktree/submodule is treated as a distinct project.

***

## 3. Project Recognition & Initialization

**Upon first run or with the `init` command:**
- Daemon identifies all valid repos, worktrees, and submodules, filtering out non-code directories/files.
- For each repository:
    - Spawns the code grapher backend to parse the current codebase.
    - Creates or connects a dedicated Neo4j database (per project/repo) using project-specific naming.
    - Loads the full code graph for that repository/worktree/submodule into Neo4j.
- Records mapping between filesystem paths and Neo4j database names to support
multi-project queries and management.

***

## 4. Long-running Watcher Operations

- **Daemon remains active in the background**:
    - Monitors all registered repositories (optionally filtered—user can enable/disable watching per repo).
    - Upon any detected file change:
        - Validates if the file is relevant (e.g., code vs. non-code,
        respects user config for ignored files/patterns).
        - Triggers the backend analysis for that file or project incrementally.
        - Queues and applies appropriate graph updates to the relevant Neo4j project database.
- **User can issue explicit commands to**:
    - **Trigger a full re-index:** Re-parses and replaces the project’s Neo4j database
    (used after large refactors or config changes).
    - **Pause/Resume watching:** Temporarily or permanently stops/starts monitoring a project
    (e.g., to save resources or for excluded repos).
    - **Stop daemon:** Fully quits background operations.

***

## 5. Manual & Alternate Operation (Non-daemon Mode)

- For users who prefer **manual operation** or want finer-grained control:
    - CLI tools provided to:
        - Initialize and index projects without file watchers.
        - Manually trigger incremental updates (e.g., on demand, before pushing code, or from hooks).
    - **Git hooks integration:**
        - Option to install pre-commit or post-commit hooks.
        - On commit, only changed files are re-indexed, pushing updates to the Neo4j graph.
    - Useful for restricted environments, scripts, or CI/CD pipelines.

***

## 6. Repo/Worktree/Submodule Handling

- The daemon maintains an updated list of active projects, tracking:
    - New worktrees and submodules (auto-added if present and configured).
    - Removal or migration of projects (cleans up orphaned databases if desired).
    - Handling of nested or linked worktrees consistent with Git’s structure,
    ensuring isolation of code graphs per logical codebase.
- Non-code files are ignored by default, but user can extend/exclude specific patterns in their config.

***

## 7. API, Visualizer, and LSP Access

- All up-to-date graphs are accessible:
    - Through REST API endpoints (browsing, querying, admin).
    - In the visualization suite (web/desktop), loading different projects as needed.
    - From LSP-enabled IDEs for navigation and language-aware features.

***

## 8. Error Handling & Monitoring

- Users are notified of errors in:
    - Configuration (invalid repo, Neo4j connection issues).
    - Watcher failures (e.g., losing track of a project, permission errors).
    - Indexing runs (syntax errors, file access issues).
- Logging is robust, and a CLI/UI command allows users to inspect or tail system logs.

***

## 9. Continuous Documentation

- At every interaction (init, config, daemon commands), inline help and full
documentation are available via `--help` or associated UI/landing pages.
- All automated setup steps provide guidance for both Linux (`systemd`) and macOS (`launchd`).
Users can review and manually adjust settings as needed.

***

## Example UX Flow Sequence

1. **User installs and configures Connectome.**
2. **Runs `connectome init`** — all repos/worktrees/submodules are detected, indexed,
and loaded into Neo4j.
3. **Daemon runs in background** (auto or manually launched), watching for changes
and keeping code graphs updated.
4. **User codes; automatic or manual updates occur.**
5. **User queries or explores current codebase in UI/IDE/API.**
6. **If needed, user stops, restarts, or reconfigures watcher, project, or daemon.**

***

This UX design ensures both flexibility and automation, providing robust,
cross-platform developer experience and supporting both always-on and manual, scriptable workflows.
