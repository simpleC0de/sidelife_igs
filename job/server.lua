ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)


-- Keep track of job vehicles - attach fuel values to truck (plate?)
-- Remove fuel if emptied or add fuel when farming
-- two types of fuel?

-- oil = nicht verarbeitet
-- gas = verarbeitet

local registeredVehicles = {}
local vehicleids = {}
-- steamid : plate

local oilVehicles = {}
local gasVehicles = {}
-- plate : fuel

local processingVehicles = {}
-- plate : playerId


RegisterNetEvent('igs:addVehicle')
AddEventHandler('igs:addVehicle', function(plate, id)
    if(not isVehicleRegistered(GetPlayerIdentifier(source, 0), plate)) then
        registerVehicle(GetPlayerIdentifier(source, 0), plate)
        vehicleids[plate] = id
    end
end)

RegisterNetEvent('igs:removeVehicle')
AddEventHandler('igs:removeVehicle', function(plate)
    if(isVehicleRegistered(GetPlayerIdentifier(source, 0), plate)) then
        unregisterVehicle(GetPlayerIdentifier(source, 0), plate)
    end
end)

RegisterNetEvent('igs:removeOil')
AddEventHandler('igs:removeOil', function(plate, amount)
    if(isVehicleRegistered(nil, plate)) then
        oilVehicles[plate] = oilVehicles[plate] - amount
    end
end)

RegisterNetEvent('igs:removeGas')
AddEventHandler('igs:removeGas', function(plate, amount)
    if(isVehicleRegistered(nil, plate)) then
        gasVehicles[plate] = gasVehicles[plate] - amount
    end
end)

RegisterNetEvent('igs:addOil')
AddEventHandler('igs:addOil', function(plate, amount)
    if(isVehicleRegistered(nil, plate)) then
        oilVehicles[plate] = oilVehicles[plate] + amount
    end
end)

RegisterNetEvent('igs:switchFuel')
AddEventHandler('igs:switchFuel', function(plate, amount)

    local _source = source
    if(getProcessingSource(plate) == _source) then
        --print('source = same')
        oilVehicles[plate] = oilVehicles[plate] - amount
        gasVehicles[plate] = gasVehicles[plate] + amount
    else
        --print('source not the same')
        TriggerClientEvent('gorok_notify', '~r~Dieses Fahrzeug wird bereits von jemandem benutzt!')
    end

end)

RegisterNetEvent('igs:removeProcessor')
AddEventHandler('igs:removeProcessor', function(plate)

    oldProcessor = getProcessingSource(plate)
    if(oldProcessor == source) then
        processingVehicles[plate] = nil
    end
end)



function registerVehicle(owner, plate)
    registeredVehicles[owner] = plate
    oilVehicles[plate] = 0
    gasVehicles[plate] = 0
end

function unregisterVehicle(owner, plate)
    registeredVehicles[owner] = nil
    oilVehicles[plate] = nil
    gasVehicles[plate] = nil
end

function isVehicleRegistered(owner, plate)

    for k,v in pairs(registeredVehicles) do
        if(owner == nil) then
            if(v == plate) then
                return true
            end
        else
            if(k == owner and v == plate) then
                return true
            end
        end
    end
    return false
end

function getVehicleOil(plate)

    for k, v in pairs(oilVehicles) do 
        if k == plate then
            return v
        end
    end
    return 0
end

function getVehicleGas(plate)
    if(plate == "") then return 0 end
    for k,v in pairs(gasVehicles) do 
        if k == plate then
            return v
        end 
    end
    return 0
end

function containsGas(plate)

    for k,_ in pairs(gasVehicles) do
        if k == plate then
            return true
        end
    end
    return false
end

function containsOil(plate)

    for k_v in pairs(oilVehicles) do 
        if k == plate then
            return true
        end
    end
    return false
end

function getOwnerWithPlate(plate)
    -- Might not be functioning well if players have multiple active vehicles
    for k,v in pairs(registeredVehicles) do 
        if(v == plate) then
            return k
        end
    end 
    return 0
end

function isPlateProcessing(plate)

    for k,_ in pairs(processingVehicles) do 
        if(k == plate) then
            return true
        end
    end
    return false
end

function getProcessingSource(plate)
    for k,v in pairs(processingVehicles) do
        if(k == plate) then
            return v
        end 
    end
    return nil
end


ESX.RegisterServerCallback('igs:returnVehicle', function(source, cb, plate)
    
    _source = source
    xPlayer = ESX.GetPlayerFromId(_source)
    steamId = GetPlayerIdentifier(_source, 0)

    if(isVehicleRegistered(steamId, plate)) then
        xPlayer.addAccountMoney('bank', 3500)
        xPlayer.showNotification('~g~Dir wurden $3500 gutgeschrieben')
        unregisterVehicle(steamId, plate)
        cb(true)
    else
        xPlayer.showNotification('~r~Nur der Besitzer kann seinen Wagen zurückgeben')
        cb(false)
    end

end)

ESX.RegisterServerCallback('igs:isRegistered', function(source, cb, plate)
    if(isVehicleRegistered(nil, plate)) then
        cb(true)
    end
    cb(false)
end)

ESX.RegisterServerCallback('igs:getGas', function(source, cb, plate)
    cb(getVehicleGas(plate))
end)

ESX.RegisterServerCallback('igs:getOil', function(source, cb, plate)
    --print('vehicle oil: ' .. getVehicleOil(plate))
    cb(getVehicleOil(plate))
end)

ESX.RegisterServerCallback('igs:getVehicleByPlate', function(source, cb, plate)
    cb(vehicleids[plate])
end)

ESX.RegisterServerCallback('igs:processOil', function(source, cb, plate)

    local _source = source
    local _plate = plate

    -- todo : if vehicle is already farming abort farming and send back 0

    -- processingVehicles - plate | source

    
    if(isPlateProcessing(plate)) then

        -- plate is already processing
        -- 

        initialProcessor = getProcessingSource(plate) -- This player started processing for the plate requested

        print("[{IGS}] Plate: " .. plate .. " wollte 2x verarbeitet werden!")
        cb({oil = 0, processTime = 999999})
        return
    end


    storedOil = getVehicleOil(plate)

    timePerLitre = 1 -- Use full numbers! (Example: 1, 2, 3 4, 12, 1352, 6123) do not use floats, numbers with decimals (!!!DO NOT!!! 0.5, 1.5, 15.2)

    if(storedOil > 0) then

        processingVehicles[plate] = source

        cb({oil = storedOil, processTime = timePerLitre*storedOil})
        return
    else
        cb({oil = 0, processTime = 0})
        return
    end

    cb({oil = 0, processTime = 0})
    return
end)


Citizen.CreateThread(function()
    while true do
        Citizen.Wait((60) * 1000)

        for k,v in pairs(gasVehicles) do 
            if(v < 0) then
                print('[SideLife IGS] ' .. getOwnerWithPlate(k) .. " hat einen Bug benutzt!")
            end
        end

        for k,v in pairs(oilVehicles) do 
            if(v < 0) then
                print('[SideLife IGS] ' .. getOwnerWithPlate(k) .. " hat einen Bug benutzt!")
            end
        end
    end
end)


-- Keep track of which vehicle is processing so that not 2 players can process the same vehicle (duping)