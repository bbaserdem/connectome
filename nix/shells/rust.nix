# Rust development shell
{
  pkgs,
  commonConfig,
  ...
}: {
  packages = commonConfig.packages ++ (with pkgs; [
    rustc
    cargo
    rustfmt
    rust-analyzer
    clippy
  ]);
  
  env = commonConfig.env;
  
  shellHook = commonConfig.shellHook + ''
    # Set up local Cargo home
    export CARGO_HOME="$PWD/.cargo"
    export PATH="$CARGO_HOME/bin:$PATH"
  '';
}