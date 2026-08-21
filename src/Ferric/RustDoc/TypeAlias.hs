module Ferric.RustDoc.TypeAlias where

import Data.Aeson
import GHC.Generics

data TypeAlias = TypeAlias
  { type_ :: Value,
    generics :: Value
  }
  deriving (Show, Generic)

instance FromJSON TypeAlias where
  parseJSON =
    genericParseJSON
      defaultOptions
        { fieldLabelModifier = reverse . dropWhile (== '_') . reverse
        }
