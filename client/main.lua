local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")

vFunc = {}
Tunnel.bindInterface("os_garages",vFunc)
vServer = Tunnel.getInterface("os_garages")

local workgarage = ""
local vehicle = {}
local vehicleBlips = {}
local pointSpawn = 1

local Cooldown = GetGameTimer()

-----------------------------------------------------------------------------------------------------------------------------------------
-- FUNCTIONS
-----------------------------------------------------------------------------------------------------------------------------------------

function openUI(name,status)
	if name and status then
		workgarage = name
		pointSpawn = status
	end

	SetNuiFocus(true,true)
	SendNUIMessage({ 
		action = "ui:visibility",
		payload = true
	})
end

function vFunc.openGarage(work,number)
	if Cooldown < GetGameTimer() then
		openUI(work,parseInt(number))
		Cooldown = GetGameTimer() + 2000
	else
		TriggerEvent("Notify","negado","Espere um pouco.",2000)
	end
end

function vFunc.vehicleMods(veh,custom)
	if custom and veh then
		SetVehicleModKit(veh,0)
		if custom.color then
			SetVehicleColours(veh,tonumber(custom.color[1]),tonumber(custom.color[2]))
			SetVehicleExtraColours(veh,tonumber(custom.extracolor[1]),tonumber(custom.extracolor[2]))
		end

		if custom.smokecolor then
			SetVehicleTyreSmokeColor(veh,tonumber(custom.smokecolor[1]),tonumber(custom.smokecolor[2]),tonumber(custom.smokecolor[3]))
		end

		if custom.neon then
			SetVehicleNeonLightEnabled(veh,0,1)
			SetVehicleNeonLightEnabled(veh,1,1)
			SetVehicleNeonLightEnabled(veh,2,1)
			SetVehicleNeonLightEnabled(veh,3,1)
			SetVehicleNeonLightsColour(veh,tonumber(custom.neoncolor[1]),tonumber(custom.neoncolor[2]),tonumber(custom.neoncolor[3]))
		else
			SetVehicleNeonLightEnabled(veh,0,0)
			SetVehicleNeonLightEnabled(veh,1,0)
			SetVehicleNeonLightEnabled(veh,2,0)
			SetVehicleNeonLightEnabled(veh,3,0)
		end

		if custom.plateindex then
			SetVehicleNumberPlateTextIndex(veh,tonumber(custom.plateindex))
		end

		if custom.windowtint then
			SetVehicleWindowTint(veh,tonumber(custom.windowtint))
		end

		if custom.bulletProofTyres then
			SetVehicleTyresCanBurst(veh,custom.bulletProofTyres)
		end

		if custom.wheeltype then
			SetVehicleWheelType(veh,tonumber(custom.wheeltype))
		end

		

		if custom.spoiler then
			SetVehicleMod(veh,0,tonumber(custom.spoiler))
			SetVehicleMod(veh,1,tonumber(custom.fbumper))
			SetVehicleMod(veh,2,tonumber(custom.rbumper))
			SetVehicleMod(veh,3,tonumber(custom.skirts))
			SetVehicleMod(veh,4,tonumber(custom.exhaust))
			SetVehicleMod(veh,5,tonumber(custom.rollcage))
			SetVehicleMod(veh,6,tonumber(custom.grille))
			SetVehicleMod(veh,7,tonumber(custom.hood))
			SetVehicleMod(veh,8,tonumber(custom.fenders))
			SetVehicleMod(veh,10,tonumber(custom.roof))
			SetVehicleMod(veh,11,tonumber(custom.engine))
			SetVehicleMod(veh,12,tonumber(custom.brakes))
			SetVehicleMod(veh,13,tonumber(custom.transmission))
			SetVehicleMod(veh,14,tonumber(custom.horn))
			SetVehicleMod(veh,15,tonumber(custom.suspension))
			SetVehicleMod(veh,16,tonumber(custom.armor))
			SetVehicleMod(veh,23,tonumber(custom.tires),custom.tiresvariation)
		
			if IsThisModelABike(GetEntityModel(veh)) then
				SetVehicleMod(veh,24,tonumber(custom.btires),custom.btiresvariation)
			end
		
			SetVehicleMod(veh,25,tonumber(custom.plateholder))
			SetVehicleMod(veh,26,tonumber(custom.vanityplates))
			SetVehicleMod(veh,27,tonumber(custom.trimdesign)) 
			SetVehicleMod(veh,28,tonumber(custom.ornaments))
			SetVehicleMod(veh,29,tonumber(custom.dashboard))
			SetVehicleMod(veh,30,tonumber(custom.dialdesign))
			SetVehicleMod(veh,31,tonumber(custom.doors))
			SetVehicleMod(veh,32,tonumber(custom.seats))
			SetVehicleMod(veh,33,tonumber(custom.steeringwheels))
			SetVehicleMod(veh,34,tonumber(custom.shiftleavers))
			SetVehicleMod(veh,35,tonumber(custom.plaques))
			SetVehicleMod(veh,36,tonumber(custom.speakers))
			SetVehicleMod(veh,37,tonumber(custom.trunk)) 
			SetVehicleMod(veh,38,tonumber(custom.hydraulics))
			SetVehicleMod(veh,39,tonumber(custom.engineblock))
			SetVehicleMod(veh,40,tonumber(custom.camcover))
			SetVehicleMod(veh,41,tonumber(custom.strutbrace))
			SetVehicleMod(veh,42,tonumber(custom.archcover))
			SetVehicleMod(veh,43,tonumber(custom.aerials))
			SetVehicleMod(veh,44,tonumber(custom.roofscoops))
			SetVehicleMod(veh,45,tonumber(custom.tank))
			SetVehicleMod(veh,46,tonumber(custom.doors))
			SetVehicleMod(veh,48,tonumber(custom.liveries))
			SetVehicleLivery(veh,tonumber(custom.liveries))

			ToggleVehicleMod(veh,20,tonumber(custom.tyresmoke))
			ToggleVehicleMod(veh,22,tonumber(custom.headlights))
			ToggleVehicleMod(veh,18,tonumber(custom.turbo))
		end

		if custom.vfarol then
			SetVehicleHeadlightsColour(veh, custom.vfarol)
		end
	end
