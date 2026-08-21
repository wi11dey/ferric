module Ferric.RustDoc.Enum where

import Data.Aeson
import GHC.Generics

data Enum id = Enum
  { generics :: Value,
    has_stripped_variants :: Bool,
    variants :: [id],
    impls :: [id]
  }
  deriving (Show, Generic, FromJSON)
