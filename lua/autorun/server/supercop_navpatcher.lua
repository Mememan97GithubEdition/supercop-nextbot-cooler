-- TAKEN FROM GLEEEEEE
-- this follows players around watching to see if they walk between unconnected navareas, and then tries to connect them.
-- necessary because 99% of all stairs generated have stupid, stupid gaps in them

local patchCount = 0

local function connectionDistance( currArea, otherArea )
    local currCenter = currArea:GetCenter()

    local nearestInitial = otherArea:GetClosestPointOnArea( currCenter )
    local nearestFinal   = currArea:GetClosestPointOnArea( nearestInitial )
    nearestFinal.z = nearestInitial.z
    local distTo   = nearestInitial:Distance( nearestFinal )
    return distTo, nearestFinal, nearestInitial

end

local function distanceEdge( currArea, otherArea )
    local currCenter = currArea:GetCenter()

    local nearestInitial    = otherArea:GetClosestPointOnArea( currCenter )
    local nearestFinal      = currArea:GetClosestPointOnArea( nearestInitial )
    local distTo            = nearestInitial:Distance( nearestFinal )
    return distTo

end

local function goodDist( distTo )
    local distQuota = 75
    local minCheck = -1
    local maxCheck = 1

    while distQuota < 400 do
        local min = distQuota + minCheck
        local max = distQuota + maxCheck

        if distTo > min and distTo < max then return true end
        distQuota = distQuota + 25

    end

    return nil

end

local upOffset = Vector( 0, 0, 25 )

-- do checks to see if connection from old area to curr area is a good idea
local function smartConnectionThink( oldArea, currArea )
    if oldArea:IsConnected( currArea ) then return end

    -- get dist flat, no z component
    local distTo = connectionDistance( oldArea, currArea )

    if distTo > 55 and not goodDist( distTo ) then return end

    -- check if there's a simple-ish way from oldArea to currArea
    -- dont create a new connection if there is
    local returnAreas = { [currArea] = true }
    local incomingAreas = currArea:GetIncomingConnections()
    if #incomingAreas > 0 then
        for _, area in ipairs( incomingAreas ) do
            returnAreas[area] = true

        end
    end

    local currsNearest = currArea:GetClosestPointOnArea( oldArea:GetCenter() ) + upOffset
    local tolerance = distTo + -5

    local doneAlready = {}
    for _, firstLayer in ipairs( oldArea:GetAdjacentAreas() ) do
        if returnAreas[firstLayer] then return end
        doneAlready[firstLayer] = true
        if firstLayer:IsVisible( currsNearest ) and distanceEdge( firstLayer, currArea ) < tolerance then print("1") return end

        for _, secondLayer in ipairs( firstLayer:GetAdjacentAreas() ) do
            if doneAlready[secondLayer] then continue end
            doneAlready[secondLayer] = true
            if returnAreas[secondLayer] then return end
            if secondLayer:IsVisible( currsNearest ) and distanceEdge( secondLayer, currArea ) < tolerance then print("2") return end

            for _, thirdLayer in ipairs( secondLayer:GetAdjacentAreas() ) do
                if doneAlready[thirdLayer] then continue end
                doneAlready[thirdLayer] = true
                if returnAreas[thirdLayer] then return end
                if thirdLayer:IsVisible( currsNearest ) and distanceEdge( thirdLayer, currArea ) < tolerance then print("3") return end

            end
        end
    end

    oldArea:ConnectTo( currArea )
    patchCount = patchCount + 1

    return true

end
-- patches gaps in navmesh, using players as a guide
-- patches will never be ideal, but they will be better than nothing

local tooFarDistSqr = 40^2
local navCheckDist = 150

