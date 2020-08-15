ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)


local sonSuccess = {}


RegisterNetEvent('umt_uber:success')
AddEventHandler('umt_uber:success', function()
	local xPlayer = ESX.GetPlayerFromId(source)
	local timeNow = os.clock()

		if not sonSuccess[source] or timeNow - sonSuccess[source] > 5 then
			sonSuccess[source] = timeNow

			math.randomseed(os.time())
			local total = math.random(Config.MeslekPara.min, Config.MeslekPara.max)

			if xPlayer.job.grade >= 3 then
				total = total * 2
			end
                    local playerMoney  = ESX.Math.Round(total / 100 * 30)
                    local bahsis       = ESX.Math.Round(total / 20 * 60)

                    xPlayer.addMoney(playerMoney)
                    xPlayer.addMoney(bahsis)


                    TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'uber', text = 'UBER :: $ ' .. playerMoney .. 'You got money'})
                    TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'uber', text = 'UBER :: $ ' .. bahsis .. ' Tipped'})

				else
					xPlayer.addMoney(total)
                    TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'uber', text = 'UBER :: ' .. total .. '$ You got money'})
                end
            end)