{-# LANGUAGE OverloadedStrings #-}
module Application where

import SfShowList.Common
import Network.Wai.Middleware.Static
import Web.Simple

import SfShowList.Controllers.Shows

app :: (Application -> IO ()) -> IO ()
app runner = do
  settings <- newAppSettings

  runner $ controllerApp settings $ do
    routeTop showsController
    routeName "shows" adminController
    fromApp $ staticPolicy (addBase "static") $ const $ return notFound

