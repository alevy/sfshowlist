{-# LANGUAGE OverloadedStrings #-}
import Database.PostgreSQL.Migrations
import Database.PostgreSQL.Simple

up :: Connection -> IO ()
up = migrate $
  create_table "show"
  [ column "id" "serial PRIMARY KEY"
  , column "bands" "text[] NOT NULL"
  , column "venue" "json NOT NULL"
  , column "notes" "text"
  , column "time" "timestamptz NOT NULL"]

down :: Connection -> IO ()
down = migrate $ do
  drop_table "show"

main :: IO ()
main = defaultMain up down

