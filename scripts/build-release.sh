#!/usr/bin/env bash
set -e

VERSION=$1

if [ -z "$VERSION" ]; then
    echo "Error: Version number required"
    exit 1
fi

echo "Building release v${VERSION} binaries..."

# Build Go binaries
if [ -f "go.mod" ]; then
    echo "Building Go binaries..."
    if command -v go &> /dev/null; then
        go build ./...
        go test ./...
        echo "✓ Go binaries built and tested"
    else
        echo "⚠ Go not found, skipping Go build"
    fi
fi

# Build Python package (local wheel/dist only)
if [ -f "pyproject.toml" ]; then
    echo "Building Python distribution..."
    if command -v uv &> /dev/null; then
        # Using uv for Python package management
        uv build
        echo "✓ Python distribution built in dist/"
    elif command -v python &> /dev/null; then
        # Fallback to standard Python tools
        python -m build
        echo "✓ Python distribution built in dist/"
    else
        echo "⚠ Python not found, skipping Python build"
    fi
fi

# Build Rust binaries
if [ -f "Cargo.toml" ]; then
    echo "Building Rust binaries..."
    if command -v cargo &> /dev/null; then
        cargo build --release
        cargo test
        echo "✓ Rust binaries built in target/release/"
    else
        echo "⚠ Cargo not found, skipping Rust build"
    fi
fi

echo "Build complete for v${VERSION}"
echo "Binaries are available in:"
echo "  - Go: Built in project root"
echo "  - Python: dist/ directory"
echo "  - Rust: target/release/ directory"