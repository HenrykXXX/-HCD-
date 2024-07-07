local isMale = true

local defaultSkin = {
    sex = 332,
    face = 0,
    skin = 0,
    beard_1 = 0,
    beard_2 = 0,
    beard_3 = 0,
    beard_4 = 0,
    hair_1 = 0,
    hair_2 = 0,
    hair_color_1 = 0,
    hair_color_2 = 0,
    tshirt_1 = 0,
    tshirt_2 = 0,
    torso_1 = 0,
    torso_2 = 0,
    decals_1 = 0,
    decals_2 = 0,
    arms = 0,
    pants_1 = 0,
    pants_2 = 0,
    shoes_1 = 0,
    shoes_2 = 0,
    mask_1 = 0,
    mask_2 = 0,
    bproof_1 = 0,
    bproof_2 = 0,
    chain_1 = 0,
    chain_2 = 0,
    helmet_1 = 0,
    helmet_2 = 0,
    glasses_1 = 0,
    glasses_2 = 0,
}

-- Function to register commands
RegisterCommand('sc.loadDefaultModel', function(source, args, rawCommand)
    TriggerEvent('skinchanger:loadDefaultModel', isMale)
end)

RegisterCommand('sc.loadSkin', function(source, args, rawCommand)
    TriggerEvent('skinchanger:loadSkin', defaultSkin)
end)

RegisterCommand('sc.loadPartialSkin', function(source, args, rawCommand)
    TriggerEvent('skinchanger:getSkin', function(skin)
		uniformObject = {
            tshirt_1 = 58,  tshirt_2 = 0,
            torso_1 = 55,   torso_2 = 0,
            decals_1 = 0,   decals_2 = 0,
            arms = 41,
            pants_1 = 25,   pants_2 = 0,
            shoes_1 = 25,   shoes_2 = 0,
            helmet_1 = -1,  helmet_2 = 0,
            chain_1 = 0,    chain_2 = 0,
            ears_1 = 2,     ears_2 = 0
        }

    	TriggerEvent('skinchanger:loadClothes', skin, uniformObject)
    end)
end)

RegisterCommand('sc.getData', function(source, args, rawCommand)
    TriggerEvent('skinchanger:getData', function(components, maxVals)
        for k, v in pairs(maxVals) do
            print(k .. " - " .. v)
        end
    end)
end)

RegisterCommand('sc.getSkin', function(source, args, rawCommand)
    TriggerEvent('skinchanger:getSkin', function(skin)
        for k, v in pairs(skin) do
            print(k .. " - " .. v)
        end
    end)
end)
