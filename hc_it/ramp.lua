local objectModel = 55777251
local objectPlaced = false
local objectEntity = nil

-- Function to place the object in front of the player
function placeObject()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local playerHeading = GetEntityHeading(playerPed)

    local objectCoords = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 2.0, 0.0)

    objectEntity = CreateObject(objectModel, objectCoords.x, objectCoords.y, objectCoords.z, true, false, false)
    SetEntityHeading(objectEntity, playerHeading)
    PlaceObjectOnGroundProperly(objectEntity)

    objectPlaced = true
end

-- Function to remove the placed object
function removeObject()
    if objectEntity ~= nil then
        DeleteObject(objectEntity)
        objectEntity = nil
        objectPlaced = false
    end
end

-- Register the command to place/remove the object
RegisterCommand("placeobject", function()
    if not objectPlaced then
        placeObject()
    else
        removeObject()
    end
end, false)

-- Register the key mapping for F3
RegisterKeyMapping("placeobject", "Place/Remove Object", "keyboard", "F3")