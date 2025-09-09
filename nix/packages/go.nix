# Go package definitions using buildGoModule
{
  pkgs,
  lib,
  ...
}: rec {
  # Main Connectome Go binary
  connectome-go = pkgs.buildGoModule {
    pname = "connectome-go";
    version = "0.1.0";
    
    src = ../..;
    
    # Set to null initially, will vendor dependencies locally
    vendorHash = null;
    
    # Only build Go files in the go/ directory if it exists
    modRoot = "./go";
    
    # Skip building if no go.mod exists
    preBuild = ''
      if [ ! -f go.mod ]; then
        echo "No go.mod found, skipping Go build"
        exit 0
      fi
    '';
    
    # Build flags
    ldflags = [
      "-s" "-w"
      "-X main.Version=${version}"
    ];
    
    # Skip tests during build
    doCheck = false;
    
    meta = with lib; {
      description = "Connectome Go components";
      license = licenses.gpl3;
    };
  };
}