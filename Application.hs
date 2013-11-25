{-# LANGUAGE OverloadedStrings #-}
module Application where

import SfShowList.Common
import Network.Wai.Middleware.MethodOverridePost
import Network.Wai.Middleware.Static
import Web.Simple
import Web.Simple.Session

import SfShowList.Auth
import SfShowList.Controllers.Shows

app :: (Application -> IO ()) -> IO ()
app runner = do
  settings <- newAppSettings

  runner $ methodOverridePost $ controllerApp settings $ withSession $ do
    openIdController handleLogin
    routeName "login" loginPage
    routeName "logout" logout

    routeTop showsController
    routeName "shows" $ adminController
    fromApp $ staticPolicy (addBase "static") $ const $ return notFound

