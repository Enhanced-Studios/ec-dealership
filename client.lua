local uiopen = false
local OpenedShop

local OpenVehicleShop = function(class, shop)
    if uiopen then
        SendNUIMessage({
            show = false
        })
        SetNuiFocus(false, false)
        uiopen = false
        OpenedShop = nil
    else
        SendNUIMessage({
            show = true,
            class = class,
            shop = shop,
            vehicles = Config.list
        })
        SetNuiFocus(true, true)
        uiopen = true
        OpenedShop = shop
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
        local isCloseToShop = false
        for key, value in pairs(Config.dealerships) do
            local dist = #(playerPos - value.shop)
            if dist < 10 and not uiopen then
                isCloseToShop = true
                DrawMarker(1, value.shop.x , value.shop.y, value.shop.z-1.02, 0, 0, 0, 0, 0, 0, 0.7,0.7,0.8, 255,255,255, 200, 0, 0, 2, 0, 0, 0, 0)
                if dist < 2.5 then
                    Draw3DText(value.shop, "Press [~p~E~w~] to open the ".. key .. " dealership")
                    if IsControlJustPressed(0, 38) then
                        OpenVehicleShop(value.classes, value.vehiclespawn)
                    end
                end
            end
        end
        if not isCloseToShop then
            Citizen.Wait(2000)
        end
    end
end)


-- NUI EVENTS

RegisterNUICallback('close', function(data)
    OpenVehicleShop()
end)

RegisterNUICallback('buy', function(data)
    local vehicle = data.vehicle
    local spawnplace = OpenedShop
    TriggerServerEvent('ec_dealership:buy', vehicle, spawnplace)
end)