local uiopen = false
local OpenedShop

local OpenVehicleShop = function(shop)
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
            class = shop.classes,
            shop = shop.vehiclespawn,
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

local CreateBlip = function(coords, name)
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, 810)
    SetBlipScale(blip, 0.7)
    SetBlipColour(blip, 7)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(name)
    EndTextCommandSetBlipName(blip)
end

local isShowcaseVehicle = nil

local DespawnShowcaseVehicle = function()
    if isShowcaseVehicle then
        DeleteEntity(isShowcaseVehicle)
        isShowcaseVehicle = nil
        Wait(100)
        SetEntityCoords(PlayerPedId(), OpenedShop.shop.x, OpenedShop.shop.y, OpenedShop.shop.z - 1)
        SetEntityVisible(PlayerPedId(), true)
        SetEntityCollision(ped, false, true)
    end
end

local SpawnShowcaseVehicle = function(vehicle)
    local hash = GetHashKey(vehicle)
    RequestModel(hash)
    while not HasModelLoaded(hash) do
        Citizen.Wait(0)
    end
    local ped = PlayerPedId()
    local playerPos = GetEntityCoords(ped, true)
    isShowcaseVehicle = CreateVehicle(hash, OpenedShop.showcasespawn, GetEntityHeading(ped), false, false)
    SetPedIntoVehicle(ped, isShowcaseVehicle, -1)
    SetVehicleOnGroundProperly(isShowcaseVehicle)
    SetEntityAsMissionEntity(isShowcaseVehicle, true, true)
    SetVehicleDoorsLocked(isShowcaseVehicle, 2)
    SetVehicleEngineOn(isShowcaseVehicle, true, true, false)
    SetVehicleUndriveable(isShowcaseVehicle, true)
    SetEntityCollision(ped, true, false)
    SetEntityCollision(isShowcaseVehicle, true, false)
    SetEntityVisible(ped, false)
    FreezeEntityPosition(isShowcaseVehicle, true)
end

if not Config.ox_target then
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
                            OpenVehicleShop(Config.dealerships[key])
                        end
                    end
                end
            end
            if not isCloseToShop then
                Citizen.Wait(2000)
            end
        end
    end)
else
    for key, value in pairs(Config.dealerships) do
        exports.ox_target:addSphereZone({
            coords = value.shop,
            radius = 1,
            debug = false,
            drawSprite = true,
            options = {
                {
                    name =  key,
                    onSelect = function()
                        OpenVehicleShop(Config.dealerships[key])
                    end,
                    icon = 'fa-solid fa-circle',
                    label = key .. 'Dealership',
                }
            }
        })
    end
end

-- NUI EVENTS

RegisterNUICallback('close', function(data, cb)
    OpenVehicleShop()
    cb("ok")
end)

RegisterNUICallback('buy', function(data, cb)
    local vehicle = data.vehicle
    local spawnplace = OpenedShop.vehiclespawn
    DespawnShowcaseVehicle()
    TriggerServerEvent('ec_dealership:buy', vehicle, spawnplace)
    OpenVehicleShop()
    cb("ok")
end)

RegisterNUICallback('Showcase', function(data, cb)
    if data.type == "close" then
        DespawnShowcaseVehicle()
        RenderScriptCams(false, false, 0, true, true)
        DestroyCam(cam, false)
        SetNuiFocus(true, true)
        cam = nil
    elseif data.type == "closefull" then
        DespawnShowcaseVehicle()
        OpenVehicleShop()
        RenderScriptCams(false, false, 0, true, true)
        DestroyCam(cam, false)
        cam = nil
    else
        local vehicle = data.vehicle
        SpawnShowcaseVehicle(vehicle)
        SetNuiFocus(true, false)
    end
    cb("ok")
end)

-- LOADING BLIPS

for key, value in pairs(Config.dealerships) do
    CreateBlip(value.shop, key .. " Dealership")
end

