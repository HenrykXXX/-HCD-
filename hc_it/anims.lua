-- Register the command
RegisterCommand('hc.playAnim', function(source, args)
    if #args == 0 then
        TriggerEvent('chat:addMessage', {
            color = {255, 0, 0},
            multiline = true,
            args = {"Animation", "Please provide an animation name."}
        })
        return
    end

    local animName = args[1]

    -- Request the animation dictionary
    local animDict = 'amb@medic@standing@kneel@base'
    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do
        Citizen.Wait(0)
    end

    -- Play the animation
    local ped = PlayerPedId()
    TaskPlayAnim(ped, animDict, animName, 8.0, -8.0, -1, 0, 0, false, false, false)

    TriggerEvent('chat:addMessage', {
        color = {0, 255, 0},
        multiline = true,
        args = {"Animation", "Playing animation: " .. animName}
    })
end, false)