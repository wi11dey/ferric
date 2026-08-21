module Ferric (crate) where

import Language.Haskell.TH
import Network.HTTP.Conduit
import qualified Codec.Compression.Zstd.Lazy as Zstd
import qualified Data.Aeson as Aeson

crate :: String -> String -> Q [Dec]
crate name version = do
  compressed <- runIO $ simpleHttp $ "https://docs.rs/crate/" ++ name ++ "/" ++ version ++ "/json"
  let decompressed = Aeson.decode @Aeson.Value $ Zstd.decompress compressed
  runIO $ putStrLn $ show decompressed
  return []
