module Ferric.AssocConst where

import Data.Aeson
import GHC.Generics

data AssocConst = AssocConst
  { type_ :: Value,
    value :: Maybe String,
    default_unstable :: Maybe Value
  }
  deriving (Show, Generic)

instance FromJSON AssocConst where
  parseJSON =
    genericParseJSON
      defaultOptions
        { fieldLabelModifier = reverse . dropWhile (== '_') . reverse
        }
