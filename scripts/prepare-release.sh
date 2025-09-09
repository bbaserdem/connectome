#!/usr/bin/env bash
set -e

VERSION=$1

if [ -z "$VERSION" ]; then
    echo "Error: Version number required"
    exit 1
fi

echo "Preparing release v${VERSION} for Go, Python, and Rust components..."

# Update Go module version (if go.mod exists)
if [ -f "go.mod" ]; then
    echo "Updating Go module version..."
    # Go doesn't store version in go.mod, but we can add a version file
    echo "package main

const Version = \"${VERSION}\"" > src/version.go
    echo "✓ Go version file updated"
fi

# Update Python version in pyproject.toml
if [ -f "pyproject.toml" ]; then
    echo "Updating Python package version..."
    sed -i "s/^version = \".*\"/version = \"${VERSION}\"/" pyproject.toml
    echo "✓ Python version updated in pyproject.toml"
fi

# Update Rust version in Cargo.toml
if [ -f "Cargo.toml" ]; then
    echo "Updating Rust crate version..."
    sed -i "s/^version = \".*\"/version = \"${VERSION}\"/" Cargo.toml
    echo "✓ Rust version updated in Cargo.toml"
fi

# Update package.json version (for npm/semantic-release)
if [ -f "package.json" ]; then
    echo "Updating package.json version..."
    sed -i "s/\"version\": \".*\"/\"version\": \"${VERSION}\"/" package.json
    echo "✓ package.json version updated"
fi

echo "Release preparation complete for v${VERSION}"