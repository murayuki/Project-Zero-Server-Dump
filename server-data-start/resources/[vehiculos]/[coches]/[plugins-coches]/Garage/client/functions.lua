OpenGarageMenu = function()
    local currentGarage = cachedData["currentGarage"]

    if not currentGarage then return end

    HandleCamera(currentGarage, true)

    ESX.TriggerServerCallback("garage:fetchPlayerVehicles", function(fetchedVehicles)
        local menuElements = {}

        for key, vehicleData in ipairs(fetchedVehicles) do
            local vehicleProps = vehicleData["props"]
            local vehicleType = vehicleData["type"]
            print('llego aqui')
            print(vehicleType)
            if vehicleType == "car" then
                print('aqui llego?')
                table.insert(menuElements, {
                    ["label"] = "Sacar del garaje " .. GetLabelText(GetDisplayNameFromVehicleModel(vehicleProps["model"])) .. " con matrícula - " .. vehicleData["plate"],
                    ["vehicle"] = vehicleData
                })
            end
        end

        if #menuElements == 0 then
            table.insert(menuElements, {
                ["label"] = "No tienes ningun vehiculo"
            })
        elseif #menuElements > 0 then
            SpawnLocalVehicle(menuElements[1]["vehicle"]["props"], currentGarage)
        end

        ESX.UI.Menu.Open("default", GetCurrentResourceName(), "main_garage_menu", {
            ["title"] = "Garaje - " .. currentGarage,
            ["align"] = Config.AlignMenu,
            ["elements"] = menuElements
        }, function(menuData, menuHandle)
            local currentVehicle = menuData["current"]["vehicle"]

            if currentVehicle then
                menuHandle.close()

                SpawnVehicle(currentVehicle["props"])
            end
        end, function(menuData, menuHandle)
            HandleCamera(currentGarage, false)

            menuHandle.close()
        end, function(menuData, menuHandle)
            local currentVehicle = menuData["current"]["vehicle"]

            if currentVehicle then
                SpawnLocalVehicle(currentVehicle["props"])
            end
        end)
    end, currentGarage)
end

OpenVehicleMenu = function()
    ESX.TriggerServerCallback("garage:fetchPlayerVehicles", function(fetchedVehicles)
        local menuElements = {}


        local gameVehicles = ESX.Game.GetVehicles()
        local pedCoords = GetEntityCoords(PlayerPedId())

        for key, vehicleData in ipairs(fetchedVehicles) do
            local vehicleProps = vehicleData["props"]
            for _, vehicle in ipairs(gameVehicles) do
                if DoesEntityExist(vehicle) then
                    local dstCheck = math.floor(#(pedCoords - GetEntityCoords(vehicle)))
                    if dstCheck >= Config.RangeCheck2 then 
                        ESX.ShowNotification("Estás demasiado lejos para ver tu coche")
                    else
                        if Config.Trim(GetVehicleNumberPlateText(vehicle)) == Config.Trim(vehicleProps["plate"]) then
                            table.insert(menuElements, {
                                ["label"] = GetLabelText(GetDisplayNameFromVehicleModel(vehicleProps["model"])) .. " - " .. vehicleData["plate"] .. " - " .. dstCheck .. "m",
                                ["vehicleData"] = vehicleData,
                                ["vehicleEntity"] = vehicle
                            })
                        end
                    end                    
                end     
            end
        end

        if #menuElements == 0 then
            table.insert(menuElements, {
                ["label"] = "No tienes ningun vehiculo"
            })
        end

        ESX.UI.Menu.Open("default", GetCurrentResourceName(), "main_vehicle_menu", {
            ["title"] = "Vehículos",
            ["align"] = Config.AlignMenu,
            ["elements"] = menuElements
        }, function(menuData, menuHandle)
            local currentVehicle = menuData["current"]["vehicleEntity"]

            if currentVehicle then
                ChooseVehicleAction(currentVehicle, function(actionChosen)
                    VehicleAction(currentVehicle, actionChosen)
                end)
            end
        end, function(menuData, menuHandle)
            menuHandle.close()
        end, function(menuData, menuHandle)
            local currentVehicle = menuData["current"]["vehicle"]

            if currentVehicle then
                SpawnLocalVehicle(currentVehicle["props"])
            end
        end)
    end)
end

ChooseVehicleAction = function(vehicleEntity, callback)
    if not cachedData["blips"] then cachedData["blips"] = {} end

    local menuElements = {
        {
            ["label"] = (GetVehicleDoorLockStatus(vehicleEntity) == 1 and "Cerrar" or "Abrir") .. " tu vehiculo",
            ["action"] = "change_lock_state"
        },
        {
            ["label"] = (GetIsVehicleEngineRunning(vehicleEntity) and "Apagar" or "Encender") .. " el motor",
            ["action"] = "change_engine_state"
        },
        {
            ["label"] = "Puertas",
            ["action"] = "change_door_state"
        },
    }

    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "second_vehicle_menu", {
        ["title"] = "Acciones para el vehiculo - " .. GetVehicleNumberPlateText(vehicleEntity),
        ["align"] = Config.AlignMenu,
        ["elements"] = menuElements
    }, function(menuData, menuHandle)
        local currentAction = menuData["current"]["action"]

        if currentAction then
            menuHandle.close()

            callback(currentAction)
        end
    end, function(menuData, menuHandle)
        menuHandle.close()
    end)
