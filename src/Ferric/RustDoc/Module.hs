module Ferric.RustDoc.Module where

import Data.Aeson
import GHC.Generics

data Module id = Module
  { is_crate :: Bool,
    items :: [id],
    is_stripped :: Bool
  }
  deriving (Show, Generic, FromJSON)
