{-# LANGUAGE DeriveGeneric, OverloadedStrings #-}
module SfShowList.Models.Show where

import Prelude hiding (Show)
import qualified Prelude

import Control.Applicative
import Data.Aeson
import Data.Text (Text)
import Data.Time hiding (Day)
import Data.Vector (Vector, fromList)
import GHC.Generics
import Database.PostgreSQL.ORM

import SfShowList.Models.Venue

data Show = Show
  { showId :: DBKey
  , showBands :: Vector Text
  , showVenue :: Venue
  , showNotes :: Maybe Text
  , showTime :: ZonedTime
  } deriving (Prelude.Show, Generic)

instance ToJSON Show where
  toJSON sh = object [ "id" .= showId sh
                     , "bands" .= showBands sh
                     , "venue" .= showVenue sh
                     , "notes" .= showNotes sh
                     , "time" .= showTime sh]

instance FromJSON Show where
  parseJSON (Object sh) = Show <$>
    (DBKey <$> sh .: "id") <*>
    sh .: "bands" <*>
    sh .: "venue" <*>
    sh .:? "notes" <*>
    sh .: "time"
  parseJSON _ = error "expecting an object"

instance Model Show where
  modelInfo = underscoreModelInfo "show"

type Year = Integer
type Month = Int
type Day = Int
type Hour = Int
type Minutes = Int

newShow :: [Text] -> Venue -> Maybe Text
        -> Year -> Month -> Day -> Hour -> Minutes -> TimeZone
        -> Show
newShow bands venue mnotes y m d h minute tz =
  Show NullKey (fromList bands) venue mnotes $
    ZonedTime (LocalTime (fromGregorian y m d) (TimeOfDay h minute 0)) tz

showDate :: Show -> ZonedTime
showDate sh = let t = showTime sh
  in t { zonedTimeToLocalTime =
        (zonedTimeToLocalTime t) { localTimeOfDay = midnight }}

groupShows :: [Show] -> [Value]
groupShows shs = map toVal $ foldr go [] shs
  where go curShow ((today, todaysShows):rst) =
          if localDay (zonedTimeToLocalTime today) <=
             localDay (zonedTimeToLocalTime $ showTime curShow) then
            (today, curShow:todaysShows):rst
            else (showDate curShow, [curShow]):(today, todaysShows):rst
        go curShow [] = [(showDate curShow, [curShow])]
        toVal (date, lst) = object ["date" .= date, "shows" .= lst]

