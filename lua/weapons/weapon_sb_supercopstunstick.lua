AddCSLuaFile()

SWEP.PrintName = "Arm of the law."
SWEP.Spawnable = false
SWEP.Author = "Straw W Wagen"
SWEP.Purpose = "Should only be used internally by advanced nextbots!"

SWEP.ViewModel = "models/weapons/v_stunbaton.mdl"
SWEP.WorldModel = "models/weapons/w_stunbaton.mdl"
SWEP.Weight = 3

if CLIENT then
    killicon.AddFont( "weapon_sb_supercopstunstick", "HL2MPTypeDeath", "!", Color( 255, 80, 0 ) )
    language.Add( "weapon_sb_supercopstunstick", SWEP.PrintName )
end

SWEP.Melee = true
SWEP.Range = 75
SWEP.HitMask = MASK_SOLID

SWEP.terminator_IgnoreWeaponUtility = true

function SWEP:Initialize()
    self:SetHoldType( "melee" )

end

function SWEP:CanPrimaryAttack()
    return CurTime() >= self:GetNextPrimaryFire()
end

function SWEP:CanSecondaryAttack()
    return false
end

local MAX_TRACE_LENGTH    = 75
local vec3_origin        = vector_origin

function SWEP:PrimaryAttack()
    if not self:CanPrimaryAttack() then return end

    local owner = self:GetOwner()

    owner:EmitSound( "Weapon_StunStick.Swing" )

    timer.Simple( 0.15, function()
        if not IsValid( self ) then return end
        self:DoDamage()

    end )

    self:SetNextPrimaryFire( CurTime() + 0.5 )
    self:SetLastShootTime()

end

local damageHull = Vector( 10, 10, 8 )

function SWEP:DoDamage()
    local owner = self:GetOwner()
    local tr = util.TraceLine( {
        start = owner:GetShootPos(),
        endpos = owner:GetShootPos() + owner:GetAimVector() * self.Range,
        filter = owner,
        mask = bit.bor( self.HitMask ),
    } )

    if not IsValid( tr.Entity ) then
        tr = util.TraceHull( {
            start = owner:GetShootPos(),
            endpos = owner:GetShootPos() + owner:GetAimVector() * self.Range,
            filter = owner,
            maxs = damageHull,
            mins = -damageHull,
            mask = bit.bor( self.HitMask ),
        } )
    end
    if tr.Hit then
        owner:EmitSound( Sound( "Weapon_StunStick.Melee_Hit" ) )
        local dmg = DamageInfo()
        dmg:SetDamage( 50000 )
        dmg:SetDamageForce( owner:GetAimVector() * 15000 )
        dmg:SetDamageType( DMG_SHOCK )
        dmg:SetAttacker( owner )
        dmg:SetInflictor( self )
        tr.Entity:TakeDamageInfo( dmg )

    end
end

function SWEP:SecondaryAttack()
    if not self:CanSecondaryAttack() then return end
end

function SWEP:Equip()
    self:GetOwner():EmitSound( "Weapon_StunStick.Activate" )
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
    local spread = { 3, 2.5, 2, 1.5, 1 }
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