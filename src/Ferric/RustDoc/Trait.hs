module Ferric.RustDoc.Trait where

import Data.Aeson
import GHC.Generics

data Trait id = Trait
  { is_auto :: Bool,
    is_unsafe :: Bool,
    is_dyn_compatible :: Bool,
    items :: [id],
    implementations :: [id]
  }
  deriving (Read, Show, Generic, FromJSON, Functor)
