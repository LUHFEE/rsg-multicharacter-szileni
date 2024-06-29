local RSGCore = exports['rsg-core']:GetCoreObject()
local charPed = nil
local selectingChar = true
local isChossing = false
local DataSkin = nil

local cams = {
    {
        type = "customization",
        x = -561.8157,
        y = -3780.966,
        z = 239.0805,
        rx = -4.2146,
        ry = -0.0007,
        rz = -87.8802,
        fov = 30.0
    },
    {
        type = "selection",
        x = 1546.80,
        y = 1187.90,
        z = 284.29,
        rx = -4.2146,
        ry = -0.0007,
        rz = -87.8802,
        fov = 30.0
    }
}

local function baseModel(sex)
    if (sex == 'mp_male') then
        ApplyShopItemToPed(charPed, 0xA11747C5, true, true, true); --head
        ApplyShopItemToPed(charPed, -806294924,  true, true, true); --hair
        ApplyShopItemToPed(charPed, 62321923,   true, true, true); --hand
        ApplyShopItemToPed(charPed, 3550965899, true, true, true); --legs
        ApplyShopItemToPed(charPed, 612262189,  true, true, true); --Eye
        --ApplyShopItemToPed(charPed, 319152566,  true, true, true); -- beard
        ApplyShopItemToPed(charPed, 2446083710, true, true, true); -- shirt
        ApplyShopItemToPed(charPed, 3531230116, true, true, true); -- bots
        ApplyShopItemToPed(charPed, 4288597979, true, true, true); -- pants
    else
        ApplyShopItemToPed(charPed, 0x7C1A194E, true, true, true); -- head
        ApplyShopItemToPed(charPed, -37225494,  true, true, true); -- hair
        ApplyShopItemToPed(charPed, 25757734,  true, true, true); -- Eye
        ApplyShopItemToPed(charPed, 736263364,  true, true, true); -- hand
        ApplyShopItemToPed(charPed, 4069644469, true, true, true); -- shirt
        ApplyShopItemToPed(charPed, 185184716, true, true, true); -- pants
        ApplyShopItemToPed(charPed, 3485733505, true, true, true); -- bots
        ApplyShopItemToPed(charPed, 1243012162, true, true, true); -- hairacc
        ApplyShopItemToPed(charPed, 2861379350, true, true, true); -- rindleft
		ApplyShopItemToPed(charPed, 2891440640, true, true, true); -- ringright
		ApplyShopItemToPed(charPed, 948647349, true, true, true); -- coat
    end
end

local function skyCam(bool)
    if bool then
        DoScreenFadeIn(1000)
        SetTimecycleModifier('hud_def_blur')
        SetTimecycleModifierStrength(1.0)
        cam = CreateCam("DEFAULT_SCRIPTED_CAMERA")
        SetCamCoord(cam, 1548.80, 1187.90, 284.29)
        SetCamRot(cam, -20.0, 0.0, 83)
        SetCamActive(cam, true)
        RenderScriptCams(true, false, 1, true, true)
        fixedCam = CreateCam("DEFAULT_SCRIPTED_CAMERA")
        SetCamCoord(fixedCam, 1545.80, 1187.90, 284.29)
        SetCamRot(fixedCam, 0.0, 0.0, 100.0)
        SetCamActive(fixedCam, true)
        SetCamActiveWithInterp(fixedCam, cam, 8000, true, true)
        Wait(5900)
        DestroyCam(groundCam)
        InterP = true
    else
        SetTimecycleModifier('default')
        SetCamActive(cam, false)
        DestroyCam(cam, true)
        RenderScriptCams(false, false, 1, true, true)
        FreezeEntityPosition(PlayerPedId(), false)
    end
end

-- Handlers

AddEventHandler('onResourceStop', function(resource)
    if (GetCurrentResourceName() == resource) then
        DeleteEntity(charPed)
        SetModelAsNoLongerNeeded(charPed)
    end
end)

local function openCharMenu(bool)
    RSGCore.Functions.TriggerCallback("rsg-multicharacter:server:GetNumberOfCharacters", function(result)
        SetNuiFocus(bool, bool)
        SendNUIMessage({
            action = "ui",
            toggle = bool,
            nChar = result,
        })
        choosingCharacter = bool
        Wait(100)
        skyCam(bool)
    end)
end

