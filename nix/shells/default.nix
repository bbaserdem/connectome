# Modular shell configurations with composition
{
  pkgs,
  inputs,
  system,
  uvBoilerplate,
  ...
}: let
  # Create base configuration that all shells can compose upon
  baseConfig = import ./base-config.nix {
    inherit pkgs uvBoilerplate;
  };

  # Shell aliases and scripts
  mkScript = name: text: let
    script = pkgs.writeShellScriptBin name text;
  in
    script;
  scripts = [
    #(mkScript "<Alias>" "<cmd> \"$@\"")
  ];

  # Helper function to create a shell from a configuration
  mkShell = config:
    pkgs.mkShell {
      packages = config.packages ++ scripts;
      env = config.env;
      shellHook = config.shellHook;
    };

  # Import individual shell configurations
  minimalConfig = import ./minimal.nix {inherit pkgs baseConfig;};
  pythonOnlyConfig = import ./python-only.nix {inherit pkgs baseConfig;};
  developmentConfig = {
    packages = pkgs.lib.unique (
      baseConfig.packages
      ++ baseConfig.python.packages
    );
    env =
      baseConfig.env
      // baseConfig.python.env;
    shellHook =
      baseConfig.shellHook
      + "\n"
      + baseConfig.python.shellHook;
  };
in {
  # Export all shell environments (only derivations for flake compatibility)
  default = mkShell developmentConfig; # Default is development (base + python)
  minimal = mkShell minimalConfig; # Just base tools
  python = mkShell pythonOnlyConfig; # Python environment only
}
