-- Copyright (c) 2026, Will Dey

module Ferric (crate, crate', Fe, Owned, Borrowed, rust) where

import qualified Codec.Compression.Zstd.Lazy as Zstd
import Control.Comonad.Cofree
import qualified Control.Functor.Linear as Linear
import Control.Monad
import Data.Aeson
import Data.ByteString.Lazy (ByteString)
import Data.Char
import Data.Coerce
import Data.Functor.Compose
import qualified Data.Functor.Linear
import Data.List hiding ((!?))
import Data.Map.Strict ((!), (!?))
import Data.String.Interpolate
import Data.String.Interpolate.Util (unindent)
import Data.Unrestricted.Linear
import Ferric.RustDoc.Crate
import qualified Ferric.RustDoc.Enum as Item
import Ferric.RustDoc.Item
import Ferric.RustDoc.ItemEnum as Rust
import Ferric.RustDoc.ItemSummary
import Ferric.RustDoc.Kind (Kind)
import qualified Ferric.RustDoc.Kind as Kind
import qualified Ferric.RustDoc.Module as Item
import qualified Ferric.RustDoc.Struct as Item
import qualified Ferric.RustDoc.Use as Item
import qualified Ferric.RustDoc.Variant as Item
import qualified Ferric.RustDoc.Visibility as Visibility
import Foreign.Ptr
import Foreign.Storable
import Language.Haskell.TH.Lib
import Language.Haskell.TH.Syntax as Haskell hiding (Kind)
import Network.HTTP.Conduit
import System.Directory
import System.Environment
import System.Exit
import System.FilePath
import System.IO.Resource.Linear
import System.Process

crate :: String -> String -> Q [Dec]
crate name version = do
  compressed <- runIO do
    let rustdocUrl = "https://docs.rs/crate" </> name </> version </> "json"
    putStrLn $ "🦀 Downloading " ++ rustdocUrl ++ "..."
    simpleHttp rustdocUrl
  crate' $ Zstd.decompress compressed

crate' :: ByteString -> Q [Dec]
crate' rustdocJson = do
  Crate {..} <- throwDecode rustdocJson
  when (format_version /= 60) $
    reportWarning $
      "The only rustdoc JSON version that is supported is 60; received "
        ++ show format_version
        ++ ". Attempting to continue generating bindings, but may be unsuccessful."

  addModFinalizer do
    fileFinalizer
    cargoFinalizer [] []

  let lookupItem :: Int -> (ItemSummary, (Compose Maybe Item) Int)
      lookupItem itemId = (paths ! itemId, Compose $ index !? itemId)
  topLevel $ unfold lookupItem root

------------------------------------------------------------------------------------------------------------------------

defaultDerivClauses :: [DerivClause]
defaultDerivClauses = [DerivClause (Just StockStrategy) [ConT ''Read, ConT ''Show, ConT ''Eq, ConT ''Ord]]

newtype RustSource = RustSource {rustSrc :: String}

emitRust :: String -> Q ()
emitRust src' = do
  src <- getQ :: Q (Maybe [RustSource])
  putQ $ concat src ++ [RustSource $ unindent src']
  return ()

topLevel :: Cofree (Compose Maybe Item) ItemSummary -> Q [Dec]
topLevel (_ :< Compose (Just Item {inner = Use Item.Use {id = Just item}})) = topLevel item
topLevel (_ :< Compose (Just Item {inner = Rust.Module Item.Module {items}})) = concat <$> mapM topLevel items
topLevel
  ( _
      :< Compose
           ( Just
               Item
                 { name = Just name,
                   visibility = Visibility.Public,
                   inner = Enum Item.Enum {variants}
                 }
             )
    ) = do
    emitRust
      [i|
      #[unsafe(no_mangle)]
      pub extern "C" fn #{name}(a: usize, b: usize) -> usize {
          a + b
      }
      |]
    return
      [ DataD
          []
          (mkName name)
          []
          Nothing
          [ kindToCon (name ++ conName) kind
          | _ :< Compose (Just Item {name = Just conName, inner = Variant Item.Variant {kind}}) <- variants
          ]
          [DerivClause Nothing [ConT ''Show]]
      ]
topLevel (_ :< Compose (Just Item {name = Just name, visibility = _, inner = Enum Item.Enum {}})) = do
  emitRust
    [i|
      #[unsafe(no_mangle)]
      pub extern "C" fn #{name}(a: usize, b: usize) -> usize {
          a + b
      }
      |]
  return [DataD [] (mkName name) [] Nothing [] []]
topLevel (_ :< Compose (Just Item {name = Just name, inner = Struct Item.Struct {kind}})) = do
  emitRust
    [i|
      #[unsafe(no_mangle)]
      pub extern "C" fn #{name}(a: usize, b: usize) -> usize {
          a + b
      }
      |]
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

kindToCon :: String -> Kind (Cofree (Compose Maybe Item) ItemSummary) -> Con
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

------------------------------------------------------------------------------------------------------------------------

-- The following is revived from https://github.com/harpocrates/inline-rust, which is under the following license:

