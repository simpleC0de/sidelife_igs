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


local rentalTruck = GetHashKey('oiltanker')
local rentalTrailer = GetHashKey('tanker')

RequestModel(rentalTruck)
RequestModel(rentalTrailer)


function spawnTruck(x, y, z, h)

    loaded = false
    while not HasModelLoaded(rentalTruck) and not HasModelLoaded(rentalTrailer) do 
        if(loaded == false) then
            RequestModel(rentalTruck)
            RequestModel(rentalTailer)
            loaded = true
        end
        Citizen.Wait(0)
    end

    truck = CreateVehicle(rentalTruck, x, y, z, h, true, false)
    SetVehicleOnGroundProperly(truck)
    TaskWarpPedIntoVehicle(GetPlayerPed(-1), truck, -1)
    --trailer = CreateVehicle(rentalTrailer, x, y, z, h, true, false)
    --AttachVehicleToTrailer(truck, trailer, 15)

    --SetVehicleOnGroundProperly(trailer)
    SetModelAsNoLongerNeeded(rentalTruck)
    --SetModelAsNoLongerNeeded(rentalTrailer)

    SetFuel(truck, 100)

    TriggerServerEvent('igs:addVehicle', GetVehicleNumberPlateText(truck), truck)

end


 local rentalSpawn = vector4(1200.79, -1457.25, 34.90, 0.37) -- x, y, z, w

 local farmingBlip = vector3(602.73, 2884.79, 39.39)
 local farmingRadius = 25

 local processingBlip = vector3(2777.31, 1495.10, 24.03)

 Citizen.CreateThread(function()


    Citizen.Wait(2500)

    -- Create Blips
    blip = AddBlipForCoord(rentalSpawn.x, rentalSpawn.y, rentalSpawn.z)
    SetBlipSprite(blip, 477)
    SetBlipDisplay(blip, 4)
	SetBlipScale(blip, 1.0)
	SetBlipColour(blip, 2)
	SetBlipAsShortRange(blip, true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString('Tanklasterverleih')
    EndTextCommandSetBlipName(blip)
    
    blip = AddBlipForCoord(farmingBlip.x, farmingBlip.y, farmingBlip.z)
    SetBlipSprite(blip, 436)
    SetBlipDisplay(blip, 4)
	SetBlipScale(blip, 1.0)
	SetBlipColour(blip, 2)
	SetBlipAsShortRange(blip, true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString('Ölquelle')
    EndTextCommandSetBlipName(blip)
    
    blip = AddBlipForCoord(processingBlip.x, processingBlip.y, processingBlip.z)
    SetBlipSprite(blip, 467)
    SetBlipDisplay(blip, 4)
	SetBlipScale(blip, 1.0)
	SetBlipColour(blip, 2)
	SetBlipAsShortRange(blip, true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString('Ölverarbeitung')
    EndTextCommandSetBlipName(blip)

 end)

 local nearFarming = false
 local nearProcessing = false
 local nearRental = false

 local lastVehicle = nil
 local lastPlate = nil
 local isRegistered = false

 local isFarming = false
 local isProcessing = false

 local plateFuel = {}

 local lastVehicleOil = 0
 local lastVehicleGas = 0


 Citizen.CreateThread(function()

    coordinateList = {}

    coordinateList['processing'] = processingBlip
    coordinateList['farming'] = farmingBlip
    coordinateList['rental'] = vector3(rentalSpawn.x, rentalSpawn.y, rentalSpawn.z)

    local playerPed = GetPlayerPed(-1)

    distanceList = {}

    while true do 
        Citizen.Wait(0)
        playerPed = GetPlayerPed(-1)
        x, y, z = table.unpack(GetEntityCoords(playerPed))
        playerVec = vector3(x, y, z)

        local distance = 0

        for k,v in pairs(coordinateList) do 
            distance = #(playerVec.xy - v.xy)
            if(distance <= 50) then
                if(k == "processing") then
                    distanceList['processing'] = distance
                    nearProcessing = true
                    dMarker(processingBlip.x, processingBlip.y, processingBlip.z - 1)
                elseif(k == "farming") then
                    distanceList['farming'] = distance
                    nearFarming = true
                elseif(k == "rental") then
                    distanceList['rental'] = distance
                    nearRental = true
                    dMarker(rentalSpawn.x, rentalSpawn.y, rentalSpawn.z - 1)
                end
            else
                if(k == "processing") then
                    distanceList['processing'] = distance
                    nearProcessing = false
                elseif(k == "farming") then
                    distanceList['farming'] = distance
                    nearFarming = false
                elseif(k == "rental") then
                    distanceList['rental'] = distance
                    nearRental = false
                end
            end
        end

        -- Player is near anywhere, exact distance can be obtained by the .distance. variable

        if(nearFarming) then
            -- add oil to last vehicle (registeredVehicle ? check nearby (last vehicle) == registered == owner)
        
            if(distanceList['farming'] <= 20) then

                if(lastVehicle == nil) then
                    DisplayHelpText('Steige in dein Fahrzeug ein!')
                else
                    if(not isRegistered) then
                        DisplayHelpText('Du kannst mit diesem Fahrzeug nicht sammeln!')
                    else
                        DisplayHelpText('Drücke ~INPUT_PICKUP~ um Öl zu sammeln')
                        if(lastVehicleOil >= 5000) then
                            ESX.ShowNotification('~r~Der Tanker ist voll!')
                            isFarming = false
                        else
                            if(IsControlJustReleased(0, 38)) then

                                if(isVehicleNearby()) then
                                    if(IsPedInAnyVehicle(GetPlayerPed(-1), false)) then
                                        ESX.ShowNotification("~r~Steige aus um zu sammeln!")
                                    else
                                        if(isFarming == false) then
                                            isFarming = true
                                            TaskStartScenarioInPlace(GetPlayerPed(-1), 'world_human_gardener_plant', 0, false)
                                            delayFarming(10000)
                                            --ESX.ShowNotification('~g~ Du sammelst Öl.')
                                        end
                                    end
                                else
                                    ESX.ShowNotification('~r~Dein Fahrzeug ist zu weit weg!')
                                end
                            end
                        end

                    end

                end


            end

            
        end

        if(nearProcessing) then
            -- get vehicle oil, process, transform to vehicle gas

            if(distanceList['processing'] <= 5) then
                if(lastVehicle == nil) then
                    DisplayHelpText('Steige in dein Fahrzeug ein!')   
                else    
                    if(not isRegistered) then
                        DisplayHelpText('Das Fahrzeug kann kein Öl verarbeiten!')
                    else
                        DisplayHelpText('Drücke ~INPUT_PICKUP~ um zu verarbeiten')

                        if(IsControlJustReleased(0, 38)) then

                            if(IsPedInAnyVehicle(GetPlayerPed(-1), false)) then
                                ESX.ShowNotification("~r~Steige aus um zu verarbeiten")
                            else
                               
                                if(isVehicleNearby) then
                                    if(not isProcessing) then
                                        isProcessing = true
    
                                        ESX.TriggerServerCallback('igs:processOil', function(processingTime)
                                        
                                            if(processingTime.processTime == 0) then
                                                isProcessing = false
                                                ESX.ShowNotification('~r~Du hast kein Öl in deinem Fahrzeug!')
                                            else
                                               if(processingTime.processTime == 999999) then
                                                isProcessing = false
                                                ESX.ShowNotification('~r~Das Fahrzeug wird bereits verarbeitet!')
                                               else
                                                Citizen.CreateThread(function()
                                                
                                                    leftTime = processingTime.processTime
                                                    leftTime = ESX.Math.Round(leftTime)
                                                    storedOil = processingTime.oil
                                                    timePerLitre = leftTime / storedOil
                                                    countTo = timePerLitre / 0.25
                                                    ESX.ShowNotification('~g~Warte ' .. leftTime .. ' Sekunden..')
                                                    counter = 0
                                                    switchNumber = 2
                                                    leftTime = (leftTime / switchNumber)
                                                    while isProcessing do
                                                        Citizen.Wait(250)
                                                        counter = counter + 1
                                                        if(distanceList['processing'] > 5) then
                                                            isProcessing = false
                                                            TriggerServerEvent('igs:removeProcessor', lastPlate)
                                                            ESX.ShowNotification('~r~Verarbeiten abgebrochen!')
                                                        end 
                                                        if(isProcessing) then
    
                                                            
                                                            if((storedOil - switchNumber) < 0) then
                                                                
                                                                if(counter == countTo) then
                                                                    counter = 0
                                                                    
                                                                    TriggerServerEvent('igs:switchFuel', lastPlate, storedOil)
                                                                    leftTime = 0
                                                                    storedOil = 0

                                                                    if(leftTime % 20 == 0 and leftTime ~= 0) then
                                                                        ESX.ShowNotification('~g~Warte ' .. leftTime .. ' Sekunden..')
                                                                    end
                                                                end

                                                            else

                                                                if(counter == countTo) then
                                                                    counter = 0
                                                                    leftTime = leftTime - timePerLitre
                                                                    storedOil = storedOil - switchNumber
                                                                    TriggerServerEvent('igs:switchFuel', lastPlate, switchNumber)
    
                                                                    if(leftTime % 20 == 0 and leftTime ~= 0) then
                                                                        ESX.ShowNotification('~g~Warte ' .. leftTime .. ' Sekunden..')
                                                                    end
                                                                end

                                                            end

                                                            if(leftTime <= 0 or storedOil == 0) then
    
                                                                isProcessing = false
                                                                TriggerServerEvent('igs:removeProcessor', lastPlate)
                                                                ESX.ShowNotification('~g~Verarbeiten abgeschlossen')
    
                                                            end
    
                                                            -- See if processing works
                                                        end
    
                                                    end
    
                                                end)
                                               end
    
                                            end
    
                                        end, lastPlate)
                                    else
                                        ESX.ShowNotification('~g~Du verarbeitest schon!')
                                    end
                                else
                                    ESX.ShowNotification('~r~Dein Fahrzeug ist zu weit weg!')
                                end

                                

                            end

                        end


                    end
                end
            end


        end

        if(nearRental) then

            if(distanceList['rental'] <= 3) then

                if(IsPedInAnyVehicle(GetPlayerPed(-1), false) and isRegistered) then
                    if(GetPedInVehicleSeat(GetVehiclePedIsIn(GetPlayerPed(-1), false), -1) == GetPlayerPed(-1)) then
                        if(isRegistered) then
                            DisplayHelpText("Drücke ~INPUT_PICKUP~ um deinen LKW zurückzugeben")
                            if(IsControlJustReleased(0, 38)) then
                                vehiclePlate = GetVehicleNumberPlateText(GetVehiclePedIsIn(GetPlayerPed(-1), false))

                                ESX.TriggerServerCallback('igs:returnVehicle', function(cb)
                                    if(cb) then
                                        ESX.Game.DeleteVehicle(GetVehiclePedIsIn(GetPlayerPed(-1)))
                                    end
                                end, vehiclePlate)

                            end
                        end
                    end
                else
                    DisplayHelpText('Drücke ~INPUT_PICKUP~ um dir einen LKW auszuleihen ($5000)')
                    if(IsControlJustReleased(0, 38) and canSpawn()) then
                        TriggerServerEvent('igs:pay', 5000)
                        spawnTruck(rentalSpawn.x, rentalSpawn.y, rentalSpawn.z, rentalSpawn.w)
                    end
                end

            end

        end

    end

 end)

 -- Tracks players last vehicle
 Citizen.CreateThread(function()

    while true do 
        Citizen.Wait(2500)

        if(IsPedInAnyVehicle(GetPlayerPed(-1), false)) then
        
            lastVehicle = GetVehiclePedIsIn(GetPlayerPed(-1), false)
            local tempPlate = GetVehicleNumberPlateText(GetVehiclePedIsIn(GetPlayerPed(-1), false))
            if(tempPlate ~= nil) then
               ESX.TriggerServerCallback('igs:isRegistered', function(registered)
				    if(registered) then
					    isRegistered = true
                        lastPlate = tempPlate
				    else
                        isRegistered = false
                        lastPlate = ""
				    end
                end, tempPlate)

            end


        else
            if(DoesEntityExist(lastVehicle)) then

                vehX, vehY, vehZ = table.unpack(GetEntityCoords(lastVehicle))
                plyX, plyY, plyZ = table.unpack(GetEntityCoords(GetPlayerPed(-1)))
                plyVec = vector3(plyX, plyY, plyZ)
                vehVec = vector3(vehX, vehY, vehZ)

                tempDistance = #(plyVec.xy - vehVec.xy)

                if(tempDistance > 25) then
                    lastVehicle = nil
                    lastPlate = ""
                    lastVehicleOil = 0
                    lastVehicleGas = 0
                else
                    
                    if(isRegistered) then
                        ESX.TriggerServerCallback('igs:getOil', function(oil)
                            lastVehicleOil = oil
                        end, lastPlate)
                        ESX.TriggerServerCallback('igs:getGas', function(gas)
                            lastVehicleGas = gas
                        end, lastPlate)
                    end

                end
            else
                lastVehicle = nil
                lastPlate = ""
            end
        end
    end

 end)


 --Display 3D Text over truck to display fuel inside truck

 Citizen.CreateThread(function()
    Citizen.Wait(5000)
    while true do
        Citizen.Wait(0)
        if(lastVehicle ~= nil and #lastPlate > 1) then
            if(DoesEntityExist(lastVehicle) and isVehicleNearby) then

                if(not IsPedInAnyVehicle(GetPlayerPed(-1), true)) then
                    x, y, z = table.unpack(GetEntityCoords(lastVehicle))
                    DrawText3Ds(x, y, z, 'Benzin: ' .. lastVehicleGas)
                    DrawText3Ds(x, y, z + 0.5, 'Öl: ' .. lastVehicleOil)
                end
            end
        end

    end

 end)


 function delayFarming(ms)
    Citizen.CreateThread(function()
        Citizen.Wait(ms)
        isFarming = false
        ClearPedTasks(GetPlayerPed(-1))
        TriggerServerEvent('igs:addOil', lastPlate, math.random(5, 13))
    end)
 end

 function DrawText3Ds(x, y, z, text)
	local onScreen,_x,_y=World3dToScreen2d(x,y,z)

	if onScreen then
		SetTextScale(0.35, 0.35)
		SetTextFont(4)
		SetTextProportional(1)
		SetTextColour(255, 255, 255, 215)
		SetTextEntry("STRING")
		SetTextCentre(1)
		AddTextComponentString(text)
		DrawText(_x,_y)
	end
end


 function DisplayHelpText(str)
	SetTextComponentFormat("STRING")
	AddTextComponentString(str)
	DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

function dMarker(x, y, z)
    DrawMarker(27, x, y, z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.5, 1.5, 1.5, 255, 255, 255, 100, false, true, 2, false, false, false, false)
end

function canSpawn()
    --check if vehicle spawn inside of eatch other
    veh = GetClosestVehicle(rentalSpawn.x, rentalSpawn.y, rentalSpawn.z, 15.0, 0, 70)
    if(veh == 0) then
        if(IsPedInAnyVehicle(GetPlayerPed(-1), true)) then
            ESX.ShowNotification('~r~Du musst aussteigen!')
            return false
        end
        ESX.ShowNotification('~g~Du hast ein LKW für $5000 ausgeparkt!')
        return true
    end
    ESX.ShowNotification('~r~Ein Fahrzeug blockiert die Garage!')
    return false
end

function isVehicleNearby()

    if(lastVehicle ~= nil) then
        if(DoesEntityExist(lastVehicle)) then
        
            vehX, vehY, vehZ = table.unpack(GetEntityCoords(lastVehicle))
            plyX, plyY, plyZ = table.unpack(GetEntityCoords(GetPlayerPed(-1)))
    
            vehVec = vector3(vehX, vehY, vehZ)
            plyVec = vector3(plyX, plyY, plyZ)
    
            distance = #(plyVec.xy - vehVec.xy)
    
            if(distance <= 20) then
                return true
            else
                return false
            end
    
        else
            ESX.ShowNotification('Dein Fahrzeug wurde zerstört.')
            return false
        end
    else
        return false
    end

end

RegisterNetEvent('igs:abortProcessing')
AddEventHandler('igs:abortProcessing', function()
    ESX.ShowNotification('~r~Der Server hat das Verarbeiten abgebrochen. Melde dies bitte im Support.')
    isProcessing = false
end)


print('------------------------------------------')
print('--- SideLife Interactive Gas stations ---')
print('---     Successfully initialized      ---')
print('---     Credits for fueling go to     ---')
print('  https://github.com/InZidiuZ/LegacyFuel  ')
print('------------------------------------------')