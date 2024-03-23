supercop_nextbot_copSpawnpoints = supercop_nextbot_copSpawnpoints or {}

hook.Add( "PlayerInitialSpawn", "supercop_nextbot_storegenericspawnpoints", function( spawned )
    timer.Simple( 2, function()
        if not IsValid( spawned ) then return end
        if #supercop_nextbot_copSpawnpoints > 20 then return end
        if spawned:Health() <= 0 then return end

        table.insert( supercop_nextbot_copSpawnpoints, spawned:GetPos() )

    end )
end )

local whereToSpawn = nil

local function setupCopRandomSpawnpoint()
    if #supercop_nextbot_copSpawnpoints <= 0 then return end
    table.Shuffle( supercop_nextbot_copSpawnpoints )
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

local logPrefix = "[Supercop Nextbot|LOG|] "
local doLogs = CreateConVar( "supercop_nextbot_server_logs", 1, bit.bor( FCVAR_ARCHIVE ), "Do supercop console |LOG|s?", 0, 1 )
-- globul...
function supercopNextbot_SupercopLog( log )
    if doLogs:GetBool() ~= true then return end
    local logAppended = logPrefix .. log

    print( logAppended )

end

local msgPrefix = "[Supercop Nextbot] "
local doPrints = CreateConVar( "supercop_nextbot_server_prints", 1, bit.bor( FCVAR_ARCHIVE ), "Do supercop chat & hud prints?", 0, 1 )

local function supercopMessage( message )
    if doPrints:GetBool() ~= true then return end
    local msgAppended = msgPrefix .. message

    print( msgAppended )
    PrintMessage( HUD_PRINTCENTER, msgAppended )
    PrintMessage( HUD_PRINTTALK, msgAppended )

end

--globul
supercop_nextbot_copThatExists = nil

local doWarnAlarm = CreateConVar( "supercop_nextbot_server_invadingalarm", 1, bit.bor( FCVAR_ARCHIVE ), "Do manhack alarm when spawned?", 0, 1 )
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
        supercopNextbot_SupercopLog( "supercopNextbot_CopCanInvade: No navmesh, Generate/install one." )
        return false

    end

    if navmesh.IsGenerating() then return end

    if IsValid( supercop_nextbot_copThatExists ) then return false end

    setupCopRandomSpawnpoint()
    if not whereToSpawn then
        supercopNextbot_SupercopLog( "supercopNextbot_CopCanInvade: Navmesh doesn't reach any map spawnpoints." )
        return false

    end

    if hook.Run( "supercop_nextbot_blockinvasion" ) == true then return false end

    return true

end

function supercopNextbot_CopInvade()
    if supercopNextbot_CopCanInvade() ~= true then return end

    if not whereToSpawn then return end
    local cop = ents.Create( "sb_advanced_nextbot_terminator_hunter_supercop" )
    if not IsValid( cop ) then
        supercopNextbot_SupercopLog( "Supercop Failed to spawn." )
        return

    end
    cop:SetPos( whereToSpawn )
    cop:Spawn()

    supercop_nextbot_copThatExists = cop

    hook.Run( "supercop_nextbot_successfulinvasion" )
    timer.Simple( 0, function()
        supercopWarn()

    end )

    supercopNextbot_SupercopLog( "Supercop Spawned:", supercop_nextbot_copThatExists )

    return cop

end

function supercopNextbot_Remove()
    if not IsValid( supercop_nextbot_copThatExists ) then supercopNextbot_SupercopLog( "No supercop to remove." ) return end

    SafeRemoveEntity( supercop_nextbot_copThatExists )

    hook.Run( "supercop_nextbot_removed" )

end

local doneNoNavmeshPrint = nil

