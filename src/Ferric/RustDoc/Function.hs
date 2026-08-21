module Ferric.RustDoc.Function where

import Data.Aeson
import GHC.Generics

data Function = Function
  { sig :: Value,
    generics :: Value,
    header :: Value,
    has_body :: Bool,
    default_unstable :: Maybe Value
  }
  deriving (Read, Show, Generic, FromJSON)
