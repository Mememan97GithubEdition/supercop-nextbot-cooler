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
local function supercopLog( log )
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
        supercopLog( "supercopNextbot_CopCanInvade: No navmesh, Generate/install one." )
        return false

    end

    if IsValid( supercop_nextbot_copThatExists ) then return false end

    setupCopRandomSpawnpoint()
    if not whereToSpawn then
        supercopLog( "supercopNextbot_CopCanInvade: Navmesh doesn't reach any map spawnpoints." )
        return false

    end

    if hook.Run( "supercop_nextbot_blockinvasion" ) == true then return false end

    return true

end

local invadedMessages = {
    "Supercop has invaded, jaywalkers BEware...",
    "Supercop has invaded.... Shouldn't have downloaded that car...",
    "Supercop is on duty. It's not illegal if he doesn't catch you...",
    "Supercop has invaded, should've stuck to the speed limit...",
    "Supercop has entered the server. The physics gun isn't mightier than his law...",
    "Supercop has landed. Familiar with the term 'RDM', right?",
    "Supercop has invaded. Should've read each of the 42 rules...",
    "Supercop has invaded. Remember folks, unlicensed fall damage is a crime...",
    "Supercop has invaded. Propsurf won't save you...",
    "Supercop has invaded. Get to the models/props_phx/misc/bunker01.mdl!!",
    "Supercop has invaded. Random death match? More like death penalty...",
    "Supercop has invaded - Should've kept your dupes up to spec...",
    "Supercop has invaded. Why? Too many watermelons...",
    "Supercop is on duty. 'Friendly fire' just became a 'friendly' felony...",
    "Supercop has invaded, and he's going to fight RDM with RDM...",
    "Supercop is laying down the law, and propsurf gets the Death penalty.",
    "Supercop has rolled up. And he doesn't care about \"R D M\".",
    "Supercop's lua has started. Problem is, you're overflowing his stack.",
    "Supercop's invading, Better beg the admins to remove him...",
    "Supercop's invading, Deathmatch is gonna get alot less random...",
    "Supercop's invading, And he doesn't read the rules...",
    "Supercop has invaded. His secret weapon? He read the rules...",
    "Supercop has invaded. His secret weapon? He paid the admins for VIP...",
    "Supercop has invaded. His secret weapon? He slipped the admins a crisp 20...",
    "Supercop has invaded. GET TO THE ELEVATORS!",
    "Supercop has invaded. Better pray the ladders aren't navmeshed!",
    "Supercop has invaded. Better pray this navmesh is unpolished...",
    "Supercop has invaded. He's got a good feeling about this...",
    "Supercop has invaded. His coffee was great this morning!",
    "Supercop has invaded. Get to to the bathtub car!!!",
    "Supercop has invaded. He's friendly!",
    "Supercop has arrived, hope your contraptions don't violate any health and safety codes...",
    "Supercop has invaded. Hope your builds are up to OSHA standards...",
    "Supercop has logged in... who needs ULX when you have bullets?",
    "Supercop has invaded. He's always behind you...",
    "Supercop has arrived. No insurance on your flying bathtub? That's a ticket...",
    "Supercop has invaded. Beware: He knows where you've hidden your stash of garry NFTS...",
    "Supercop has invaded. Beware: GMAN ratted out your NFTS of garry's luscious locks...",
    "Supercop is on deck. Your tool gun won't rewrite the rule book...",
    "Supercop is on duty. Your prop block won't do you much good now...",
    "Supercop has invaded. Shouldn't have cheated those achievements in...",
    "Supercop's in the server. Launching off into space is a severe violation...",
    "Supercop is in pursuit. Cold, hard justice is his beverage of choice...",
    "Supercop has invaded. Better bolt your doors, pray your props aren't breakable...",
    "Supercop is online. Best hope your contraption can outrun the law...",
    "Supercop has entered. Tricks are nice, but can't trick a bullet...",

}

