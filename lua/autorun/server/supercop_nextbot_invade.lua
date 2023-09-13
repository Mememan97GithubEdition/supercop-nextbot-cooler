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

local msgPrefix = "[Supercop Nextbot] "
local doPrints = CreateConVar( "supercop_nextbot_do_prints", 1, FCVAR_ARCHIVE, "Do supercop prints?", 0, 100 )

local function supercopMessage( message )
    if doPrints:GetBool() ~= true then return end
    local msgAppended = msgPrefix .. message

    PrintMessage( HUD_PRINTCONSOLE, msgAppended )
    PrintMessage( HUD_PRINTCENTER, msgAppended )
    PrintMessage( HUD_PRINTTALK, msgAppended )

end

local absolutelyCannotSpawn = nil
local copThatExists = nil

local doWarnAlarm = CreateConVar( "supercop_nextbot_do_invadingalarm", 1, FCVAR_ARCHIVE, "Do manhack alarm when spawned?", 0, 100 )
local function supercopWarn()
    if doWarnAlarm:GetBool() ~= true then return end
    local filterAllPlayers = RecipientFilter()
    filterAllPlayers:AddAllPlayers()

    if not IsValid( copThatExists ) then return end

    copThatExists.alarmSound = CreateSound( copThatExists, "ambient/alarms/manhack_alert_pass1.wav", filterAllPlayers )
    copThatExists.alarmSound:SetSoundLevel( 0 )
    copThatExists.alarmSound:Play()

end

function supercopNextbot_CopCanInvade()
    if absolutelyCannotSpawn then return false end
    if #navmesh.GetAllNavAreas() <= 0 then
        supercopMessage( "Supercop cannot invade... No navmesh." )
        absolutelyCannotSpawn = true
        return false

    end

    if IsValid( copThatExists ) then return false end

    setupCopRandomSpawnpoint()
    if not whereToSpawn then return false end

    if hook.Run( "supercop_nextbot_blockinvasion" ) == true then return end

    return true

end

local invadedMessages = {
    "Supercop has invaded...",
    "Supercop is here to lay down the law...",
    "Supercop has arrived to uphold justice...", 
    "Crime rates about to decrease...Supercop is here...",
    "Beware criminals, Supercop has invaded...",
    "Supercop is now on duty...",
    "Criminals, Your worst nightmare has arrived, Supercop is here...",
    "Supercop has pulled up to maintain law and order...",
    "Supercop has taken charge of the situation...",
    "Buckle up, Supercop has invaded...",

}

function supercopNextbot_CopInvade()
    if not whereToSpawn then return end
    local cop = ents.Create( "sb_advanced_nextbot_terminator_hunter_supercop" )
    if not IsValid( cop ) then return end
    cop:SetPos( whereToSpawn )
    cop:Spawn()

    copThatExists = cop

    hook.Run( "supercop_nextbot_successfulinvasion" )
    supercopMessage( invadedMessages[ math.random( 1, #invadedMessages ) ] )
    timer.Simple( 0, function()
        supercopWarn()

    end )

    return cop

end

function supercopNextbot_Remove()
    if IsValid( copThatExists ) then
        supercopMessage( "Supercop has been sent to the void..." )

    end
    SafeRemoveEntity( copThatExists )

end

local theGamemode = engine.ActiveGamemode()
if theGamemode == "terrortown" then
    local spawnChance   = CreateConVar( "supercop_nextbot_ttt_invadechanceonroundstart",    15, FCVAR_ARCHIVE, "Spawn chance on round start, 0 to never spawn, 100 to always spawn.", 0, 100 )
    local invadeDelay   = CreateConVar( "supercop_nextbot_ttt_invadedelay",                 15, FCVAR_ARCHIVE, "How long after the round starts should supercop wait to invade, seconds.", 0, 60 * 20 )
    local oncePerMap    = CreateConVar( "supercop_nextbot_ttt_invadeonce",                  1, FCVAR_ARCHIVE, "Only allow supercop to invade once per map.", 0, 1 )

    local doneInvade = nil

    hook.Add( "TTTBeginRound", "supercop_nextbot_trytospawn", function()
        timer.Simple( invadeDelay:GetInt(), function()
            local chance = spawnChance:GetFloat()
            if chance <= 0 then return end

            if doneInvade and oncePerMap:GetBool() then
                PrintMessage( HUD_PRINTCONSOLE, msgPrefix .. "LOG: Supercop tried to invade twice in one map. blocked by convar 'supercop_nextbot_ttt_invadeonce'" )
                return

            end

            local rand = math.random( 1, 100 )
            -- if rand ends up above chance, do not invade
            if chance ~= 100 and rand >= chance then
                PrintMessage( HUD_PRINTCONSOLE, msgPrefix .. "LOG: Supercop did not invade. \nRoll: " .. rand .. "\nRequired: < " .. chance )
                return

            end

            if not supercopNextbot_CopCanInvade() then return end
            supercopNextbot_CopInvade()

            doneInvade = true

        end )
    end )
else
    local spawnChance       = CreateConVar( "supercop_nextbot_generic_invasionchance",   2, FCVAR_ARCHIVE, "Chance for supercop to invade, rolled once every minute, 0 never spawns, 100, always.", 0, 100 )
    local invasionLength    = CreateConVar( "supercop_nextbot_generic_invasionlength",   15, FCVAR_ARCHIVE, "How long in minutes, will supercop invade for? 0 to never despawn.", 0, 1000 )

    -- remove timer for editing file
    timer.Remove( "supercop_randomspawnchance" )
    timer.Create( "supercop_randomspawnchance", 60, 0, function()
        local chance = spawnChance:GetFloat()
        if chance <= 0 then return end
        if not supercopNextbot_CopCanInvade() then return end

        if math.random( 1, 100 ) >= chance then return end
        supercopNextbot_CopInvade()

        timer.Simple( 60 * invasionLength:GetInt(), function()
            supercopNextbot_Remove()

        end )
    end )
end