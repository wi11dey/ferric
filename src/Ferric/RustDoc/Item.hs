module Ferric.RustDoc.Item where

import Data.Aeson
import Ferric.RustDoc.ItemEnum (ItemEnum)
import Ferric.RustDoc.Visibility (Visibility)
import GHC.Generics

data Item id = Item
  { id :: Int,
    name :: Maybe String,
    visibility :: Visibility id,
    docs :: Maybe String,
    inner :: ItemEnum id
  }
  deriving (Read, Show, Generic, FromJSON, Functor)
