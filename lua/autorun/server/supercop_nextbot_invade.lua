supercop_nextbot_copSpawnpoints = supercop_nextbot_copSpawnpoints or {}

hook.Add( "PlayerInitialSpawn", "supercop_nextbot_storegenericspawnpoints", function( spawned )
    timer.Simple( 1, function()
        if not IsValid( spawned ) then return end
        if #supercop_nextbot_copSpawnpoints > 20 then return end
        if spawned:Health() <= 0 then return end

        table.insert( supercop_nextbot_copSpawnpoints, spawned:GetPos() )

    end )
end )

local whereToSpawn = nil

local function setupCopRandomSpawnpoint()
    if #supercop_nextbot_copSpawnpoints <= 0 then return end
    for _, potentialSpawn in ipairs( supercop_nextbot_copSpawnpoints ) do
        local area = navmesh.GetNearestNavArea( potentialSpawn, true, 400, false, true, -2 )
        if not area or not area.IsValid or not area:IsValid() then continue end

        whereToSpawn = area:GetCenter()

    end
end

local function hasNavmesh()
    if #navmesh.GetAllNavAreas() <= 0 then return end

    return true

end

local msgPrefix = "[Supercop Nextbot] "
local doPrints = CreateConVar( "supercop_nextbot_do_prints", 1, bit.bor( FCVAR_ARCHIVE ), "Do supercop prints?", 0, 1 )

local function supercopMessage( message )
    if doPrints:GetBool() ~= true then return end
    local msgAppended = msgPrefix .. message

    print( msgAppended )
    PrintMessage( HUD_PRINTCENTER, msgAppended )
    PrintMessage( HUD_PRINTTALK, msgAppended )

end

--globul
supercop_nextbot_copThatExists = nil

local doWarnAlarm = CreateConVar( "supercop_nextbot_do_invadingalarm", 1, bit.bor( FCVAR_ARCHIVE ), "Do manhack alarm when spawned?", 0, 1 )
local function supercopWarn()
    if doWarnAlarm:GetBool() ~= true then return end
    local filterAllPlayers = RecipientFilter()
    filterAllPlayers:AddAllPlayers()

    if not IsValid( supercop_nextbot_copThatExists ) then return end

    supercop_nextbot_copThatExists.alarmSound = CreateSound( supercop_nextbot_copThatExists, "ambient/alarms/manhack_alert_pass1.wav", filterAllPlayers )
    supercop_nextbot_copThatExists.alarmSound:SetSoundLevel( 0 )
    supercop_nextbot_copThatExists.alarmSound:Play()

end

function supercopNextbot_CopCanInvade()
    if not hasNavmesh() then
        print( "supercopNextbot_CopCanInvade: No navmesh, Generate/install one." )
        return false

    end

    if IsValid( supercop_nextbot_copThatExists ) then return false end

    setupCopRandomSpawnpoint()
    if not whereToSpawn then
        print( "supercopNextbot_CopCanInvade: Navmesh doesn't reach any map spawnpoints." )
        return false

    end

    if hook.Run( "supercop_nextbot_blockinvasion" ) == true then return false end

    return true

end

local invadedMessages = {
    "Supercop has invaded, hide your contraband...",
    "Supercop is on the beat, watch out tax evaders...",
    "Supercop has invaded, jaywalkers beware...",
    "Supercop has invaded. Time to pay your parking tickets...",
    "Supercop has invaded. Shouldn't have downloaded that car...",
    "Supercop has invaded. Litterers, think twice...",
    "Supercop is on duty. It's not illegal if he doesn't catch you...",
    "Supercop has invaded, so you might want to stick to the speed limit...",
    "Supercop has invaded, so reconsider your love for graffiti...",
    "Supercop has invaded - it's a bad day for unconventional yard sales...",
    "Supercop has invaded, maybe rethink the unauthorized lemonade stand...",

}

