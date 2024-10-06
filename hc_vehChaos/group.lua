-- Configuration
local characterModels = {
    {hash = `player_zero`, name = "Michael"},
    {hash = `player_one`, name = "Franklin"},
    {hash = `player_two`, name = "Trevor"}
}

local spawnDistance = 3.0 -- Distance to spawn characters from the player
local followDistance = 5.0 -- Distance characters try to maintain while following

-- Variables to store character information
local characterHandles = {}
local isFollowing = false

-- Voice lines for each character (GTA V's voice lines)
local voiceLines = {
    Michael = {
        "S_M_Y_Ranger_01", -- Example voice line
        "S_M_Y_Ranger_02"  -- Add more actual voice lines here
    },
    Franklin = {
        "S_M_Y_Ranger_01", -- Example voice line
        "S_M_Y_Ranger_02"  -- Add more actual voice lines here
    },
    Trevor = {
        "S_M_Y_Ranger_01", -- Example voice line
        "S_M_Y_Ranger_02"  -- Add more actual voice lines here
    }
}

-- Function to spawn characters
function SpawnCharacters()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    for i, character in ipairs(characterModels) do
        -- Calculate spawn position in a circle around the player
        local angle = (i - 1) * (2 * math.pi / #characterModels)
        local spawnX = playerCoords.x + spawnDistance * math.cos(angle)
        local spawnY = playerCoords.y + spawnDistance * math.sin(angle)

        -- Load the model
        RequestModel(character.hash)
        while not HasModelLoaded(character.hash) do
            Wait(500)
        end

        -- Create character
        local handle = CreatePed(4, character.hash, spawnX, spawnY, playerCoords.z, 0.0, true, false)
        SetModelAsNoLongerNeeded(character.hash)

        -- Set character attributes
        SetPedDefaultComponentVariation(handle)
        SetPedHearingRange(handle, 100.0)
        SetPedSeeingRange(handle, 100.0)
        SetPedAlertness(handle, 0)
        SetPedFleeAttributes(handle, 0, false)
        SetPedCombatAttributes(handle, 17, true)
        SetBlockingOfNonTemporaryEvents(handle, true)

        -- Make character friendly
        SetPedAsGroupMember(handle, GetPedGroupIndex(playerPed))
        SetPedCanBeTargetted(handle, false)

        -- Start following the player
        TaskFollowToOffsetOfEntity(handle, playerPed, 0.0, -followDistance, 0.0, 5.0, -1, 1.0, true)

        SetEntityInvincible(handle, true)

        table.insert(characterHandles, handle)
        TriggerEvent('chatMessage', "^2" .. character.name .. " has spawned and is following you!")
    end

    isFollowing = true
end

-- Function to remove characters
function RemoveCharacters()
    for _, handle in ipairs(characterHandles) do
        if DoesEntityExist(handle) then
            DeleteEntity(handle)
        end
    end
    characterHandles = {}
    isFollowing = false
end

-- Command to spawn characters
RegisterCommand("spawnprotagonists", function()
    if #characterHandles == 0 then
        SpawnCharacters()
    else
        TriggerEvent('chatMessage', "^3The characters are already spawned!")
    end
end, false)

-- Command to remove characters
RegisterCommand("removeprotagonists", function()
    if #characterHandles > 0 then
        RemoveCharacters()
        TriggerEvent('chatMessage', "^2The characters have been removed.")
    else
        TriggerEvent('chatMessage', "^3No characters are currently spawned.")
    end
end, false)

-- Function to check if player is in a vehicle
function IsPlayerInVehicle()
    local playerPed = PlayerPedId()
    return IsPedInAnyVehicle(playerPed, false)
end

-- Function to make characters enter the player's vehicle
function MakeCharactersEnterVehicle()
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)
    
    if vehicle ~= 0 then
        local enteredCount = 0
        for i, handle in ipairs(characterHandles) do
            if not IsPedInAnyVehicle(handle, false) then
                local seatIndex = i - 1  -- Assign each character a specific seat
                if IsVehicleSeatFree(vehicle, seatIndex) then
                    if not IsPedInVehicle(handle, vehicle, true) then
                        TaskEnterVehicle(handle, vehicle, -1, seatIndex, 1.0, 1, 0)
                        enteredCount = enteredCount + 1
                    end
                end
            end
        end
        if enteredCount > 0 then
            TriggerEvent('chatMessage', "^2" .. enteredCount .. " character(s) are getting into your vehicle.")
        else
            TriggerEvent('chatMessage', "^3No room for characters in the vehicle.")
        end
    end
end

-- Function to make characters say random voice lines
function SpeakRandomVoiceLine()
    for i, handle in ipairs(characterHandles) do
        if DoesEntityExist(handle) then
            local characterName = characterModels[i].name
            print(characterName)
            local lines = voiceLines[characterName]
            local randomLine = lines[math.random(#lines)] -- Select a random line

            -- Play the random line using FiveM audio function
            PlaySoundFromEntity(-1, randomLine, handle, "SPEECH_PARAMS_STANDARD", false, 0, false)
        end
    end
end

-- Thread to manage characters' behavior
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000) -- Check every second
        if isFollowing and #characterHandles > 0 then
            local playerPed = PlayerPedId()
            local isInVehicle = IsPlayerInVehicle()
            
            if isInVehicle then
                MakeCharactersEnterVehicle()
            else
                local playerCoords = GetEntityCoords(playerPed)
                for _, handle in ipairs(characterHandles) do
                    if DoesEntityExist(handle) then
                        local charCoords = GetEntityCoords(handle)
                        local distance = #(playerCoords - charCoords)

                        if distance > followDistance * 2 then
                            -- If character is too far, update their task
                            TaskFollowToOffsetOfEntity(handle, playerPed, 0.0, -followDistance, 0.0, 5.0, -1, 1.0, true)
                        end

                        -- Check if character needs to be woken up or unstuck
                        if not GetIsTaskActive(handle, 222) then -- 222 is the task index for following
                            TaskGoToEntity(handle, playerPed, -1, 2.0, 1.0, 1073741824.0, 0)
                        end
                    end
                end
            end
        end

        -- Randomly trigger character dialogues every 10 seconds
        --if math.random() < 0.5 then -- 10% chance each second
            SpeakRandomVoiceLine()
            print("speak")
        --end
    end
end)