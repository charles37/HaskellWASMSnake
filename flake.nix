{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    ghc-wasm-meta.url = "gitlab:ghc/ghc-wasm-meta/1b4a14b3?host=gitlab.haskell.org";
  };
  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ghc-wasm-meta,
  }:
    flake-utils.lib.eachDefaultSystem
    (
      system: let
        inherit ((import nixpkgs {inherit system;})) pkgs;
      in {
        packages = flake-utils.lib.flattenTree {
          update = pkgs.writeShellApplication {
            name = "update";
            runtimeInputs = [
              ghc-wasm-meta.packages.${system}.default
            ];
            text = ''
              wasm32-wasi-cabal update
            '';
          };
          build = pkgs.writeShellApplication {
            name = "build";
            runtimeInputs = [
              pkgs.nodejs
              ghc-wasm-meta.packages.${system}.default
            ];
            text = ''
              npm install
              npm run build
              wasm32-wasi-cabal build
              HaskellWASMSnake=$(wasm32-wasi-cabal list-bin exe:HaskellWASMSnake)
              cp "$HaskellWASMSnake" dist
            '';
          };
        };
      }
    );
}
