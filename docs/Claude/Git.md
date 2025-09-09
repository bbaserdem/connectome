# Commit Conventions

This project uses [Conventional Commits](https://www.conventionalcommits.org/) with semantic-release for automated versioning across Go, Python, and Rust components.

## Commit Message Format

```
<type>(<scope>): <subject>

[optional body]

[optional footer(s)]
```

## Types

- **feat**: A new feature (triggers MINOR version bump)
- **fix**: A bug fix (triggers PATCH version bump)
- **docs**: Documentation only changes
- **style**: Code style changes (formatting, semicolons, etc)
- **refactor**: Code change that neither fixes a bug nor adds a feature
- **perf**: Performance improvements
- **test**: Adding or updating tests
- **build**: Changes to build system or dependencies
- **ci**: Changes to CI configuration files
- **chore**: Other changes that don't modify src or test files
- **revert**: Reverts a previous commit

## Scopes (optional)

- **go**: Go-specific changes
- **python**: Python-specific changes
- **rust**: Rust-specific changes
- **api**: API-related changes
- **parser**: Parser engine changes
- **watcher**: File watcher changes
- **daemon**: Daemon service changes
- **neo4j**: Graph database changes

## Breaking Changes

Add `BREAKING CHANGE:` in the footer or `!` after the type/scope:

```
feat(api)!: change API response format

BREAKING CHANGE: API responses now use camelCase instead of snake_case
```

This triggers a MAJOR version bump.

## Examples

### Feature
```
feat(python): add incremental parsing support

Implement tree-sitter based incremental parsing for Python files
to improve performance on large codebases.
```

### Bug Fix
```
fix(watcher): handle file permission errors gracefully

Previously the watcher would crash when encountering files without
read permissions. Now it logs a warning and continues.
```

### Multi-language Change
```
feat: add support for async operations

- Go: Added goroutine-based async processing
- Python: Implemented asyncio support
- Rust: Added tokio async runtime
```

### Performance
```
perf(parser): optimize AST traversal for large files

Reduced memory usage by 40% when parsing files over 10MB
```

## Version Bumping Rules

- **PATCH** (0.0.X): `fix`, `perf`, `revert` (backwards compatible bug fixes)
- **MINOR** (0.X.0): `feat` (backwards compatible new features)
- **MAJOR** (X.0.0): Breaking changes (any commit with `BREAKING CHANGE:` or `!`)

## Automation

When you push to the `main` branch with properly formatted commits:

1. semantic-release analyzes commit messages
2. Determines the version bump type
3. Updates version in:
   - `pyproject.toml` (Python)
   - `Cargo.toml` (Rust)
   - `go.mod` (Go modules use git tags)
   - `package.json` (Node.js/npm)
4. Generates CHANGELOG.md
5. Creates a GitHub release
6. Tags the commit with the new version

## Local Testing

Test your commit message:
```bash
echo "feat(rust): add new parser" | npx commitlint
```

Dry run semantic-release:
```bash
npx semantic-release --dry-run
```