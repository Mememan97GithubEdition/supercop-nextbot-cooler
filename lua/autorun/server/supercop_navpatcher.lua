-- TAKEN FROM GLEEEEEE
-- this follows players around watching to see if they walk between unconnected navareas, and then tries to connect them.
-- necessary because 99% of all stairs generated have stupid, stupid gaps in them

local patchCount = 0

local function connectionDistance( currArea, otherArea )
    local currCenter = currArea:GetCenter()

    local nearestInitial = otherArea:GetClosestPointOnArea( currCenter )
    local nearestFinal   = currArea:GetClosestPointOnArea( nearestInitial )
    nearestFinal.z = nearestInitial.z
    local distTo   = nearestInitial:DistToSqr( nearestFinal )
    return distTo, nearestFinal, nearestInitial

end

-- see if the z of start area
local function arePlanar( startArea, toCheckAreas, criteria )
    for _, currArea in ipairs( toCheckAreas ) do
        if startArea:IsConnected( currArea ) then
            local height = math.abs( startArea:ComputeAdjacentConnectionHeightChange( currArea ) )
            if height < criteria then return true end

        end

        local startAreaClosest = startArea:GetClosestPointOnArea( currArea:GetCenter() )
        local currAreaClosest = currArea:GetClosestPointOnArea( startAreaClosest )

        height = currAreaClosest.z - startAreaClosest.z
        height = math.abs( height )

        if height < criteria then return true end

    end
    return false
end

local function goodDist( distTo )
    local distQuota = 75
    local minCheck = -1
    local maxCheck = 1

    while distQuota < 400 do
        local min = distQuota + minCheck
        local max = distQuota + maxCheck
        min = min^2
        max = max^2

        if distTo > min and distTo < max then return true end
        distQuota = distQuota + 25

    end

    return nil

end

-- do checks to see if connection from old area to curr area is a good idea
local function smartConnectionThink( oldArea, currArea, ignorePlanar )
    if oldArea:IsConnected( currArea ) then return end

    -- get dist sqr and old area's closest point to curr area
    local distTo, _, currAreasClosest = connectionDistance( oldArea, currArea )

    if distTo > 55^2 and not goodDist( distTo ) then return end

    local pos1 = oldArea:GetClosestPointOnArea( currAreasClosest )
    local pos2 = currArea:GetClosestPointOnArea( pos1 )
    local criteria = math.abs( pos1.z - pos2.z ) + 50
    --debugoverlay.Cross( pos1, 50, 10, color_white, true )
    --debugoverlay.Cross( pos2, 100, 10, Color( 255,0,0 ), true )

    local navDirTakenByConnection = oldArea:ComputeDirection( pos2 )
    local areasInNavDir = oldArea:GetAdjacentAreasAtSide( navDirTakenByConnection )

    if not ignorePlanar and #areasInNavDir > 0 and arePlanar( currArea, areasInNavDir, criteria ) == true then return end

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
    if not currArea or not currArea.IsValid or not currArea:IsValid() then return end
    local distToArea = plyPos:DistToSqr( currArea:GetClosestPointOnArea( plyPos ) )

    -- cant be sure of areas further away than this!
    if distToArea > tooFarDistSqr then return end

    local oldArea = ply.oldPatchingArea
    ply.oldPatchingArea = currArea

    if not oldArea or not oldArea.IsValid or not oldArea:IsValid() then return end
    if currArea == oldArea then return end

    local currClosestPos = currArea:GetClosestPointOnArea( plyPos )
    local oldClosestPos = oldArea:GetClosestPointOnArea( plyPos )
    local zOverride = math.max( plyPos.z, oldClosestPos.z + 10, currClosestPos.z + 10 ) + 10 -- just check walls

    local plyPos2 = Vector( plyPos.x, plyPos.y, zOverride ) -- yuck
    currClosestPos.z = zOverride

    --debugoverlay.Line( plyPos2, currClosestPos, 5, Color(255,255,255), true )
    --print( plyPos2.z, currClosestPos.z, plyPos.z )

    -- needs terminator nextbot addon!
    if not terminator_Extras.PosCanSee( plyPos2, currClosestPos, MASK_SOLID_BRUSHONLY ) then return end
    if not terminator_Extras.PosCanSee( plyPos2, oldClosestPos, MASK_SOLID_BRUSHONLY ) then return end

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

local _IsValid = IsValid
local donePatching = nil

hook.Add( "Think", "supercop_nextbot_navpatcher", function()
    local validCop = _IsValid( supercop_nextbot_copThatExists )
    if donePatching and not validCop then
        donePatching = nil
        supercopNextbot_SupercopLog( "Supercop removed, navpatcher stopping..." )

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

hook.Add( "supercop_nextbot_removed", "supercop_nextbot_finishpatching", function()
    finishPatching()

end )