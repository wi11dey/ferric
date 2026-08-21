module Ferric.RustDoc.Enum where

import Data.Aeson
import GHC.Generics

data Enum id = Enum
  { generics :: Value,
    has_stripped_variants :: Bool,
    variants :: [id],
    impls :: [id]
  }
  deriving (Read, Show, Generic, FromJSON, Functor)
