
local doNavSave = CreateConVar( "supercop_nextbot_server_navsave", 1, bit.bor( FCVAR_ARCHIVE ), "If navpatcher ran, save the navmesh after supercop is removed?", 0, 1 )

local doinPatching
local patchCount = 0
local _IsValid = IsValid

hook.Add( "terminator_navpatcher_patched", "supercop_count_new_connections", function()
    patchCount = patchCount + 1

end )

local function finishPatching()
    if doNavSave:GetBool() ~= true then return end

    navmesh.Save()

    supercopNextbot_SupercopLog( "Supercop removed, navpatcher's " .. tostring( patchCount ) .. " new connections, have been saved..." )

    patchCount = 0
    doinPatching = nil

end

hook.Add( "supercop_nextbot_removed", "supercop_nextbot_finishpatching", function()
    finishPatching()

end )

hook.Add( "Think", "supercop_nextbot_navpatcher", function()
    local validCop = _IsValid( supercop_nextbot_copThatExists )
    if doinPatching and not validCop then
        finishPatching()

    elseif validCop then
        if not doinPatching then
            doinPatching = true
            supercopNextbot_SupercopLog( "Navpatcher is PATCHING!" )

        end
    end
end )