end

VehicleAction = function(vehicleEntity, action)
    local dstCheck = #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(vehicleEntity))

    while not NetworkHasControlOfEntity(vehicleEntity) do
        Citizen.Wait(0)
    
        NetworkRequestControlOfEntity(vehicleEntity)
    end

    if action == "change_lock_state" then
        if dstCheck >= Config.RangeCheck then return ESX.ShowNotification("Estás demasiado lejos para usar la llave") end

        PlayAnimation(PlayerPedId(), "anim@mp_player_intmenu@key_fob@", "fob_click", {
            ["speed"] = 8.0,
            ["speedMultiplier"] = 8.0,
            ["duration"] = 1820,
            ["flag"] = 49,
            ["playbackRate"] = false
        })

        -- for index = 1, 4 do
        --     if (index % 2 == 0) then
        --         SetVehicleLights(vehicleEntity, 2)
        --     else
        --         SetVehicleLights(vehicleEntity, 0)
        --     end

        --     Citizen.Wait(300)
        -- end

        StartVehicleHorn(vehicleEntity, 50, 1, false)
        
        local vehicleLockState = GetVehicleDoorLockStatus(vehicleEntity)

        if vehicleLockState == 1 then
            local estado = true
            TriggerEvent("StopDespawn:update", vehicleEntity, estado)
            SetVehicleDoorsLocked(vehicleEntity, 2)
            PlayVehicleDoorCloseSound(vehicleEntity, 1)
            SetVehicleLights(vehicleEntity, 0)
            Citizen.Wait(750)
            SetVehicleLights(vehicleEntity, 2)
            Citizen.Wait(750)
            -- SetVehicleNeonLightEnabled(vehicleEntity, 1, false)
            -- Citizen.Wait(10)
            -- SetVehicleNeonLightEnabled(vehicleEntity, 2, false)
            -- Citizen.Wait(10)
            -- SetVehicleNeonLightEnabled(vehicleEntity, 3, false)
            -- Citizen.Wait(10)
            -- SetVehicleNeonLightEnabled(vehicleEntity, 4, false)
            SetVehicleLights(vehicleEntity, 0)
        elseif vehicleLockState == 2 then
            local estado = false
            TriggerEvent("StopDespawn:update", vehicleEntity, estado)
            SetVehicleDoorsLocked(vehicleEntity, 1)
            PlayVehicleDoorOpenSound(vehicleEntity, 0)
            SetVehicleLights(vehicleEntity, 0)
            Citizen.Wait(750)
            SetVehicleLights(vehicleEntity, 2)
            Citizen.Wait(750)
            SetVehicleLights(vehicleEntity, 0)
            Citizen.Wait(750)
            SetVehicleLights(vehicleEntity, 2)
            
            local oldCoords = GetEntityCoords(PlayerPedId())
            local oldHeading = GetEntityHeading(PlayerPedId())

            if not IsPedInVehicle(PlayerPedId(), vehicleEntity) and not DoesEntityExist(GetPedInVehicleSeat(vehicleEntity, -1)) then
                SetPedIntoVehicle(PlayerPedId(), vehicleEntity, -1)
                TaskLeaveVehicle(PlayerPedId(), vehicleEntity, 16)
                SetEntityCoords(PlayerPedId(), oldCoords - vector3(0.0, 0.0, 0.99))
                SetEntityHeading(PlayerPedId(), oldHeading)
            end
        end

        ESX.ShowNotification(GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(vehicleEntity))) .. " con matrícula - " .. GetVehicleNumberPlateText(vehicleEntity) .. " esta ahora " .. (vehicleLockState == 1 and "CERRADO" or "ABIERTO"))
    elseif action == "change_door_state" then
        if dstCheck >= Config.RangeCheck then return ESX.ShowNotification("Estás demasiado lejos para usar la llave") end

        ChooseDoor(vehicleEntity, function(doorChosen)
            if doorChosen then
                if GetVehicleDoorAngleRatio(vehicleEntity, doorChosen) == 0 then
                    SetVehicleDoorOpen(vehicleEntity, doorChosen, false, false)
                else
                    SetVehicleDoorShut(vehicleEntity, doorChosen, false, false)
                end
            end
        end)
    elseif action == "change_engine_state" then
        if dstCheck >= Config.RangeCheck then return ESX.ShowNotification("Estás demasiado lejos para usar la llave") end

        if GetIsVehicleEngineRunning(vehicleEntity) then
            SetVehicleEngineOn(vehicleEntity, false, false)

            cachedData["engineState"] = true

            Citizen.CreateThread(function()
                while cachedData["engineState"] do
                    Citizen.Wait(5)

                    SetVehicleUndriveable(vehicleEntity, true)
                end

                SetVehicleUndriveable(vehicleEntity, false)
            end)
        else
            cachedData["engineState"] = false

            SetVehicleEngineOn(vehicleEntity, true, true)
        end
    elseif action == "change_gps_state" then
        if DoesBlipExist(cachedData["blips"][vehicleEntity]) then
            RemoveBlip(cachedData["blips"][vehicleEntity])
        else
            cachedData["blips"][vehicleEntity] = AddBlipForEntity(vehicleEntity)
    
            SetBlipSprite(cachedData["blips"][vehicleEntity], GetVehicleClass(vehicleEntity) == 8 and 226 or 225)
            SetBlipScale(cachedData["blips"][vehicleEntity], 1.05)
            SetBlipColour(cachedData["blips"][vehicleEntity], 30)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString("Vehiculo personal - " .. GetVehicleNumberPlateText(vehicleEntity))
            EndTextCommandSetBlipName(cachedData["blips"][vehicleEntity])
        end
    end
