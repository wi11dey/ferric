module Ferric.RustDoc.Enum where

import Data.Aeson
import Ferric.RustDoc.Generics (Generics)
import GHC.Generics

data Enum id = Enum
  { generics :: Generics,
    variants :: [id],
    impls :: [id]
  }
  deriving (Read, Show, Generic, FromJSON, Functor)
