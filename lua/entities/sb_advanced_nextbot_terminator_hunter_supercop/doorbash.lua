local function DoorHitSound( ent )
    ent:EmitSound( "ambient/materials/door_hit1.wav", 100, math.random( 80, 120 ) )

end
local function BreakSound( ent )
    local Snd = "physics/wood/wood_furniture_break" .. tostring( math.random( 1, 2 ) ) .. ".wav"
    ent:EmitSound( Snd, 110, math.random( 80, 90 ) )

end

local function LockBustSound( ent )
    ent:EmitSound( "doors/vent_open1.wav", 100, 80, 1, CHAN_STATIC )
    ent:EmitSound( "physics/metal/metal_solid_strain3.wav", 100, 200, 1, CHAN_STATIC )

end

local function SparkEffect( SparkPos )
    timer.Simple( 0, function() -- wow wouldnt it be cool if effects worked on the first tick personally i think that would be really cool
        local Sparks = EffectData()
        Sparks:SetOrigin( SparkPos )
        Sparks:SetMagnitude( 2 )
        Sparks:SetScale( 1 )
        Sparks:SetRadius( 6 )
        util.Effect( "Sparks", Sparks )

    end )

end

local function ModelBoundSparks( ent )
    local randpos = ent:WorldSpaceCenter() + VectorRand() * ent:GetModelRadius()
    randpos = ent:NearestPoint( randpos )

    -- move them a bit in from the exact edges of the model
    randpos = ent:WorldToLocal( randpos )
    randpos = randpos * 0.8
    randpos = ent:LocalToWorld( randpos )

    SparkEffect( randpos )

end

-- code from the sanic nextbot, the greatest nexbot
local function detachAreaPortals( maker, door )

    local doorName = door:GetName()
    if doorName == "" then return end

    for _, portal in ipairs( ents.FindByClass( "func_areaportal" ) ) do
        local portalTarget = portal:GetInternalVariable( "m_target" )
        if portalTarget == doorName then

            portal:Input( "Open", maker, door )

            portal:SetSaveValue( "m_target", "" )
        end
    end
end

function supercop_MakeDoor( maker, ent )
    local vel = maker:GetForward() * 4800
    pos = ent:GetPos()
    ang = ent:GetAngles()
    mdl = ent:GetModel()
    ski = ent:GetSkin()

    detachAreaPortals( maker:GetOwner(), ent )

    local getRidOf = { ent }
    table.Add( getRidOf, ent:GetChildren() )
    for _, toRid in pairs( getRidOf ) do
        toRid:SetNotSolid( true )
        toRid:SetNoDraw( true )
    end
    prop = ents.Create( "prop_physics" )
    prop:SetPos( pos )
    prop:SetAngles( ang )
    prop:SetModel( mdl )
    prop:SetSkin( ski or 0 )
    prop:Spawn()
    prop:SetVelocity( vel )
    prop:GetPhysicsObject():ApplyForceOffset( vel, maker:GetPos() )
    prop:SetPhysicsAttacker( maker )
    prop:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
    DoorHitSound( prop )
    BreakSound( prop )

    prop.isBustedDoor = true
    prop.bustedDoorHp = 400

end

local lockOffset = Vector( 0, 42.6, -10 )

function supercop_HandleDoor( maker, tr )
    if CLIENT or not IsValid( tr.Entity ) then return end
    local door = tr.Entity
    if door.realDoor then
        door = door.realDoor

    end
    local owner = maker:GetOwner()
    local class = door:GetClass()

    -- let nails do their thing
    if door.huntersglee_breakablenails then return end

    local doorsLocked = door:GetInternalVariable( "m_bLocked" ) == true

    if class == "func_door_rotating" or class == "prop_door_rotating" then

        if terminator_Extras.CanBashDoor( door ) == false then
            DoorHitSound( door )
        else
            supercop_MakeDoor( maker, door )

            if doorsLocked then
                SparkEffect( door:GetPos() + -lockOffset )
                LockBustSound( door )

            end
        end
    elseif class == "func_door" and doorsLocked then
        local lockHealth = door.terminator_lockHealth
        if not door.terminator_lockHealth then
            local initialHealth = 200
            local doorsObj = door:GetPhysicsObject()
            if doorsObj and doorsObj:IsValid() then
                initialHealth = math.max( initialHealth, doorsObj:GetVolume() / 1250 )

            end
            lockHealth = initialHealth
            door.terminator_lockMaxHealth = initialHealth

        end

        local lockDamage = 200

        lockHealth = lockHealth + -lockDamage

        if lockHealth <= 0 then
            lockHealth = nil
            door:Fire( "unlock", "", .01 )
            DoorHitSound( door )
            LockBustSound( door )

            util.ScreenShake( owner:GetPos(), 80, 10, 1, 1500 )

            for _ = 1, 20 do
                ModelBoundSparks( door )

            end

        else
            DoorHitSound( door )
            if lockHealth < door.terminator_lockMaxHealth * 0.45 then
                ModelBoundSparks( door )
                util.ScreenShake( owner:GetPos(), 10, 10, 0.5, 600 )
                local pitch = math.random( 175, 200 ) + math.Clamp( -lockHealth, -100, 0 )
                door:EmitSound( "physics/metal/metal_box_break1.wav", 90, pitch, 1, CHAN_STATIC )

            end
        end

        door.terminator_lockHealth = lockHealth

    end
end