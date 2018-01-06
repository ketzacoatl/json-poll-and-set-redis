module Main where

import           Control.Concurrent             (threadDelay)
import           Control.Monad                  (forever)
import           Control.Monad.IO.Class         (liftIO)
import           Control.Monad.Logger.CallStack (logDebug
                                                ,logInfo
                                                ,runStdoutLoggingT)
import           Data.Aeson                     (encode)
import           Data.Aeson.Parser              (json)
import qualified Data.ByteString.Char8      as  C
import           Data.ByteString.Lazy           (toStrict)
import           Data.Conduit                   (($$))
import           Data.Conduit.Attoparsec        (sinkParser)
import qualified Data.Text                  as  T
import           Database.Redis                 (connect
                                                ,defaultConnectInfo
                                                ,set
                                                ,runRedis)

import           Network.HTTP.Client
import           Network.HTTP.Client.Conduit    (bodyReaderSource)
import           Network.HTTP.Client.TLS        (tlsManagerSettings)
import           Network.HTTP.Types.Status      (statusCode)


main :: IO ()
main = runStdoutLoggingT $ do
  logInfo $ T.pack $ "Data processing sink started!"
  manager <- liftIO $ newManager tlsManagerSettings
  rconn   <- liftIO $ connect defaultConnectInfo
  request <- parseRequest "https://httpbin.org/get"
  forever $ do
    --logDebug $ "Data processing sink started!"
    liftIO $ withResponse request manager $ \response -> do
      value <- bodyReaderSource (responseBody response)
            $$ sinkParser json
      print value
      runRedis rconn $ set (C.pack "json_response") $ (toStrict $ encode value)
    -- pause for 30 seconds
    liftIO $ threadDelay $ (30 * 1000 * 1000)
