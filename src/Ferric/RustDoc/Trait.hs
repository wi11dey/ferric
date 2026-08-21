module Ferric.RustDoc.Trait where

import Data.Aeson
import GHC.Generics

data Trait = Trait
  { is_auto :: Bool,
    is_unsafe :: Bool,
    is_dyn_compatible :: Bool,
    items :: [Int],
    implementations :: [Int]
  }
  deriving (Show, Generic, FromJSON)
