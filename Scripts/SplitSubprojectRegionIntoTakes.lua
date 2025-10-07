-- @description Split Subproject Regions Into Takes
-- @author corentinB
-- @version 1.0
-- @about
--	This script explode selected subproject items into takes and select them randomly


function IsSubProject(item)
    return select(2, reaper.GetItemStateChunk(item, '', false)):find 'SOURCE RPP_PROJECT' and true or false
end

function GetRegionsByIDX(projectIndex)
  local i=0
  local regions_idx = {}
  local startPos = 0
  repeat
    local iRetval, bIsrgnOut, iPosOut, iRgnendOut, sNameOut, iMarkrgnindexnumberOut, iColorOur = reaper.EnumProjectMarkers3(projectIndex,i)
    if iRetval >= 1 then
      if bIsrgnOut == true then -- NOTE: Mod
        local region = {}
        region.pos_start = iPosOut
        region.pos_end = iRgnendOut
        region.color = iColorOur -- In case field is only $blank to clear
        region.name = sNameOut
        region.idx = iMarkrgnindexnumberOut
        regions_idx[iMarkrgnindexnumberOut] = region
      else
        if sNameOut == "=START" then
          startPos = iPosOut
        end
      end
    end
    i = i+1
  until iRetval == 0
  return regions_idx, startPos
end


-- MAIN --
regions = {}
nbItem = reaper.CountSelectedMediaItems(0)
selectedItem = {}
copiedItem = {}
startPosition = 0

-- Get select item
for i = 1, nbItem do
  local item = reaper.GetSelectedMediaItem(0, i-1)
  selectedItem[i] = item
end


-- For each item, add take with the same source and shift the start
-- Resize the item to the max region size
for itemIndex = 1, #selectedItem do
  if IsSubProject(selectedItem[itemIndex]) then
    local itemPosition = reaper.GetMediaItemInfo_Value(selectedItem[itemIndex], "D_POSITION")
    local take =  reaper.GetActiveTake(selectedItem[itemIndex])
    local takeSource = reaper.GetMediaItemTake_Source(take)
    local maxRegionLength = 0
    
    if take then 
      local src = reaper.GetMediaItemTake_Source(take)
      subproj = reaper.GetSubProjectFromSource(src)
      regions, startPosition = GetRegionsByIDX(subproj)
      reaper.SetMediaItemTakeInfo_Value(take, "D_STARTOFFS", regions[1].pos_start - startPosition)
      
      if #regions > 1 then
        for regionIndex = 2, #regions do
          local regionLength = regions[regionIndex].pos_end - regions[regionIndex].pos_start
          if regionLength > maxRegionLength then
            maxRegionLength = regionLength
          end
          
          local newTake = reaper.AddTakeToMediaItem(selectedItem[itemIndex])
          reaper.SetMediaItemTake_Source(newTake, takeSource)
          reaper.SetMediaItemTakeInfo_Value(newTake, "D_STARTOFFS", regions[regionIndex].pos_start - startPosition)
        end
      end
      
      reaper.SetMediaItemLength(selectedItem[itemIndex], maxRegionLength, true)
    end
  end
end

-- select random takes
actionNumber = reaper.NamedCommandLookup("_XENAKIOS_SHUFFLESELECTTAKES")
reaper.Main_OnCommand(actionNumber, 0) 

