{-# LANGUAGE NoRebindableSyntax #-}
{-# OPTIONS_GHC -fno-warn-missing-import-lists #-}
{-# OPTIONS_GHC -w #-}
module PackageInfo_HaskellWASMSnake (
    name,
    version,
    synopsis,
    copyright,
    homepage,
  ) where

import Data.Version (Version(..))
import Prelude

name :: String
name = "HaskellWASMSnake"
version :: Version
version = Version [0,1,0,0] []

synopsis :: String
synopsis = "Snake game that runs in the browser using GHC's WebAssembly backend"
copyright :: String
copyright = ""
homepage :: String
homepage = ""
