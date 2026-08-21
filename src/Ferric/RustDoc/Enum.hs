module Ferric.RustDoc.Enum where

import Data.Aeson
import GHC.Generics

data Enum id = Enum
  { generics :: Value,
    variants :: [id],
    impls :: [id]
  }
  deriving (Read, Show, Generic, FromJSON, Functor)
