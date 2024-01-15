local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")

vFunc = {}
Tunnel.bindInterface("os_garages",vFunc)
vClient = Tunnel.getInterface("os_garages")

vRP._prepare("os_garages/get_vehicle","SELECT * FROM vrp_user_vehicles WHERE user_id = @user_id")
vRP._prepare("os_garages/rem_vehicle","DELETE FROM vrp_user_vehicles WHERE user_id = @user_id AND vehicle = @vehicle")
vRP._prepare("os_garages/get_vehicles","SELECT * FROM vrp_user_vehicles WHERE user_id = @user_id AND vehicle = @vehicle")
vRP._prepare("os_garages/set_update_vehicles","UPDATE vrp_user_vehicles SET engine = @engine, body = @body, fuel = @fuel WHERE user_id = @user_id AND vehicle = @vehicle")
vRP._prepare("os_garages/set_detido","UPDATE vrp_user_vehicles SET detido = @detido, time = @time WHERE user_id = @user_id AND vehicle = @vehicle")
vRP._prepare("os_garages/set_ipva","UPDATE vrp_user_vehicles SET ipva = @ipva WHERE user_id = @user_id AND vehicle = @vehicle")
vRP._prepare("os_garages/move_vehicle","UPDATE vrp_user_vehicles SET user_id = @nuser_id WHERE user_id = @user_id AND vehicle = @vehicle")
vRP._prepare("os_garages/add_vehicle","INSERT IGNORE INTO vrp_user_vehicles(user_id,vehicle,ipva) VALUES(@user_id,@vehicle,@ipva)")
vRP._prepare("os_garages/rem_srv_data","DELETE FROM vrp_srv_data WHERE dkey = @dkey")
vRP._prepare("os_garages/get_estoque","SELECT * FROM vrp_estoque WHERE vehicle = @vehicle")
vRP._prepare("os_garages/set_estoque","UPDATE vrp_estoque SET quantidade = @quantidade WHERE vehicle = @vehicle")

local PoliceAlerts = {}
local VehicleList = {}
local TryDoors = {}

-----------------------------------------------------------------------------------------------------------------------------------------
-- FUNCTIONS
-----------------------------------------------------------------------------------------------------------------------------------------

function vFunc.myVehicles(typeGarage)
	local source = source
	local user_id = vRP.getUserId(source)
	local myVehicles = {}
	if Config.Vehicles[typeGarage] then
		for k,v in pairs(Config.Vehicles) do
			if k == typeGarage then
				for _, Vehicle in pairs(v) do
					table.insert(myVehicles,{ name = Vehicle })
				end
			end
		end
	else
		local vehicle = vRP.query("os_garages/get_vehicle",{ user_id = user_id })
		for k,v in pairs(vehicle) do
			table.insert(myVehicles,{ name = vehicle[k].vehicle })
		end
	end
	return myVehicles, typeGarage
end

