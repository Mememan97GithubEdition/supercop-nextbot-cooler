-- credit to https://steamcommunity.com/id/TakeTheBeansIDontCare/

local supercopSpawnSet = {
    name = "supercops_glee", -- unique name
    prettyName = "Anti-Citizen Experience",
    description = "Suspect, prepare to receive civil judgement.",
    difficultyPerMin = "default", -- difficulty per minute
    waveInterval = "default", -- time between spawn waves
    diffBumpWhenWaveKilled = "default", -- when there's <= 1 hunter left, the difficulty is permanently bumped by this amount
    startingBudget = "default", -- so budget isnt 0
    spawnCountPerDifficulty = "default", -- max of ten at 10 minutes
    startingSpawnCount = "default",
    maxSpawnCount = "default",
    maxSpawnDist = "default",
    roundStartSound = "ambient/alarms/manhack_alert_pass1.wav",
    roundEndSound = "ambient/alarms/citadel_alert_loop2.wav",
    chanceToBeVotable = 0.5,
    spawns = {
        {
            hardRandomChance = nil,
            name = "supercop",
            prettyName = "The Supercop",
            class = "terminator_nextbot_supercop",
            spawnType = "hunter",
            difficultyCost = { 5, 10 },
            countClass = "terminator_nextbot_supercop",
            postSpawnedFuncs = nil,
        },
    }
}

table.insert( GLEE_SPAWNSETS, supercopSpawnSet )