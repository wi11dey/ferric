module Ferric.ItemEnum where

import Data.Aeson
import Ferric.AssocConst (AssocConst)
import Ferric.AssocType (AssocType)
import Ferric.Constant (Constant)
import Ferric.Enum (Enum)
import Ferric.ExternCrate (ExternCrate)
import Ferric.Function (Function)
import Ferric.Impl (Impl)
import Ferric.Module (Module)
import Ferric.Struct (Struct)
import Ferric.StructField (StructField)
import Ferric.Trait (Trait)
import Ferric.TypeAlias (TypeAlias)
import Ferric.Use (Use)
import Ferric.Variant (Variant)
import GHC.Generics
import Prelude hiding (Enum)

data ItemEnum
  = AssocConst AssocConst
  | AssocType AssocType
  | Constant Constant
  | Enum Enum
  | ExternCrate ExternCrate
  | Function Function
  | Impl Impl
  | Macro String
  | Module Module
  | Struct Struct
  | StructField StructField
  | Trait Trait
  | TypeAlias TypeAlias
  | Use Use
  | Variant Variant
  deriving (Show, Generic)

instance FromJSON ItemEnum where
  parseJSON =
    genericParseJSON
      defaultOptions
        { constructorTagModifier = camelTo2 '_',
          sumEncoding = ObjectWithSingleField
        }
