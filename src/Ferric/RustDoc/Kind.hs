{-# LANGUAGE OverloadedStrings #-}

module Ferric.RustDoc.Kind where

import Control.Applicative
import Data.Aeson
import GHC.Generics

data Kind id = Unit | Tuple [Maybe id] | Struct {fields :: [id], has_stripped_fields :: Bool}
  deriving (Read, Show, Generic, Functor)

instance (FromJSON id) => FromJSON (Kind id) where
  parseJSON (String "unit") = pure Unit
  parseJSON (String "plain") = pure Unit
  parseJSON value =
    flip (withObject "Kind") value $ \obj ->
      (Tuple <$> obj .: "tuple")
        <|> do
          (obj .: "struct" <|> obj .: "plain") >>= withObject "Struct" \struct ->
            Struct
              <$> struct .: "fields"
              <*> struct .: "has_stripped_fields"
