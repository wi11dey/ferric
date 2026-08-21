module Ferric.RustDoc.Crate where

import Data.Aeson
import Data.Map.Strict (Map)
import Ferric.RustDoc.Item
import GHC.Generics

data Crate = Crate
  { root :: Int,
    crate_version :: Maybe String,
    includes_private :: Bool,
    index :: Map Int Item,
    format_version :: Int
  }
  deriving (Show, Generic, FromJSON)
