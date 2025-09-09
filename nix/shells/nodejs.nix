# Node.js/TypeScript development shell
{
  pkgs,
  commonConfig,
  ...
}: {
  packages = commonConfig.packages ++ (with pkgs; [
    nodejs
    pnpm
    typescript
    nodePackages.typescript-language-server
  ]);
  
  env = commonConfig.env;
  
  shellHook = commonConfig.shellHook;
}