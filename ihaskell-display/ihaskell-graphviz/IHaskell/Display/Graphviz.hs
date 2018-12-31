
-- | A module to help displaying information using the amazing Graphviz
-- (https://www.graphviz.org/) graph layouts.
--
-- You need to install and have graphviz tools available in your environment.
-- 
-- Currently only 'dot' is provided as a proof-of-concept.  This module may be
-- split in two (a package as an helper to Graphviz command line and this
-- package to provide 'IHaskellDisplay' instances.
--
-- Minimal notebook example:
--
-- @ import IHaskell.Display.Graphviz @
-- @ dot "digraph { l -> o; o -> v; v -> e; h -> a ; a -> s; s -> k ; k -> e ; e -> l ; l -> l}" @
module IHaskell.Display.Graphviz (
    dot
  , Graphviz
  ) where

import qualified Data.ByteString.Char8 as Char
import           System.Process (readProcess)
import           IHaskell.Display

-- | The body of a Graphviz program.
--
-- e.g. @ graph { a -- b } @
type GraphvizProgramBody = String

-- | Main Graphviz object.
data Graphviz =
  Dot !GraphvizProgramBody
  -- ^ A Graphviz plotted using Dot (only available currently).

-- | Create a 'Graphviz' using 'dot'.
dot :: GraphvizProgramBody -> Graphviz
dot = Dot

instance IHaskellDisplay Graphviz where
  display fig = do
    pngDisp <- graphDataPNG fig
    return $ Display [pngDisp]

name = "ihaskell-graphviz."

-- Width and height
w = 300
h = 300

graphDataPNG :: Graphviz -> IO DisplayData
graphDataPNG (Dot dotBody) = do
  switchToTmpDir

  let fname = name ++ "png"
  -- Write the image.
  ret <- readProcess "dot" ["-Tpng", "-o", fname] dotBody

  -- Force strictness on readProcess, read file, and convert to base64.
  imgData <- seq (length ret) $ Char.readFile fname
  return $ png w h $ base64 imgData