function vFunc.spawnVehicles(name,use)
	local source = source
	local user_id = vRP.getUserId(source)
	local identity = vRP.getUserIdentity(user_id)
	local multas = json.decode(vRP.getUData(user_id,"vRP:multas")) or 0
	if multas >= 10000 then
		TriggerClientEvent("Notify",source,"negado","Você tem multas pendentes.",3000)
		return true
	end
	if not vClient.returnVehicle(source,name) then
		local vehicle = vRP.query("os_garages/get_vehicles",{ user_id = user_id, vehicle = name })
		local custom = json.decode(vRP.getSData("custom:u"..user_id.."veh_"..name)) or {}
		if vehicle[1]  then
			if parseInt(os.time()) <= parseInt(vehicle[1].time+24*60*60) then
				local requestSeguro = vRP.request(source,"Veículo na retenção, deseja acionar o seguro pagando $"..(vRP.vehiclePrice(name) / 2).." dólares ?",60)
				if requestSeguro then
					if vRP.tryFullPayment(user_id,vRP.vehiclePrice(name)*0.5) then
						vRP.execute("os_garages/set_detido",{ user_id = user_id, vehicle = name, detido = 0, time = 0 })
						TriggerClientEvent("Notify",source,"sucesso","Veículo liberado.",3000)
					else
						TriggerClientEvent("Notify",source,"negado","Dinheiro insuficiente.",3000)
					end
				end
			elseif vehicle[1].detido >= 1 then
				local ok = vRP.request(source,"Veículo na detenção, deseja acionar o seguro pagando $"..vRP.vehiclePrice(name)*0.1.." dólares ?",60)
				if ok then
					if vRP.tryFullPayment(user_id,vRP.vehiclePrice(name) * 0.1) then
						vRP.execute("os_garages/set_detido",{ user_id = user_id, vehicle = name, detido = 0, time = 0 })
						TriggerClientEvent("Notify",source,"sucesso","Veículo liberado.",3000)
					else
						TriggerClientEvent("Notify",source,"negado","Dinheiro insuficiente.",3000)
					end
				end
			else
				if parseInt(os.time()) <= parseInt(vehicle[1].ipva+24*15*60*60) then
					if Config.Garages[use].payment then
						if vRP.vehicleType(name) == "exclusive" or vRP.vehicleType(name) == "rental" then
							local spawnVehicle,vehicleId = vClient.spawnVehicle(source,name,vehicle[1].engine,vehicle[1].body,vehicle[1].fuel,custom)
							VehicleList[vehicleId] = { user_id,name }
							TriggerClientEvent("Notify",source,"sucesso","Veículo exclusivo ou alugado, não será cobrado a taxa de liberação.",3000)
						end
						if (vRP.getBankMoney(user_id) + vRP.getMoney(user_id)) >= vRP.vehiclePrice(name) * 0.005 and not vRP.vehicleType(name) == "exclusive" or vRP.vehicleType(name) == "rental" then
							local spawnVehicle,vehicleId = vClient.spawnVehicle(source,name,vehicle[1].engine,vehicle[1].body,vehicle[1].fuel,custom)
							if spawnVehicle and vRP.tryFullPayment(user_id,vRP.vehiclePrice(name) * 0.005) then
								VehicleList[vehicleId] = { user_id, name }
								TriggerClientEvent("Notify",source,"financeiro","Você pagou $"..vRP.vehiclePrice(name)*0.005.." dólares, da taxa de liberação.",3000)
							end
						else
							TriggerClientEvent("Notify",source,"negado","Dinheiro insuficiente.",3000)
						end
					else
						local spawnVehicle,vehicleId = vClient.spawnVehicle(source,name,vehicle[1].engine,vehicle[1].body,vehicle[1].fuel,custom,parseInt(vehicle[1].colorR),parseInt(vehicle[1].colorG),parseInt(vehicle[1].colorB),parseInt(vehicle[1].color2R),parseInt(vehicle[1].color2G),parseInt(vehicle[1].color2B),false)
						if spawnVehicle then
							VehicleList[vehicleId] = { user_id,name }
						end
					end
				else
					if vRP.vehicleType(name) == "exclusive" or vRP.vehicleType(name) == "rental" then
						local requestTax = vRP.request(source,"Deseja pagar a taxa do veículo "..vRP.vehicleName(name).." por $"..vRP.vehiclePrice(name)*0.00.." dólares?",60)
						if requestTax then
							if vRP.tryFullPayment(user_id,vRP.vehiclePrice(name) * 0.00) then
								vRP.execute("os_garages/set_ipva",{ user_id = user_id, vehicle = name, ipva = os.time() })
								TriggerClientEvent("Notify",source,"sucesso","Pagamento da taxa do veiculo efetuado com sucesso.",3000)
							else
								TriggerClientEvent("Notify",source,"negado","Dinheiro insuficiente.",3000)
							end
						end
					else
						local priceTax = vRP.vehiclePrice(name) * 0.10
						if priceTax > 100000 then
							priceTax = 100000
						end
						local requestTax = vRP.request(source,"Deseja pagar a taxa do veículo "..vRP.vehicleName(name).." por $"..priceTax.." dólares?",60)
						if requestTax then
							if vRP.tryFullPayment(user_id,priceTax) then
								vRP.execute("os_garages/set_ipva",{ user_id = user_id, vehicle = name, ipva = os.time()})
								TriggerClientEvent("Notify",source,"sucesso","Pagamento da taxa efetuado com sucesso.",3000)
							else
								TriggerClientEvent("Notify",source,"negado","Dinheiro insuficiente.",3000)
							end
						end
					end
				end
			end
		else
			local spawnveh,vehicleId = vClient.spawnVehicle(source,name,1000,1000,100,custom,0,0,0,0,0,0,true)
			if spawnveh then
				VehicleList[vehicleId] = { user_id,name }
			end
		end
	else
		TriggerClientEvent("Notify",source,"aviso","Este veiculo ja foi retirado da garagem.",3000)
	end
end

function vFunc.deleteVehicles()
	local source = source
	local vehicle = vRPclient.getNearestVehicle(source,30)
	if vehicle then
		vClient.deleteVehicle(source,vehicle)
	end
end