end

ChooseDoor = function(vehicleEntity, callback)
    local menuElements = {
        {
            ["label"] = "Puerta delantera izquierda",
            ["door"] = 0
        },
        {
            ["label"] = "Puerta delantera derecha",
            ["door"] = 1
        },
        {
            ["label"] = "Puerta trasera izquierda",
            ["door"] = 2
        },
        {
            ["label"] = "Puerta trasera derecha",
            ["door"] = 3
        },
        {
            ["label"] = "Capo",
            ["door"] = 4
        },
        {
            ["label"] = "Maletero",
            ["door"] = 5
        }
    }

    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "door_vehicle_menu", {
        ["title"] = "Elige una puerta",
        ["align"] = Config.AlignMenu,
        ["elements"] = menuElements
    }, function(menuData, menuHandle)
        local currentDoor = menuData["current"]["door"]

        if currentDoor then
            callback(currentDoor)
        end
    end, function(menuData, menuHandle)
        menuHandle.close()
    end)
end

SpawnLocalVehicle = function(vehicleProps)
    local currentGarage = cachedData["currentGarage"]
	local spawnpoint = Config.Garages[cachedData["currentGarage"]]["positions"]["vehicle"]

	WaitForModel(vehicleProps["model"])

	if DoesEntityExist(cachedData["vehicle"]) then
		DeleteEntity(cachedData["vehicle"])
	end
	
	if not ESX.Game.IsSpawnPointClear(spawnpoint["position"], 3.0) then 
        ESX.ShowNotification("Un vehiculo esta bloqueando el camino, por favor muevalo")
        HandleCamera(currentGarage, false)
		return
	end
	
	if not IsModelValid(vehicleProps["model"]) then
		return
	end

	ESX.Game.SpawnLocalVehicle(vehicleProps["model"], spawnpoint["position"], spawnpoint["heading"], function(yourVehicle)
		cachedData["vehicle"] = yourVehicle

		SetVehicleProperties(yourVehicle, vehicleProps)

		SetModelAsNoLongerNeeded(vehicleProps["model"])
	end)
