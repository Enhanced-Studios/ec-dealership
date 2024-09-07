local uiopen = false

local OpenVehicleShop = function()
    if uiopen then
        SendNUIMessage({
            show = false
        })
        SetNuiFocus(false, false)
        uiopen = false
    else
        SendNUIMessage({
            show = true,
            vehicles = Config.list
        })
        SetNuiFocus(true, true)
        uiopen = true
    end
end

local Draw3DText = function(coords, text)
    local onScreen, _x, _y = World3dToScreen2d(coords.x, coords.y, coords.z)
    local p = GetGameplayCamCoords()
    local distance = GetDistanceBetweenCoords(p.x, p.y, p.z, coords.x, coords.y, coords.z, 1)
    local scale = (1 / distance) * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    local scale = scale * fov * 0.5
    if onScreen then
        SetTextScale(0.0, scale)
        SetTextFont(0)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        local ped = PlayerPedId()
        local playerPos = GetEntityCoords(ped, true)

        local distance = Vdist(playerPos.x, playerPos.y, playerPos.z, Config.shop.x , Config.shop.y, Config.shop.z)
        if distance < 20 and not uiopen then
            DrawMarker(1, Config.shop.x , Config.shop.y, Config.shop.z-1.02, 0, 0, 0, 0, 0, 0, 0.7,0.7,0.8, 255,255,255, 200, 0, 0, 2, 0, 0, 0, 0)
            if distance < 2.5 then
                Draw3DText(Config.shop, "Press [~p~E~w~] to open the vehicle shop")
                if IsControlJustPressed(0, 38) then
                    OpenVehicleShop()
                end
            end
        else
            Citizen.Wait(1000)
        end
    end
end)


-- NUI EVENTS

RegisterNUICallback('close', function(data, cb)
    OpenVehicleShop()
end)

RegisterNUICallback('buy', function(data, cb)
    local vehicle = data.vehicle
    TriggerServerEvent('ec_dealership:buy', vehicle)
end)