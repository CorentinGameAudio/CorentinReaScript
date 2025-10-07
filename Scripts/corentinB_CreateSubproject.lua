-- @description Create subproject copying first track item in time selection
-- @author corentinB
-- @version 1.0
-- @about
--   This script create a subproject with some tracks.
--   And copy the time selection of the first track into it.


function CreateTracks(trackColor)
 for i = 1, 15 do
    reaper.InsertTrackAtIndex(i, false)
    local track = reaper.GetTrack(0, i)
    reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "SFX", true)
    reaper.SetTrackColor(track, trackColor)
  end
end
  
  
--MAIN --
mainProjTrack = reaper.GetSelectedTrack(0, 0)
color = 0
if mainProjTrack then
  color = reaper.GetTrackColor(mainProjTrack)
end

-- create subproject
reaper.Main_OnCommand(41049, 0) 

-- unselect items and tracks
actionNumber = reaper.NamedCommandLookup("_SWS_UNSELALL")
reaper.Main_OnCommand(actionNumber, 0) 

-- select first track
actionNumber = reaper.NamedCommandLookup("_SWS_SEL1")
reaper.Main_OnCommand(actionNumber, 0)

-- select item in time selection on selected track
reaper.Main_OnCommand(40718, 0)

-- copy
reaper.Main_OnCommand(41383, 0)

-- switch last tab
actionNumber = reaper.NamedCommandLookup("_SWS_LASTPROJTAB")
reaper.Main_OnCommand(actionNumber, 0)

-- paste
reaper.Main_OnCommand(42398, 0)

-- create some default tracks
CreateTracks(color)

-- rename first track in video
track = reaper.GetTrack(0, 0)
reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "video", true)
reaper.SetTrackUIVolume(track, -150, false, true, 1)

-- make master track visible
reaper.SetMasterTrackVisibility(1)

