module Ferric.RustDoc.Variant where

import Data.Aeson
import Ferric.RustDoc.Kind (Kind)
import GHC.Generics

data Variant id = Variant
  { kind :: Kind id,
    discriminant :: Maybe Value
  }
  deriving (Read, Show, Generic, FromJSON, Functor)
