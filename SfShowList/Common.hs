{-# LANGUAGE TypeSynonymInstances, OverloadedStrings #-}
module SfShowList.Common where

import Control.Applicative
import Data.Aeson
import Data.Time
import Web.Simple
import Web.Simple.PostgreSQL
import Web.Simple.Templates
import Web.Simple.Session
import System.Locale

data AppSettings = AppSettings { appDB :: PostgreSQLConn
                               , appSession :: Maybe Session }

newAppSettings :: IO AppSettings
newAppSettings = do
  db <- createPostgreSQLConn
  return $ AppSettings { appDB = db , appSession = Nothing }

instance HasPostgreSQL AppSettings where
  postgreSQLConn = appDB

instance HasSession AppSettings where
  getSession = appSession
  setSession sess = do
    cs <- controllerState
    putState $ cs { appSession = Just sess }

instance HasTemplates AppSettings where
  defaultLayout = Just <$> getTemplate "templates/main.html"
  functionMap = return $ fromList
    [ ("formatTime", toFunction formatZonedTime) ]

formatZonedTime :: String -> ZonedTime -> Value
formatZonedTime fmtStr zt = toJSON $ formatTime defaultTimeLocale fmtStr zt

