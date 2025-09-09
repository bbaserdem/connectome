# Connectome Project: System

The end goal of the Connectome Project is a robust, extensible, cross-platform system that continuously parses code, constructs and updates rich code graphs in Neo4j, exposes structured APIs for analysis and visualization, and integrates deeply with developer tooling. The architecture is modular, enabling maintainability and future expandability across both Linux and macOS environments.[1]

## Mermaid Diagram

```mermaid
flowchart TD
    FW[File Watcher (Rust)]
    DAEM[Code Update Daemon (Go)]
    PARSER[Parser & Analysis (Rust)]
    NEO[Neo4j Database]
    API[API Layer (Python)]
    MCP[MCP Server (Python)]
    VIS[Visualization Suite (TypeScript)]
    LSP[LSP Adapter (Rust)]
    
    FW -- JSON over IPC --> DAEM
    DAEM -- Event triggers --> PARSER
    PARSER -- JSON graph fragment --> DAEM
    DAEM -- Cypher updates --> NEO
    API -- DB driver --> NEO
    MCP -- REST/Direct --> API
    VIS -- REST API --> API
    LSP -- REST/IPC --> API
    DAEM -. (admin, status) .-> MCP

    classDef comp fill:#f9f,stroke:#333,stroke-width:2px;
    class FW,DAEM,PARSER,NEO,API,MCP,VIS,LSP comp;
```

## Overview

The system consists of these major components:

- **File Watcher (Rust):** Monitors directories for changes and notifies the system of file events.
- **Parser/Static Analysis Engine (Rust):** Consumes file event notifications, parses updated files (using tree-sitter and grammars) to produce a canonical graph representation.
- **Code Update Daemon (Go):** The orchestrator: coordinates file watchers, invokes parsing as needed, manages event batching, orders changes, and writes updates to the Neo4j code graph.
- **Neo4j Database:** Schema stores code entities, relationships, and supports queries via Cypher.
- **API Layer (Python, FastAPI):** Provides REST endpoints for data access, project automation, and orchestration.
- **MCP Server (Python):** Admin/orchestration layer (can be merged with API for simplicity).
- **Visualization Suite (TypeScript + React):** Interactive front-end for exploring, querying, and visualizing the code graph (web or desktop, cross-platform).
- **LSP Adapter (Rust):** Provides IDEs with real-time code graph information for navigation, auto-completion, and linting.
- **IPC/Communication:** All cross-language traffic uses JSON over Unix sockets or stdio pipes (no systemd/dbus/etc.), ensuring cross-compatibility.
- **Service Management:** Includes systemd units (Linux) and launchd plists (macOS) for process supervision. All components can also be run manually for local development.

***

## Component Interactions

### Flow Description

1. **File Watcher** detects file/directory changes and emits event messages
(serialized as JSON) to the **Code Update Daemon** using a Unix domain socket or stdio.
2. The **Daemon** batches and orders events, then triggers the **Parser** subprocess
to analyze the modified code.
3. The **Parser** outputs a canonical code graph fragment as JSON over IPC to the **Daemon**.
4. **Daemon** validates and merges graph changes, then writes updates into the
**Neo4j Database** using the official driver.
5. The **API Layer** delivers REST access to code graph data, project operations,
and status, talking directly to Neo4j using `neo4j` or `py2neo`.
6. The **MCP Server** offers admin automation over APIs (can be a superset/extension
of API Layer endpoints).
7. The **Visualization Suite** queries the API layer for graph data, rendering
interactive UIs for code structure exploration.
8. The **LSP Adapter** connects to the API (or the daemon, for real-time data),
supporting advanced IDE integration for navigation, completion, and cross-reference queries.
9. All IPC is performed using OS-agnostic sockets or pipes; each component
can be launched directly, allowing for both service (daemonized) and local/dev workflows.

***

## Component Details

### 1. **File Watcher (Rust)**
- Uses the `notify` crate for inotify (Linux), FSEvents (macOS).
- CLI-configurable; outputs structured JSON events for every file change.

### 2. **Parser/Static Analysis (Rust)**
- Modular; supports new languages by adding grammars.
- Produces graph nodes/edges in canonical schema per file/project.

### 3. **Code Update Daemon (Go)**
- Spawns file watchers and parser workers as subprocesses.
- Batches, orders, and validates code updates for integrity.
- Connects to Neo4j via driver for efficient updates.
- Supervises and logs all component activity.

### 4. **Neo4j Database**
- Multi-database (per project).
- Stores all code graph structure and metadata.

### 5. **API Layer (Python)**
- FastAPI server with secure and CORS-enabled endpoints.
- Provides data for visualization, scripting, and integration clients.

### 6. **MCP Server (Python)**
- Exposes admin operations and project automation APIs.

### 7. **Visualization Suite (TypeScript/React)**
- SPA or desktop (Tauri/Electron).
- Renders graphs, queries, relationships, and search.

### 8. **LSP Adapter (Rust)**
- Implements Language Server Protocol using `tower-lsp`.
- Integrates with VSCode and others for real-time, graph-based IDE UX.

### 9. **IPC/Communication**
- Always uses socket/pipes with JSON messages, never system-specific buses.
- Set up and teardown handled by daemon or CLI helper scripts.

***

## Key Cross-Platform Points

- All communication and orchestration is managed in a way that is identical on both Linux and macOS.
- No systemd/dbus dependency; all service management scripts are supplied for both OSes.
- File system watching, IPC, service management, and all APIs are platform-agnostic.

***

This design ensures the Connectome Project is flexible, modern, and ready for growth
while maximizing portability, maintainability, and ease of onboarding.
