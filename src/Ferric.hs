module Ferric (crate, crate') where

import qualified Codec.Compression.Zstd.Lazy as Zstd
import Control.Applicative
import Control.Monad.Free
import Data.Aeson
import Data.ByteString.Lazy (ByteString)
import Data.Map.Strict ((!?))
import Data.Maybe
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
import Language.Haskell.TH
import Network.HTTP.Conduit

crate :: String -> String -> Q [Dec]
crate name version = do
  compressed <- runIO do
    let rustdocUrl = "https://docs.rs/crate/" ++ name ++ "/" ++ version ++ "/json"
    putStrLn $ "Downloading " ++ rustdocUrl ++ "..."
    simpleHttp rustdocUrl
  crate' $ Zstd.decompress compressed

crate' :: ByteString -> Q [Dec]
crate' rustdocJson = do
  Crate {..} <- throwDecode rustdocJson
  if format_version /= 60
    then reportWarning $ "The only rustdoc JSON version that is supported is 60; received " ++ show format_version ++ ". Attempting to continue generating bindings, but may be unsuccessful."
    else pure ()
  let
    lookupItem :: Int -> Either ItemSummary (Item Int)
    lookupItem itemId =
      fromJust $ (Right <$> index !? itemId) <|> (Left <$> paths !? itemId)
  topLevel $ unfold lookupItem root

topLevel :: Free Item ItemSummary -> Q [Dec]
topLevel (Free Item {inner = Use Item.Use {id = Just item}}) = topLevel item
topLevel (Free Item {name = Just name, inner = Module Item.Module {items}}) = concat <$> mapM topLevel items
topLevel (Free Item {name = Just name, inner = Enum Item.Enum {variants}}) = do
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
topLevel (Free Item {name = Just name, inner = Struct Item.Struct {kind}}) = do
  return [DataD [] (mkName name) [] Nothing [kindToCon name kind] [DerivClause Nothing [ConT ''Read, ConT ''Show, ConT ''Eq, ConT ''Ord]]]
topLevel _ = return []

kindToCon :: String -> Kind.Kind (Free Item ItemSummary) -> Con
kindToCon name Kind.Unit = NormalC (mkName name) []
kindToCon name Kind.Struct {fields} = RecC (mkName name) []
kindToCon name kind = NormalC (mkName name) []
