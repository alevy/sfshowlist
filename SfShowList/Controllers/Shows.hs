{-# LANGUAGE OverloadedStrings #-}
module SfShowList.Controllers.Shows where

import Prelude hiding (Show, shows)

import Control.Applicative
import Control.Monad.IO.Class
import qualified Data.ByteString.Char8 as S8
import Data.Text.Encoding
import Data.Time
import Database.PostgreSQL.ORM
import SfShowList.Auth
import SfShowList.Common
import SfShowList.Models.Show
import System.Locale
import Web.Simple
import Web.REST
import Web.Simple.Templates
import Web.Simple.PostgreSQL

showsController :: Controller AppSettings ()
showsController = withConnection $ \db -> do
  today <- liftIO $ localDay . zonedTimeToLocalTime <$> getZonedTime
  shows <- liftIO $ dbSelect db $ setOrderBy "date asc, time asc"
                                $ addWhere "date >= ?" [today]
                                $ modelDBSelect
  render "index.html" $ groupShows shows

adminController :: Controller AppSettings ()
adminController = requiresAdmin "/login" $ routeREST $ rest $ do
  new $ do
    render "new.html" ()

  edit $ do
    sid <- readQueryParam' "id"
    liftIO $ print sid
    withConnection $ \db -> do
      mshow <- liftIO $ (findRow db sid :: IO (Maybe Show))
      case mshow of
        Just s -> render "edit.html" s
        Nothing -> respond $ notFound

  create $ do
    (prms0, _) <- parseForm
    let prms = filter (not . S8.null . snd) prms0
    let mshow = do
        bill <- decodeUtf8 <$> lookup "bill" prms
        venue <- decodeUtf8 <$> lookup "venue" prms
        let displayNotes = decodeUtf8 <$> lookup "display_notes" prms
        let provenance = decodeUtf8 <$> lookup "provenance" prms
        date <- parseTime defaultTimeLocale "%F" =<<
                  (S8.unpack <$> lookup "date" prms)
        let time = parseTime defaultTimeLocale "%H:%M" =<<
                    (S8.unpack <$> lookup "time" prms)
        return $ Show NullKey bill venue displayNotes provenance time date
    case mshow of
      Just newShow -> do
        withConnection $ \db -> liftIO $ save db newShow
        respond $ redirectTo "/"
      Nothing -> redirectBack

  update $ do
    sid <- DBKey <$> readQueryParam' "id"
    (prms0, _) <- parseForm
    let prms = filter (not . S8.null . snd) prms0
    let mshow = do
        bill <- decodeUtf8 <$> lookup "bill" prms
        venue <- decodeUtf8 <$> lookup "venue" prms
        let displayNotes = decodeUtf8 <$> lookup "display_notes" prms
        let provenance = decodeUtf8 <$> lookup "provenance" prms
        date <- parseTime defaultTimeLocale "%F" =<<
                  (S8.unpack <$> lookup "date" prms)
        let time = parseTime defaultTimeLocale "%H:%M" =<<
                    (S8.unpack <$> lookup "time" prms)
        return $ Show sid bill venue displayNotes provenance time date
    case mshow of
      Just updatedShow -> do
        withConnection $ \db -> liftIO $ save db updatedShow
        respond $ redirectTo "/"
      Nothing -> redirectBack

