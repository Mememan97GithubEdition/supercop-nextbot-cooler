-- nerf accuracy at range?
-- make sniping more last resort

AddCSLuaFile()

SWEP.PrintName = "O'l Reliable."
SWEP.Spawnable = false
SWEP.AdminOnly = true
SWEP.Author = "Straw W Wagen"
SWEP.Purpose = "Shoot without asking!"

SWEP.ViewModel = "models/weapons/v_357.mdl"
SWEP.WorldModel = "models/weapons/w_357.mdl"
SWEP.Weight = 11564674

if SERVER then
    util.AddNetworkString( "weapon_sb_supercoprevolver.muzzleflash" )
else
    killicon.AddFont( "weapon_sb_supercoprevolver", "HL2MPTypeDeath", ".", Color( 255, 80, 0 ) )
    language.Add( "weapon_sb_supercoprevolver", SWEP.PrintName )
end

SWEP.terminator_IgnoreWeaponUtility = true

SWEP.Primary = {
    Ammo = "357",
    ClipSize = 6,
    DefaultClip = 6,
}

SWEP.Secondary = {
    Ammo = "None",
    ClipSize = -1,
    DefaultClip = -1,
}

function SWEP:Initialize()
    self:SetHoldType( "revolver" )

end

function SWEP:CanPrimaryAttack()
    return CurTime() >= self:GetNextPrimaryFire() and self:Clip1() > 0 and self:GetHoldType() == "revolver"

end

function SWEP:CanSecondaryAttack()
    return false
end

local MAX_TRACE_LENGTH    = 56756
local vec3_origin        = vector_origin

function SWEP:PrimaryAttack()
    if not self:CanPrimaryAttack() then return end

    local owner = self:GetOwner()
    local reallyMad = IsValid( owner ) and owner.IsReallyAngry and owner:IsReallyAngry()
    owner.SupercopBlockShooting = CurTime() + 1.5
    self:SetWeaponHoldType( "revolver" )

    owner:FireBullets( {
        Num = 1,
        Src = owner:GetShootPos(),
        Dir = owner:GetAimVector(),
        Spread = vec3_origin,
        Distance = MAX_TRACE_LENGTH,
        Damage = 5000,
        Tracer = 0,
        Force = 1,
        Attacker = owner,
        Callback = function( _, trace )
            local tracerEffect = EffectData()
            tracerEffect:SetStart( owner:GetShootPos() )
            tracerEffect:SetOrigin( trace.HitPos )
            tracerEffect:SetScale( 25000 ) -- fast
            tracerEffect:SetFlags( 0x0001 ) --whiz!

            util.Effect( "StriderTracer", tracerEffect ) -- BIG effect

            if reallyMad and IsValid( trace.Entity ) then
                damage = DamageInfo()
                damage:SetDamage( 5000000 )
                damage:SetDamageType( DMG_BLAST )
                damage:SetAttacker( owner )
                damage:SetInflictor( self )
                trace.Entity:TakeDamageInfo( damage )

            end
        end
    } )

    self:DoMuzzleFlash()

    self:SetClip1( self:Clip1() - 1 )
    self:SetNextPrimaryFire( CurTime() + 0.74 )
    self:SetLastShootTime()

    if not SERVER then return end

    util.ScreenShake( owner:GetPos(), 5, 20, 0.25, 1000, true )
    util.ScreenShake( owner:GetPos(), 1, 20, 0.45, 4000, true )

    local filterAllPlayers = RecipientFilter()
    filterAllPlayers:AddAllPlayers()

    if owner.SuperGunSound then
        owner.SuperGunSound:Stop()

    end

    owner.SuperGunSound = CreateSound( owner, "Weapon_357.Single", filterAllPlayers )
    owner.SuperGunSound:PlayEx( 1, 88 )

    timer.Simple( 0.05, function()
        if not IsValid( self ) then return end
        if not IsValid( owner ) then return end
        -- ECHO!
        local superGunEcho = CreateSound( self, "Weapon_357.Single", filterAllPlayers )
        superGunEcho:SetDSP( 22 )
        superGunEcho:SetSoundLevel( 120 )
        superGunEcho:PlayEx( 0.6, math.Rand( 55, 60 ) )

        sound.EmitHint( SOUND_COMBAT, owner:GetShootPos(), 6000, 1, owner )

    end )
end

function SWEP:DoMuzzleFlash()
    if SERVER then
        net.Start( "weapon_sb_supercoprevolver.muzzleflash", true )
            net.WriteEntity( self )
        net.SendPVS( self:GetPos() )
    else
        local MUZZLEFLASH_357 = 6

        local ef = EffectData()
        ef:SetEntity( self )
        ef:SetAttachment( self:LookupAttachment( "muzzle" ) )
        ef:SetScale( 2 )
        ef:SetFlags( MUZZLEFLASH_357 )
        util.Effect( "MuzzleFlash", ef, false )
    end
end

if CLIENT then
    net.Receive( "weapon_sb_supercoprevolver.muzzleflash", function( len )
        local ent = net.ReadEntity()

        if IsValid( ent ) and ent.DoMuzzleFlash then
            ent:DoMuzzleFlash()
        end
    end )
end

function SWEP:SecondaryAttack()
    if not self:CanSecondaryAttack() then return end
end

function SWEP:Equip()
end

function SWEP:OwnerChanged()
end

function SWEP:OnDrop()
end

function SWEP:Reload()
    self:SetClip1( self.Primary.ClipSize )
    self:SetNextPrimaryFire( CurTime() + 1.25 )

end

function SWEP:CanBePickedUpByNPCs()
    return true
end

function SWEP:GetNPCBulletSpread( prof )
    local base = 0
    local owner = self:GetOwner()
    if IsValid( owner ) and owner.GetEnemy and owner.SupercopMaxUnequipRevolverDist and owner.DistToEnemy > ( owner.SupercopMaxUnequipRevolverDist * 1.5 ) then
        base = 0.3

    end

    local spread = { base + 2, base + 1.5, base + 1, base + 0.5, base }
    return spread[ prof + 1 ]
end

function SWEP:GetNPCBurstSettings()
    return 1,1,1.5
end

function SWEP:GetNPCRestTimes()
    return 1.5,1.5
end

function SWEP:GetCapabilities()
    return CAP_WEAPON_RANGE_ATTACK1
end

function SWEP:DrawWorldModel()
    self:DrawModel()
end