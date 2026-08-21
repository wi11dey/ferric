module Ferric.RustDoc.AssocType where

import Data.Aeson
import GHC.Generics

data AssocType = AssocType
  { generics :: Value,
    bounds :: [Value],
    type_ :: Maybe Value,
    default_unstable :: Maybe Value
  }
  deriving (Show, Generic)

instance FromJSON AssocType where
  parseJSON =
    genericParseJSON
      defaultOptions
        { fieldLabelModifier = reverse . dropWhile (== '_') . reverse
        }
