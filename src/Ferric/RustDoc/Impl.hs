module Ferric.RustDoc.Impl where

import Data.Aeson
import GHC.Generics

data Impl id = Impl
  { is_unsafe :: Bool,
    generics :: Value,
    provided_trait_methods :: [String],
    trait :: Maybe Value,
    for_ :: Value,
    items :: [id],
    is_negative :: Bool,
    is_synthetic :: Bool,
    blanket_impl :: Maybe Value
  }
  deriving (Read, Show, Generic, Functor)

instance (FromJSON id) => FromJSON (Impl id) where
  parseJSON =
    genericParseJSON
      defaultOptions
        { fieldLabelModifier = reverse . dropWhile (== '_') . reverse
        }