end

SpawnVehicle = function(vehicleProps)
    local currentGarage = cachedData["currentGarage"]
	local spawnpoint = Config.Garages[cachedData["currentGarage"]]["positions"]["vehicle"]

	WaitForModel(vehicleProps["model"])

	if DoesEntityExist(cachedData["vehicle"]) then
		DeleteEntity(cachedData["vehicle"])
	end
	
	if not ESX.Game.IsSpawnPointClear(spawnpoint["position"], 3.0) then 
        ESX.ShowNotification("Un vehiculo esta bloqueando el camino, por favor muevalo")
        HandleCamera(currentGarage, false)        
        menuHandle.close()
		return
	end
	
	local gameVehicles = ESX.Game.GetVehicles()

	for i = 1, #gameVehicles do
		local vehicle = gameVehicles[i]

        if DoesEntityExist(vehicle) then
			if Config.Trim(GetVehicleNumberPlateText(vehicle)) == Config.Trim(vehicleProps["plate"]) then
				ESX.ShowNotification("Este vehiculo ya esta por ahi, no puedes sacar dos vehiculos iguales del garaje!")

				return HandleCamera(cachedData["currentGarage"])
			end
		end
	end

    ESX.Game.SpawnVehicle(vehicleProps["model"], spawnpoint["position"], spawnpoint["heading"], function(yourVehicle)
        
        SetVehicleNumberPlateText(yourVehicle, vehicleProps["plate"]) 

		SetVehicleProperties(yourVehicle, vehicleProps)

        NetworkFadeInEntity(yourVehicle, true, true)

		SetModelAsNoLongerNeeded(vehicleProps["model"])

		TaskWarpPedIntoVehicle(PlayerPedId(), yourVehicle, -1)

        SetEntityAsMissionEntity(yourVehicle, true, true)
        
        ESX.ShowNotification("Has sacado el vehiculo del garaje")

        HandleCamera(cachedData["currentGarage"])

        Citizen.Wait(1000)

        spawnfuel(yourVehicle)
	end)
end

PutInVehicle = function()
    local vehicle = GetVehiclePedIsUsing(PlayerPedId())

	if DoesEntityExist(vehicle) then
		local vehicleProps = GetVehicleProperties(vehicle)

		ESX.TriggerServerCallback("garage:validateVehicle", function(valid)
			if valid then
				TaskLeaveVehicle(PlayerPedId(), vehicle, 0)
	
				while IsPedInVehicle(PlayerPedId(), vehicle, true) do
					Citizen.Wait(0)
				end
	
				Citizen.Wait(500)
	
				NetworkFadeOutEntity(vehicle, true, true)
	
				Citizen.Wait(100)
	
				ESX.Game.DeleteVehicle(vehicle)

				ESX.ShowNotification("Has guardado tu vehiculo en el garaje")
			else
				ESX.ShowNotification("Este vehiculo realmente es tuyo?")
			end

		end, vehicleProps, cachedData["currentGarage"])
	end