end

function vFunc.spawnVehicle(vehName,vehEngine,vehBody,vehFuel,custom)
	if not vehicle[vehName] then
		local checkSlot = 1
		local mhash = GetHashKey(vehName)
		while not HasModelLoaded(mhash) do
			RequestModel(mhash)
			Wait(1)
		end

		if HasModelLoaded(mhash) then
			while true do
				local checkCoords = Config.Garages[pointSpawn].slots[checkSlot]
				local checkPos = GetClosestVehicle(checkCoords.x,checkCoords.y,checkCoords.z,3.001,0,71)
				if DoesEntityExist(checkPos) then
					checkSlot = checkSlot + 1
					if checkSlot > #Config.Garages[pointSpawn].slots then
						checkSlot = -1
						TriggerEvent("Notify","importante","Todas as vagas estão ocupadas no momento.",10000)
						break
					end
				else
					break
				end
				Wait(10)
			end

			if checkSlot ~= -1 then
				local nveh = CreateVehicle(mhash,Config.Garages[pointSpawn].slots[checkSlot] + vec4(0,0,0.5,0),true,false)

				SetVehicleOnGroundProperly(nveh)
				SetVehicleNumberPlateText(nveh,vRP.getRegistrationNumber())
				SetEntityAsMissionEntity(nveh,true,true)
				SetVehRadioStation(nveh,"OFF")
				SetVehicleDirtLevel(nveh,1)
				SetVehicleEngineHealth(nveh,vehEngine+0.0)
				SetVehicleBodyHealth(nveh,vehBody+0.0)
				SetVehicleFuelLevel(nveh,vehFuel+0.0)

				if custom and custom.customPcolor then
                	-- trigger seu script de customização de veiculos
                else
                    vFunc.vehicleMods(nveh,custom)
                end
				vFunc.syncBlips(nveh,vehName)

				vehicle[vehName] = true

				return true, VehToNet(nveh)
			end
		end
	end
	return false
