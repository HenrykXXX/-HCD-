RegisterCommand("hcgod", function(_, args)
    local pped = GetPlayerPed(-1)
    SetEntityInvincible(pped, true)

   -- TriggerServerEvent("hc_god:god")
end)