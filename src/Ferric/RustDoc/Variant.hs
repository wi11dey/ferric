module Ferric.RustDoc.Variant where

import Data.Aeson
import GHC.Generics

data Variant = Variant
  { kind :: Value,
    discriminant :: Maybe Value
  }
  deriving (Read, Show, Generic, FromJSON)
