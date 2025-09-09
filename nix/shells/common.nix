# Common environment requirements for all shells
{
  pkgs,
  ...
}: {
  # Essential tools for all environments
  packages = with pkgs; [
    # Version control
    git
    
    # Basic utilities
    coreutils
    findutils
    gnugrep
    gnused
    
    # Enhanced CLI tools
    ripgrep   # Fast search
    fd        # Fast find
    bat       # Better cat
    eza       # Better ls
    htop      # Process viewer
    tree      # Directory tree
    
    # Data processing
    jq        # JSON processor
    
    # Network tools
    curl
    wget
    
    # Archive tools
    unzip
    zip
  ];
  
  # Common environment variables
  env = {};
  
  # Common shell initialization
  shellHook = "";
}