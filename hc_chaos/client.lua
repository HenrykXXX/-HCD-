-- List of weapons
local weapons = {
    `WEAPON_PISTOL`,
    `WEAPON_COMBATPISTOL`,
    `WEAPON_APPISTOL`,
    `WEAPON_PISTOL50`,
    `WEAPON_MICROSMG`,
    `WEAPON_SMG`,
    `WEAPON_ASSAULTSMG`,
    `WEAPON_ASSAULTRIFLE`,
    `WEAPON_CARBINERIFLE`,
    `WEAPON_ADVANCEDRIFLE`,
    `WEAPON_MG`,
    `WEAPON_COMBATMG`,
    `WEAPON_PUMPSHOTGUN`,
    `WEAPON_SAWNOFFSHOTGUN`,
    `WEAPON_ASSAULTSHOTGUN`,
    `WEAPON_BULLPUPSHOTGUN`,
    `WEAPON_STUNGUN`,
    `WEAPON_SNIPERRIFLE`,
    `WEAPON_HEAVYSNIPER`,
    `WEAPON_REMOTESNIPER`,
    `WEAPON_GRENADELAUNCHER`,
    `WEAPON_GRENADELAUNCHER_SMOKE`,
    `WEAPON_RPG`,
    `WEAPON_MINIGUN`,
    `WEAPON_GRENADE`,
    `WEAPON_STICKYBOMB`,
    `WEAPON_SMOKEGRENADE`,
    `WEAPON_BZGAS`,
    `WEAPON_MOLOTOV`,
    `WEAPON_FIREEXTINGUISHER`,
    `WEAPON_PETROLCAN`,
    `WEAPON_FLARE`,
    --`WEAPON_KNUCKLE`,
    `WEAPON_NIGHTSTICK`,
    --`WEAPON_HAMMER`,
    --`WEAPON_BAT`,
    --`WEAPON_GOLFCLUB`,
    --`WEAPON_CROWBAR`,
    --`WEAPON_BOTTLE`,
    --`WEAPON_DAGGER`,
    --`WEAPON_HATCHET`,
    --`WEAPON_MACHETE`,
    --`WEAPON_FLASHLIGHT`,
    --`WEAPON_SWITCHBLADE`,
    --`WEAPON_POOLCUE`,
    --`WEAPON_PIPEWRENCH`
}

-- function to get all peds
function GetNearbyPeds(x, y, z, radius)
    local peds = {} -- nearby peds array
    local handle, ped = FindFirstPed()

    local success
    repeat
        success, ped = FindNextPed(handle)
        if DoesEntityExist(ped) and IsPedHuman(ped) and not IsPedAPlayer(ped) then
            local pedCords = GetEntityCoords(ped)
            if Vdist(x, y, z, pedCords.x, pedCords.y, pedCords.z) <= radius then
                table.insert(peds, ped)
            end
        end
    until not success
    EndFindPed(handle)
    return peds
end

-- Create Thread to manage chaos
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5000) -- wiat 5s
        
        local playerPed = PlayerPedId() -- get player ped
        local playerPos = GetEntityCoords(playerPed) -- get player ped position
        local nearbyPeds = GetNearbyPeds(playerPos.x, playerPos.y, playerPos.z, 60.0) -- get peds in 60 radius

        for i = 1, #nearbyPeds do
            local ped = nearbyPeds[i]
            local pedPos = GetEntityCoords(ped)

            -- give random weapon to a ped
            local randomWeapon = weapons[math.random(1, #weapons)]
            GiveWeaponToPed(ped, randomWeapon, 300, false, true) 

            if not IsPedAPlayer(ped) then
                local pedGroup = GetPedRelationshipGroupHash(ped)
                if pedGroup ~= `HATES_EVERYONE` then
                    SetPedRelationshipGroupHash(ped, `HATES_EVERYONE`)
                end

                -- Find nearest target to attack
                local nearestPed = nil
                local closestDistance = math.huge -- make it huge
                for j = 1, #nearbyPeds do
                    -- make sure so it wont attack itself
                    if i ~= j then
                        local targetPed = nearbyPeds[j]
                        local targetPos = GetEntityCoords(targetPed) -- get target ped cords
                        local distance = Vdist(pedPos.x, pedPos.y, pedPos.z, targetPos.x, targetPos.y, targetPos.z) -- get distance

                        if distance < closestDistance then
                            closestDistance = distance
                            nearestPed = targetPed
                        end
                    end
                end


                if nearestPed then
                    TaskCombatPed(ped, nearestPed, 0, 16) -- make them fight
                end
            end
        end
    end
end)