RegisterNetEvent('rsg-multicharacter:client:closeNUI', function()
    DeleteEntity(charPed)
    SetNuiFocus(false, false)
    isChossing = false
end)

RegisterNetEvent('rsg-multicharacter:client:chooseChar', function()
    SetEntityVisible(PlayerPedId(), false, false)
    SetNuiFocus(false, false)
    DoScreenFadeOut(10)
    Wait(1000)
    GetInteriorAtCoords(1542.79, 1187.29, 283.18, -91.68)
    FreezeEntityPosition(PlayerPedId(), true)
    SetEntityCoords(PlayerPedId(), 1542.79, 1187.29, 283.18)
    Wait(1500)
    ShutdownLoadingScreen()
    ShutdownLoadingScreenNui()
    Wait(10)
    exports.weathersync:setMyTime(21, 0, 0, 0, true)
	exports.weathersync:setMyWeather("sunny", 10.0, false, false)
    openCharMenu(true)
    Wait(3000)
    while selectingChar do
        Wait(1)
        local coords = GetEntityCoords(PlayerPedId())
        DrawLightWithRange(coords.x + 10.0, coords.y , coords.z + 10.0 , 255, 255, 255, 15.0, 15.0)
    end
end)

-- NUI
RegisterNUICallback('cDataPed', function(data) -- Visually seeing the char
    local cData = data.cData
    SetEntityAsMissionEntity(charPed, true, true)
    DeleteEntity(charPed)
    if cData ~= nil then
        RSGCore.Functions.TriggerCallback('rsg-multicharacter:server:getAppearance', function(appearance)
            local skinTable = appearance.skin or {}
            DataSkin = appearance.skin
            local clothesTable = appearance.clothes or {}
            local sex = tonumber(skinTable.sex) == 1 and `mp_male` or `mp_female`
            if sex ~= nil then
                CreateThread(function ()
                    RequestModel(sex)
                    while not HasModelLoaded(sex) do
                        Wait(0)
                    end
                    charPed = CreatePed(sex, 1544.10, 1187.65, 283.18, -91.68, false, false)
                    FreezeEntityPosition(charPed, false)
					-- SCENARIO  ---------------------------------------------------------------
					if IsPedMale(charPed) and 'mp_male' then
						TaskStartScenarioInPlace(charPed, joaat('MP_LOBBY_STANDING_C'), -1, true)
					else
						if not IsPedMale(charPed) and 'mp_female' then
						TaskStartScenarioInPlace(charPed, joaat('MP_LOBBY_STANDING_G'), -1, true)
						else
						TaskStartScenarioInPlace(charPed, joaat('MP_LOBBY_STANDING_D'), -1, true)
						end
					end
					-----------------------------------------------------------------------------
                    SetEntityInvincible(charPed, true)
                    SetBlockingOfNonTemporaryEvents(charPed, true)
                    while not IsPedReadyToRender(charPed) do
                        Wait(1)
                    end
                    exports['rsg-appearance']:ApplySkinMultiChar(skinTable, charPed, clothesTable)
                end)
            else
                CreateThread(function()
                    local randommodels = {
                        "mp_male",
                        "mp_female",
                    }
                    local randomModel = randommodels[math.random(1, #randommodels)]
                    local model = joaat(randomModel)
                    RequestModel(model)
                    while not HasModelLoaded(model) do
                        Wait(0)
                    end
					-- SCENARIO  ---------------------------------------------------------------
					if IsPedMale(charPed) and 'mp_male' then
						TaskStartScenarioInPlace(charPed, joaat('MP_LOBBY_STANDING_C'), -1, true)
					else
						if not IsPedMale(charPed) and 'mp_female' then
						TaskStartScenarioInPlace(charPed, joaat('MP_LOBBY_STANDING_G'), -1, true)
						else
						TaskStartScenarioInPlace(charPed, joaat('MP_LOBBY_STANDING_D'), -1, true)
						end
					end
					-----------------------------------------------------------------------------
                    Wait(100)
                    baseModel(randomModel)
                    charPed = CreatePed(model, 1544.10, 1187.65, 283.18, -91.68, false, false)
                    FreezeEntityPosition(charPed, false)
                    SetEntityInvincible(charPed, true)
                    SetBlockingOfNonTemporaryEvents(charPed, true)
                end)
            end
        end, cData.citizenid)
    else
        CreateThread(function()
            local randommodels = {
                "mp_male",
                "mp_female",
            }
            local randomModel = randommodels[math.random(1, #randommodels)]
            local model = joaat(randomModel)
            RequestModel(model)
            while not HasModelLoaded(model) do
                Wait(0)
            end
            charPed = CreatePed(model, 1544.10, 1187.65, 283.18, -91.68, false, false)
			-- SCENARIO  ---------------------------------------------------------------
			if IsPedMale(charPed) and 'mp_male' then
				TaskStartScenarioInPlace(charPed, joaat('MP_LOBBY_STANDING_C'), -1, true)
			else
				if not IsPedMale(charPed) and 'mp_female' then
				TaskStartScenarioInPlace(charPed, joaat('MP_LOBBY_STANDING_G'), -1, true)
				else
				TaskStartScenarioInPlace(charPed, joaat('MP_LOBBY_STANDING_D'), -1, true)
				end
			end
			-----------------------------------------------------------------------------
            Wait(100)
            baseModel(randomModel)
            FreezeEntityPosition(charPed, false)
            SetEntityInvincible(charPed, true)
            NetworkSetEntityInvisibleToNetwork(charPed, true)
            SetBlockingOfNonTemporaryEvents(charPed, true)
        end)
    end
end)

RegisterNUICallback('closeUI', function()
    openCharMenu(false)
end)

RegisterNUICallback('disconnectButton', function()
    SetEntityAsMissionEntity(charPed, true, true)
    DeleteEntity(charPed)
    TriggerServerEvent('rsg-multicharacter:server:disconnect')
end)

RegisterNUICallback('selectCharacter', function(data)
    selectingChar = false
    local cData = data.cData
    if DataSkin ~= nil then
        DoScreenFadeOut(10)
        TriggerServerEvent('rsg-multicharacter:server:loadUserData', cData)
        openCharMenu(false)
        local model = IsPedMale(charPed) and 'mp_male' or 'mp_female'
        SetEntityAsMissionEntity(charPed, true, true)
        DeleteEntity(charPed)
        Wait(5000)
        TriggerServerEvent("rsg-appearance:loadSkin")
        Wait(500)
        TriggerServerEvent("rsg-clothes:LoadClothes", 1)
        SetModelAsNoLongerNeeded(model)
    else
        DoScreenFadeOut(10)
        TriggerServerEvent('rsg-multicharacter:server:loadUserData', cData, true)
        openCharMenu(false)
        local model = IsPedMale(charPed) and 'mp_male' or 'mp_female'
        SetEntityAsMissionEntity(charPed, true, true)
        DeleteEntity(charPed)
        SetModelAsNoLongerNeeded(model)
    end
end)

RegisterNUICallback('setupCharacters', function() -- Present char info
    RSGCore.Functions.TriggerCallback("rsg-multicharacter:server:setupCharacters", function(result)
        SendNUIMessage({
            action = "setupCharacters",
            characters = result,
        })
    end)
end)

RegisterNUICallback('removeBlur', function()
    SetTimecycleModifier('default')
end)

RegisterNUICallback('createNewCharacter', function(data) -- Creating a char
    selectingChar = false
    DoScreenFadeOut(150)
    Wait(200)
    TriggerEvent("rsg-multicharacter:client:closeNUI")
    DestroyAllCams(true)
    SetModelAsNoLongerNeeded(charPed)
    DeleteEntity(charPed)
    DoScreenFadeIn(1000)
    FreezeEntityPosition(PlayerPedId(), false)
    TriggerEvent("rsg-appearance:OpenCreator", data)
end)

RegisterNUICallback('removeCharacter', function(data) -- Removing a char
    TriggerServerEvent('rsg-multicharacter:server:deleteCharacter', data.citizenid)
    TriggerEvent('rsg-multicharacter:client:chooseChar')
end)

-- Threads
CreateThread(function()

    repeat Wait(1000) until GetIsLoadingScreenActive()

    RequestImap(-1699673416)
    RequestImap(1679934574)
    RequestImap(183712523)

    TriggerEvent('rsg-multicharacter:client:chooseChar')

    isChossing = true
        CreateThread(function()
            while isChossing do
            Wait(0)
            Citizen.InvokeNative(0xF1622CE88A1946FB)
        end
    end)
end)
