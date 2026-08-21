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

data ItemEnum id
  = AssocConst AssocConst
  | AssocType AssocType
  | Constant Constant
  | Enum (Enum id)
  | ExternCrate ExternCrate
  | Function Function
  | Impl (Impl id)
  | Macro String
  | Module (Module id)
  | Struct (Struct id)
  | StructField StructField
  | Trait (Trait id)
  | TypeAlias TypeAlias
  | Use (Use id)
  | Variant (Variant id)
  deriving (Read, Show, Generic, Functor)

instance (FromJSON id) => FromJSON (ItemEnum id) where
  parseJSON =
    genericParseJSON
      defaultOptions
        { constructorTagModifier = camelTo2 '_',
          sumEncoding = ObjectWithSingleField
        }
