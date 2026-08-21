module Ferric.Item where

import Data.Aeson
import Ferric.ItemEnum (ItemEnum)
import Ferric.Visibility (Visibility)
import GHC.Generics

data Item = Item
  { id :: Int
  , crate_id :: Int
  , name :: Maybe String
  , visibility :: Visibility
  , docs :: Maybe String
  , inner :: ItemEnum
  }
  deriving (Show, Generic, FromJSON)
