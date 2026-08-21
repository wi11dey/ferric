module Ferric.RustDoc.ItemSummary where

import Data.Aeson
import GHC.Generics

data ItemSummary = ItemSummary
  { crate_id :: Int,
    path :: [String]
  }
  deriving (Show, Generic, FromJSON)
