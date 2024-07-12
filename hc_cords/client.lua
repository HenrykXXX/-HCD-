local hc = exports.hc_com.hc()
local display = false

function ShowCords()
    display = true
    SetNuiFocus(true, true)
    SendNUIMessage({
        type = "show"
    })
end

RegisterNUICallback('HideCords', function(data, cb)
    display = false
    cb('ok')
    SetNuiFocus(false, false)
end)

-- Toggle the display when F6 is pressed
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if IsControlJustReleased(1, 167) then  -- 167 is the key code for F6
            ShowCords()
            if display then
                local coords = GetEntityCoords(PlayerPedId())
                local heading = GetEntityHeading(PlayerPedId())
                SendNUIMessage({
                    action = "setCoords",
                    coords = math.floor(coords.x) .. ".0, " .. math.floor(coords.y) .. ".0, " .. math.floor(coords.z) .. ".0 - " .. math.floor(heading) .. ".0"
                })
            end
        end
    end
end)


RegisterCommand('tpm', function()
    local playerPed = PlayerPedId()  -- Get the player ped
    local waypoint = GetFirstBlipInfoId(8)  -- Get the waypoint blip (blip id 8 is the waypoint)

    if DoesBlipExist(waypoint) then  -- Check if the waypoint blip exists
        local waypointCoords = GetBlipInfoIdCoord(waypoint)  -- Get the coordinates of the waypoint
        hc.com.teleportPlayerToGround(waypointCoords.x, waypointCoords.y, waypointCoords.z)
    else
        print("No waypoint set.")
    end
end, false)