{-# LANGUAGE DeriveGeneric, OverloadedStrings #-}
module SfShowList.Models.Show where

import Prelude hiding (Show)
import qualified Prelude

import Data.Aeson
import Data.Text (Text)
import Data.Time
import GHC.Generics
import Database.PostgreSQL.ORM

data Show = Show
  { showId :: DBKey
  , showBill :: Text
  , showVenue :: Text
  , showDisplayNotes :: Maybe Text
  , showProvenance :: Maybe Text
  , showTime :: Maybe TimeOfDay
  , showDate :: Day
  } deriving (Prelude.Show, Generic)

instance ToJSON Show where
  toJSON sh = object [ "id" .= showId sh
                     , "bands" .= showBill sh
                     , "venue" .= showVenue sh
                     , "display_notes" .= showDisplayNotes sh
                     , "date" .= dayToZonedTime (showDate sh)
                     , "time" .= showZonedTime sh ]

showZonedTime :: Show -> Maybe ZonedTime
showZonedTime sh =
  fmap (\t -> ZonedTime (LocalTime (showDate sh) t) utc)
       (showTime sh)

instance Model Show where
  modelInfo = underscoreModelInfo "show"

dayToZonedTime :: Day -> ZonedTime
dayToZonedTime date = ZonedTime (LocalTime date midnight) utc

groupShows :: [Show] -> [Value]
groupShows shs = map toVal $ foldr go [] shs
  where go curShow ((today, todaysShows):rst) =
          if today <= showDate curShow then
            (today, curShow:todaysShows):rst
            else (showDate curShow, [curShow]):(today, todaysShows):rst
        go curShow [] = [(showDate curShow, [curShow])]
        toVal (date, lst) = object ["date" .= dayToZonedTime date
                                   , "shows" .= lst]

