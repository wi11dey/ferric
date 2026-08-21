module Ferric.RustDoc.Constant where

import Data.Aeson
import GHC.Generics

data Constant = Constant
  { type_ :: Value,
    const :: Value
  }
  deriving (Show, Generic)

instance FromJSON Constant where
  parseJSON =
    genericParseJSON
      defaultOptions
        { fieldLabelModifier = reverse . dropWhile (== '_') . reverse
        }
