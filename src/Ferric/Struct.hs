module Ferric.Struct where

import Data.Aeson
import GHC.Generics

data Struct = Struct
  { kind :: Value,
    generics :: Value,
    impls :: [Int]
  }
  deriving (Show, Generic, FromJSON)