function vFunc.vehicleLock()
	local source = source
	local user_id = vRP.getUserId(source)

	if GetEntityHealth(GetPlayerPed(source)) <= 101 then 
		TriggerClientEvent('Notify', source, 'negado','Você não pode fazer isso em coma.',3000) 
		return
	end

	local vehicle,vehicleNetId,vehiclePlate,vehicleName,vehicleLock,banned = vRPclient.vehList(source,7)
	
	if vehicle and vehiclePlate then
		local userPlate = vRP.getUserByRegistration(vehiclePlate)
		if user_id == userPlate then
			vClient.vehicleClientLock(-1,vehicleNetId,vehicleLock)

			vRPclient.playAnim(source,true,{"anim@mp_player_intmenu@key_fob@","fob_click"},false)

			if vehicleLock == 1 then
				TriggerClientEvent("Notify",source,'importante',"Veículo trancado com sucesso.",8000)
			else
				TriggerClientEvent("Notify",source,'importante',"Veículo destrancado com sucesso.",8000)
			end
			TriggerClientEvent("vrp_sound:source",source,"lock",0.5)
		end
	end
end

function vFunc.tryDelete(vehicleId,vehicleEngine,vehicleBody,vehicleFuel)
	if VehicleList[vehicleId] and vehicleId ~= 0 then
		local user_id = VehicleList[vehicleId][1]
		local vehicleName = VehicleList[vehicleId][2]
		local player = vRP.getUserSource(user_id)
		if player then
			vClient.syncNameDelete(player,vehicleName)
		end

		if vehicleEngine <= 100 then
			vehicleEngine = 100
		end

		if vehicleBody <= 100 then
			vehicleBody = 100
		end

		if vehicleFuel >= 100 then
			vehicleFuel = 100
		end

		local vehicle = vRP.query("os_garages/get_vehicles",{ user_id = user_id, vehicle = vehicleName })
		if vehicle[1] then
			vRP.execute("os_garages/set_update_vehicles",{ user_id = user_id, vehicle = vehicleName, engine = vehicleEngine, body = vehicleBody, fuel = vehicleFuel })
		end
	end
	vClient.syncVehicle(-1,vehicleId)
end

function vFunc.returnHouses(nome,garage)
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		local homeAddress = vRP.query("homes/get_homeuserid",{ user_id = user_id })
		if #homeAddress > 0 then
			for k,v in pairs(homeAddress) do
				if v.home == Config.Garages[garage].name then
					if v.garage == 1 then
						local resultOwner = vRP.query("homes/get_homeuseridowner",{ home = nome })
						if resultOwner[1] then
							if os.time() >= resultOwner[1].tax+24*15*60*60 then
								TriggerClientEvent("Notify",source,'aviso',"O IPTU da residência está atrasado.",3000)
								return false
							else
								vClient.openGarage(source,nome,garage)
							end
						end
					end
				end
			end
		end
		if Config.Garages[garage].perm then
			if vRP.hasPermission(user_id,Config.Garages[garage].perm) then
				return vClient.openGarage(source,nome,garage)
			end
		else
			return vClient.openGarage(source,nome,garage)
		end
		return false
	end
end

function vFunc.policeAlert()
	local source = source
	local user_id = vRP.getUserId(source)
	local ped = GetPlayerPed(source)

	local vehicle,vehicleNetId,vehiclePlate,vehicleName,lock,banned,trunk,vehicleModel,street = vRPclient.vehList(source,7)
	if vehicle then
		local policia = vRP.getUsersByPermission("policia.permissao")
		local coords = GetEntityCoords(ped)
		for k,v in pairs(policia) do
			local player = vRP.getUserSource(v)
			if player then
				async(function()
					local id = #PoliceAlerts + 1
					TriggerClientEvent('chatMessage',player,"911",{64,64,255},"Roubo na "..street.." do veículo "..vehicleModel.." de placa "..vehiclePlate.." verifique o ocorrido.")
					PoliceAlerts[id] = vRPclient.addBlip(player,coords.x,coords.y,coords.z,304,3,"Ocorrência",0.6,false)
					SetTimeout(60000,function() 
						vRPclient.removeBlip(player,PoliceAlerts[id])
					end)
				end)
			end
		end
	end
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- COMMANDS
-----------------------------------------------------------------------------------------------------------------------------------------

