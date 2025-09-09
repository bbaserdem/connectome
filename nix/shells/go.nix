# Go development shell
{
  pkgs,
  commonConfig,
  ...
}: {
  packages = commonConfig.packages ++ (with pkgs; [
    go
    gopls
    gotools
    go-migrate
    delve
  ]);
  
  env = commonConfig.env // {
    CGO_ENABLED = "1";
  };
  
  shellHook = commonConfig.shellHook + ''
    # Set up local Go workspace
    export GOPATH="$PWD/.go"
    export GOCACHE="$PWD/.go/cache"
    export PATH="$GOPATH/bin:$PATH"
  '';
}