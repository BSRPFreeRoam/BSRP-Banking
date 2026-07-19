local open = false
local nearBank = nil
local nearAtm = nil

local function notify(msg, nType)
    if GetResourceState('bsrp') == 'started' then
        exports.bsrp:Notify(msg, nType or 'info')
    else
        TriggerEvent('chat:addMessage', { args = { 'BANK', msg } })
    end
end

local function closeUi()
    if not open then return end
    open = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
end

RegisterNetEvent('bsrp-banking:client:open', function(mode, data)
    open = true
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        mode = mode or 'bank',
        data = data,
    })
end)

RegisterNetEvent('bsrp-banking:client:update', function(data)
    SendNUIMessage({ action = 'update', data = data })
end)

RegisterNUICallback('close', function(_, cb)
    closeUi()
    cb({ ok = true })
end)

RegisterNUICallback('deposit', function(data, cb)
    TriggerServerEvent('bsrp-banking:server:deposit', data and data.amount)
    cb({ ok = true })
end)

RegisterNUICallback('withdraw', function(data, cb)
    TriggerServerEvent('bsrp-banking:server:withdraw', data and data.amount)
    cb({ ok = true })
end)

RegisterNUICallback('transfer', function(data, cb)
    TriggerServerEvent('bsrp-banking:server:transfer', data and data.target, data and data.amount, data and data.note)
    cb({ ok = true })
end)

RegisterNUICallback('refresh', function(_, cb)
    TriggerServerEvent('bsrp-banking:server:refresh')
    cb({ ok = true })
end)

-- Blips
CreateThread(function()
    if Config.Blip.bank and Config.Blip.bank.enabled then
        for _, bank in ipairs(Config.Banks) do
            local b = AddBlipForCoord(bank.coords.x, bank.coords.y, bank.coords.z)
            SetBlipSprite(b, Config.Blip.bank.sprite)
            SetBlipDisplay(b, 4)
            SetBlipScale(b, Config.Blip.bank.scale)
            SetBlipColour(b, Config.Blip.bank.color)
            SetBlipAsShortRange(b, true)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentSubstringPlayerName(Config.Blip.bank.label or 'Bank')
            EndTextCommandSetBlipName(b)
        end
    end
end)

-- Markers + interaction
CreateThread(function()
    while true do
        local sleep = 800
        if not open then
            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)
            nearBank = nil
            nearAtm = nil

            for _, bank in ipairs(Config.Banks) do
                local dist = #(coords - bank.coords)
                if dist < Config.MarkerDistance then
                    sleep = 0
                    if Config.DrawMarker then
                        local m = Config.Marker
                        DrawMarker(
                            m.type,
                            bank.coords.x, bank.coords.y, bank.coords.z - 0.95,
                            0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                            m.scale.x, m.scale.y, m.scale.z,
                            m.color.r, m.color.g, m.color.b, m.color.a,
                            m.bob, false, 2, m.rotate, nil, nil, false
                        )
                    end
                    if dist < Config.InteractDistance then
                        nearBank = bank
                        BeginTextCommandDisplayHelp('STRING')
                        AddTextComponentSubstringPlayerName(('~INPUT_CONTEXT~ Access %s'):format(bank.label or 'Bank'))
                        EndTextCommandDisplayHelp(0, false, true, -1)
                        if IsControlJustReleased(0, Config.InteractKey) then
                            TriggerServerEvent('bsrp-banking:server:open', 'bank')
                        end
                    end
                end
            end

            -- Nearby ATM props (model pool scan)
            if not nearBank then
                local closest, closestDist = nil, 1.9
                for _, model in ipairs(Config.AtmModels) do
                    local obj = GetClosestObjectOfType(coords.x, coords.y, coords.z, 12.0, model, false, false, false)
                    if obj and obj ~= 0 then
                        local oc = GetEntityCoords(obj)
                        local d = #(coords - oc)
                        if d < 12.0 then sleep = 0 end
                        if d < closestDist then
                            closest = obj
                            closestDist = d
                        end
                    end
                end

                if closest then
                    nearAtm = closest
                    BeginTextCommandDisplayHelp('STRING')
                    AddTextComponentSubstringPlayerName('~INPUT_CONTEXT~ Use ATM')
                    EndTextCommandDisplayHelp(0, false, true, -1)
                    if IsControlJustReleased(0, Config.InteractKey) then
                        TriggerServerEvent('bsrp-banking:server:open', 'atm')
                    end
                end
            end
        else
            sleep = 200
            if IsControlJustReleased(0, 322) or IsControlJustReleased(0, 200) then
                closeUi()
            end
        end
        Wait(sleep)
    end
end)

-- Command fallback
RegisterCommand('bank', function()
    if nearBank or nearAtm then
        TriggerServerEvent('bsrp-banking:server:open', nearBank and 'bank' or 'atm')
    else
        notify('Go to a bank or ATM', 'error')
    end
end, false)

exports('OpenBanking', function(mode)
    TriggerServerEvent('bsrp-banking:server:open', mode or 'bank')
end)
