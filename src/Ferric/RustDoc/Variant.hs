module Ferric.RustDoc.Variant where

import Data.Aeson
import Ferric.RustDoc.VariantKind (VariantKind)
import GHC.Generics

data Variant id = Variant
  { kind :: VariantKind id,
    discriminant :: Maybe Value
  }
  deriving (Read, Show, Generic, FromJSON, Functor)
