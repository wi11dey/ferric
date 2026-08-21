{-# LANGUAGE BlockArguments #-}
{-# LANGUAGE OverloadedStrings #-}

module Ferric.RustDoc.Visibility where

import Control.Monad
import Data.Aeson
import GHC.Generics

data Visibility id
  = Public
  | Default
  | Crate
  | Restricted
      { parent :: id,
        path :: String
      }
  deriving (Read, Show, Generic, Functor)

instance (FromJSON id) => FromJSON (Visibility id) where
  parseJSON (String "public") = pure Public
  parseJSON (String "default") = pure Default
  parseJSON (String "crate") = pure Crate
  parseJSON value =
    flip (withObject "Visibility") value $
      (.: "restricted") >=> withObject "Restricted" \obj ->
        Restricted
          <$> obj .: "parent"
          <*> obj .: "path"
