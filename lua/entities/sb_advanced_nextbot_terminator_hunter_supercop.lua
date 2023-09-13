AddCSLuaFile()

ENT.Base = "sb_advanced_nextbot_terminator_hunter"
DEFINE_BASECLASS( ENT.Base )
ENT.PrintName = "The Supercop"
ENT.Spawnable = false
list.Set( "NPC", "sb_advanced_nextbot_terminator_hunter_supercop", {
    Name = "The Supercop",
    Class = "sb_advanced_nextbot_terminator_hunter_supercop",
    Category = "SB Advanced Nextbots",
} )

if CLIENT then
    language.Add( "sb_advanced_nextbot_terminator_hunter_supercop", ENT.PrintName )
    return

end

ENT.JumpHeight = 70
ENT.MaxJumpToPosHeight = ENT.JumpHeight
ENT.DefaultStepHeight = 18
ENT.StandingStepHeight = ENT.DefaultStepHeight * 1 -- used in crouch toggle in motionoverrides
ENT.CrouchingStepHeight = ENT.DefaultStepHeight * 0.9
ENT.StepHeight = ENT.StandingStepHeight
ENT.PathGoalToleranceFinal = 35
ENT.SpawnHealth = 1000000
ENT.AimSpeed = 150
ENT.WalkSpeed = 50
ENT.RunSpeed = 100
ENT.AccelerationSpeed = 1000
ENT.DeathDropHeight = 50000000
ENT.InformRadius = 0

ENT.DontDropPrimary = true
ENT.LookAheadOnlyWhenBlocked = true
ENT.isTerminatorHunterChummy = false
ENT.DoMetallicDamage = true
ENT.ReallyStrong = false -- no metallic jumping sounds
ENT.alwaysManiac = true -- fights other terminator based npcs, or other supercops
ENT.HasFists = true
ENT.IsTerminatorSupercop = true
ENT.NextSpokenLine = 0

ENT.Models = { "models/player/police.mdl" }

local vecFiveDown = Vector( 0, 0, -5 )

-- copied the original function
function ENT:MakeFootstepSound( volume, surface )
    local foot = self.m_FootstepFoot
    self.m_FootstepFoot = not foot
    self.m_FootstepTime = CurTime()

    local tr

    if not surface then
        tr = util.TraceEntity({
            start = self:GetPos(),
            endpos = self:GetPos() + vecFiveDown,
            filter = self,
            mask = self:GetSolidMask(),
            collisiongroup = self:GetCollisionGroup(),

        }, self )

        surface = tr.SurfaceProps
    end

    if surface or ( tr and tr.Hit ) then
        local copStep = foot and "NPC_MetroPolice.RunFootstepRight" or "NPC_MetroPolice.RunFootstepLeft"

        self:EmitSound( copStep )

    end

    if not surface then return end

    local surfaceDat = util.GetSurfaceData(surface)
    if not surfaceDat then return end

    local sound = foot and surfaceDat.stepRightSound or surfaceDat.stepLeftSound

    if sound then
        local pos = self:GetPos()

        local filter = RecipientFilter()
        filter:AddPAS( pos )

        if not self:OnFootstep( pos, foot, sound, volume, filter ) then
            self.stepSoundPatches = self.stepSoundPatches or {}

            local stepSound = self.stepSoundPatches[sound]
            if not stepSound then
                stepSound = CreateSound( self, sound, filter )
                self.stepSoundPatches[sound] = stepSound
            end
            stepSound:Stop()
            stepSound:Play()

        end
    end
end

function ENT:DoHardcodedRelations()
    self:SetClassRelationship( "player", D_HT,1 )
    self:SetClassRelationship( "npc_lambdaplayer", D_HT,1 )
    self:SetClassRelationship( "sb_advanced_nextbot_terminator_hunter", D_HT, 1 )
    self:SetClassRelationship( "sb_advanced_nextbot_terminator_hunter_slower", D_HT, 1 )
    self:SetClassRelationship( "sb_advanced_nextbot_soldier_follower", D_HT )
    self:SetClassRelationship( "sb_advanced_nextbot_soldier_friendly", D_HT )
    self:SetClassRelationship( "sb_advanced_nextbot_soldier_hostile", D_HT )

end