end

SetVehicleProperties = function(vehicle, vehicleProps)
    ESX.Game.SetVehicleProperties(vehicle, vehicleProps)

    SetVehicleEngineHealth(vehicle, vehicleProps["engineHealth"] and vehicleProps["engineHealth"] + 0.0 or 1000.0)
    SetVehicleBodyHealth(vehicle, vehicleProps["bodyHealth"] and vehicleProps["bodyHealth"] + 0.0 or 1000.0)
    -- SetVehicleFuelLevel(vehicle, vehicleProps["fuelLevel"] and vehicleProps["fuelLevel"] + 0.0 or 1000.0)

    if vehicleProps["windows"] then
        for windowId = 1, 13, 1 do
            if vehicleProps["windows"][windowId] == false then
                SmashVehicleWindow(vehicle, windowId)
            end
        end
    end

    if vehicleProps["tyres"] then
        for tyreId = 1, 7, 1 do
            if vehicleProps["tyres"][tyreId] ~= false then
                SetVehicleTyreBurst(vehicle, tyreId, true, 1000)
            end
        end
    end

    if vehicleProps["doors"] then
        for doorId = 0, 5, 1 do
            if vehicleProps["doors"][doorId] ~= false then
                SetVehicleDoorBroken(vehicle, doorId - 1, true)
            end
        end
    end
end

