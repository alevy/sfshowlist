{-# LANGUAGE OverloadedStrings #-}
module SfShowList.Auth where

import Prelude hiding (div)

import Control.Applicative
import Control.Monad
import Control.Monad.IO.Class
import Data.Aeson
import qualified Data.ByteString.Char8 as S8
import qualified Data.Text as T
import Data.Text.Encoding
import Data.Maybe
import Database.PostgreSQL.Simple
import Network.HTTP.Conduit (withManager)
import Web.Frank
import Web.Simple
import Web.Simple.PostgreSQL
import Web.Simple.Session
import Web.Simple.Templates
import Web.Authenticate.OpenId

import SfShowList.Common

openIdController :: HasSession a
                 => (Maybe S8.ByteString -> T.Text -> Controller a ())
                 -> Controller a ()
openIdController loginHandler = do
  get "auth/finalize" $ do
    prms <- (map (\(k,(Just v)) -> (decodeUtf8 k, decodeUtf8 v)))
              <$> queryString <$> request
    oidr <- liftIO $ withManager $ authenticateClaimed prms
    case identifier <$> oirClaimed oidr of
      Just openid -> do
        minviteCode <- sessionLookup "invite_code"
        sessionDelete "invite_code"
        loginHandler minviteCode openid
      _ -> respond forbidden
  get "auth/login" $ do
    claimedId <- queryParam' "openid_identifier"
    (Just host) <- requestHeader "Host"
    secure <- isSecure <$> request
    let completePage = decodeUtf8 $
          if secure then
            S8.concat ["https://", host, "/auth/finalize"]
            else S8.concat ["http://", host, "/auth/finalize"]
    fu <- liftIO $ withManager $ getForwardUrl claimedId
                    completePage Nothing []
    mcode <- queryParam "invite_code"
    case mcode of
      Nothing -> return ()
      Just code -> do
        when (not $ S8.null code) $
          sessionInsert "invite_code" code
    respond $ redirectTo $ encodeUtf8 fu

handleLogin :: Maybe S8.ByteString -> T.Text -> Controller AppSettings ()
handleLogin minviteCode openid = do
  case minviteCode of
    Nothing -> do
      (Only res):[] <- withConnection $ \conn -> liftIO $
        query conn "select count(*) from admins where openid = ?" (Only openid)
      when (res == (0 :: Int)) $
        respond forbidden
    Just inviteCode -> do
      i <- withConnection $ \conn -> liftIO $
        execute conn
          "update admins set openid = ?, invite_code = NULL where invite_code = ?"
          (openid, inviteCode)
      when (i == 0) $ do
        respond forbidden
  ret <- fromMaybe "/" `fmap` sessionLookup "return_to"
  sessionDelete "return_to"
  sessionInsert "user" $ encodeUtf8 openid
  respond $ redirectTo ret

logout :: Controller AppSettings ()
logout = do
  sessionDelete "user"
  respond $ redirectTo "/"

requiresAdmin :: S8.ByteString
              -> Controller AppSettings b -> Controller AppSettings b
requiresAdmin loginUrl cnt = do
  muser <- sessionLookup "user"
  if isJust muser then
    cnt
    else do
      req <- request
      sessionInsert "return_to" $ rawPathInfo req
      respond $ redirectTo loginUrl

loginPage :: Controller AppSettings ()
loginPage = render "login.html" Null

