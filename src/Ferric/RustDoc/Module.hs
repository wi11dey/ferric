module Ferric.RustDoc.Module where

import Data.Aeson
import GHC.Generics

data Module = Module
  { is_crate :: Bool,
    items :: [Int],
    is_stripped :: Bool
  }
  deriving (Show, Generic, FromJSON)
