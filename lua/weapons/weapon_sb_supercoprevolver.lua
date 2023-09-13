AddCSLuaFile()

SWEP.PrintName = "O'l Reliable."
SWEP.Spawnable = false
SWEP.Author = "Straw W Wagen"
SWEP.Purpose = "Should only be used internally by advanced nextbots!"

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
    owner.SupercopBlockShooting = CurTime() + 0.75
    self:SetWeaponHoldType( "revolver" )

    owner:FireBullets( {
        Num = 1,
        Src = owner:GetShootPos(),
        Dir = owner:GetAimVector(),
        Spread = vec3_origin,
        Distance = MAX_TRACE_LENGTH,
        AmmoType = self:GetPrimaryAmmoType(),
        Damage = 5000,
        Force = 1,
        Attacker = owner,
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
        ef:SetScale( 1 )
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
end

function SWEP:CanBePickedUpByNPCs()
    return true
end

function SWEP:GetNPCBulletSpread( prof )
    local spread = { 2.5, 2, 1.5, 1, 0.5 }
    return spread[ prof + 1 ]
end

function SWEP:GetNPCBurstSettings()
    return 1,1,0.75
end

function SWEP:GetNPCRestTimes()
    return 0.75,0.75
end

function SWEP:GetCapabilities()
    return CAP_WEAPON_RANGE_ATTACK1
end

function SWEP:DrawWorldModel()
    self:DrawModel()
end