function supercopNextbot_CopInvade()
    if supercopNextbot_CopCanInvade() ~= true then return end

    if not whereToSpawn then return end
    local cop = ents.Create( "sb_advanced_nextbot_terminator_hunter_supercop" )
    if not IsValid( cop ) then
        supercopLog( "Supercop Failed to spawn." )
        return

    end
    cop:SetPos( whereToSpawn )
    cop:Spawn()

    supercop_nextbot_copThatExists = cop

    hook.Run( "supercop_nextbot_successfulinvasion" )
    timer.Simple( 0, function()
        supercopWarn()

    end )

    supercopLog( "Supercop Spawned:", cop )

    return cop

end

function supercopNextbot_Remove()
    if not IsValid( supercop_nextbot_copThatExists ) then supercopLog( "No supercop to remove." ) return end

    SafeRemoveEntity( supercop_nextbot_copThatExists )

    hook.Run( "supercop_nextbot_removed" )

end

local doneNoNavmeshPrint = nil

local aiDisabled = GetConVar( "ai_disabled" )
local aiIgnorePlayers = GetConVar( "ai_ignoreplayers" )

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

            if aiDisabled:GetBool() then return end
            if aiIgnorePlayers:GetBool() then return end

            if not hasNavmesh() then
                if doneNoNavmeshPrint then return end
                doneNoNavmeshPrint = true
                supercopMessage( "Supercop cannot invade... No navmesh." )
                return

            end

            if doneInvade and oncePerMap:GetBool() then
                supercopLog( "Supercop tried to invade on round start twice in one map.\nBlocked by convar 'supercop_nextbot_ttt_invadeonce'" )
                return

            end

            local roll = math.Rand( 0, 100 )
            -- if roll ends up above chance, do not invade
            if roll >= chance then -- don't spawn
                supercopLog( "Supercop invasion on round start, blocked by random chance.\nRoll: " .. math.Round( roll, 3 ) .. "\nRequired: < " .. chance .. "\nChange supercop_nextbot_ttt_invadechanceonroundstart to 100, to always invade." )
                return

            end

            if not supercopNextbot_CopCanInvade() then return end
            local cop = supercopNextbot_CopInvade()

            if not IsValid( cop ) then return end

            -- valid invade, tell players!
            supercopMessage( invadedMessages[ math.random( 1, #invadedMessages ) ] )
            supercopLog( "Supercop has auto-invaded.\nRun the command: \"supercop_nextbot_ttt_invadechanceonroundstart 0\" To disable TTT auto-invasion" )

            doneInvade = true

        end )
    end )
else
    local spawnChance       = CreateConVar( "supercop_nextbot_generic_invasionchance",   3, bit.bor( FCVAR_ARCHIVE ), "Chance for supercop to invade non-ttt sessions, rolled once every minute, 0 never spawns, 100, always.", 0, 100 )
    local invasionLength    = CreateConVar( "supercop_nextbot_generic_invasionlength",   15, bit.bor( FCVAR_ARCHIVE ), "How long in minutes, will supercop invade for? 0 to never despawn.", 0, 1000 )

    -- remove timer for editing file
    timer.Remove( "supercop_randomspawnchance" )
    timer.Create( "supercop_randomspawnchance", 60, 0, function()
        local chance = spawnChance:GetFloat()
        if chance <= 0 then return end

        if aiDisabled:GetBool() then return end
        if aiIgnorePlayers:GetBool() then return end

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
        supercopMessage( invadedMessages[ math.random( 1, #invadedMessages ) ] )
        supercopLog( "Supercop has invaded.\nRun the command: \"supercop_nextbot_generic_invasionchance 0\" To disable auto-invasion" )

        local spawnedTime = CurTime()
        cop.spawnedTime = spawnedTime

        if invasionLength:GetInt() < 1 then
            supercopLog( "\"Infinite\" invasion ENABLED!" )
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

local _IsValid = IsValid

hook.Add( "CanTool", "supercop_nextbot_blocktooling", function( _, tr )
    if tr.Hit and _IsValid( tr.Entity ) and tr.Entity == supercop_nextbot_copThatExists then return false end

end )

hook.Add( "PhysgunPickup", "supercop_nextbot_blockphysgun", function( _, pickedUp )
    if _IsValid( pickedUp ) and pickedUp == supercop_nextbot_copThatExists then return false end

end )

hook.Add( "CanProperty", "supercop_nextbot_blockcontext", function( _, _, toProperty )
    if _IsValid( toProperty ) and toProperty == supercop_nextbot_copThatExists then return false end

end )