function supercopNextbot_CopInvade()
    if supercopNextbot_CopCanInvade() ~= true then return end

    if not whereToSpawn then return end
    local cop = ents.Create( "sb_advanced_nextbot_terminator_hunter_supercop" )
    if not IsValid( cop ) then
        print( "Supercop Failed to spawn." )
        return

    end
    cop:SetPos( whereToSpawn )
    cop:Spawn()

    supercop_nextbot_copThatExists = cop

    hook.Run( "supercop_nextbot_successfulinvasion" )
    supercopMessage( invadedMessages[ math.random( 1, #invadedMessages ) ] )
    timer.Simple( 0, function()
        supercopWarn()

    end )

    print( "Supercop Spawned:", cop )

    return cop

end

function supercopNextbot_Remove()
    if not IsValid( supercop_nextbot_copThatExists ) then print( "No supercop to remove." ) return end

    supercopMessage( "Supercop has been sent to the void..." )
    SafeRemoveEntity( supercop_nextbot_copThatExists )

end

local doneNoNavmeshPrint = nil

local theGamemode = engine.ActiveGamemode()
if theGamemode == "terrortown" then
    local spawnChance   = CreateConVar( "supercop_nextbot_ttt_invadechanceonroundstart",    15, bit.bor( FCVAR_ARCHIVE ), "Spawn chance on round start, 0 to never spawn, 100 to always spawn.", 0, 100 )
    local invadeDelay   = CreateConVar( "supercop_nextbot_ttt_invadedelay",                 15, bit.bor( FCVAR_ARCHIVE ), "How long after the round starts should supercop wait to invade, seconds.", 0, 60 * 20 )
    local oncePerMap    = CreateConVar( "supercop_nextbot_ttt_invadeonce",                  1, bit.bor( FCVAR_ARCHIVE ), "Only allow supercop to invade once per map.", 0, 1 )

    local doneInvade = nil

    hook.Add( "TTTBeginRound", "supercop_nextbot_trytospawn", function()
        timer.Simple( invadeDelay:GetInt(), function()
            local chance = spawnChance:GetFloat()
            if chance <= 0 then return end

            if not hasNavmesh() then
                if doneNoNavmeshPrint then return end
                doneNoNavmeshPrint = true
                supercopMessage( "Supercop cannot invade... No navmesh." )
                return

            end

            if doneInvade and oncePerMap:GetBool() then
                print( msgPrefix .. "LOG: Supercop tried to invade on round start twice in one map.\nBlocked by convar 'supercop_nextbot_ttt_invadeonce'" )
                return

            end

            local roll = math.random( 0, 100 )
            -- if roll ends up above chance, do not invade
            if roll >= chance then -- don't spawn
                print( msgPrefix .. "LOG: Supercop invasion on round start, blocked by random chance.\nRoll: " .. roll .. "\nRequired: < " .. chance .. "\nChange supercop_nextbot_ttt_invadechanceonroundstart to 100, to always invade." )
                return

            end

            if not supercopNextbot_CopCanInvade() then return end
            supercopNextbot_CopInvade()

            doneInvade = true

        end )
    end )
else
    local spawnChance       = CreateConVar( "supercop_nextbot_generic_invasionchance",   2, bit.bor( FCVAR_ARCHIVE ), "Chance for supercop to invade non-ttt sessions, rolled once every minute, 0 never spawns, 100, always.", 0, 100 )
    local invasionLength    = CreateConVar( "supercop_nextbot_generic_invasionlength",   15, bit.bor( FCVAR_ARCHIVE ), "How long in minutes, will supercop invade for? 0 to never despawn.", 0, 1000 )

    -- remove timer for editing file
    timer.Remove( "supercop_randomspawnchance" )
    timer.Create( "supercop_randomspawnchance", 60, 0, function()
        local chance = spawnChance:GetFloat()
        if chance <= 0 then return end

        if not hasNavmesh() then
            if doneNoNavmeshPrint then return end
            doneNoNavmeshPrint = true
            supercopMessage( "Supercop cannot invade... No navmesh." )
            return

        end

        if math.random( 0, 100 ) >= chance then return end
        if not supercopNextbot_CopCanInvade() then return end
        local cop = supercopNextbot_CopInvade()
        local spawnedTime = CurTime()
        cop.spawnedTime = spawnedTime

        timer.Simple( 60 * invasionLength:GetInt(), function()
            if not IsValid( supercop_nextbot_copThatExists ) then return end
            if not supercop_nextbot_copThatExists.spawnedTime then return end
            if supercop_nextbot_copThatExists.spawnedTime ~= spawnedTime then return end

            supercopNextbot_Remove()

        end )
    end )
end