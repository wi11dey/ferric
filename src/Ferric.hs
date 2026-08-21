module Ferric (crate, crate') where

import qualified Codec.Compression.Zstd.Lazy as Zstd
import Data.Aeson
import Data.ByteString.Lazy (ByteString)
import Data.Map.Strict (Map, (!))
import qualified Data.Text.Lazy as Text
import Ferric.RustDoc.Crate
import Ferric.RustDoc.Item
import qualified Ferric.RustDoc.ItemEnum as ItemEnum
import Ferric.RustDoc.Module
import Language.Haskell.TH
import Network.HTTP.Conduit
import Text.Pretty.Simple

crate :: String -> String -> Q [Dec]
crate name version = do
  compressed <- runIO $ simpleHttp $ "https://docs.rs/crate/" ++ name ++ "/" ++ version ++ "/json"
  crate' $ Zstd.decompress compressed

crate' :: ByteString -> Q [Dec]
crate' rustdocJson = do
  Crate {..} <- throwDecode @Crate rustdocJson
  runIO $ do
    mapM_ putStrLn $ emit index root
  return []

emit :: Map Int Item -> Int -> [String]
emit index root =
  let Item {name, inner} = index ! root
   in case inner of
        ItemEnum.Module Module {..} -> concatMap (emit index) items -- TODO: make new module
        ItemEnum.Enum enum -> ["Enum " ++ show name]
        ItemEnum.Struct struct -> ["Struct " ++ show name]
        ItemEnum.Impl impl -> ["Impl " ++ show name]
        ItemEnum.Function f -> ["Function " ++ show name]
        _ -> []
