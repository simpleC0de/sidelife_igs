ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)


-- Gasstation factory

station = {}
station.prototype = {owner = nil, account = 0, fuel = 0, x = 0, y = 0, z = 0, sold = false, id = nil}
station.metatable = {__index = station.prototype}

function station:new(o)
	setmetatable(o, station.metatable)
	return o
end


local stations = {}

local station1 = station:new({owner = "peter", account = 420})
local station2 = station:new({owner = "mario", account = 690})


function retrieveGasStation()

    MySQL.Async.fetchAll('SELECT * FROM gasstations WHERE owner IS null', {}, function(players)
        for k,_ in pairs(players) do
            stations[players[k].id] = station:new({owner = players[k].owner, account = players[k].account, fuel = players[k].fuel, fuelcost = players[k].fuelcost, buyprice = players[k].buyprice, soldfuel = players[k].soldfuel, x = players[k].x, y = players[k].y, z = players[k].z, sold = false, id = players[k].id})
        end
    end)


    MySQL.Async.fetchAll('SELECT * FROM gasstations WHERE owner IS NOT null', {}, function(players)
            for k,_ in pairs(players) do
                dbOject = players[k]
                local gasStation = station:new({owner = dbOject.owner, account = dbOject.account, fuel = dbOject.fuel, fuelcost = dbOject.fuelcost, buyprice = dbOject.buyprice, soldfuel = dbOject.soldfuel, x = dbOject.x, y = dbOject.y, z = dbOject.z, sold = true, id = players[k].id})
                stations[dbOject.id] = gasStation
            end
    end)

end

-- Database Update Thread
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5000)
        retrieveGasStation()
    end
end)


