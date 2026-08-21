{-# LANGUAGE BlockArguments #-}
{-# LANGUAGE OverloadedStrings #-}

module Ferric.Visibility where

import Control.Monad
import Data.Aeson
import GHC.Generics

data Visibility
  = Public
  | Default
  | Crate
  | Restricted
      { parent :: Int,
        path :: String
      }
  deriving (Show, Generic)

instance FromJSON Visibility where
  parseJSON (String "public") = pure Public
  parseJSON (String "default") = pure Default
  parseJSON (String "crate") = pure Crate
  parseJSON value =
    flip (withObject "Visibility") value $
      (.: "restricted") >=> withObject "Restricted" \obj ->
        Restricted
          <$> obj .: "parent"
          <*> obj .: "path"
