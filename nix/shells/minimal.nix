# Minimal runtime shell - only environment requirements, no dev tools
{
  pkgs,
  ...
}: {
  packages = with pkgs; [
    # Runtime requirements only
    git
    coreutils
    findutils
    gnugrep
    gnused
  ];
  env = {};
  shellHook = "";
}