end

function vFunc.spawnVehicleAdmin(vehName,custom)
	local ped = PlayerPedId()
	local pedHeading = GetEntityHeading(ped)
	local pedCoords = GetEntityCoords(ped)
	local mhash = GetHashKey(vehName)
	while not HasModelLoaded(mhash) do
		RequestModel(mhash)
		Wait(1)
	end

	local car = CreateVehicle(mhash,pedCoords + vec3(0,0,0.5),pedHeading,true,false)

	SetVehicleNumberPlateText(car,vRP.getRegistrationNumber())
	SetEntityAsMissionEntity(car,true,true)
	SetVehRadioStation(car,"OFF")
	SetVehicleEngineHealth(car,1000.0)
	SetVehicleBodyHealth(car,1000.0)
	SetVehicleFuelLevel(car,100.0)

	vFunc.vehicleMods(car,custom)
	
	SetModelAsNoLongerNeeded(mhash)
	SetPedIntoVehicle(ped, car, -1)
end

function vFunc.syncBlips(nVeh,vehName)
	if GetBlipFromEntity(nVeh) == 0 then
		vehicleBlips[vehName] = AddBlipForEntity(nVeh)
		SetBlipSprite(vehicleBlips[vehName],433)
		SetBlipAsShortRange(vehicleBlips[vehName],false)
		SetBlipColour(vehicleBlips[vehName],80)
		SetBlipScale(vehicleBlips[vehName],0.4)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString("Rastreador: "..GetDisplayNameFromVehicleModel(GetEntityModel(nVeh)))
		EndTextCommandSetBlipName(vehicleBlips[vehName])
	end
end

function vFunc.deleteVehicle(vehicle)
	if IsEntityAVehicle(vehicle) then
		vServer.tryDelete(VehToNet(vehicle),GetVehicleEngineHealth(vehicle),GetVehicleBodyHealth(vehicle),GetVehicleFuelLevel(vehicle))
	end
end

function vFunc.removeGpsVehicle(vehName)
	if vehicle[vehName] then
		RemoveBlip(vehicleBlips[vehName])
		vehicleBlips[vehName] = nil
	end
end

function vFunc.syncNameDelete(vehName)
	if vehicle[vehName] then
		vehicle[vehName] = nil
		if DoesBlipExist(vehicleBlips[vehName]) then
			RemoveBlip(vehicleBlips[vehName])
			vehicleBlips[vehName] = nil
		end
	end
end

function vFunc.syncVehicle(vehicle)
	if NetworkDoesNetworkIdExist(vehicle) then
		local v = NetToVeh(vehicle)
		if DoesEntityExist(v) and IsEntityAVehicle(v) then
			Citizen.InvokeNative(0xAD738C3085FE7E11,v,true,true)
			SetEntityAsMissionEntity(v,true,true)
			SetVehicleHasBeenOwnedByPlayer(v,true)
			NetworkRequestControlOfEntity(v)
			Citizen.InvokeNative(0xEA386986E786A54F,Citizen.PointerValueIntInitialized(v))
			DeleteEntity(v)
			DeleteVehicle(v)
			SetEntityAsNoLongerNeeded(v)
		end
	end
end

function vFunc.syncNameDelete(vehname)
	if vehicle[vehName] then
		vehicle[vehName] = nil
		if DoesBlipExist(vehicleBlips[vehName]) then
			RemoveBlip(vehicleBlips[vehName])
			vehicleBlips[vehName] = nil
		end
	end
end

function vFunc.returnVehicle(name)
	return vehicle[name]
end

