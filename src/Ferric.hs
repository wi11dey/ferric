module Ferric (crate, crate', Fe, Owned, Borrowed, rust) where

import qualified Codec.Compression.Zstd.Lazy as Zstd
import Control.Applicative
import qualified Control.Functor.Linear as Linear
import Control.Monad.Free
import Data.Aeson
import Data.ByteString.Lazy (ByteString)
import Data.Coerce
import qualified Data.Functor.Linear
import Data.Map.Strict ((!?))
import Data.Maybe
import Data.Unrestricted.Linear
import Ferric.RustDoc.Crate
import qualified Ferric.RustDoc.Enum as Item
import Ferric.RustDoc.Item
import Ferric.RustDoc.ItemEnum
import Ferric.RustDoc.ItemSummary
import qualified Ferric.RustDoc.Kind as Kind
import qualified Ferric.RustDoc.Module as Item
import qualified Ferric.RustDoc.Struct as Item
import qualified Ferric.RustDoc.Use as Item
import qualified Ferric.RustDoc.Variant as Item
import qualified Ferric.RustDoc.Visibility as Visibility
import Foreign.Ptr
import Foreign.Storable
import Language.Haskell.TH
import Network.HTTP.Conduit
import System.IO.Resource.Linear

crate :: String -> String -> Q [Dec]
crate name version = do
  compressed <- runIO do
    let rustdocUrl = "https://docs.rs/crate/" ++ name ++ "/" ++ version ++ "/json"
    putStrLn $ "🦀 Downloading " ++ rustdocUrl ++ "..."
    simpleHttp rustdocUrl
  crate' $ Zstd.decompress compressed

crate' :: ByteString -> Q [Dec]
crate' rustdocJson = do
  Crate {..} <- throwDecode rustdocJson
  if format_version /= 60
    then
      reportWarning $
        "The only rustdoc JSON version that is supported is 60; received "
          ++ show format_version
          ++ ". Attempting to continue generating bindings, but may be unsuccessful."
    else pure ()
  let lookupItem :: Int -> Either ItemSummary (Item Int)
      lookupItem itemId =
        fromJust $ (Right <$> index !? itemId) <|> (Left <$> paths !? itemId)
  topLevel $ unfold lookupItem root

------------------------------------------------------------------------------------------------------------------------

defaultDerivClauses :: [DerivClause]
defaultDerivClauses = [DerivClause (Just StockStrategy) [ConT ''Read, ConT ''Show, ConT ''Eq, ConT ''Ord]]

topLevel :: Free Item ItemSummary -> Q [Dec]
topLevel (Free Item {inner = Use Item.Use {id = Just item}}) = topLevel item
topLevel (Free Item {inner = Module Item.Module {items}}) = concat <$> mapM topLevel items
topLevel (Free Item {name = Just name, visibility = Visibility.Public, inner = Enum Item.Enum {variants}}) = do
  return
    [ DataD
        []
        (mkName name)
        []
        Nothing
        [ kindToCon (name ++ conName) kind
        | Free Item {name = Just conName, inner = Variant Item.Variant {kind}} <- variants
        ]
        [DerivClause Nothing [ConT ''Show]]
    ]
topLevel (Free Item {name = Just name, visibility = _, inner = Enum Item.Enum {}}) = do
  return [DataD [] (mkName name) [] Nothing [] []]
topLevel (Free Item {name = Just name, inner = Struct Item.Struct {kind}}) = do
  return
    [ DataD
        []
        (mkName name)
        []
        Nothing
        [kindToCon name kind]
        defaultDerivClauses
    ]
topLevel _ = return []

kindToCon :: String -> Kind.Kind (Free Item ItemSummary) -> Con
kindToCon name Kind.Unit = NormalC (mkName name) []
kindToCon name Kind.Struct {fields} = RecC (mkName name) []
kindToCon name kind = NormalC (mkName name) []

------------------------------------------------------------------------------------------------------------------------

-- | Monad in which to do borrow-checked Rust logic
newtype Fe a = Fe {runFe :: RIO a}
  deriving newtype
    ( Data.Functor.Linear.Functor,
      Data.Functor.Linear.Applicative,
      Linear.Functor,
      Linear.Applicative,
      Linear.Monad
    )

newtype Owned a = Owned (Ptr a)

newtype Borrowed a = Borrowed (Ptr a)

unmarshal :: a %1 -> RIO (Ur a)
unmarshal = undefined

rust :: (Storable a) => Fe (Owned a) -> IO a
rust fe = do
  ptr <- run (runFe fe Linear.>>= unmarshal)
  peek $ coerce ptr
