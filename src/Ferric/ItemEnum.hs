module Ferric.ItemEnum where

import Data.Aeson
import GHC.Generics

data ItemEnum = Struct deriving (Show, Generic, FromJSON)
