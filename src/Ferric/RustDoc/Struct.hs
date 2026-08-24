module Ferric.RustDoc.Struct where

import Data.Aeson
import Ferric.RustDoc.Generics (Generics)
import Ferric.RustDoc.Kind (Kind)
import GHC.Generics

data Struct id = Struct
  { kind :: Kind id,
    generics :: Generics,
    impls :: [id]
  }
  deriving (Read, Show, Generic, FromJSON, Functor)
