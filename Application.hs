{-# LANGUAGE OverloadedStrings #-}
module Application where

import SfShowList.Common
import Web.Simple

import SfShowList.Controllers.Shows

app :: (Application -> IO ()) -> IO ()
app runner = do
  settings <- newAppSettings

  runner $ controllerApp settings $ do
    showsController