function vFunc.vehicleClientLock(vehid,lock)
	if NetworkDoesNetworkIdExist(vehid) then
		local v = NetToVeh(vehid)
		if DoesEntityExist(v) and IsEntityAVehicle(v) then
			if lock == 1 then
				SetVehicleDoorsLocked(v,2)
			else
				SetVehicleDoorsLocked(v,1)
			end
			SetVehicleLights(v,2)
			Wait(200)
			SetVehicleLights(v,0)
			Wait(200)
			SetVehicleLights(v,2)
			Wait(200)
			SetVehicleLights(v,0)
		end
	end
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- CALLBACKS
-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback("getCurrentGarage",function(_,Callback)
	local vehicles, typeGarage = vServer.myVehicles(workgarage)
	if vehicles then
		Callback({ vehicles = vehicles, title = string.upper(typeGarage) })
	end
end)

RegisterNUICallback('spawnVehicle',function(data)
    if Cooldown < GetGameTimer() then
        Cooldown = GetGameTimer() + 3000
        vServer.spawnVehicles(data.vehicle.name,pointSpawn)
	else
		TriggerEvent("Notify","negado","Espere um pouco.",2000)
    end
end)

RegisterNUICallback('storeVehicle',function()
    if Cooldown < GetGameTimer() then
        Cooldown = GetGameTimer() + 3000
        vServer.deleteVehicles()
	else
		TriggerEvent("Notify","negado","Espere um pouco.",2000)
    end
end)

RegisterNUICallback("removeFocus", function(data)
	SetNuiFocus(false,false)
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- COMMANDS
-----------------------------------------------------------------------------------------------------------------------------------------

RegisterCommand('lockcar', function()
	local ped = PlayerPedId()
	if GetEntityHealth(ped) > 101 then
		vServer.vehicleLock()
	end
end)

RegisterCommand('garagem', function()
	SetNuiFocus(false,false)
	if Cooldown < GetGameTimer() then
		local ped = PlayerPedId()
		if GetEntityHealth(ped) > 101 and not IsPedInAnyVehicle(ped) then 
			local pedCoords = GetEntityCoords(ped)
			for k,v in pairs(Config.Garages) do
				if #(pedCoords - v.coords) <= 2 then
					vServer.returnHouses(v.name,k)
				end
			end
		end
	else
		TriggerEvent("Notify","negado","Espere um pouco.",2000)
	end
end)

RegisterKeyMapping("lockcar","Trancar o veículo","keyboard","l")
RegisterKeyMapping("garagem","Garagem","keyboard","e")

-----------------------------------------------------------------------------------------------------------------------------------------
-- EVENTS
-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNetEvent('reparar', function()
	local vehicle = vRP.getNearestVehicle(3)
	if IsEntityAVehicle(vehicle) then
		TriggerServerEvent("tryreparar",VehToNet(vehicle))
	end
end)

RegisterNetEvent('syncreparar',function(index)
	if NetworkDoesNetworkIdExist(index) then
		local v = NetToVeh(index)
		local fuel = GetVehicleFuelLevel(v)
		if DoesEntityExist(v) then
			if IsEntityAVehicle(v) then
				SetVehicleFixed(v)
				SetVehicleDirtLevel(v,0.0)
				SetVehicleUndriveable(v,false)
				Citizen.InvokeNative(0xAD738C3085FE7E11,v,true,true)
				SetVehicleOnGroundProperly(v)
				SetVehicleFuelLevel(v,fuel)
			end
		end
	end
end)

RegisterNetEvent('repararmotor',function()
	local vehicle = vRP.getNearestVehicle(3)
	if IsEntityAVehicle(vehicle) then
		TriggerServerEvent("trymotor",VehToNet(vehicle))
	end
end)

RegisterNetEvent('syncmotor',function(index)
	if NetworkDoesNetworkIdExist(index) then
		local v = NetToVeh(index)
		if DoesEntityExist(v) then
			if IsEntityAVehicle(v) then
				SetVehicleEngineHealth(v,1000.0)
			end
		end
	end
end)