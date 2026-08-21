module Ferric (crate, crate') where

import qualified Codec.Compression.Zstd.Lazy as Zstd
import Data.Aeson
import Data.ByteString.Lazy (ByteString)
import Data.Map.Strict (Map, (!))
import Ferric.RustDoc.Crate
import Ferric.RustDoc.Item
import qualified Ferric.RustDoc.ItemEnum as ItemEnum
import Ferric.RustDoc.ItemSummary
import Ferric.RustDoc.Module
import Language.Haskell.TH
import Network.HTTP.Conduit

crate :: String -> String -> Q [Dec]
crate name version = do
  compressed <- runIO $ simpleHttp $ "https://docs.rs/crate/" ++ name ++ "/" ++ version ++ "/json"
  crate' $ Zstd.decompress compressed

crate' :: ByteString -> Q [Dec]
crate' rustdocJson = do
  Crate {..} <- throwDecode @Crate rustdocJson
  runIO $ putStrLn $ show $ emit paths index root
  return []

emit :: Map Int ItemSummary -> Map Int Item -> Int -> [String]
emit paths index root =
  case inner $ index ! root of
    ItemEnum.Module (Module {..}) -> concatMap (emit paths index) items -- TODO: make new module
    _ -> []
