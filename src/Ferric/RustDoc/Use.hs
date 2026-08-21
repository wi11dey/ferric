module Ferric.RustDoc.Use where

import Data.Aeson
import GHC.Generics

data Use = Use
  { source :: String,
    name :: String,
    id :: Int,
    is_glob :: Bool
  }
  deriving (Show, Generic, FromJSON)
