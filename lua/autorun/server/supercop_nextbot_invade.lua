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

local invadedMessages = {
    -- random
    "Supercop has invaded, jaywalkers BEware...",
    "Supercop has invaded.... Shouldn't have downloaded that car...",
    "Supercop is on duty. It's not illegal if he doesn't catch you...",
    "Supercop has invaded, should've stuck to the speed limit...",
    "Supercop has entered the server. The physics gun isn't mightier than his law...",
    "Supercop has invaded. Remember folks, unlicensed fall damage is a crime...",
    "Supercop has invaded. Propsurf won't save you...",
    "Supercop has invaded. Get to the models/props_phx/misc/bunker01.mdl!!",
    "Supercop has invaded - Should've kept your dupes up to spec...",
    "Supercop has invaded. Why? Too many watermelons...",
    "Supercop's lua has started. Problem is, you're overflowing his stack.",
    "Supercop is on duty. 'Friendly fire' just became a 'friendly' felony...",
    "Supercop has invaded. Get to to the bathtub car!!!",
    "Supercop has invaded. He's friendly!",
    "Supercop has arrived, hope your contraptions don't violate any health and safety codes...",
    "Supercop has invaded. Hope your builds are up to OSHA standards...",
    "Supercop has logged in... who needs ULX when you have bullets?",
    "Supercop has invaded. He's always behind you...",
    "Supercop has arrived. No insurance on your flying bathtub? That's a ticket...",
    "Supercop has invaded. Beware: He knows you stole your Garry NFTs...",
    "Supercop has invaded. Beware: He knows where you've hidden your stash of garry NFTS...",
    "Supercop has invaded. Beware: GMAN ratted out your NFTS of garry's luscious locks...",
    "Supercop is on duty. Your prop block won't do you much good now...",
    "Supercop has invaded. Shouldn't have cheated those achievements in...",
    "Supercop's in the server. Your very... classy \"spaceship\" probably got the attention of the neighbors...",
    "Supercop has invaded. Better bolt your doors, pray your props aren't breakable...",
    "Supercop is online. Best hope your contraption can outrun the law...",
    "Supercop has entered. Tricks are nice, but can't trick a bullet...",
    "Supercop is in pursuit. His bodycam is off...",
    "Supercop is in pursuit. His bodycam is \"out of battery\"...",
    -- rdm jokes
    "Supercop has landed. Familiar with the term 'RDM', right?",
    "Supercop has invaded. Random death match? More like death penalty...",
    "Supercop has invaded, and he's going to fight RDM with RDM...",
    "Supercop is laying down the law, and propsurf gets the Death penalty.",
    "Supercop has rolled up. And he doesn't care about \"R D M\".",
    "Supercop's invading, Deathmatch is gonna get alot less random...",
    -- server rules/admin meta jokes
    "Supercop has invaded. Should've read each of the 42 rules...",
    "Supercop's invading, Better beg the admins to remove him...",
    "Supercop's invading, And he doesn't read the rules...",
    "Supercop's invading, He's a professional rule lawyer...",
    "Supercop has invaded. His secret weapon? He read the rules...",
    "Supercop has invaded. His secret weapon? He paid the admins for VIP...",
    "Supercop has invaded. His secret weapon? He slipped the admins a crisp 20...",
    -- referencing citizen quotes
    "Supercop has invaded. He's got a good feeling about this...",
    "Supercop has invaded. Shouldn't have dreamed about cheese...",
    "Supercop has invaded. He's talkin to you...",
    "Supercop has invaded. And about time, too...",
    "Supercop has invaded. He's all done selling insurance...",
    "Supercop has invaded. He's gonna make a stalker out of you...",
    "Supercop has invaded. It's just one of those days...",
    "Supercop has invaded. This is bad...",
    "Supercop has invaded. What now?",
    "Supercop has invaded. Try not to dwell on it...",
    "Supercop has invaded. He'll put it on your tombstone...",
    "Supercop has invaded. There's a first time for everything...",
    "Supercop has invaded. He's not one to even the odds...",
    "Supercop has invaded... Finally!",
    "Supercop has invaded. Get down!",
    "Supercop has invaded! Get the hell out of here!",
    "Good god... Supercop has invaded!",
    "Supercop has invaded! Spread the word...",
    "We're done for... Supercop has invaded!",
    "Supercop has invaded! What a way to go...",
    "Supercop has invaded! Don't take it personally...",
    -- kliener quotes
    "Supercop has invaded! Where did he get to!",
    "Supercop has invaded! It'll be an hour before you coax him out!",
    "Dear me... Supercop has invaded!",
    "Oh fiddlesticks... Supercop has invaded!",
    "There seems to be some kind of interference... Supercop has invaded!",
    "Supercop has invaded! And at such an inopportune time!",
    -- g guy
    "Rise and shine, supercop, rise, and shine...",
    -- food
    "Supercop is in pursuit. Cold, hard justice is his beverage of choice...",
    "Supercop has invaded. His coffee was great this morning!",
    "Supercop has invaded. His coffee tasted like mine tailings...",
    "Supercop has invaded. His coffee reminded him of his childhood!",
    "Supercop has invaded. His coffee reminded him of his adulthood...",
    "Supercop has invaded. His coffee is single origin!",
    "Supercop has invaded. His coffee pairs great with doughnuts!",
    "Supercop has invaded. His coffee tasted like iron...",
    "Supercop has invaded. His coffee was decaf...",
    "Supercop has invaded. His coffee creamer was spoiled...",
    "Supercop has invaded. Someone tried to make him tea...",
    "Supercop has invaded. His favourite donuts are chocolate spinkle!",
    "Supercop has invaded. You better hope he didn't miss the last doughnut...",
    -- cities
    "Supercop has invaded. He just transferred from portland...",
    "Supercop has invaded. He just transferred from cleaveland...",
    "Supercop has invaded. He just transferred from new york...",
    "Supercop has invaded. He just transferred from detroit...",
    "Supercop has invaded. He just transferred from LA...",
    "Supercop has invaded. He just transferred from san francisco...",
    "Supercop has invaded. He just transferred from vancouver... washington...",
    "Supercop has invaded. He just transferred from moscow...",
    -- tutorials
    "Supercop has invaded. GET TO THE ELEVATORS!",
    "Supercop has invaded. Better pray the ladders aren't navmeshed!",
    "Supercop has invaded. Better pray this navmesh is unpolished...",
    "Supercop is on deck. Your tool gun won't change the law...",
    "Supercop is on deck. Your toolgun isn't strong enough...",
    "Supercop is on duty. Sorry, your toolgun must be version 25 or higher to remove him!",
    "Supercop has invaded. Please insert card to upgrade your physics gun to version 25!",
    "Supercop has invaded. Sorry, your physics gun is on the free plan...",

}

local invadedMessagesToPrint = {}

local function supercopInvadedMessage()
    if #invadedMessagesToPrint <= 1 then
        invadedMessagesToPrint = table.Copy( invadedMessages )

    end

    return table.remove( invadedMessagesToPrint, math.random( 1, #invadedMessagesToPrint ) )

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

local aiDisabled = GetConVar( "ai_disabled" )
local aiIgnorePlayers = GetConVar( "ai_ignoreplayers" )

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
            if aiDisabled:GetBool() then return end
            if aiIgnorePlayers:GetBool() then return end

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
            supercopMessage( supercopInvadedMessage() )
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
        supercopMessage( supercopInvadedMessage() )
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