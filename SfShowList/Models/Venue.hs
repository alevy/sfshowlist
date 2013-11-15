{-# LANGUAGE DeriveDataTypeable, OverloadedStrings #-}
module SfShowList.Models.Venue where

import Control.Applicative
import Data.Aeson
import Data.Text
import Data.Typeable
import Database.PostgreSQL.Simple.FromField
import Database.PostgreSQL.Simple.ToField

data Venue = Venue { venueName :: Text
                   , venueAddress :: Text } deriving (Prelude.Show, Typeable)

instance FromField Venue where
  fromField = fromJSONField

instance ToField Venue where
  toField = toField . toJSON

instance ToJSON Venue where
  toJSON venue = object [ "name" .= venueName venue
                        , "address" .= venueAddress venue ]

instance FromJSON Venue where
  parseJSON (Object v) = Venue <$>
    v .: "name" <*>
    v .: "address"
  parseJSON _ = error "expecting an object"

