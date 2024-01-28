ESX = exports["es_extended"]:getSharedObject()

ESX.RegisterServerCallback('c3-vrtnar:checkMoney', function(playerId, cb)
	local xPlayer = ESX.GetPlayerFromId(playerId)
    local name = ESX.GetPlayerFromId(playerId)

	if xPlayer.getMoney() >= Config.DepositPrice then
        xPlayer.removeMoney(Config.DepositPrice)
		cb(true)
    elseif xPlayer.getAccount('bank').money >= Config.DepositPrice then
        xPlayer.removeAccountMoney('bank', Config.DepositPrice)
        cb(true)
	else
		cb(false)
	end
end)

RegisterServerEvent('c3-vrtnar:returnVehicle')
AddEventHandler('c3-vrtnar:returnVehicle', function()
	local xPlayer = ESX.GetPlayerFromId(source)
	local Payout = Config.DepositPrice
	
	xPlayer.addAccountMoney('bank', Config.DepositPrice)
end)

RegisterServerEvent('c3-vrtnar:Payout')
AddEventHandler('c3-vrtnar:Payout', function(salary, arg)	
	local xPlayer = ESX.GetPlayerFromId(source)
	local Payout = salary * arg
	
	xPlayer.addMoney(Payout)
end)