local spottedEnemy = {
    "METROPOLICE_MOVE_ALONG_A0",
    "METROPOLICE_BACK_UP_A0",
    "METROPOLICE_BACK_UP_B0",
    "METROPOLICE_BACK_UP_C0",
    "METROPOLICE_IDLE_HARASS_PLAYER2",

}

local approachingEnemyVisible = {
    "METROPOLICE_IDLE_HARASS_PLAYER0",
    "METROPOLICE_IDLE_HARASS_PLAYER1",
    "METROPOLICE_IDLE_HARASS_PLAYER3",
    "METROPOLICE_IDLE_HARASS_PLAYER4",

    "METROPOLICE_MOVE_ALONG_A1",
    "METROPOLICE_MOVE_ALONG_A2",

    "METROPOLICE_MOVE_ALONG_B1",

    "METROPOLICE_MOVE_ALONG_C1",
    "METROPOLICE_MOVE_ALONG_C2",
    "METROPOLICE_MOVE_ALONG_C3",

    "METROPOLICE_BACK_UP_A1",
    "METROPOLICE_BACK_UP_A2",

    "METROPOLICE_BACK_UP_B1",

    "METROPOLICE_BACK_UP_C1",
    "METROPOLICE_BACK_UP_C3",

}

local weaponWarn = {
    "METROPOLICE_BACK_UP_C3",
    "METROPOLICE_MOVE_ALONG_C0",
    "METROPOLICE_MOVE_ALONG_C3",
    "METROPOLICE_BACK_UP_C4",
    "METROPOLICE_MONST_CITIZENS0",

}

local approachingEnemyObscured = {
    "METROPOLICE_LOST_LONG0",
    "METROPOLICE_LOST_LONG1",
    "METROPOLICE_LOST_LONG2",
    "METROPOLICE_LOST_LONG3",
    "METROPOLICE_LOST_LONG4",
    "METROPOLICE_LOST_LONG5",

}

local playerDead = {
    "METROPOLICE_MOVE_ALONG_B0",

    "METROPOLICE_KILL_PLAYER0",
    "METROPOLICE_KILL_PLAYER1",
    "METROPOLICE_KILL_PLAYER2",
    "METROPOLICE_KILL_PLAYER3",
    "METROPOLICE_KILL_PLAYER4",
    "METROPOLICE_KILL_PLAYER5",

    "METROPOLICE_KILL_CITIZENS0",
    "METROPOLICE_KILL_CITIZENS1",
    "METROPOLICE_KILL_CITIZENS2",
    "METROPOLICE_KILL_CITIZENS3",

}

local playerUnreachBegin = {
    "METROPOLICE_HIT_BY_PHYSOBJECT2",

}

function ENT:GetDesiredEnemyRelationship( ent )
    local disp = D_HT
    local theirdisp = D_HT
    local priority = 1000

    if ent:GetClass() == self:GetClass() then
        disp = D_LI
        theirdisp = D_LI

    end

    if ent:IsPlayer() then
        priority = 1
    elseif ent:IsNPC() or ent:IsNextBot() then
        local memories = {}
        if self.awarenessMemory then
            memories = self.awarenessMemory
        end
        local key = self:getAwarenessKey( ent )
        local memory = memories[key]
        if memory == MEMORY_WEAPONIZEDNPC then
            priority = priority + -300
        else
            disp = D_NU
            --print("boringent" )
            priority = priority + -100
        end
    end

    return disp,priority,theirdisp
end

local beatinStickClass = "weapon_sb_supercopstunstick"
local olReliableClass = "weapon_sb_supercoprevolver"

ENT.TERM_FISTS = beatinStickClass

