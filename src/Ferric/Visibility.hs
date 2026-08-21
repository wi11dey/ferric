module Ferric.Visibility where

import GHC.Generics

data Visibility = Public
                | Default
                | Crate
                | Restricted
                  { parent :: Int
                  , path:: String
                  }
  deriving (Show, Generic)
