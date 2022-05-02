ESX = nil
Citizen.CreateThread(function()
	while true do
		Wait(5)
		if ESX ~= nil then
		
		else
			ESX = nil
			TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		end
	end
end)

--station = {}
--station.prototype = {owner = nil, account = 0, fuel = 0, x = 0, y = 0, z = 0, sold = false, id = nil}
--station.metatable = {__index = station.prototype}

--function station:new(o)
--	setmetatable(o, station.metatable)
--	return o
--end


local fuelBlips = {}

local nearStation = nil

local closeStation = nil
local closeDistance = 5000

local gasstationPrice = 150000



Citizen.CreateThread(function()

	while true do
		Citizen.Wait(0)
		if(closeDistance <= 25) and GetBlipColour(fuelBlips[closeStation.id]) == 1 and (nearStation.owner == nil) then
			DisplayHelpText('Drücke ~INPUT_INTERACTION_MENU~ um die Tankstelle zu kaufen ($' .. gasstationPrice .. ')')

			if(IsControlJustPressed(0, 244)) then
				ESX.TriggerServerCallback('igs:doesOwn', function(outcome)
					if(outcome) then
						ESX.ShowNotification('~r~Du besitzt bereits eine Tankstelle!')
					else
						TriggerServerEvent('igs:buyStation', closeStation.id)
					end
				end)
			end
		end
	end

end)

Citizen.CreateThread(function()

	while ESX == nil do
		Citizen.Wait(5)
	end
	while true do

		Citizen.Wait(2500)

		getNearestStation()

		local nearestStation = nil
		local count = 0

		while nearestStation == nil do
			nearestStation = nearStation
			if(count >= 600) then
				return
			end
			Citizen.Wait(5)
			count = count + 1
		end

		local pedX, pedY, pedZ = table.unpack(GetEntityCoords(GetPlayerPed(-1)))
		local distance = GetDistanceBetweenCoords(nearestStation.x, nearestStation.y, nearestStation.z, pedX, pedY, pedZ)

		if(distance < 10) then

			if(isStationUseable(nearestStation)) then
				--print("Station is useable")
				-- You can fuel maybe
			else
			--	print("Station is not useable")
				if(nearestStation.owner == nil) then
				--	print("Station has no owner")
					-- You can buy this gasstation
				end
			end
		end
	end	

end)

function getStationObject()
	return nearStation
end

function getNearestStation()


	local stationToReturn = nil

	local nearX = nil
	local nearY = nil
	local nearZ = nil
	local closestStation = nil
	ESX.TriggerServerCallback('igs:getStations', function(stations)
		local closestCoordinate = nil
		local plyX, plyY, plyZ = table.unpack(GetEntityCoords(GetPlayerPed(-1)))
		local playerVec = vector3(plyX, plyY, plyZ)
		for k, v in pairs(stations) do

			local ramVec = vector3(v.x, v.y, v.z)
			local currentCoordinate = #(playerVec.xy - ramVec.xy)
			if(closestCoordinate == nil) then
				closestCoordinate = currentCoordinate
				closestStation = v
				if(v.id == 1) then
					nearX = v.x
					nearY = v.y
					nearZ = v.z
					closestCoordinate = currentCoordinate
					closestStation = v
				end
			else

				if(currentCoordinate < closestCoordinate) then
					closestCoordinate = currentCoordinate
					closestStation = v

					nearX = v.x
					nearY = v.y
					nearZ = v.z
				end
			end
		end
	
		
			local stationVec = vector3(nearX, nearY, nearZ)

			closeDistance = #(playerVec.xy - stationVec.xy)
			
			closeStation = closestStation


			if(closestStation.owner ~= nil) then
			stationToReturn = closestStation
			else
				stationToReturn = closestStation
			end
		
			if(stationToReturn ~= nil) then
				nearStation = stationToReturn
			end
		
	end)

end

function isStationUseable(station)
	if(station.owner ~= nil) then
		if(station.fuel > 0) then
			return true
		else
			return false
		end
	else
		return false
	end
end

function buyFuel(fuelAmount, station)
	--local _station = station
	--station.fuel = station.fuel - fuelAmount
	--ESX.TriggerServerCallback('igs:stationPrice', function(price)
	--	local toPay = (fuelAmount * price)
	--	station.account = station.account + toPay
	--	TriggerServerEvent('igs:pay', toPay)
	--end)

	-- Use server table to buyFuel not local station list
end	


