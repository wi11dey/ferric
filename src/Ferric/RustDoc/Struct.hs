module Ferric.RustDoc.Struct where

import Data.Aeson
import GHC.Generics

data Struct id = Struct
  { kind :: Value,
    generics :: Value,
    impls :: [id]
  }
  deriving (Read, Show, Generic, FromJSON, Functor)