GetVehicleProperties = function(vehicle)
    if DoesEntityExist(vehicle) then
        local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)

        vehicleProps["tyres"] = {}
        vehicleProps["windows"] = {}
        vehicleProps["doors"] = {}

        for id = 1, 7 do
            local tyreId = IsVehicleTyreBurst(vehicle, id, false)
        
            if tyreId then
                vehicleProps["tyres"][#vehicleProps["tyres"] + 1] = tyreId
        
                if tyreId == false then
                    tyreId = IsVehicleTyreBurst(vehicle, id, true)
                    vehicleProps["tyres"][ #vehicleProps["tyres"]] = tyreId
                end
            else
                vehicleProps["tyres"][#vehicleProps["tyres"] + 1] = false
            end
        end

        for id = 1, 13 do
            local windowId = IsVehicleWindowIntact(vehicle, id)

            if windowId ~= nil then
                vehicleProps["windows"][#vehicleProps["windows"] + 1] = windowId
            else
                vehicleProps["windows"][#vehicleProps["windows"] + 1] = true
            end
        end
        
        for id = 0, 5 do
            local doorId = IsVehicleDoorDamaged(vehicle, id)
        
            if doorId then
                vehicleProps["doors"][#vehicleProps["doors"] + 1] = doorId
            else
                vehicleProps["doors"][#vehicleProps["doors"] + 1] = false
            end
        end

        vehicleProps["engineHealth"] = GetVehicleEngineHealth(vehicle)
        vehicleProps["bodyHealth"] = GetVehicleBodyHealth(vehicle)
        
        local fuel = math.ceil(GetVehicleFuelLevel(vehicle))
        savefuel(vehicle,vehicleProps,fuel)
        
        return vehicleProps
    end
end

HandleAction = function(action)
    if action == "menu" then
        OpenGarageMenu()
    elseif action == "vehicle" then
        PutInVehicle()
    end
end

HandleCamera = function(garage, toggle)
    local Camerapos = Config.Garages[garage]["camera"]

    if not Camerapos then return end

	if not toggle then
		if cachedData["cam"] then
			DestroyCam(cachedData["cam"])
		end
		
		if DoesEntityExist(cachedData["vehicle"]) then
			DeleteEntity(cachedData["vehicle"])
		end

		RenderScriptCams(0, 1, 750, 1, 0)

		return
	end

	if cachedData["cam"] then
		DestroyCam(cachedData["cam"])
	end

	cachedData["cam"] = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)

	SetCamCoord(cachedData["cam"], Camerapos["x"], Camerapos["y"], Camerapos["z"])
	SetCamRot(cachedData["cam"], Camerapos["rotationX"], Camerapos["rotationY"], Camerapos["rotationZ"])
	SetCamActive(cachedData["cam"], true)

	RenderScriptCams(1, 1, 750, 1, 1)

	Citizen.Wait(500)
end

DrawScriptMarker = function(markerData)
    DrawMarker(markerData["type"] or 1, markerData["pos"] or vector3(0.0, 0.0, 0.0), 0.0, 0.0, 0.0, (markerData["type"] == 6 and -90.0 or markerData["rotate"] and -180.0) or 0.0, 0.0, 0.0, markerData["sizeX"] or 1.0, markerData["sizeY"] or 1.0, markerData["sizeZ"] or 1.0, markerData["r"] or 1.0, markerData["g"] or 1.0, markerData["b"] or 1.0, 100, false, true, 2, false, false, false, false)
end

PlayAnimation = function(ped, dict, anim, settings)
	if dict then
        Citizen.CreateThread(function()
            RequestAnimDict(dict)

            while not HasAnimDictLoaded(dict) do
                Citizen.Wait(100)
            end

            if settings == nil then
                TaskPlayAnim(ped, dict, anim, 1.0, -1.0, 1.0, 0, 0, 0, 0, 0)
            else 
                local speed = 1.0
                local speedMultiplier = -1.0
                local duration = 1.0
                local flag = 0
                local playbackRate = 0

                if settings["speed"] then
                    speed = settings["speed"]
                end

                if settings["speedMultiplier"] then
                    speedMultiplier = settings["speedMultiplier"]
                end

                if settings["duration"] then
                    duration = settings["duration"]
                end

                if settings["flag"] then
                    flag = settings["flag"]
                end

                if settings["playbackRate"] then
                    playbackRate = settings["playbackRate"]
                end

                TaskPlayAnim(ped, dict, anim, speed, speedMultiplier, duration, flag, playbackRate, 0, 0, 0)
            end
      
            RemoveAnimDict(dict)
		end)
	else
		TaskStartScenarioInPlace(ped, anim, 0, true)
	end
end

WaitForModel = function(model)
    local DrawScreenText = function(text, red, green, blue, alpha)
        SetTextFont(4)
        SetTextScale(0.0, 0.5)
        SetTextColour(red, green, blue, alpha)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(1, 0, 0, 0, 255)
        SetTextDropShadow()
        SetTextOutline()
        SetTextCentre(true)
    
        BeginTextCommandDisplayText("STRING")
        AddTextComponentSubstringPlayerName(text)
        EndTextCommandDisplayText(0.5, 0.5)
    end

    if not IsModelValid(model) then
        return ESX.ShowNotification("El modelo del vehiculo no exite")
    end

	if not HasModelLoaded(model) then
		RequestModel(model)
	end
	
	while not HasModelLoaded(model) do
		Citizen.Wait(0)

		DrawScreenText("Pedir prestado un vehículo " .. GetLabelText(GetDisplayNameFromVehicleModel(model)) .. "...", 255, 255, 255, 150)
	end
end



function savefuel(vehicle,vehicleProps,fuel)
	TriggerServerEvent('eden_garage:modifystatestored', vehicleProps.plate, true, true, fuel, damage)
end

function spawnfuel(yourVehicle)

	ESX.TriggerServerCallback('eden_garage:getVehicles', function(vehicles)

		for _,v in pairs(vehicles) do

            local stored = v.stored
            local vehiculo = yourVehicle
            
            if stored == true then
                local gasofa = v.fuel
                Citizen.Wait(300)
                SetVehicleFuelLevel(vehiculo , gasofa + 0.0)
            end

						
		end
	end)
end