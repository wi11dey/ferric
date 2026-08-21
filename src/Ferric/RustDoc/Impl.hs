module Ferric.RustDoc.Impl where

import Data.Aeson
import GHC.Generics

data Impl = Impl
  { is_unsafe :: Bool,
    generics :: Value,
    provided_trait_methods :: [String],
    trait :: Maybe Value,
    for_ :: Value,
    items :: [Int],
    is_negative :: Bool,
    is_synthetic :: Bool,
    blanket_impl :: Maybe Value
  }
  deriving (Show, Generic)

instance FromJSON Impl where
  parseJSON =
    genericParseJSON
      defaultOptions
        { fieldLabelModifier = reverse . dropWhile (== '_') . reverse
        }