local function navPatchingThink( ply )

    local badMovement = ply:GetMoveType() == MOVETYPE_NOCLIP or ply:Health() <= 0 or ply:GetObserverMode() ~= OBS_MODE_NONE or ply:InVehicle()

    if badMovement then ply.oldPatchingArea = nil return end

    local plyPos = ply:GetPos()

    local currArea = navmesh.GetNearestNavArea( plyPos, true, navCheckDist, false, true )
    if not IsValid( currArea ) then return end
    local distToArea = plyPos:DistToSqr( currArea:GetClosestPointOnArea( plyPos ) )

    -- cant be sure of areas further away than this!
    if distToArea > tooFarDistSqr then return end

    local oldArea = ply.oldPatchingArea
    ply.oldPatchingArea = currArea

    if not IsValid( oldArea ) then return end
    if currArea == oldArea then return end
    if oldArea:IsConnected( currArea ) and currArea:IsConnected( oldArea ) then return end

    local plysCenter = ply:WorldSpaceCenter()

    local currClosestPos = currArea:GetClosestPointOnArea( plysCenter )
    local oldClosestPos = oldArea:GetClosestPointOnArea( plysCenter )
    local zOverride = math.max( plysCenter.z, oldClosestPos.z + 10, currClosestPos.z + 10 ) + 10 -- just check walls

    local plysCenter2 = Vector( plysCenter.x, plysCenter.y, zOverride ) -- yuck

    local currClosestPosInAir = Vector( currClosestPos.x, currClosestPos.y, zOverride )
    local oldClosestPosInAir = Vector( oldClosestPos.x, oldClosestPos.y, zOverride )

    -- needs terminator nextbot addon!
    --debugoverlay.Line( currClosestPos, currClosestPosInAir, 5, color_white, true )
    --debugoverlay.Line( currClosestPosInAir, plysCenter2, 5, color_white, true )
    --debugoverlay.Line( plysCenter2, oldClosestPosInAir, 5, color_white, true )
    --debugoverlay.Line( oldClosestPos, oldClosestPosInAir, 5, color_white, true )
    if not terminator_Extras.PosCanSee( currClosestPos, currClosestPosInAir, MASK_SOLID_BRUSHONLY ) then return end
    if not terminator_Extras.PosCanSee( currClosestPosInAir, plysCenter2, MASK_SOLID_BRUSHONLY ) then return end
    if not terminator_Extras.PosCanSee( plysCenter2, oldClosestPosInAir, MASK_SOLID_BRUSHONLY ) then return end
    if not terminator_Extras.PosCanSee( oldClosestPos, oldClosestPosInAir, MASK_SOLID_BRUSHONLY ) then return end

    smartConnectionThink( oldArea, currArea )
    smartConnectionThink( currArea, oldArea )

end

local targetCountToPatch = 6

local function manageNavPatching( players )
    local playersToPatch = {}

    -- if there is still room in the table, add other people
    for _, ply in ipairs( players ) do
        local lowCount = #playersToPatch < targetCountToPatch
        if lowCount then
            table.insert( playersToPatch, ply )

        else
            break

        end
    end

    for _, ply in ipairs( playersToPatch ) do
        navPatchingThink( ply )

    end
end

local doPatching = CreateConVar( "supercop_nextbot_server_navpatcher", 1, bit.bor( FCVAR_ARCHIVE ), "Do supercop navpatcher? Fixes supercop not being able to use some stairs.", 0, 1 )
local doNavSave = CreateConVar( "supercop_nextbot_server_navsave", 1, bit.bor( FCVAR_ARCHIVE ), "If navpatcher ran, save the navmesh after supercop is removed?", 0, 1 )

local _IsValid = IsValid
local donePatching = nil

local function finishPatching()
    if doNavSave:GetBool() ~= true then return end
    if not donePatching then return end
    donePatching = nil

    navmesh.Save()

    supercopNextbot_SupercopLog( "Supercop removed, navpatcher's " .. tostring( patchCount ) .. " new connections, have been saved..." )

    patchCount = 0

end

hook.Add( "supercop_nextbot_removed", "supercop_nextbot_finishpatching", function()
    finishPatching()

end )

hook.Add( "Think", "supercop_nextbot_navpatcher", function()
    local validCop = _IsValid( supercop_nextbot_copThatExists )
    if donePatching and not validCop then
        finishPatching()

    elseif validCop then
        if doPatching:GetBool() ~= true then return end

        if not donePatching then
            supercopNextbot_SupercopLog( "Navpatcher is PATCHING!" )

        end

        -- never want this to spam errors, and i dont trust it
        local success = ProtectedCall( function() manageNavPatching( player.GetAll() ) end )
        if success ~= true then
            hook.Remove( "Think", "supercop_nextbot_navpatcher" )

        else
            donePatching = true

        end
    end
end )