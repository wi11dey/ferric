module Ferric (crate) where

import Data.ByteString.Lazy (ByteString)
import Ferric.Crate
import Language.Haskell.TH
import Network.HTTP.Conduit
import qualified Codec.Compression.Zstd.Lazy as Zstd
import Data.Aeson

crate :: String -> String -> Q [Dec]
crate name version = do
  compressed <- runIO $ simpleHttp $ "https://docs.rs/crate/" ++ name ++ "/" ++ version ++ "/json"
  crate' $ Zstd.decompress compressed

crate' :: ByteString -> Q [Dec]
crate' rustdocJson = do
  decoded <- throwDecode @Crate rustdocJson
  runIO $ putStrLn $ show decoded
  return []
