local HasAlreadyEnteredMarker, OnJob, IsNearCustomer, CustomerIsEnteringVehicle, CustomerEnteredVehicle, IsDead, CurrentActionData = false, false, false, false, false, false, {}
local CurrentCustomer, CurrentCustomerBlip, DestinationBlip, targetCoords, LastZone, CurrentAction, CurrentActionMsg

ESX = nil
local myPedId = nil




Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
end)



function DrawSub(msg, time)
	ClearPrints()
	BeginTextCommandPrint('STRING')
	AddTextComponentSubstringPlayerName(msg)
	EndTextCommandPrint(time, 1)
end

function ShowLoadingPromt(msg, time, type)
	Citizen.CreateThread(function()
		Citizen.Wait(0)

		BeginTextCommandBusyspinnerOn('STRING')
		AddTextComponentSubstringPlayerName(msg)
		EndTextCommandBusyspinnerOn(type)
		Citizen.Wait(time)

		BusyspinnerOff()
	end)
end

function YuruyenNPCrandom()
	local search = {}
	local peds   = ESX.Game.GetPeds()

	for i=1, #peds, 1 do
		if IsPedHuman(peds[i]) and IsPedWalking(peds[i]) and not IsPedAPlayer(peds[i]) then
			table.insert(search, peds[i])
		end
	end

	if #search > 0 then
		return search[GetRandomIntInRange(1, #search)]
	end

	for i=1, 250, 1 do
		local ped = GetRandomPedAtCoord(0.0, 0.0, 0.0, math.huge + 0.0, math.huge + 0.0, math.huge + 0.0, 26)

		if DoesEntityExist(ped) and IsPedHuman(ped) and IsPedWalking(ped) and not IsPedAPlayer(ped) then
			table.insert(search, ped)
		end
	end

	if #search > 0 then
		return search[GetRandomIntInRange(1, #search)]
	end
end



function StartUberJob()
	ShowLoadingPromt('Starting Service', 5000, 3)
	ClearCurrentMission()

	OnJob = true
end

function StopUberJob()
	local playerPed = PlayerPedId()

	if IsPedInAnyVehicle(playerPed, false) and CurrentCustomer ~= nil then
		local vehicle = GetVehiclePedIsIn(playerPed,  false)
		TaskLeaveVehicle(CurrentCustomer,  vehicle,  0)

		if CustomerEnteredVehicle then
			TaskGoStraightToCoord(CurrentCustomer,  targetCoords.x,  targetCoords.y,  targetCoords.z,  1.0,  -1,  0.0,  0.0)
		end
	end

	ClearCurrentMission()
	OnJob = false
	exports['mythic_notify']:SendAlert('uber', 'UBER :: You finished the task')

end


function ClearCurrentMission()
	if DoesBlipExist(CurrentCustomerBlip) then
		RemoveBlip(CurrentCustomerBlip)
	end

	if DoesBlipExist(DestinationBlip) then
		RemoveBlip(DestinationBlip)
	end

	CurrentCustomer           = nil
	CurrentCustomerBlip       = nil
	DestinationBlip           = nil
	IsNearCustomer            = false
	CustomerIsEnteringVehicle = false
	CustomerEnteredVehicle    = false
	targetCoords              = nil
end

function loadAnimDict(dict)
	RequestAnimDict(dict)
	while not HasAnimDictLoaded(dict) do
		Citizen.Wait(1)
	end
end




RegisterCommand('uber', function()
	local playerPed = PlayerPedId()
	local vehicle   = GetVehiclePedIsIn(playerPed, false)

	-- umtAnim()
	-- PlayOut()				------- Before starting work, just open this place to enter the phone animation.
	-- Citizen.Wait(5000)
	-- ClearPedTasksImmediately(playerPed)


		if OnJob then
			StopUberJob()
		else
			if IsPedInAnyVehicle(playerPed, false) and GetPedInVehicleSeat(vehicle, -1) == playerPed then
				StartUberJob()
				exports['mythic_notify']:DoHudText('uber', 'UBER :: You started!')

			else
				exports['mythic_notify']:DoHudText('uber', 'UBER :: In the vehicle')
			end
		end
	
		-------------------------------------- You can make it according to a specific vehicle.
			-- else
				if AracaSahip() then
					StartUberJob()
				else
					exports['mythic_notify']:DoHudText('uber', 'UBER :: You must be in a vehicle specified by the company')
				end
			-- end
			if IsPedInAnyVehicle(playerPed, false) and GetPedInVehicleSeat(vehicle, -1) == playerPed then
				exports['mythic_notify']:DoHudText('uber', 'UBER :: In the vehicle')
			else
				exports['mythic_notify']:DoHudText('uber', 'UBER :: You must be in a vehicle specified by the company')
			deleteRadio()

			ClearPedTasksImmediately(GetPlayerPed(-1))
			end

end)




---

function AracaSahip()
	local playerPed = PlayerPedId()
	local vehModel  = GetEntityModel(GetVehiclePedIsIn(playerPed, false))

	for i=1, #Config.Arac, 1 do
		if vehModel == GetHashKey(Config.Arac[i].model) then
			return true
		end
	end
	
	return false
end



Citizen.CreateThread(function()
	while true do

		Citizen.Wait(0)
		local playerPed = PlayerPedId()

		if OnJob then
			if CurrentCustomer == nil then
				
				DrawSub('Move around and wait for the customer to reach you', 5000)
				if IsPedInAnyVehicle(playerPed, false) and GetEntitySpeed(playerPed) > 0 then
					local waitUntil = GetGameTimer() + GetRandomIntInRange(30000, 45000)

					while OnJob and waitUntil > GetGameTimer() do
						Citizen.Wait(0)
					end

					if OnJob and IsPedInAnyVehicle(playerPed, false) and GetEntitySpeed(playerPed) > 0 then
						CurrentCustomer = YuruyenNPCrandom()

						if CurrentCustomer ~= nil then
							CurrentCustomerBlip = AddBlipForEntity(CurrentCustomer)

							SetBlipAsFriendly(CurrentCustomerBlip, true)
							SetBlipColour(CurrentCustomerBlip, 2)
							SetBlipCategory(CurrentCustomerBlip, 3)
							SetBlipRoute(CurrentCustomerBlip, true)

							SetEntityAsMissionEntity(CurrentCustomer, true, false)
							ClearPedTasksImmediately(CurrentCustomer)
							SetBlockingOfNonTemporaryEvents(CurrentCustomer, true)

							local standTime = GetRandomIntInRange(5000, 10000) -- 60000, 180000     // yeni kısmı 5000, 10000
							TaskStandStill(CurrentCustomer, standTime)

							exports['mythic_notify']:DoHudText('inform', 'you found a customer, approach them')

						end
					end
				end
			else
				if IsPedFatallyInjured(CurrentCustomer) then
					exports['mythic_notify']:DoHudText('inform', 'your client is a parasite, look for another')


					if DoesBlipExist(CurrentCustomerBlip) then
						RemoveBlip(CurrentCustomerBlip)
					end

					if DoesBlipExist(DestinationBlip) then
						RemoveBlip(DestinationBlip)
					end

					SetEntityAsMissionEntity(CurrentCustomer, false, true)

					CurrentCustomer, CurrentCustomerBlip, DestinationBlip, IsNearCustomer, CustomerIsEnteringVehicle, CustomerEnteredVehicle, targetCoords = nil, nil, nil, false, false, false, nil
				end

				if IsPedInAnyVehicle(playerPed, false) then
					local vehicle          = GetVehiclePedIsIn(playerPed, false)
					local playerCoords     = GetEntityCoords(playerPed)
					local customerCoords   = GetEntityCoords(CurrentCustomer)
					local customerDistance = #(playerCoords - customerCoords)

					if IsPedSittingInVehicle(CurrentCustomer, vehicle) then
						if CustomerEnteredVehicle then
							local targetDistance = #(playerCoords - targetCoords)

							if targetDistance <= 10.0 then
								TaskLeaveVehicle(CurrentCustomer, vehicle, 0)

								exports['mythic_notify']:DoHudText('uber', 'UBER :: New customer wanted!')


								

								TaskGoStraightToCoord(CurrentCustomer, targetCoords.x, targetCoords.y, targetCoords.z, 1.0, -1, 0.0, 0.0)
								SetEntityAsMissionEntity(CurrentCustomer, false, true)
								TriggerServerEvent('umt_uber:success')
								RemoveBlip(DestinationBlip)

								local scope = function(customer)
									ESX.SetTimeout(20000, function() -- 60000
										DeletePed(customer)
									end)
								end

								scope(CurrentCustomer)

								CurrentCustomer, CurrentCustomerBlip, DestinationBlip, IsNearCustomer, CustomerIsEnteringVehicle, CustomerEnteredVehicle, targetCoords = nil, nil, nil, false, false, false, nil
							end

							if targetCoords then
								DrawMarker(20, targetCoords.x, targetCoords.y, targetCoords.z + 1.1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 234, 223, 72, 155, false, false, 2, true, nil, nil, false)
							end
						else
							RemoveBlip(CurrentCustomerBlip)
							CurrentCustomerBlip = nil
							targetCoords = Config.NPCLoc[GetRandomIntInRange(1, #Config.NPCLoc)]
							local distance = #(playerCoords - targetCoords)
							while distance < Config.OrtalamaUzak do
								Citizen.Wait(5)

								targetCoords = Config.NPCLoc[GetRandomIntInRange(1, #Config.NPCLoc)]
								distance = #(playerCoords - targetCoords)
							end

							local street = table.pack(GetStreetNameAtCoord(targetCoords.x, targetCoords.y, targetCoords.z))
							local msg    = nil

							if street[2] ~= 0 and street[2] ~= nil then
								msg = string.format('There a place close to take me there', GetStreetNameFromHashKey(street[1]), GetStreetNameFromHashKey(street[2]))
							else
								msg = string.format('KİŞİ :: To the location I marked please', GetStreetNameFromHashKey(street[1]))
							end

							exports['mythic_notify']:DoHudText('uber', msg)


							DestinationBlip = AddBlipForCoord(targetCoords.x, targetCoords.y, targetCoords.z)

							BeginTextCommandSetBlipName('STRING')
							AddTextComponentSubstringPlayerName('Destination')
							EndTextCommandSetBlipName(blip)
							SetBlipRoute(DestinationBlip, true)

							CustomerEnteredVehicle = true
						end
					else
						DrawMarker(20, customerCoords.x, customerCoords.y, customerCoords.z + 1.1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 234, 223, 72, 155, false, false, 2, true, nil, nil, false)

						if not CustomerEnteredVehicle then
							if customerDistance <= 40.0 then

								if not IsNearCustomer then
									exports['mythic_notify']:DoHudText('inform', 'Customer Get a little closer soon')

									IsNearCustomer = true
								end

							end

							if customerDistance <= 20.0 then
								if not CustomerIsEnteringVehicle then
									ClearPedTasksImmediately(CurrentCustomer)

									local maxSeats, freeSeat = GetVehicleMaxNumberOfPassengers(vehicle)

									for i=maxSeats - 1, 0, -1 do
										if IsVehicleSeatFree(vehicle, i) then
											freeSeat = i
											break
										end
									end

									if freeSeat then
										TaskEnterVehicle(CurrentCustomer, vehicle, -1, freeSeat, 2.0, 0)
										CustomerIsEnteringVehicle = true
									end
								end
							end
						end
					end
				else
					DrawSub('Lütfen Aracına geri dön', 5000)
				end
			end
		else
			Citizen.Wait(500)
		end
	end
end)
















































-------------------------------------------------------

--						ANIMATION AREA you can open it if you want.

-------------------------------------------------------



-- local phoneProp = 0
-- local phoneModel = "prop_npc_phone_02"

-- local currentStatus = 'out'
-- local lastDict = nil
-- local lastAnim = nil
-- local lastIsFreeze = false
-- local oIsAnimationOn = false
-- local oObjectProp = "prop_npc_phone_02"
-- local oObject_net = nil


-- function umtAnim()
-- 	local player = GetPlayerPed(-1)
-- 	local playerID = PlayerId()
-- 	local plyCoords = GetOffsetFromEntityInWorldCoords(GetPlayerPed(PlayerId()), 0.0, 0.0, -5.0)
-- 	local phoneRspawned = CreateObject(GetHashKey(oObjectProp), plyCoords.x, plyCoords.y, plyCoords.z, 1, 1, 1)
-- 	local netid = ObjToNet(phoneRspawned)
-- 	local ad = "amb@world_human_stand_mobile@female@text@enter"
-- 	local ad2 = "amb@world_human_stand_mobile@female@text@base"
-- 	local ad3 = "amb@world_human_stand_mobile@female@text@exit"
  
-- 	if (DoesEntityExist(player) and not IsEntityDead(player)) then
-- 		loadAnimDict(ad)
-- 		loadAnimDict(ad2)
-- 		loadAnimDict(ad3)
-- 		RequestModel(GetHashKey(oObjectProp))
-- 		if oIsAnimationOn == true then
-- 			--EnableGui(false)
-- 			TaskPlayAnim(player, ad3, "exit", 8.0, 1.0, -1, 50, 0, 0, 0, 0)
-- 			Wait(1840)
-- 			DetachEntity(NetToObj(oObject_net), 1, 1)
-- 			DeleteEntity(NetToObj(oObject_net))
-- 			Wait(750)
-- 			ClearPedSecondaryTask(player)
-- 			oObject_net = nil
-- 			oIsAnimationOn = false
-- 		else
-- 			oIsAnimationOn = true
-- 			Wait(500)
-- 			--SetNetworkIdExistsOnAllMachines(netid, true)
-- 			--NetworkSetNetworkIdDynamic(netid, true)
-- 			--SetNetworkIdCanMigrate(netid, false)
-- 			TaskPlayAnim(player, ad, "enter", 8.0, 1.0, -1, 50, 0, 0, 0, 0)
-- 			Wait(1360)
-- 			AttachEntityToEntity(phoneRspawned,GetPlayerPed(playerID),GetPedBoneIndex(GetPlayerPed(playerID), 28422),-0.005,0.0,0.0,360.0,360.0,0.0,1,1,0,1,0,1)
-- 			oObject_net = netid
-- 			Wait(200)
-- 			--EnableGui(true)
-- 		end
-- 	end
--   end

-- function PlayAnim (status, freeze, force)
-- 	if currentStatus == status and force ~= true then
-- 		return
-- 	end

-- 	myPedId = GetPlayerPed(-1)
-- 	local freeze = freeze or false

-- 	local dict = "cellphone@"
-- 	if IsPedInAnyVehicle(myPedId, false) then
-- 		dict = "anim@cellphone@in_car@ps"
-- 	end
-- 	loadAnimDict(dict)

-- 	local anim = ANIMS[dict][currentStatus][status]
-- 	if currentStatus ~= 'out' then
-- 		StopAnimTask(myPedId, lastDict, lastAnim, 1.0)
-- 	end
-- 	local flag = 50
-- 	if freeze == true then
-- 		flag = 14
-- 	end
-- 	TaskPlayAnim(myPedId, dict, anim, 3.0, -1, -1, flag, 0, false, false, false)

-- 	if status ~= 'out' and currentStatus == 'out' then
-- 		Citizen.Wait(380)
-- 		newProp()
-- 	end

-- 	lastDict = dict
-- 	lastAnim = anim
-- 	lastIsFreeze = freeze
-- 	currentStatus = status

-- 	if status == 'out' then
-- 		Citizen.Wait(180)
-- 		deleteRadio()
-- 		StopAnimTask(myPedId, lastDict, lastAnim, 1.0)
-- 	end

-- end

-- function PlayOut ()
-- 	PlayAnim('out')
-- end

-- function newProp()
-- 	deleteRadio()
-- 	RequestModel(phoneModel)
-- 	while not HasModelLoaded(phoneModel) do
-- 		Citizen.Wait(1)
-- 	end
-- 	phoneProp = CreateObject(phoneModel, 1.0, 1.0, 1.0, 1, 1, 0)
-- 	local bone = GetPedBoneIndex(myPedId, 28422)
-- 	AttachEntityToEntity(phoneProp, myPedId, bone, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1, 1, 0, 0, 2, 1)
-- end

-- function deleteRadio ()
-- 	if phoneProp ~= 0 then
-- 		Citizen.InvokeNative(0xAE3CBE5BF394C9C9 , Citizen.PointerValueIntInitialized(phoneProp))
-- 		phoneProp = 0
-- 	end
-- end
