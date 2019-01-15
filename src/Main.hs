{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}

module Main where

import Control.Monad.IO.Class
import qualified Control.Monad.Trans.State as S
import Control.Monad.Trans
import Data.Aeson ( FromJSON, ToJSON, encode )
import Data.IORef
import Data.Monoid (mconcat)
import Data.String
import Data.Text.Lazy
import GHC.Generics
import Network.HTTP.Types
import System.IO
import System.Random
import Text.Read (readMaybe)
import Web.Scotty.Trans

data Guess = Guess { guessText :: String }
  deriving (Generic, Show)

instance FromJSON Guess
instance ToJSON Guess

data GuessResult = Correct | TooHigh | TooLow | Invalid
  deriving (Generic, Show)

instance FromJSON GuessResult
instance ToJSON GuessResult

data Response = Response { result :: GuessResult }
  deriving (Generic, Show)

instance FromJSON Response
instance ToJSON Response

getHTMLFile :: String -> ActionT Text IO ()
getHTMLFile content = do
  liftIO $ putStrLn "serving some HTML"
  html (fromString content)

getJSFile :: String -> ActionT Text IO ()
getJSFile content = do
  liftIO $ putStrLn "serving some JavaScript"
  text (fromString content)

newGame :: IORef Int -> ActionT Text IO ()
newGame xRef = do
  x <- liftIO $ getStdRandom (randomR (1,100))
  liftIO $ writeIORef xRef x
  liftIO $ putStrLn $ "starting new game with " ++ show x

processGuess :: IORef Int -> ActionT Text IO ()
processGuess xRef = do
  guess :: Guess <- jsonData
  x <- liftIO $ readIORef xRef
  case readMaybe (guessText guess) :: Maybe Int of
    Just guessVal -> case guessVal `compare` x of
      LT -> json (Response TooLow)
      GT -> json (Response TooHigh)
      EQ -> do
        json (Response Correct)
        newGame xRef
    Nothing -> json (Response Invalid)

main :: IO ()
main = do
  index <- readFile "html/index.html"
  samplejs <- readFile "html/sample.js"
  xRef <- newIORef 0
  scottyT 4000 id $ do
    get "/" $ do
      getHTMLFile index
      newGame xRef
    get "/sample.js" $ getJSFile samplejs
    post "/guess" $ processGuess xRef
