module Ferric.RustDoc.ItemEnum where

import Data.Aeson
import Ferric.RustDoc.AssocConst (AssocConst)
import Ferric.RustDoc.AssocType (AssocType)
import Ferric.RustDoc.Constant (Constant)
import Ferric.RustDoc.Enum (Enum)
import Ferric.RustDoc.ExternCrate (ExternCrate)
import Ferric.RustDoc.Function (Function)
import Ferric.RustDoc.Impl (Impl)
import Ferric.RustDoc.Module (Module)
import Ferric.RustDoc.Struct (Struct)
import Ferric.RustDoc.StructField (StructField)
import Ferric.RustDoc.Trait (Trait)
import Ferric.RustDoc.TypeAlias (TypeAlias)
import Ferric.RustDoc.Use (Use)
import Ferric.RustDoc.Variant (Variant)
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
