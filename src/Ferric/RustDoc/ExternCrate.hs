module Ferric.RustDoc.ExternCrate where

import Data.Aeson
import GHC.Generics

data ExternCrate = ExternCrate
  { name :: String,
    rename :: Maybe String
  }
  deriving (Read, Show, Generic, FromJSON)
