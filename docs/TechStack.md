# Required Software Overview

Below is a summary of all core software required for the Connectome Project stack. These include databases, runtimes, external software, and significant language environments. This section provides a one-glance checklist for basic deployment, local development, and integration.

---

## Essential Software

- **Neo4j Database**
  - Community or Enterprise Edition with multi-database support
  - Can be run locally or pointed to a remote server

- **Go (Golang)**
  - Required for the main code update daemon

- **Rust**
  - Required for code parsing/analysis engine and all file watcher subprocesses

- **Python 3.9+**
  - Needed for the MCP server and API backends

- **Node.js + npm**
  - Required for building and running the TypeScript visualization suite

- **Web Browser**
  - Latest Chrome, Firefox, Safari, or Edge for using the web visualization app

---

## Major Libraries & Packages

- **Neo4j Drivers**
  - `neo4j-go-driver` (Go)
  - `neo4j` or `py2neo` (Python)
  - `neo4rs` (Rust) [optional/advanced]

- **Rust Crates**
  - `tree-sitter`, `tree-sitter-graph`, language grammars (Rust)
  - `notify`
  - `serde`, `serde_json`
  - `tower-lsp`, `tokio`

- **Go Libraries**
  - `os/exec`, `logrus`, `spf13/viper` (config), `grpc-go` (optional IPC)

- **Python Packages**
  - `fastapi`, `uvicorn`, `pydantic`, `neo4j`/`py2neo`, `loguru`, `fastapi-cors`, `fastapi-jwt-auth`

- **TypeScript / JS Packages**
  - `ts-graphviz`, `cytoscape.js`, `sigma.js`, `d3.js`, `zustand`, `redux`, `chakra-ui`, `mui`
  - `axios`, `vite`/`webpack`

- **Desktop App Packaging (Optional)**
  - `Tauri` (Rust backend)
  - `Electron` (Node.js + Chromium)

- **DevOps / Tooling**
  - Git
  - Docker (optional, for dev scripts/all-in-one setup)
  - Bash, PowerShell, or compatible shell for setup scripts

---

# Connectome Project Tech Stack

This stack leverages a modular, concurrent, and future-proof design to deliver scalable code analysis and code graph infrastructure. Neo4j is used as the canonical database for per-project code graphs, with the ability to easily switch between local or remote Neo4j instances via configuration.

---

## 1. Project Code Graph Database

**Description:**  
Stores the complete structured code graph for each project in an isolated Neo4j database. All queries, analysis, and visualization are powered by these databases.

**Language/Platform:**  
- External software: **Neo4j** (Community or Enterprise)

**Dependencies:**  
- Neo4j server (multi-database enabled; user provides connection info via config)
- Per-project: Separate Neo4j database
- Default configuration provided for convenient local setup; remote Neo4j URLs fully supported

---

## 2. Code Parsing & Static Analysis Engine

**Description:**  
Parses, analyzes, and extracts code structure and relationships on both full-project and incremental (file-level) bases. Produces canonical code graph changesets on demand.

**Language/Platform:**  
- **Rust**

**Dependencies:**  
- `tree-sitter`: Incremental parser engine  
- `tree-sitter-graph`: Pattern-based graph extractor  
- Language-specific grammars (e.g., `tree-sitter-rust`)
- `serde`, `serde_json` (for serialization)
- Communicates with the code update daemon (not directly with Neo4j)

---

## 3. File Watcher (Subprocess)

**Description:**  
Monitors target directories for file changes and reports granular change events to the code update daemon. Does not parse or analyze source; simply pushes events upward.

**Language/Platform:**  
- **Rust**

**Dependencies:**  
- `notify`: Cross-platform file/directory monitor
- `clap`, `structopt`: CLI / process config
- `serde`, `serde_json`: For event serialization to daemon

The need to keep a memory-resident, up-to-date copy of each code file for incremental parsing with Tree-sitter means **file watchers must strictly limit which files are indexed in-memory** to prevent excessive RAM usage, especially for large or non-source files.[1][2]

### Recommendations for File Size Limits

- **Impose a maximum file size threshold** for any file that watchers will admit
to the in-memory cache and allow to be parsed incrementally
(commonly 256KB–1MB per file is reasonable for source code).
- Exclude:
  - Very large files (over the configured threshold).
  - Non-source files or files with unrecognized extensions (e.g., images, blobs, generated data).
- If a file crosses the limit, it can be:
  - Ignored entirely.
  - Or only parsed on-demand with warnings, but not watched incrementally.
- Exclusion should be **configurable** via user options in the project configuration,
with clear logging of any skipped files.

### Implementation Notes

- File watcher processes should check file size during discovery and before caching a new version,
logging a warning if any file is skipped.
- The daemon should report in its status/admin endpoints the total memory in use for
file caches and the size/number of currently “live” watched files.
- Large files can be optionally indexed only with a lightweight stub
(e.g., filename, metadata) so their existence is still visible in the graph,
but their contents are not parsed.
---

## 4. Code Update Daemon

