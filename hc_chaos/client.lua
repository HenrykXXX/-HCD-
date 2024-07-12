-- List of unique and interesting weapons
local weapons = {
    `WEAPON_STUNGUN`,
    `WEAPON_STUNGUN`,
    `WEAPON_STUNGUN`,
    `WEAPON_STUNGUN`,
    `WEAPON_STUNGUN`,
    `WEAPON_STUNGUN`,
    `WEAPON_GRENADELAUNCHER`,
    `WEAPON_GRENADELAUNCHER_SMOKE`,
    --`WEAPON_RPG`,
    `WEAPON_MINIGUN`,
    `WEAPON_GRENADE`,
    `WEAPON_STICKYBOMB`,
    `WEAPON_SMOKEGRENADE`,
    `WEAPON_BZGAS`,
    `WEAPON_MOLOTOV`,
    `WEAPON_FLARE`,
    `WEAPON_RAYPISTOL`, -- Up-n-Atomizer
    --`WEAPON_RAILGUN`,
    `WEAPON_FIREWORK`,
    `WEAPON_SNOWBALL`,
    `WEAPON_FIREWORK`,
    `WEAPON_SNOWBALL`,
    `WEAPON_FIREWORK`,
    `WEAPON_SNOWBALL`,
    `WEAPON_FIREWORK`,
    `WEAPON_SNOWBALL`,
    --`WEAPON_PROXMINE`,
    --`WEAPON_HOMINGLAUNCHER`,
    `WEAPON_MARKSMANPISTOL`
}

-- Function to get all peds including cops
function GetNearbyPeds(x, y, z, radius)
    local peds = {}
    local handle, ped = FindFirstPed()
    local success
    repeat
        if DoesEntityExist(ped) and not IsPedAPlayer(ped) then
            local pedCoords = GetEntityCoords(ped)
            if #(vector3(x, y, z) - pedCoords) <= radius then
                table.insert(peds, ped)
            end
        end
        success, ped = FindNextPed(handle)
    until not success
    EndFindPed(handle)
    return peds
end

-- Create Thread to manage chaos
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5000) -- Wait 5s
        
        local playerPed = PlayerPedId()
        local playerPos = GetEntityCoords(playerPed)
        local nearbyPeds = GetNearbyPeds(playerPos.x, playerPos.y, playerPos.z, 60.0)

        for _, ped in ipairs(nearbyPeds) do
            -- Give random weapon to a ped
            local randomWeapon = weapons[math.random(#weapons)]
            GiveWeaponToPed(ped, randomWeapon, 300, false, true)

            -- Set all peds (including cops) to hate everyone
            SetPedRelationshipGroupHash(ped, `HATES_EVERYONE`)

            -- Find nearest target to attack
            local nearestPed = nil
            local closestDistance = math.huge
            for _, targetPed in ipairs(nearbyPeds) do
                if ped ~= targetPed then
                    local distance = #(GetEntityCoords(ped) - GetEntityCoords(targetPed))
                    if distance < closestDistance then
                        closestDistance = distance
                        nearestPed = targetPed
                    end
                end
            end

            if nearestPed then
                TaskCombatPed(ped, nearestPed, 0, 16)
            end
        end
    end
end)