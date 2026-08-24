module Ferric.RustDoc.Generics where

import Data.Aeson
import GHC.Generics

data Generics = Generics
  { params :: [Value],
    where_predicates :: [Value]
  }
  deriving (Read, Show, Generic, FromJSON)