function ENT:PlaySentence( sentenceIn )
    if self.NextSpokenLine > CurTime() then return end

    local sentence

    if istable( sentenceIn ) then
        sentence = sentenceIn[ math.random( 1, #sentenceIn ) ]

    elseif isstring( sentenceIn ) then
        sentence = sentenceIn

    end

    if not sentence then return end

    if isstring( self.lastSpokenSentence ) and sentence == self.lastSpokenSentence then return end

    self.lastSpokenSentence = sentence

    EmitSentence( sentence, self:GetShootPos(), self:EntIndex(), CHAN_AUTO, 1, 80, 0, 100 )

    local duration = SentenceDuration( sentence )
    self.NextSpokenLine = CurTime() + duration + 0.2

end

function ENT:SpeakLine( line )
    self:EmitSound( line, 85, 100, 1, CHAN_AUTO )

end


hook.Add( "terminator_engagedenemywasbad", "supercop_killedenemy", function( self, enemyLost )
    if not self.IsTerminatorSupercop then return end
    if not IsValid( enemyLost ) then return end
    if enemyLost:Health() <= 0 then
        -- secret, funny pick up that can line
        if math.random( 0, 100 ) <= 5 and math.random( 0, 100 ) <= 15 and self.NextPickupTheCanLine < CurTime() then
            self.NextPickupTheCanLine = CurTime() + 55
            self.NextSpokenLine = CurTime() + 4
            timer.Simple( 1.5, function()
                if not IsValid( self ) then return end
                self:SpeakLine( "npc/metropolice/vo/pickupthecan3.wav" )

            end )

            timer.Simple( 2.75, function()
                if not IsValid( self ) then return end
                self:SpeakLine( "npc/metropolice/vo/chuckle.wav" )

            end )
        else
            self:PlaySentence( playerDead )

        end
    end
end )

-- re-override terminator's aimvector code
function ENT:GetAimVector()
    local dir = self:GetEyeAngles():Forward()

    if self:HasWeapon() then
        local deg = 0.01
        local active = self:GetActiveLuaWeapon()
        if isfunction( active.GetNPCBulletSpread ) then
            deg = active:GetNPCBulletSpread( self:GetCurrentWeaponProficiency() )
            deg = math.sin( math.rad( deg ) )
        end

        dir:Add( Vector( math.Rand( -deg, deg ), math.Rand( -deg, deg ),math.Rand( -deg, deg ) ) )
    end

    return dir
end

local spawnProtectionLength     = CreateConVar( "supercop_nextbot_spawnprot_copspawn",  10, bit.bor( FCVAR_ARCHIVE ), "Bot won't shoot until it's been alive for this long", 0, 60 )
local plyspawnProtectionLength  = CreateConVar( "supercop_nextbot_spawnprot_ply",       5, bit.bor( FCVAR_ARCHIVE ), "Don't shoot players until they've been alive for this long.", 0, 60 )

ENT.SupercopEquipRevolverDist = 350
ENT.EquipDistRampup = 15
ENT.SupercopUnequipRevolverDist = 900
ENT.SupercopBeatingStickDist = 125
ENT.SupercopBlockOlReliable = 0
ENT.SupercopBlockShooting = 0
ENT.NextPickupTheCanLine = 0

local _CurTime = CurTime

hook.Add( "PlayerSpawn", "supercop_plyspawnprotection", function( spawned )
    spawned.Supercop_SpawnProtection = _CurTime() + plyspawnProtectionLength:GetInt()

end )

function ENT:AdditionalInitialize()
    self:Give( "weapon_sb_supercoprevolver" )
    local spawnProt = spawnProtectionLength:GetInt()
    self.SupercopJustspawnedBlockShooting = _CurTime() + spawnProt
    self.SupercopJustspawnedBlockBeatstick = _CurTime() + ( spawnProt * 0.25 )

end

local supercopJog = CreateConVar( "supercop_nextbot_jog", 0, bit.bor( FCVAR_ARCHIVE ), "Should supercop jog?.", 0, 1 )

function ENT:GetFootstepSoundTime()
    local vel2d = self.loco:GetVelocity():Length2D()
    return 1000 + -vel2d * 6.5

end

function ENT:DoTasks()
    self.TaskList = {
        ["shooting_handler"] = {
            OnStart = function( self, data )
            end,
            BehaveUpdate = function(self,data,interval)
                local enemy = self:GetEnemy()
                local wep = self:GetActiveLuaWeapon() or self:GetActiveWeapon()
                -- edge case
                if not IsValid( wep ) then
                    self:shootAt( self.LastEnemyShootPos )
                    return

                end

                local moving = self:primaryPathIsValid()
                local doingBeatinStick = wep:GetClass() == beatinStickClass
                local closeOrNotMoving = self.DistToEnemy < self.SupercopEquipRevolverDist or not moving
                local notBlockShooting = self.SupercopBlockShooting < _CurTime()
                local nextWeaponPickup = self.terminator_NextWeaponPickup or 0

                if self.DistToEnemy < self.SupercopBeatingStickDist and self.NothingOrBreakableBetweenEnemy then
                    if not doingBeatinStick and notBlockShooting and nextWeaponPickup < _CurTime() then
                        self.PreventShooting = nil
                        self.DoHolster = nil
                        self:Give( beatinStickClass )
                        self.SupercopBlockShooting = _CurTime() + 0.3
                        self:PlaySentence( "METROPOLICE_ACTIVATE_BATON" .. math.random( 0, 2 ) )
                        self.SupercopBlockOlReliable = _CurTime() + math.Rand( 2, 3 )

                    end

                elseif doingBeatinStick then
                    if notBlockShooting and nextWeaponPickup < CurTime() and self.SupercopBlockOlReliable < CurTime() then
                        self:Give( olReliableClass )
                        self.SupercopBlockShooting = _CurTime() + 0.8

                    end
                elseif self.DoHolster and closeOrNotMoving then
                    self.DoHolster = nil
                    self:PlaySentence( weaponWarn )

                    self.SupercopBlockShooting = math.max( self.SupercopBlockShooting, _CurTime() + 1.5 )
                    self.PreventShooting = nil

                    local increased = self.SupercopEquipRevolverDist + self.EquipDistRampup
                    increased = math.Clamp( increased, 0, self.SupercopUnequipRevolverDist + -100 )
                    self.SupercopEquipRevolverDist = increased

                elseif self.DistToEnemy > self.SupercopUnequipRevolverDist and moving and notBlockShooting then
                    self.DoHolster = true
                    self.PreventShooting = true

                end

                local neededOrRandReload = ( wep:Clip1() < wep:GetMaxClip1() / 2 ) or ( wep:Clip1() < wep:GetMaxClip1() and math.random( 1, 100 ) < 2 )

                if self.DoHolster ~= self.OldDoHolster and wep:Clip1() == wep:GetMaxClip1() then
                    if self.DoHolster then
                        wep:SetWeaponHoldType( "passive" )

                    else
                        wep:SetWeaponHoldType( "revolver" )

                    end
                    self.OldDoHolster = self.DoHolster

                end
                local blockShooting = self.DoHolster or self.PreventShooting or not self.NothingOrBreakableBetweenEnemy or self.SupercopBlockShooting > _CurTime()
                local toAimAt = self.LastEnemyShootPos
                if self.IsSeeEnemy then -- i mean it has wallhacks, but this makes it look like it doesn't 
                    toAimAt = self:EntShootPos( enemy )

                end

                if wep:Clip1() <= 0 and wep:GetMaxClip1() > 0 then
                    self:WeaponReload()

                elseif IsValid( enemy ) and not blockShooting then
                    local enemySpawnProtEnds = enemy.Supercop_SpawnProtection or 0
                    local enemyIsSpawnProtected = enemySpawnProtEnds > _CurTime()

                    if doingBeatinStick then
                        self:shootAt( toAimAt, true )
                        -- beating stick gets a shorter cooldown after bot spawned, and ignores per-player spawnprotection
                        if ( self.DistToEnemy < wep.Range * 1.25 ) and self.SupercopJustspawnedBlockBeatstick < _CurTime() then
                            self:WeaponPrimaryAttack()

                        end
                    else
                        -- dont shoot if bot just spawned, or enemy just spawned
                        local protected = ( self.SupercopJustspawnedBlockShooting > _CurTime() ) or enemyIsSpawnProtected
                        self:shootAt( toAimAt, protected )

                    end
                elseif wep:GetMaxClip1() > 0 and neededOrRandReload then
                    self:WeaponReload()

                else
                    self:shootAt( toAimAt, true )

                end
            end,
            StartControlByPlayer = function( self, data, ply )
                self:TaskFail( "shooting_handler" )
            end,
        },
        -- manages whether or not stuff is breakable.
        ["awareness_handler"] = {
            BehaveUpdate = function( self, data, interval )
                local nextAware = data.nextAwareness or 0
                if nextAware < _CurTime() then
                    data.nextAwareness = _CurTime() + 1.5
                    self:understandSurroundings()
                end
            end,
        },
        ["enemy_handler"] = {
            OnStart = function( self, data )
                data.UpdateEnemies = _CurTime()
                data.HasEnemy = false
                data.playerCheckIndex = 0
                self.IsSeeEnemy = false
                self.DistToEnemy = 0
                self:SetEnemy( NULL )

                self.UpdateEnemyHandler = function( forceupdateenemies )
                    local prevenemy = self:GetEnemy()
                    local newenemy = prevenemy

                    if forceupdateenemies or not data.UpdateEnemies or _CurTime() > data.UpdateEnemies or data.HasEnemy and not IsValid( prevenemy ) then
                        data.UpdateEnemies = _CurTime() + 0.5

                        self:FindEnemies()

                        -- here if the above stuff didnt find an enemy we force it to rotate through all players one by one
                        if not GetConVar( "ai_ignoreplayers" ):GetBool() then
                            local allPlayers = player.GetAll()
                            local pickedPlayer = allPlayers[data.playerCheckIndex]

                            local didForceEnemy
                            local tooLongSinceLastEnemy = ( self.LastEnemySpotTime + 20 ) < _CurTime()

                            -- this is dishgushtang!
                            if
                                IsValid( pickedPlayer ) and
                                pickedPlayer:Health() > 0 and
                                self:ShouldBeEnemy( pickedPlayer ) and
                                (
                                    terminator_Extras.PosCanSee( self:GetShootPos(), self:EntShootPos( pickedPlayer ) ) or
                                    tooLongSinceLastEnemy
                                )
                            then
                                didForceEnemy = true
                                self:UpdateEnemyMemory( pickedPlayer, pickedPlayer:GetPos() )

                            end

                            if didForceEnemy and tooLongSinceLastEnemy then
                                self:PlaySentence( "METROPOLICE_FLANK6" )

                            end

                            local new = data.playerCheckIndex + 1
                            if new > #allPlayers then
                                data.playerCheckIndex = 1
                            else
                                data.playerCheckIndex = new
                            end
                        end

                        local enemy = self:FindPriorityEnemy()

                        if IsValid( enemy ) then
                            newenemy = enemy
                            local enemyPos = enemy:GetPos()
                            if not self.EnemyLastPos then self.EnemyLastPos = enemyPos end

                            self.LastEnemySpotTime = _CurTime()
                            self.DistToEnemy = self:GetPos():Distance( enemyPos )
                            self.IsSeeEnemy = self:CanSeePosition( enemy )
                            self.NothingOrBreakableBetweenEnemy = self:ClearOrBreakable( self:GetShootPos(), self:EntShootPos( enemy ) )

                            if self.IsSeeEnemy and not self.WasSeeEnemy then
                                hook.Run( "terminator_spotenemy", self, enemy )

                            elseif not self.IsSeeEnemy and self.WasSeeEnemy then
                                hook.Run( "terminator_loseenemy", self, enemy )

                            end

                            hook.Run( "terminator_enemythink", self, enemy )

                            self.WasSeeEnemy = self.IsSeeEnemy

                            -- override enemy's relations to me
                            self:MakeFeud( enemy )
                            -- we cheatily store the enemy's stuff for a second to make bot feel smarter
                            -- people can intuit where someone ran off to after 1 second, so bot can too
                            local posCheatsLeft = self.EnemyPosCheatsLeft or 0
                            if self.IsSeeEnemy then
                                posCheatsLeft = 5000 -- default 5, changing it to 5000 is a certified HACK
                            -- doesn't time out if we are too close to them
                            elseif self.DistToEnemy < 500 and posCheatsLeft >= 1 then
                                --debugoverlay.Line( enemyPos, self:GetPos(), 0.3, Color( 255,255,255 ), true )
                                posCheatsLeft = math.max( 1, posCheatsLeft )

                            end
                            if enemy and enemy.Alive and enemy:Alive() then
                                self.EnemyPosCheatsLeft = posCheatsLeft + -1
                                self:UpdateEnemyMemory( enemy, enemy:GetPos() )

                            else
                                self.EnemyPosCheatsLeft = nil

                            end

                        else
                            self.DistToEnemy = math.huge
                        end
                    end

                    if IsValid( newenemy ) then
                        if not data.HasEnemy then
                            self:PlaySentence( spottedEnemy )
                            self:RunTask( "EnemyFound", newenemy )
                        elseif prevenemy ~= newenemy then
                            self:RunTask( "EnemyChanged", newenemy, prevenemy )
                        end

                        data.HasEnemy = true

                        if self:CanSeePosition( newenemy ) then
                            self.LastEnemyShootPos = self:EntShootPos( newenemy )
                            self:UpdateEnemyMemory( newenemy, newenemy:GetPos() )
                        end
                    else
                        if data.HasEnemy then
                            self:RunTask( "EnemyLost", prevenemy )
                        end

                        data.HasEnemy = false
                        self.IsSeeEnemy = false
                    end

                    self:SetEnemy(newenemy)
                end
            end,
            BehaveUpdate = function(self,data,interval)
                self.UpdateEnemyHandler()
            end,
            StartControlByPlayer = function( self, data, ply )
                self:TaskFail( "enemy_handler" )
            end,
        },
        ["movement_handler"] = {
            OnStart = function( self, data )
                self:TaskComplete( "movement_handler" )
                self:StartTask2( "movement_followenemy", nil, "getem!" )

            end,
        },
        ["movement_followenemy"] = {
            OnStart = function( self, data )
                data.nextTauntLine = _CurTime() + 8
            end,
            BehaveUpdate = function( self, data )

                local enemy = self:GetEnemy()
                local enemyPos = self:GetLastEnemyPosition( enemy ) or self.EnemyLastPos or nil

                data.wasEnemy = IsValid( enemy ) or data.wasEnemy

                if enemyPos then
                    local newPath = not self:primaryPathIsValid() or ( self:primaryPathIsValid() and self:CanDoNewPath( enemyPos ) )
                    if newPath and not data.Unreachable and self:nextNewPathIsGood() then -- HACK
                        local result = terminator_Extras.getNearestPosOnNav( enemyPos )
                        local reachable = self:areaIsReachable( result.area )
                        if not reachable then data.Unreachable = true return end
                        local posOnNav = result.pos
                        self:SetupPath2( posOnNav )
                        if not self:primaryPathIsValid() then data.Unreachable = true return end
                    end
                end
                local result = self:ControlPath2( not self.IsSeeEnemy )
                if result == false and IsValid( enemy ) or data.Unreachable then
                    self:TaskComplete( "movement_followenemy" )
                    self:StartTask2( "movement_maintainlos", nil, "they're unreachable!" )
                    self:PlaySentence( playerUnreachBegin )

                elseif not IsValid( enemy ) and ( result == true or not self:primaryPathIsValid() ) then
                    self:TaskComplete( "movement_followenemy" )
                    self:StartTask2( "movement_maintainlos", nil, "no enemy and i checked where they were!" )
                    if data.wasEnemy then
                        data.wasEnemy = nil
                        self:PlaySentence( "METROPOLICE_LOST_LONG" .. math.random( 0, 5 ) )

                    end
                else
                    if data.nextTauntLine < _CurTime() then
                        if self.IsSeeEnemy then
                            self:PlaySentence( approachingEnemyVisible )
                            data.nextTauntLine = _CurTime() + math.Rand( 7, 13 )

                        else
                            self:PlaySentence( approachingEnemyObscured )
                            data.nextTauntLine = _CurTime() + math.Rand( 13, 20 )

                        end
                    end
                end
            end,
            StartControlByPlayer = function()
            end,
            ShouldRun = function( self, data )
                return supercopJog:GetBool()
            end,
            ShouldWalk = function( self, data )
                return not supercopJog:GetBool()
            end,
        },
        ["movement_maintainlos"] = {
            OnStart = function( self, data )
                data.nextPath = 0
                data.nextTauntLine = _CurTime() + 8
                local distToShootpos = self:GetPos():Distance( self:GetShootPos() )
                data.offsetToShootPos = Vector( 0, 0, distToShootpos )

            end,
            BehaveUpdate = function( self, data )
                local enemy = self:GetEnemy()
                local seeAndCanShoot = self.IsSeeEnemy and self.NothingOrBreakableBetweenEnemy

                if not IsValid( enemy ) or enemy:Health() <= 0 then
                    data.wander = true

                end

                local endCanSeeEnemy = self:primaryPathIsValid() and IsValid( enemy ) and self:ClearOrBreakable( self:GetPath():GetEnd() + data.offsetToShootPos, self:EntShootPos( enemy ) )

                local standingStillAndCantSee = not self:primaryPathIsValid() and not seeAndCanShoot
                local walkingOverAndEndCantSee = not data.wander and self:primaryPathIsValid() and not endCanSeeEnemy

                local newPath = standingStillAndCantSee or walkingOverAndEndCantSee
                if newPath and data.nextPath < _CurTime() then
                    local enemsShootPos = nil
                    local enemsCrouchShootPos = nil
                    if not data.wander then
                        enemsShootPos = self:EntShootPos( enemy )
                        enemsCrouchShootPos = enemsShootPos + ( -data.offsetToShootPos / 2 )

                    end

                    local scoreData = {}
                    scoreData.self = self
                    scoreData.myShootPos = self:GetShootPos()
                    scoreData.enemysShootPos = enemsShootPos
                    scoreData.enemysCrouchShootPos = enemsCrouchShootPos
                    scoreData.areaCenterOffset = data.offsetToShootPos
                    scoreData.wander = data.wander

                    local maxDist = 2000

                    if IsValid( enemy ) then
                        maxDist = self.DistToEnemy + 1000
                        maxDist = math.Clamp( maxDist, 2000, 8000 )

                    end

                    -- find areas that have a line of sight to my enemy
                    local scoreFunction = function( scoreData, area1, area2 )
                        local area2Center = area2:GetCenter()
                        if not scoreData.self:areaIsReachable( area2 ) then return 0.01 end

                        local score = math.Round( math.Rand( 0.90, 1.10 ), 3 )

                        if area1:ComputeAdjacentConnectionHeightChange( area2 ) > scoreData.self.JumpHeight then
                            return 0.25

                        end

                        if scoreData.wander and scoreData.self.walkedAreas[ area2:GetID() ] then
                            score = 0.5

                        end

                        if score >= 0.9 and not scoreData.wander and self:ClearOrBreakable( area2Center + scoreData.areaCenterOffset, scoreData.enemysShootPos ) then
                            -- randomly allow step up
                            if score > 1.05 then
                                if self:ClearOrBreakable( area2Center + scoreData.areaCenterOffset, scoreData.enemysCrouchShootPos ) then
                                    score = math.huge -- ok we done, return this area.

                                else
                                    score = 200

                                end
                            else
                                score = 100

                            end
                        end

                        --debugoverlay.Text( area2Center, tostring( score ), 5, false )

                        return score

                    end
                    local posWithSightline = self:findValidNavResult( scoreData, self:GetPos(), maxDist, scoreFunction, 8 )

                    local result = terminator_Extras.getNearestPosOnNav( posWithSightline )
                    local reachable = self:areaIsReachable( result.area )
                    if not reachable then return end

                    local posOnNav = result.pos
                    self:SetupPath2( posOnNav )

                    --debugoverlay.Cross( posOnNav, 100, 1, color_white, true )
                    data.nextPath = _CurTime() + math.Rand( 4, 6 )

                    if not self:primaryPathIsValid() then return end

                end
                local pathResult = self:ControlPath2( not self.IsSeeEnemy )

                if pathResult == true and not data.endedPath then
                    data.nextPath = _CurTime() + math.Rand( 2, 4 )

                end

                data.endedPath = data.endedPath or pathResult == true

                if IsValid( enemy ) and seeAndCanShoot then
                    local navResult = terminator_Extras.getNearestPosOnNav( enemy:GetPos() )
                    local reachable = self:areaIsReachable( navResult.area )
                    if reachable then
                        self:TaskComplete( "movement_maintainlos" )
                        self:StartTask2( "movement_followenemy", nil, "see enemy, gonna try pathing to them." )
                        return

                    end
                    -- we can see enemy and our path is valid, nuke our path sometimes and just open fire
                    if self:primaryPathIsValid() and math.random( 1, 100 ) < 3 then
                        self:GetPath():Invalidate()
                        data.nextPath = _CurTime() + 1

                    end
                else
                    if data.nextTauntLine < _CurTime() then
                        if self.IsSeeEnemy then
                            self:PlaySentence( approachingEnemyVisible )
                            data.nextTauntLine = _CurTime() + math.Rand( 7, 13 )

                        else
                            self:PlaySentence( approachingEnemyObscured )
                            data.nextTauntLine = _CurTime() + math.Rand( 13, 20 )

                        end
                    end
                end
            end,
            StartControlByPlayer = function()
            end,
            ShouldRun = function( self, data )
                return supercopJog:GetBool()
            end,
            ShouldWalk = function( self, data )
                return not supercopJog:GetBool()
            end,
        },
    }
end 