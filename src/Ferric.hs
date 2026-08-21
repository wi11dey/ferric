module Ferric (crate, crate') where

import Data.Aeson
import Data.ByteString.Lazy (ByteString)
import Data.Map.Strict (Map)
import Data.Maybe
import Ferric.RustDoc.Crate
import Ferric.RustDoc.Item
import Language.Haskell.TH
import Network.HTTP.Conduit
import qualified Codec.Compression.Zstd.Lazy as Zstd
import qualified Data.Map.Strict as Map

crate :: String -> String -> Q [Dec]
crate name version = do
  compressed <- runIO $ simpleHttp $ "https://docs.rs/crate/" ++ name ++ "/" ++ version ++ "/json"
  crate' $ Zstd.decompress compressed

crate' :: ByteString -> Q [Dec]
crate' rustdocJson = do
  Crate {..} <- throwDecode @Crate rustdocJson
  runIO $ putStrLn $ show $ emit index root
  return []

emit :: Map Int Item -> Int -> [String]
emit root index =
  case inner $ fromJust $ Map.lookup index root of
    _ -> []