function printOutInfo()
    Citizen.CreateThread(function()
    
        if(#stations > 23) then
            Citizen.Wait(1000)
        end

        for k, v in pairs(stations) do
            if(v.id == 21 or v.id == "21") then
                print("Index: " .. k)
                print("Owner: " .. "ist null")
                print("Account: " .. v.account)
                print("Fuel: " .. v.fuel)
                print("X: " .. v.x)
                print("Y: " .. v.y)
                print("Z: " .. v.z)
                print("Sold: " .. "true oder false")
                print("---------------------")
            end
        end
    
    end)
end

function getStationFromId(id)
    local returnStation = nil
    for _,v in pairs(stations) do
        if(id == v.id) then
            returnStation = v
        end
    end
    return returnStation
end

function updateStationParam(stationId, param, value)
    local station = getStationFromId(stationId)
    if(param == "owner") then

    end
    if(param == "fuel") then

    end
    if(param == "buyprice") then
        station.buyprice = value
    end
    if(param == "fuelcost") then
        station.fuelcost = value
    end
    refreshStation(stationId, station)
end

function updateAccount(stationId, amount, mathSymbol)
    local station = getStationFromId(stationId)
    local currentAccount = station.account

    -- TRUE equals +
    -- FALSE equals -

    if(mathSymbol) then
        station.account = currentAccount + amount
    else
        station.account = currentAccount - amount
    end
    asyncMySql('UPDATE gasstations SET account = ' .. station.account .. ' WHERE id = ' .. stationId)
    refreshStation(station.id, station)
end

function updateSoldfuel(stationId, amount, mathSymbol)
    local station = getStationFromId(stationId)
    local currentFuel = station.soldfuel

    -- TRUE equals +
    -- FALSE equals -

    if(mathSymbol) then
        station.soldfuel = currentFuel + amount
        asyncMySql('UPDATE gasstations SET soldfuel = soldfuel + ' .. amount .. ' WHERE id = ' .. stationId)
    else
        station.soldfuel = currentFuel - amount
        asyncMySql('UPDATE gasstations SET soldfuel = soldfuel - ' .. amount .. ' WHERE id = ' .. stationId)
    end

    refreshStation(station.id, station)
end

function doesPlayerOwn(source) 
    local steamId = GetPlayerIdentifier(source, 0)
    for _,v in pairs(stations) do 
        if(v.owner ~= nil) then
            if(v.owner == steamId) then
                return true
            end
        end
    end
    return false
end

function doesPlayerOwnStation(source, station)
    local steamId = GetPlayerIdentifier(source, 0)
    for k,v in pairs(stations) do

        if(v.owner ~= nil) then
            if(v.owner == steamId and v.id == station) then
                return true
            end
        end

    end
    return false
end


function refreshStation(stationId, value)
    local stationtoUpdate = getStationFromId(stationId)
    stations[stationId] = value
end

function asyncMySql(query)
    MySQL.Async.execute(query, {}, function(rowsChanged) if(rowsChanged < 1) then print('query failure : 143 /server/main.lua') end end)
end




-- ESX ServerCallbacks

ESX.RegisterServerCallback('igs:doesOwn', function(source, cb)
    cb(doesPlayerOwn(source))
end)

ESX.RegisterServerCallback('igs:getStation', function(source, cb)
    local stationToReturn = nil
    local steamId = GetPlayerIdentifier(source, 0)
    for _,v in pairs(stations) do
        if(v.owner ~= nil) then
            if(v.owner == steamId) then
                stationToReturn = v
            end
        end
    end
    cb(stationToReturn)
end)


ESX.RegisterServerCallback('igs:getOwner', function(source, cb, stationId)
    cb(getStationFromId(stationId).owner)
end)

ESX.RegisterServerCallback('igs:getFuel', function(source, cb, stationId)
    cb(getStationFromId(stationId.fuel))
end)

ESX.RegisterServerCallback('igs:getAccount', function(source, cb, stationId)
    cb(getStationFromId[stationId].account)
end)

ESX.RegisterServerCallback('igs:getStations', function(source, cb)
    cb(stations)
end)

ESX.RegisterServerCallback('igs:stationPrice', function(source, cb)
    -- Should define the FUEL COST SET FROM THE OWNER
    cb(50)
end)

ESX.RegisterServerCallback('igs:getSoldFuel', function(source, cb, stationId)
    cb(getStationFromId(stationId).soldfuel)
end)

ESX.RegisterServerCallback('igs:getFuelPrice', function(source, cb, stationId)
    -- THE PRICE THE CAR PAYS TO GET FILLED UP WITH FUEL // per litre i guess
    cb(getStationFromId(stationId).fuelcost)
end)

ESX.RegisterServerCallback('igs:getBuyPrice', function(source, cb, stationId)
    -- THE PRICE THE OWNER PAYS TO GET FUEL
    cb(getStationFromId(stationId).buyprice)
end)


--NetEvents
RegisterNetEvent('igs:syncBlips')
AddEventHandler('igs:syncBlips', function(stationId)
    Citizen.CreateThread(function()
        --print("Received id: " .. stationId)
        TriggerClientEvent('igs:updateBlip', -1, getStationFromId(stationId))
    end)
end)

RegisterNetEvent('igs:updateFuelPrice')
AddEventHandler('igs:updateFuelPrice', function(stationId, newPrice)
    --fuelcost
    local restation = getStationFromId(stationId)
    restation.fuelcost = newPrice
    MySQL.Async.execute('UPDATE gasstations SET fuelcost = ' .. newPrice .. ' WHERE id = ' .. stationId, {}, function(rowsChanged) end)
    refreshStation(stationId, restation)
end)

RegisterNetEvent('igs:updateFuel')
AddEventHandler('igs:updateFuel', function(stationId, soldFuel)
    --fuelcost
    local restation = getStationFromId(stationId)
    restation.fuel = restation.fuel - soldFuel
    MySQL.Async.execute('UPDATE gasstations SET fuel = fuel - ' .. soldFuel .. ' WHERE id = ' .. stationId, {}, function(rowsChanged) end)
    refreshStation(stationId, restation)
end)

RegisterNetEvent('igs:buyFuel')
AddEventHandler('igs:buyFuel', function(stationId, boughtFuel, price)

    local restation = getStationFromId(stationId)
    restation.fuel = restation.fuel + boughtFuel
    asyncMySql('UPDATE gasstations SET fuel = fuel + ' .. boughtFuel .. ' WHERE id = ' .. stationId)
    updateAccount(stationId, price, false)
    xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.addAccountMoney('bank', price)
end)

RegisterNetEvent('igs:updateAccount')
AddEventHandler('igs:updateAccount', function(stationId, price)
    --paying the shit
    updateAccount(stationId, price, true)
end)


RegisterNetEvent('igs:updateBuyPrice')
AddEventHandler('igs:updateBuyPrice', function(stationId, newPrice)
    --Maybe check if the owner == source
    --buyprice
    local restation = getStationFromId(stationId)
    restation.buyprice = newPrice
    MySQL.Async.execute('UPDATE gasstations SET buyprice = ' .. newPrice .. ' WHERE id = ' .. stationId, {}, function(rowsChanged) end)
    refreshStation(stationId, restation)
end)

RegisterNetEvent('igs:updateSoldFuel')
AddEventHandler('igs:updateSoldFuel', function(stationId, litres)
    --soldfuel
    updateSoldfuel(stationId, litres, true)
end)

RegisterNetEvent('igs:syncFuel')
AddEventHandler('igs:syncFuel', function(table)
    TriggerClientEvent('igs:sync', -1, table)
end)

RegisterServerEvent('igs:updateStation')
AddEventHandler('igs:updateStation', function(station)
    -- Used for fuel increase money increase or decrease
    local newStation = station
    stations[station.id] = newStation
end)

RegisterServerEvent('igs:pay')
AddEventHandler('igs:pay', function(toPay)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    xPlayer.removeAccountMoney('bank', toPay)
end)

RegisterServerEvent('igs:withdraw')
AddEventHandler('igs:withdraw', function(stationId, amount)
    --stationId, amount, mathSymbol
    xPlayer = ESX.GetPlayerFromId(source)
    if(doesPlayerOwnStation(source, stationId)) then
        if(getStationFromId(stationId).account - amount >= 0) then
            xPlayer.addAccountMoney('bank', amount)
            updateAccount(stationId, amount, false)
            xPlayer.showNotification('~g~Du hast $' .. amount .. ' abgehoben!')
        else
            xPlayer.showNotification('~r~Du hast nicht so viel Geld auf dem Konto!')
        end
    else
        --print("Player does not own this station??")
    end
end)

RegisterNetEvent('igs:deposit')
AddEventHandler('igs:deposit', function(stationId, amount)

    xPlayer = ESX.GetPlayerFromId(source)
    if(doesPlayerOwnStation(source, stationId)) then

        playerBank = xPlayer.getAccount('bank').money
        if(playerBank - amount >= 0) then
            xPlayer.removeAccountMoney('bank', amount)
            updateAccount(stationId, amount, true)
        else
            xPlayer.showNotification('~r~Du hast nicht so viel Geld!')
        end
        

    else
        --print('Player does not own this station, he wanted to deposit lololol')
    end

end)


RegisterNetEvent('igs:buyStation')
AddEventHandler('igs:buyStation', function(stationId)

    local xPlayer = ESX.GetPlayerFromId(source)
    
    local accountMoney = xPlayer.getAccount('bank').money
    --print('Accountmoney: ' .. accountMoney)

    if(accountMoney >= 150000) then

            local steamId = GetPlayerIdentifier(source, 0)
                MySQL.Async.execute('UPDATE gasstations SET owner = "' .. steamId .. '" WHERE id = ' .. stationId, {}, function(rowsChanged)

                    retrieveGasStation()
            end)
            --print('Triggering updateblip')
            TriggerClientEvent('igs:updateBlip', -1, getStationFromId(stationId))
            
            xPlayer.removeAccountMoney('bank', 150000)
            xPlayer.showNotification('~g~Du hast die Tankstelle gekauft!')
            TriggerEvent('igs:updateBuyPrice', stationId, getStationFromId(stationId).buyprice)

    else 
        xPlayer.showNotification('~r~Du hast nicht genug Geld!')
    end


end)


-- Must be called when the script stats to collect data (takes around 90 - 130ms to fetch everything)
retrieveGasStation()
