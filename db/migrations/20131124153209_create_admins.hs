{-# LANGUAGE OverloadedStrings #-}
import Control.Monad.IO.Class
import Control.Monad.Reader
import Database.PostgreSQL.Migrations
import Database.PostgreSQL.Simple

up :: Connection -> IO ()
up = migrate $ do
  create_table "admins"
    [ column "openid" "text UNIQUE"
    , column "invite_code" "varchar(4) UNIQUE"]
  conn <- ask
  liftIO $ execute_ conn
    "insert into admins (invite_code) values ('abcd')"

down :: Connection -> IO ()
down = migrate $ do
  drop_table "admins"

main :: IO ()
main = defaultMain up down

