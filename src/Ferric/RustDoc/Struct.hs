module Ferric.RustDoc.Struct where

import Data.Aeson
import Ferric.RustDoc.Kind (Kind)
import GHC.Generics

data Struct id = Struct
  { kind :: Kind id,
    generics :: Value,
    impls :: [id]
  }
  deriving (Read, Show, Generic, FromJSON, Functor)