function createBlips()

	Citizen.CreateThread(function()
		while ESX == nil do
			Citizen.Wait(5)
		end
		tempStations = nil
		ESX.TriggerServerCallback('igs:getStations', function(stations)

			--if(#fuelBlips > 0) then
				--for k,v in pairs(fuelBlips) do 
					--RemoveBlip(fuelBlips[k])
					--fuelBlips[k] = nil 
				--end
			--end

			tempStations = stations
	
		end)

		while tempStations == nil do 
			Citizen.Wait(100)
		end

		for k,v in pairs(tempStations) do 
			Citizen.Wait(50)
			local x = v.x
			local y = v.y
			local z = v.z
			blip = nil
			if(isStationUseable(v)) then
				

					  blip = CreateBlip(vector3(x, y, z), 'Tankstelle | $' .. v.fuelcost, 2)
					  fuelBlips[k] = blip
				
			else 
				

					  blip = CreateBlip(vector3(x, y, z), 'Tankstelle', 1)
					  fuelBlips[k] = blip
				
			end


		end


	end)

end



function DisplayHelpText(str)
	SetTextComponentFormat("STRING")
	AddTextComponentString(str)
	DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

-- Blip Updater if something has changed

RegisterNetEvent('igs:updateBlip')
AddEventHandler('igs:updateBlip', function(station)

	--print("Replacing stationid " .. station.id)
	

	local blip = fuelBlips[station.id]
	if(station.owner ~= nil) then

		if(station.fuel <= 0) then
			SetBlipSprite(blip, 361)
			SetBlipColour(blip, 17)
			SetBlipAsShortRange(blip, true)
			BeginTextCommandSetBlipName("STRING")
			AddTextComponentString('Tankstelle | $' .. station.fuelcost)
			EndTextCommandSetBlipName(blip)
		else
		
			SetBlipSprite(blip, 361)
			SetBlipColour(blip, 2)
			SetBlipAsShortRange(blip, true)
			BeginTextCommandSetBlipName("STRING")
			AddTextComponentString('Tankstelle | $' .. station.fuelcost)
			EndTextCommandSetBlipName(blip)

		
		end

	else
		SetBlipSprite(blip, 361)
		SetBlipColour(blip, 1)
		SetBlipAsShortRange(blip, true)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString('Tankstelle')
		EndTextCommandSetBlipName(blip)
	end
	fuelBlips[station.id] = blip
end)

function isBlipRendered(blipId)

	for k,_ in pairs(fuelBlips) do 
		if(k == blipId) then
			return true
		end
	end
	return false
end

function renderBlip(station)

	Citizen.CreateThread(function()
	
		if(isStationUseable(station) and not isBlipRendered(station.id)) then
					
	
			blip = AddBlipForCoord(station.x, station.y, station.z)
			SetBlipSprite(blip, 361)
			SetBlipColour(blip, 2)
			SetBlipAsShortRange(blip, true)
			SetBlipDisplay(blip, 6)
			BeginTextCommandSetBlipName("STRING")
			AddTextComponentString('Tankstelle | $' .. station.fuelcost)
			EndTextCommandSetBlipName(blip)
			fuelBlips[station.id] = blip
			--print('Added blip: ' .. station.id)
  		else 	
	  
			if(not isBlipRendered(station.id)) then
				blip = AddBlipForCoord(station.x, station.y, station.z)
				SetBlipSprite(blip, 361)
				SetBlipColour(blip, 1)
				SetBlipAsShortRange(blip, true)
				SetBlipDisplay(blip, 6)
				BeginTextCommandSetBlipName("STRING")
				AddTextComponentString('Tankstelle')
				EndTextCommandSetBlipName(blip)
				fuelBlips[station.id] = blip
				--print('Added blip: (nonuse) ' .. station.id)
			end
	  
  		end

	end)

end

function renderNearbyBlips()

	Citizen.CreateThread(function()
	
		while true do
			Citizen.Wait(5000)
			activeBlips = 0
			local plyX, plyY, plyZ = table.unpack(GetEntityCoords(GetPlayerPed(-1)))

			ESX.TriggerServerCallback('igs:getStations', function(stations)
				
				for k,v in pairs(stations) do 
					Citizen.Wait(50)	
						x = v.x
						y = v.y
						z = v.z
	
						stationVec = vector3(x, y, z)
	
						x, y, z = table.unpack(GetEntityCoords(GetPlayerPed(-1)))
						plyVec = vector3(x, y, z)
	
						distance = #(plyVec.xy - stationVec.xy)

					if(not isBlipRendered(k)) then
						if(distance <= 2500) then

							if(plyY < 600) then
								if(distance <= 750) then
									renderBlip(v)
								end
							else
								renderBlip(v)
							end

						end
					else
						if(plyY < 600) then
							if(distance > 750) then
								--print('Removing blip: ' .. k)
								RemoveBlip(fuelBlips[k])
								fuelBlips[k] = nil
							end
						else
							if(distance > 2500) then
								RemoveBlip(fuelBlips[k])
								fuelBlips[k] = nil
							end
						end
						

						
					end

				end
				for _,_ in pairs(fuelBlips) do activeBlips = activeBlips + 1 end
					--print('Active Blips: ' .. activeBlips)
			end)
		end
		
	end)

end


Citizen.CreateThread(function()

--	while true do
--		Citizen.Wait(((60) * 1000) * 30)
--
--		ESX.TriggerServerCallback('igs:getStations', function(stations)
--	
--			for k,v in pairs(stations) do
--	
--				if(v.owner ~= nil) then
--					if(GetBlipColour(fuelBlips[k]) ~= 2) then
--	
--						--TriggerEvent('igs:updateBlip', v)
--	
--					end
--				end
--				-- This a test, if it's not working replace it with the outlined again
--				TriggerEvent('igs:updateBlip', v)
--	
--			end
--		
--		end)
--
--	end

end)




--renderNearbyBlips()
createBlips()