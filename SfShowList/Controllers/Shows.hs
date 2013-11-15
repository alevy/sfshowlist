{-# LANGUAGE OverloadedStrings #-}
module SfShowList.Controllers.Shows where

import Prelude hiding (Show, shows)

import Control.Monad.IO.Class
import Data.Time
import Database.PostgreSQL.ORM
import SfShowList.Common
import SfShowList.Models.Show
import Web.Simple
import Web.REST
import Web.Simple.Templates
import Web.Simple.PostgreSQL

showsController :: Controller AppSettings ()
showsController = routeREST $ rest $ do
  index $ do
    withConnection $ \db -> do
      now <- liftIO $ getZonedTime
      shows <- liftIO $ dbSelect db $ setOrderBy "time asc"
                                 --   $ addWhere "time >= ?" [now]
                                    $ modelDBSelect
      render "index.html" $ groupShows shows