**Description:**  
Orchestrates the end-to-end update lifecycle.
Manages file watcher subprocesses, receives raw file event data,
batches events for order and efficiency, invokes parsing/analysis,
coordinates correct application of graph updates to Neo4j,
and centralizes logging, retries, and status reporting.
Ensures event ordering and batching for maximal data integrity and efficiency.
Has both systemd and launchd integration for cross-platform support.

**Language/Platform:**  
- **Go**

**Dependencies:**  
- `neo4j-go-driver`: Official Neo4j driver  
- `os/exec`, `os/signal`: Manage watcher processes  
- Go stdlib `goroutines`, `channels`: Internal queues, concurrency  
- IPC: Std pipes for file watcher communication; cross-platform (optionally, gRPC with `grpc-go` later)
- `logrus`: Structured logging  
- `spf13/viper`: Config handling (for Neo4j/local/remote, batching, etc.)
- Full support for environment or config-driven selection of Neo4j server (local or remote)

---

## 5. MCP Server (Meta Control Point)

**Description:**  
Provides orchestration, admin, and REST API surface for bulk project operations, automation, and metadata. Acts as a bridge between backend infrastructure and clients, including the visualization suite.

**Language/Platform:**  
- **Python**

**Dependencies:**  
- `FastAPI`: Async web API  
- `neo4j`, `py2neo`: Database APIs  
- `uvicorn`: ASGI server for deploy  
- `pydantic`: Schema and validation  
- `loguru`: Logging

---

## 6. Language Server (LSP) Adapter

**Description:**  
Implements the Language Server Protocol (LSP) to deliver real-time code navigation, completion, and diagnostics to IDEs via the code graph infrastructure.

**Language/Platform:**  
- **Rust**

**Dependencies:**  
- `tower-lsp`: LSP implementation  
- `serde`, `serde_json`: Protocol messages  
- `tokio`, `async-std`: Async IO  
- Communicates with the daemon for up-to-date graph data

---

## 7. API Endpoints for Tools & Visualization

**Description:**  
REST endpoints for all frontend tools, scripting/automation consumers, and analysis dashboards. These surface essential project/data queries and administrative actions.

**Language/Platform:**  
- **Python**

**Dependencies:**  
- `FastAPI`  
- `neo4j` or `py2neo`  
- `uvicorn`  
- `pydantic`  
- CORS, Auth extensions (`fastapi-cors`, `fastapi-jwt-auth` if needed)

---

## 8. Visualization Suite (Web & Desktop)

**Description:**  
Rich, interactive UI for exploring code graphs, queries, and metrics. Shipped as a web app, can be packaged for desktop with minimal changes.

**Language/Platform:**  
- **TypeScript** (React recommended, but agnostic)

**Dependencies:**  
- Visualization: `ts-graphviz`, `Cytoscape.js`, `Sigma.js`, `D3.js`, or `Vizdom`
- State/tooling: `zustand`, `redux`, `chakra-ui`, `mui`
- API client: `axios`
- Build: `Vite` or `Webpack`
- For desktop:  
    - `Tauri` (recommended for Rust-powered desktop builds)  
    - `Electron` (classic option)

---

## 9. Interprocess Communication

**Description:**  
Allows robust and language-agnostic comms between the Go daemon and watcher/analysis subprocesses. Supports reliable batching/ordering of file event and update data.

**Language/Platform:**  
- **Go, Rust**

**Dependencies:**  
- `os/exec` (Go) for subprocesses  
- Pipes/stdin-stdout with JSON protocol (simple, portable)  
- Optionally: Unix domain sockets or gRPC (`interprocess` in Rust, `grpc-go` in Go) for advanced comms

---

## 10. Project Documentation & Setup Tooling

**Description:**  
Essential docs and helpers for configuring, installing, and running the stack with both local and remote Neo4j support. Sample configs and scripts for devs and contributors.

**Language/Platform:**  
- Markdown  
- Bash, Powershell, or cross-platform shell scripts  
- (Optional) Docker for all-in-one dev setup

**Dependencies:**  
- Sample `config.yaml`/`.env` with Neo4j connection options (local and remote)  
- Neo4j run/start/seed scripts

---

## Notes

- **Neo4j config** (host, port, credentials) is always user-overridable; default is local, but remote servers are fully supported via standard config.
- **Daemon manages batching/order of graph updates** before they are written to Neo4j, ensuring data integrity and efficiency.
- **File watcher** processes send only file event data to the daemon; the daemon invokes parsing/analysis when appropriate.
- **Explicit daemon duties**: spawning/managing watchers, receiving events, batching, invoking analysis, coordinating and ordering updates, writing to Neo4j, logging, error handling, configuration.

---

# Cross-platform Support


| Component | Linux (default) | macOS Equivalent | Recommendation |
| --- | --- | --- | --- |
| Daemon Supervision | systemd | launchd | Provide both unit and plist files |
| IPC | pipes, sockets | pipes, sockets, local HTTP | Prefer Unix sockets/pipes over DBus |
| File Watching | inotify (notify) | FSEvents (notify) | Use notify/watchexec crate |
| Service Scripts | systemd/init.d | launchd plists | Include both, with instructions |


