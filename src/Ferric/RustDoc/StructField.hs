{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}

module Ferric.RustDoc.StructField where

import Data.Aeson

newtype StructField = StructField Value
  deriving stock (Read, Show)
  deriving newtype (FromJSON)
