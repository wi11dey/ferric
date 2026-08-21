{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}

module Ferric.StructField where

import Data.Aeson

newtype StructField = StructField Value
  deriving stock (Show)
  deriving newtype (FromJSON)