RegisterCommand('vehs',function(source,args)
	local user_id = vRP.getUserId(source)
	local nuser_id = tonumber(args[2])

	local vehicleName = vRP.vehicleName(args[1])

	if args[1] then
		local nplayer = vRP.getUserSource(nuser_id)
		if nplayer then
			local myVehicles = vRP.query("os_garages/get_vehicles",{ user_id = user_id, vehicle = args[1] })
			if myVehicles[1] then
				if vRP.vehicleType(args[1]) == "exclusive" or vRP.vehicleType(args[1]) == "rental" then
					TriggerClientEvent("Notify",source,"negado",vehicleName.." não pode ser transferido por ser um veículo exclusivo ou alugado.",3000)
				else
					local identity = vRP.getUserIdentity(nuser_id)
					local nIdentity = vRP.getUserIdentity(user_id)
					local price = tonumber(vRP.prompt(source,"Valor:",""))
					local requestSell = vRP.request(source,"Deseja vender um "..vehicleName.." para "..identity.name.." "..identity.firstname.." por $"..price.." dólares ?",30)
					if requestSell then	
						local requestBuy = vRP.request(nplayer,"Aceita comprar um "..vehicleName.." de "..nIdentity.name.." "..nIdentity.firstname.." por $"..price.." dólares ?",30)
						if requestBuy then
							local query = vRP.query("os_garages/get_vehicles",{ user_id = nuser_id, vehicle = args[1] })
							if price > 0 then
								if vRP.tryFullPayment(nuser_id,price) then
									if query[1] then
										TriggerClientEvent("Notify",source,"negado", identity.name.." "..identity.firstname.." já possui este modelo de veículo.",3000)
									else
										vRP.execute("os_garages/move_vehicle",{ user_id = user_id, nuser_id = nuser_id, vehicle = args[1] })
										local custom = json.decode(vRP.getSData("custom:u"..user_id.."veh_"..args[1]))
										if custom then
											vRP.setSData("custom:u"..nuser_id.."veh_"..args[1],json.encode(custom))
											vRP.execute("os_garages/rem_srv_data",{ dkey = "custom:u"..user_id.."veh_"..args[1] })
										end
										local chest = json.decode(vRP.getSData("chest:u"..user_id.."veh_"..args[1]))
										if chest then
											vRP.setSData("chest:u"..nuser_id.."veh_"..args[1],json.encode(chest))
											vRP.execute("os_garages/rem_srv_data",{ dkey = "chest:u"..user_id.."veh_"..args[1] })
										end

										TriggerClientEvent("Notify",source,"sucesso","Você vendeu "..vehicleName.." e recebeu $"..price.." dólares.",3000)
										TriggerClientEvent("Notify",nplayer,"importante","Você recebeu as chaves do veículo "..vehicleName.." de "..nIdentity.name.." "..nIdentity.firstname.." e pagou $"..price.." dólares.",3000)

										vRPclient.playSound(source,"Hack_Success","DLC_HEIST_BIOLAB_PREP_HACKING_SOUNDS")
										vRPclient.playSound(nplayer,"Hack_Success","DLC_HEIST_BIOLAB_PREP_HACKING_SOUNDS")

										local bankMoney = vRP.getBankMoney(user_id)
										vRP.setBankMoney(user_id, bankMoney + price)
									end
								else
									TriggerClientEvent("Notify",nplayer,"negado","Dinheiro insuficiente.",3000)
									TriggerClientEvent("Notify",source,"negado","Dinheiro insuficiente.",3000)
								end	
							end
						end
					end
				end
			else
				local query = vRP.query("os_garages/get_vehicle",{ user_id = user_id })
				if #query > 0 then 
	    	        local carNames = {}
	    	        for k,v in pairs(query) do
	    	        	table.insert(carNames, vRP.vehicleName(v.vehicle).. " | "..v.vehicle.."\n")
	    	        end
	    	        TriggerClientEvent("Notify",source,"importante","Seus veículos: " .. carNames,3000)
				else 
					TriggerClientEvent("Notify",source,"importante","Você não possui nenhum veículo.",3000)
				end
			end
		end
	end
end)

RegisterCommand('car',function(source,args)
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		local identity = vRP.getUserIdentity(user_id)
		if vRP.hasPermission(user_id,"admin.permissao") then
			if args[1] then
				local tuning = vRP.getSData("custom:u"..user_id.."veh_"..args[1]) or {}
				local custom = json.decode(tuning) or {}
				vClient.spawnVehicleAdmin(source,args[1],custom)
			end
		end
	end
end)

RegisterCommand('dv',function(source,args)
	local user_id = vRP.getUserId(source)
	if vRP.hasPermission(user_id,"admin.permissao") then
		if not args[1] then
			local vehicle = vRPclient.getNearestVehicle(source,7)
			if vehicle then
				vClient.deleteVehicle(source,vehicle)
			end
		else 
			local nuser_id = parseInt(args[1])
			local nsource = vRP.getUserSource(nuser_id)
			local vehicle = vRPclient.getNearestVehicle(nsource,7)
			if vehicle then
				vClient.deleteVehicle(nsource,vehicle)
			end
		end
	end
end)

RegisterCommand('hash',function(source)
    local user_id = vRP.getUserId(source)
    if vRP.hasPermission(user_id,"admin.permissao") then
        local vehassh = vClient.getHash(source,vehiclehash)
        vRP.prompt(source,"Hash:",""..vehassh)
    end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- EVENTS
-----------------------------------------------------------------------------------------------------------------------------------------

RegisterServerEvent("tryreparar" ,function(nveh)
	TriggerClientEvent("syncreparar",-1,nveh)
end)

RegisterServerEvent("trymotor" ,function(nveh)
	TriggerClientEvent("syncmotor",-1,nveh)
end)