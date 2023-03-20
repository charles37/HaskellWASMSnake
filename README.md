Snake game that runs in the browser using GHC's WebAssembly backend

```shell
nix run .#update
nix run .#build
python -m http.server --directory dist
```

 The snake game reads keyboard events (JavaScript), computes the GameState (Haskell), 
 and renders the GameState to the browser (JavaScript). 

using https://github.com/willmcpherson2/ghc-wasm-experiment as template


https://gitlab.haskell.org/ghc/ghc-wasm-meta

https://github.com/tweag/ormolu/tree/master/ormolu-live
