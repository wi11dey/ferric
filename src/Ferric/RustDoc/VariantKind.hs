{-# LANGUAGE OverloadedStrings #-}

module Ferric.RustDoc.VariantKind where

import Control.Applicative
import Data.Aeson
import GHC.Generics

data VariantKind id = Plain | Tuple [Maybe id] | Struct {fields :: [id], has_stripped_fields :: Bool}
  deriving (Read, Show, Generic, Functor)

instance (FromJSON id) => FromJSON (VariantKind id) where
  parseJSON (String "plain") = pure Plain
  parseJSON value =
    flip (withObject "VariantKind") value $ \obj ->
      (Tuple <$> obj .: "tuple")
        <|> do
          obj .: "struct" >>= withObject "Struct" \struct ->
            Struct
              <$> struct .: "fields"
              <*> struct .: "has_stripped_fields"
