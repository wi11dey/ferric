module Ferric.RustDoc.Enum where

import Data.Aeson
import GHC.Generics

data Enum = Enum
  { generics :: Value,
    has_stripped_variants :: Bool,
    variants :: [Int],
    impls :: [Int]
  }
  deriving (Show, Generic, FromJSON)
