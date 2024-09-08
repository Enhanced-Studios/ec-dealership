local function GetRandomNumber(Length)
    local Result = ''
    for i = 1, Length do
        Result = Result .. tostring(math.random(0, 9))
    end
    return Result
end

local function GetRandomLetter(Length)
    local Result = ''
    for i = 1, Length do
        Result = Result .. string.char(math.random(26) + 64)
    end
    return Result
end

if Config.framework == "ESX" then
    ESX = exports["es_extended"]:getSharedObject()

    GeneratePlate = function()
        math.randomseed(GetGameTimer())
    
        local generatedPlate = string.upper(GetRandomLetter(2) .. " " .. GetRandomNumber(4))
    
        local isTaken = MySQL.Sync.fetchScalar('SELECT plate FROM owned_vehicles WHERE plate = ?', {generatedPlate})
        if isTaken then 
            return GeneratePlate()
        end
    
        return generatedPlate
    end

    Player = function(source)
        return ESX.GetPlayerFromId(source)
    end

    AddVehicle = function(user_id, vehicle)
        local plate = GeneratePlate()
        MySQL.insert('INSERT INTO owned_vehicles (owner, plate, vehicle) VALUES (?, ?, ?)', {user_id.identifier, plate, json.encode({model = joaat(vehicle), plate = plate})
        }, function(rowsChanged)
            if rowsChanged > 0 then
                print("Added vehicle to owned_vehicles")
            end
        end)
        return plate
    end

    Pay = function(user_id, amount)
        if user_id.getAccount('bank').money >= amount then
            user_id.removeAccountMoney("bank", amount)
            return true
        elseif user_id.getAccount('money').money >= amount then
            user_id.removeAccountMoney("money", amount)
            return true
        else
            print('INGEN PENGE')
            return false
        end
    end

    SpawnVehicle = function(source, model, plate, spawnplace)
        ESX.OneSync.SpawnVehicle(model, spawnplace.xyz, spawnplace.w, {plate = plate}, function(vehicle)
            Wait(100)
            local vehicle = NetworkGetEntityFromNetworkId(vehicle)
            Wait(300)
            TaskWarpPedIntoVehicle(GetPlayerPed(source), vehicle, -1)
        end)
    end

    Notify = function(user_id, message)
        TriggerClientEvent('esx:showNotification', user_id.source, message)
    end
elseif Config.framework == "vRP" then
    vRP = module("vrp", "lib/Proxy").getInterface("vRP")

    Player = function(source)
        return vRP.getUserId({source})
    end

    AddVehicle = function(user_id, vehicle)
        MySQL.Async.execute("INSERT INTO vrp_user_vehicles (user_id, vehicle) VALUES (?, ?)", {user_id, vehicle})
        return
    end

    Pay = function(user_id, amount)
        if vRP.tryFullPayment({user_id, amount}) then
            return true
        else
            return false
        end
    end

    Notify = function(user_id, message)
        vRPclient.notify({user_id, {message}})
    end
elseif Config.framework == "Qbcore" then
    QBCore = exports['qb-core']:GetCoreObject()

    GeneratePlate = function()
        math.randomseed(GetGameTimer())
    
        local generatedPlate = string.upper(GetRandomLetter(2) .. " " .. GetRandomNumber(4))
    
        local isTaken = MySQL.Sync.fetchScalar('SELECT plate FROM player_vehicles WHERE plate = ?', {generatedPlate})
        if isTaken then 
            return GeneratePlate()
        end
    
        return generatedPlate
    end

    Player = function(source)
        return QBCore.Functions.GetPlayer(source)
    end

    AddVehicle = function(user_id, vehicle)
        MySQL.Async.execute('INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, garage, state) VALUES (?, ?, ?, ?, ?, ?, ?, ?)', {
            user_id.PlayerData.license,
            user_id.PlayerData.citizenid,
            vehicle,
            GetHashKey(vehicle),
            '{}',
            GeneratePlate(),
            'pillboxgarage',
            0
        })
        return
    end

    Pay = function(user_id, amount)
        if user_id.Functions.RemoveMoney('cash', amount, 'DealerShip') or user_id.Functions.RemoveMoney('bank', amount, 'DealerShip') then
            return true
        else
            return false
        end
    end

    Notify = function(ply, message)
        QBCore.Functions.Notify(message)
    end
end


RegisterServerEvent("ec_dealership:buy")
AddEventHandler("ec_dealership:buy", function(vehicle, spawnplace)
    local source = source
    local ply = Player(source)
    if ply then
        if Pay(ply, Config.list[vehicle].price) then
            local plate = AddVehicle(ply, vehicle)
            if plate then
                SpawnVehicle(source, vehicle, plate, spawnplace)
            end
            Notify(ply, "You bought a " .. vehicle)
        else
            Notify(ply, "You don't have enough money")
        end
    end
end)