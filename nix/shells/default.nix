# Shell configurations
{
  pkgs,
  inputs,
  system,
  uvBoilerplate,
  ...
}: let
  # Common configuration used by all shells
  commonConfig = import ./common.nix { inherit pkgs; };
  
  # Helper to create shells
  mkShell = config:
    pkgs.mkShell {
      packages = config.packages;
      env = config.env;
      shellHook = config.shellHook;
    };

  # Individual shell configurations
  minimalShell = import ./minimal.nix { inherit pkgs; };
  pythonShell = import ./python.nix { inherit pkgs commonConfig uvBoilerplate; };
  goShell = import ./go.nix { inherit pkgs commonConfig; };
  rustShell = import ./rust.nix { inherit pkgs commonConfig; };
  nodejsShell = import ./nodejs.nix { inherit pkgs commonConfig; };
  
  # Default shell with all development tools
  defaultShell = {
    packages = pkgs.lib.unique (
      commonConfig.packages
      ++ (with pkgs; [
        # Python
        uv
        # Go  
        go
        gopls
        gotools
        go-migrate
        delve
        # Rust
        rustc
        cargo
        rustfmt
        rust-analyzer
        clippy
        # Node.js
        nodejs
        pnpm
        typescript
        nodePackages.typescript-language-server
      ])
      ++ uvBoilerplate.uvShellSet.packages
    );
    
    env = commonConfig.env // uvBoilerplate.uvShellSet.env // {
      CGO_ENABLED = "1";
    };
    
    shellHook = ''
      ${uvBoilerplate.uvShellSet.shellHook}
      
      # Go workspace
      export GOPATH="$PWD/.go"
      export GOCACHE="$PWD/.go/cache"
      export PATH="$GOPATH/bin:$PATH"
      
      # Cargo home
      export CARGO_HOME="$PWD/.cargo"
      export PATH="$CARGO_HOME/bin:$PATH"
      
      # Node modules (already in path from base)
      export PATH="$PWD/node_modules/.bin:$PATH"
    '';
  };

in {
  # Export all shell environments
  default = mkShell defaultShell;
  minimal = mkShell minimalShell;
  python = mkShell pythonShell;
  go = mkShell goShell;
  rust = mkShell rustShell;
  nodejs = mkShell nodejsShell;
}