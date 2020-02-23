RegisterNetEvent('es:setMoneyIcon')
AddEventHandler('es:setMoneyIcon', function(i)
	SendNUIMessage({
		seticon = true,
		icon = i
	})
end)

RegisterNetEvent('es:activateMoney')
AddEventHandler('es:activateMoney', function(e)
	SendNUIMessage({
		setmoney = true,
		money = e
	})
end)

RegisterNetEvent('es:displayMoney')
AddEventHandler('es:displayMoney', function(a)
	enableNative[1] = true

    SetMultiplayerHudCash(a, 0)
    StatSetInt(GetHashKey("MP0_WALLET_BALANCE"), a)
end)

RegisterNetEvent('es:displayBank')
AddEventHandler('es:displayBank', function(a)
	enableNative[2] = true

	SetMultiplayerBankCash()
	SetPlayerCashChange(0, 1)
	Citizen.InvokeNative(0x170F541E1CADD1DE, true)
	SetPlayerCashChange(0, a)
end)

RegisterNetEvent("es:addedMoney")
AddEventHandler("es:addedMoney", function(m, native, current)

	if not native then
		SendNUIMessage({
			addcash = true,
			money = m
		})
	else
		SetMultiplayerHudCash(current, 0)
		StatSetInt(GetHashKey("MP0_WALLET_BALANCE"), current)
	end

end)

RegisterNetEvent("es:removedMoney")
AddEventHandler("es:removedMoney", function(m, native, current)
	if not native then
		SendNUIMessage({
			removecash = true,
			money = m
		})
	else
		SetMultiplayerHudCash(current, 0)
		StatSetInt(GetHashKey("MP0_WALLET_BALANCE"), current)
	end
end)

RegisterNetEvent('es:addedBank')
AddEventHandler('es:addedBank', function(m)
	Citizen.InvokeNative(0x170F541E1CADD1DE, true)
	SetPlayerCashChange(0, math.floor(m))
end)

RegisterNetEvent('es:removedBank')
AddEventHandler('es:removedBank', function(m)
	Citizen.InvokeNative(0x170F541E1CADD1DE, true)
	SetPlayerCashChange(0, -math.floor(m))
end)

RegisterNetEvent("es:setMoneyDisplay")
AddEventHandler("es:setMoneyDisplay", function(val)
	SendNUIMessage({
		setDisplay = true,
		display = val
	})
end)

RegisterNetEvent("es_ui:setSeperatorType")
AddEventHandler("es_ui:setSeperatorType", function(val)
	SendNUIMessage({
		setType = true,
		value = val
	})
end)