{-

Copyright (c) 2016, Alec Theriault

All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.

    * Redistributions in binary form must reproduce the above
      copyright notice, this list of conditions and the following
      disclaimer in the documentation and/or other materials provided
      with the distribution.

    * Neither the name of Alec Theriault nor the names of other
      contributors may be used to endorse or promote products derived
      from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

-}

-- * Finalizers

-- | A finalizer to run Cargo and link in the static library. This function
-- should be the very last @inline-rust@ related TH to run.
--
-- After generating an appropriate @Cargo.toml@ file, it calls out to Cargo to
-- compile all the Rust files into a static library and which it then tells TH
-- to link in.
cargoFinalizer ::
  -- | Extra @cargo@ arguments
  [String] ->
  -- | Dependencies
  [(String, String)] ->
  Q ()
cargoFinalizer extraArgs dependencies = do
  (pkg, mods) <- currentFile

  let dir = ".inline-rust" </> pkg
      thisFile = foldr1 (</>) mods <.> "rs"
      localCrate = "quasiquote_" ++ pkg

  -- Make contents of a @Cargo.toml@ file
  let cargoToml = dir </> "Cargo" <.> "toml"
      cargoSrc =
        unlines
          [ "[package]",
            "name = \"" ++ localCrate ++ "\"",
            "version = \"0.0.0\"",
            "[dependencies]",
            unlines
              [ name ++ " = \"" ++ version ++ "\""
              | (name, version) <- dependencies
              ],
            "[lib]",
            "path = \"" ++ thisFile ++ "\"",
            "crate-type = [\"staticlib\"]"
          ]
  runIO $ createDirectoryIfMissing True dir
  runIO $ writeFile cargoToml cargoSrc

  -- Run Cargo to compile the project
  --
  -- NOTE: We set `--print native-static-libs` to inform the user these are the
  --       libraries they should be specifying in `ghc-options`. It would be
  --       much better if:
  --
  --         * We could parse the `stdout` and print out a `ghc-options` related
  --           message. _However_ the message only gets printed if cargo ended
  --           up doing work, and I don't know how to detect that.
  --
  --         * We could automatically link in these libraries, if GHC supported
  --           specifying libraries to pass to the final linker call.
  --
  -- TODO: just pass this into cargo via CreateProcess
  runIO $ setEnv "RUSTFLAGS" "--print native-static-libs"
  let cargoArgs =
        [ "build",
          "--release",
          "--manifest-path=" ++ cargoToml
        ]
          ++ extraArgs
      msgFormat = ["--message-format=json"]

  ec <- runIO $ spawnProcess "cargo" cargoArgs >>= waitForProcess
  when
    (ec /= ExitSuccess)
    (reportError "Rust source file associated with this module failed to compile")

  -- Run Cargo again to get the static library path
  jOuts <- runIO $ readProcess "cargo" (cargoArgs ++ msgFormat) ""
  let jOut = last (lines jOuts)
  return ()

-- TODO uncomment this
-- rustLibFp <-
--   case decode jOut of
--     Error msg -> fail ("cargoFinalizer: " ++ msg)
--     Ok jObj -> case lookup "filenames" (fromJSObject jObj) of
--                  Just (JSArray [ JSString jStr ]) -> pure (fromJSString jStr)
--                  _ -> fail ("cargoFinalizer: did not find one static library")

-- -- Move the library to a GHC temporary file
-- let ext = takeExtension rustLibFp
-- rustLibFp' <- addTempFile ext
-- runIO $ copyFile rustLibFp rustLibFp'

-- -- Link in the static library
-- addForeignFilePath RawObject rustLibFp'

-- | A finalizer to write out a Rust source file when we are done processing
-- a module. This emits into a file in the @.inline-rust@ directory all of the
-- Rust code we have produced while processing the current files contexts and
-- quasiquotes.
fileFinalizer :: Q ()
fileFinalizer = do
  (pkg, mods) <- currentFile

  -- TODO: make this a temp dir
  let dir = ".inline-rust" </> pkg
      thisFile = foldr1 (</>) mods <.> "rs"

  -- Figure out what we are putting into this file
  Just sources <- getQ :: Q (Maybe [RustSource])
  -- Just (Context (_,_,impls)) <- getQ
  let code = unlines (rustSrc <$> sources)

  -- Write out the file
  runIO $ createDirectoryIfMissing True dir
  runIO $ writeFile (dir </> thisFile) code

-- | Figure out what file we are currently in.
currentFile ::
  Q
    ( String,
      -- \^ package name, amended to be a valid crate name
      [String]
    )
-- \^ dot-delimited segments of module name

currentFile = do
  Haskell.Module (PkgName pkg) (ModName modName) <- thisModule
  let prefix
        | null pkg = "krate"
        | isAlpha (head pkg) = ""
        | otherwise = "krate_"
      pkg' = prefix ++ map fixChar pkg
  pure (pkg', splitDots modName)
  where
    fixChar c
      | isAlphaNum c = c
      | otherwise = '_'

    splitDots = unfoldr splitDot
    splitDot s
      | null s = Nothing
      | otherwise = let (x, r) = break (== '.') s in Just (x, drop 1 r)
