{-# LANGUAGE OverloadedStrings #-}
import Database.PostgreSQL.Migrations
import Database.PostgreSQL.Simple

up :: Connection -> IO ()
up = migrate $
  create_table "show"
    [ column "id" "serial PRIMARY KEY"
    , column "bill" "text NOT NULL"
    , column "venue" "text NOT NULL"
    , column "display_notes" "text"
    , column "provenance" "text"
    , column "time" "timestamptz NOT NULL" ]

down :: Connection -> IO ()
down = migrate $ do
  drop_table "show"

main :: IO ()
main = defaultMain up down