local theGamemode = engine.ActiveGamemode()
if theGamemode == "terrortown" then
    local spawnChance   = CreateConVar( "supercop_nextbot_ttt_invadechanceonroundstart",    10, bit.bor( FCVAR_ARCHIVE ), "Spawn chance on round start, 0 to never spawn, 100 to always spawn.", 0, 100 )
    local invadeDelay   = CreateConVar( "supercop_nextbot_ttt_invadedelay",                 15, bit.bor( FCVAR_ARCHIVE ), "How long after the round starts should supercop wait to invade, seconds.", 0, 60 * 20 )
    local oncePerMap    = CreateConVar( "supercop_nextbot_ttt_invadeonce",                  1, bit.bor( FCVAR_ARCHIVE ), "Only allow supercop to invade once per map.", 0, 1 )

    local doneInvade = nil

    hook.Add( "TTTBeginRound", "supercop_nextbot_trytospawn", function()
        timer.Simple( invadeDelay:GetInt(), function()
            local chance = spawnChance:GetFloat()
            if chance <= 0 then return end

            if #player.GetAll() <= 0 then return end

            if not hasNavmesh() then
                if doneNoNavmeshPrint then return end
                doneNoNavmeshPrint = true
                supercopMessage( "Supercop cannot invade... No navmesh." )
                return

            end

            if doneInvade and oncePerMap:GetBool() then
                supercopNextbot_SupercopLog( "Supercop tried to invade on round start twice in one map.\nBlocked by convar 'supercop_nextbot_ttt_invadeonce'" )
                return

            end

            local roll = math.Rand( 0, 100 )
            -- if roll ends up above chance, do not invade
            if roll >= chance then -- don't spawn
                supercopNextbot_SupercopLog( "Supercop invasion on round start, blocked by random chance.\nRoll: " .. math.Round( roll, 3 ) .. "\nRequired: < " .. chance .. "\nChange supercop_nextbot_ttt_invadechanceonroundstart to 100, to always invade." )
                return

            end

            if not supercopNextbot_CopCanInvade() then return end
            local cop = supercopNextbot_CopInvade()

            if not IsValid( cop ) then return end

            -- valid invade, tell players!
            supercopMessage( supercopNextbot_SupercopInvadedMessage() )
            supercopNextbot_SupercopLog( "Supercop has auto-invaded.\nRun the command: \"supercop_nextbot_ttt_invadechanceonroundstart 0\" To disable TTT auto-invasion" )

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

        if #player.GetAll() <= 0 then return end

        if not hasNavmesh() then
            if doneNoNavmeshPrint then return end
            doneNoNavmeshPrint = true
            -- send this to players in session because they're probably not gonna check console
            supercopMessage( "Supercop cannot invade... No navmesh." )
            return

        end

        if math.Rand( 0, 100 ) >= chance then return end
        if not supercopNextbot_CopCanInvade() then return end
        local cop = supercopNextbot_CopInvade()

        if not IsValid( cop ) then return end

        -- valid invade, tell players!
        supercopMessage( supercopNextbot_SupercopInvadedMessage() )
        supercopNextbot_SupercopLog( "Supercop has invaded.\nRun the command: \"supercop_nextbot_generic_invasionchance 0\" To disable auto-invasion" )

        local spawnedTime = CurTime()
        cop.spawnedTime = spawnedTime

        if invasionLength:GetInt() < 1 then
            supercopNextbot_SupercopLog( "\"Infinite\" invasion ENABLED!" )
            return

        end

        timer.Simple( 60 * invasionLength:GetInt(), function()
            if not IsValid( supercop_nextbot_copThatExists ) then return end
            if not supercop_nextbot_copThatExists.spawnedTime then return end
            if supercop_nextbot_copThatExists.spawnedTime ~= spawnedTime then return end

            supercopNextbot_Remove()
            supercopMessage( "Supercop has been sent to the void..." )

        end )
    end )
end

hook.Add( "PhysgunPickup", "supercop_nextbot_respect_physdisabled", function( _, pickedUp )
    if IsValid( pickedUp ) and pickedUp.PhysgunDisabled then return false end

end )