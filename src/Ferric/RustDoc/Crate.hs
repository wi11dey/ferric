module Ferric.RustDoc.Crate where

import Data.Aeson
import Data.Map.Strict (Map)
import Ferric.RustDoc.Item (Item)
import Ferric.RustDoc.ItemSummary (ItemSummary)
import GHC.Generics

data Crate = Crate
  { root :: Int,
    crate_version :: Maybe String,
    includes_private :: Bool,
    index :: Map Int (Item Int),
    paths :: Map Int ItemSummary,
    format_version :: Int
  }
  deriving (Show, Generic, FromJSON)
