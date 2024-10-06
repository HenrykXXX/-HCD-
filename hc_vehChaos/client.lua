-- Traffic speed multiplier (1000% increase)
local speedMultiplier = 3.0

-- Function to adjust the speed of all nearby vehicles
function SpeedUpTraffic()
    local playerPed = PlayerPedId()  -- Get player's Ped (character)
    local playerCoords = GetEntityCoords(playerPed)  -- Get player's current position

    -- Find all vehicles around the player within a 1000-unit radius
    local vehicles = GetNearbyVehicles(playerCoords, 1000.0)

    for _, vehicle in ipairs(vehicles) do
        -- Get the current speed of the vehicle
        local currentSpeed = GetEntitySpeed(vehicle)

        -- Apply the speed multiplier
        if vehicle ~= GetVehiclePedIsIn(playerPed, true) then
            local driver = GetPedInVehicleSeat(vehicle, -1)
            if DoesEntityExist(driver) then
                -- Set extremely aggressive driving style
                SetDriverAggressiveness(driver, 100.0)
                SetDriverAbility(driver, 1.0)
                
                -- Use a more aggressive driving style flag
                SetDriveTaskDrivingStyle(driver, 1074528293) -- Combines multiple aggressive flags
            end
            
            SetVehicleForwardSpeed(vehicle, currentSpeed * speedMultiplier)
        

            SetVehicleEnginePowerMultiplier(vehicle, 1000.0)
            SetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fTractionCurveMax', 20.0)
            SetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fTractionCurveMin', 40.0)
            SetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fDownforceModifier', 100.0)

            SetVehicleDamageModifier(vehicle, 0.01)
        end
    end
end

-- Helper function to get all vehicles nearby
function GetNearbyVehicles(coords, radius)
    local nearbyVehicles = {}
    for vehicle in EnumerateVehicles() do
        local vehicleCoords = GetEntityCoords(vehicle)
        local distance = #(coords - vehicleCoords)

        if distance <= radius then
            table.insert(nearbyVehicles, vehicle)
        end
    end
    return nearbyVehicles
end

-- Vehicle enumerator for fetching all vehicles
function EnumerateVehicles()
    return coroutine.wrap(function()
        local handle, vehicle = FindFirstVehicle()
        if not handle or handle == -1 then
            EndFindVehicle(handle)
            return
        end

        local success
        repeat
            coroutine.yield(vehicle)
            success, vehicle = FindNextVehicle(handle)
        until not success

        EndFindVehicle(handle)
    end)
end

-- Run the function every few seconds to keep vehicles sped up
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)  -- Run every second
        SpeedUpTraffic()
    end
end)

-- Function to maximize traffic and pedestrian density
function SetMaxTrafficDensity()
    -- Set vehicle and pedestrian density to maximum
    SetVehicleDensityMultiplierThisFrame(1.0)    -- Maximum vehicle density (1.0 is default max)
    SetRandomVehicleDensityMultiplierThisFrame(1.0)  -- Maximum random vehicle density
    SetParkedVehicleDensityMultiplierThisFrame(1.0)  -- Maximum parked vehicle density
    SetPedDensityMultiplierThisFrame(1.0)        -- Maximum pedestrian density

    -- Optional: Maximize the amount of scenario peds (people doing activities) on the streets
    SetScenarioPedDensityMultiplierThisFrame(1.0, 1.0)
end

-- Run the function every frame to ensure maximum traffic is always applied
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)  -- Run every frame
        SetMaxTrafficDensity()
    end
end)

