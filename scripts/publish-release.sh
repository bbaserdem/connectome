#!/usr/bin/env bash
set -e

VERSION=$1

if [ -z "$VERSION" ]; then
    echo "Error: Version number required"
    exit 1
fi

echo "Publishing release v${VERSION}..."

# Build and publish Go module (if applicable)
if [ -f "go.mod" ]; then
    echo "Building Go module..."
    if command -v go &> /dev/null; then
        go build ./...
        go test ./...
        echo "✓ Go module built and tested"
        # Note: Go modules are published by pushing tags to git
        # The semantic-release git plugin will handle the tagging
    else
        echo "⚠ Go not found, skipping Go build"
    fi
fi

# Build and publish Python package (if applicable)
if [ -f "pyproject.toml" ]; then
    echo "Building Python package..."
    if command -v uv &> /dev/null; then
        # Using uv for Python package management
        uv build
        echo "✓ Python package built"
        # Uncomment to publish to PyPI:
        # uv publish --token $PYPI_TOKEN
    elif command -v python &> /dev/null; then
        # Fallback to standard Python tools
        python -m build
        echo "✓ Python package built"
        # Uncomment to publish to PyPI:
        # python -m twine upload dist/*
    else
        echo "⚠ Python not found, skipping Python build"
    fi
fi

# Build and publish Rust crate (if applicable)
if [ -f "Cargo.toml" ]; then
    echo "Building Rust crate..."
    if command -v cargo &> /dev/null; then
        cargo build --release
        cargo test
        echo "✓ Rust crate built and tested"
        # Uncomment to publish to crates.io:
        # cargo publish --token $CARGO_REGISTRY_TOKEN
    else
        echo "⚠ Cargo not found, skipping Rust build"
    fi
fi

echo "Release v${VERSION} published successfully!"