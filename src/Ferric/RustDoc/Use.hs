module Ferric.RustDoc.Use where

import Data.Aeson
import GHC.Generics

data Use id = Use
  { source :: String,
    name :: String,
    id :: Maybe id,
    is_glob :: Bool
  }
  deriving (Read, Show, Generic, FromJSON, Functor)
