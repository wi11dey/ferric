module Ferric.Crate where

import Data.IntMap.Strict (IntMap)
import Ferric.Item
import GHC.Generics

data Crate = Crate
  { root :: Int
  , crate_version :: Maybe String
  , includes_private :: Bool
  , index :: IntMap Item
  , format_version :: Int
  }
  deriving (Show, Generic)
