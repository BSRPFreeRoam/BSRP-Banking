local History = {} -- [identifier] = { {type, amount, note, time}, ... }

local function getPlayer(src)
    if GetResourceState('bsrp') ~= 'started' then return nil end
    return exports.bsrp:GetPlayer(src)
end

local function getMoney(src, account)
    return exports.bsrp:GetMoney(src, account) or 0
end

local function addMoney(src, account, amount, reason)
    return exports.bsrp:AddMoney(src, account, amount, reason)
end

local function removeMoney(src, account, amount, reason)
    return exports.bsrp:RemoveMoney(src, account, amount, reason)
end

local function notify(src, msg, nType)
    TriggerClientEvent('bsrp:client:notify', src, msg, nType or 'info')
end

local function identifier(src)
    local p = getPlayer(src)
    return p and p.identifier or ('src:' .. src)
end

local function pushHistory(src, entry)
    local id = identifier(src)
    History[id] = History[id] or {}
    table.insert(History[id], 1, {
        type = entry.type,
        amount = entry.amount,
        note = entry.note or '',
        time = os.time(),
    })
    while #History[id] > (Config.HistoryLimit or 30) do
        table.remove(History[id])
    end
end

local function slimHistory(src)
    local id = identifier(src)
    local list = History[id] or {}
    local out = {}
    for i = 1, math.min(#list, Config.HistoryLimit or 30) do
        local e = list[i]
        out[#out + 1] = {
            type = e.type,
            amount = e.amount,
            note = e.note,
            time = e.time,
            label = os.date('%m/%d %H:%M', e.time),
        }
    end
    return out
end

local function balancePayload(src)
    local p = getPlayer(src)
    return {
        cash = getMoney(src, 'cash'),
        bank = getMoney(src, 'bank'),
        name = p and p.name or GetPlayerName(src),
        history = slimHistory(src),
        quick = Config.QuickAmounts or { 100, 500, 1000, 5000 },
        bankName = Config.BankName,
        subtitle = Config.Subtitle,
    }
end

RegisterNetEvent('bsrp-banking:server:open', function(mode)
    local src = source
    if not getPlayer(src) then
        notify(src, 'Account not loaded', 'error')
        return
    end
    TriggerClientEvent('bsrp-banking:client:open', src, mode or 'bank', balancePayload(src))
end)

RegisterNetEvent('bsrp-banking:server:refresh', function()
    local src = source
    if not getPlayer(src) then return end
    TriggerClientEvent('bsrp-banking:client:update', src, balancePayload(src))
end)

RegisterNetEvent('bsrp-banking:server:deposit', function(amount)
    local src = source
    amount = math.floor(tonumber(amount) or 0)
    if amount <= 0 then return end
    if not getPlayer(src) then return end

    if not removeMoney(src, 'cash', amount, 'bank_deposit') then
        notify(src, 'Not enough cash', 'error')
        return
    end
    addMoney(src, 'bank', amount, 'bank_deposit')
    pushHistory(src, { type = 'deposit', amount = amount, note = 'Cash deposit' })
    notify(src, ('Deposited $%s'):format(amount), 'success')
    TriggerClientEvent('bsrp-banking:client:update', src, balancePayload(src))
end)

RegisterNetEvent('bsrp-banking:server:withdraw', function(amount)
    local src = source
    amount = math.floor(tonumber(amount) or 0)
    if amount <= 0 then return end
    if not getPlayer(src) then return end

    if not removeMoney(src, 'bank', amount, 'bank_withdraw') then
        notify(src, 'Insufficient bank balance', 'error')
        return
    end
    addMoney(src, 'cash', amount, 'bank_withdraw')
    pushHistory(src, { type = 'withdraw', amount = amount, note = 'Cash withdraw' })
    notify(src, ('Withdrew $%s'):format(amount), 'success')
    TriggerClientEvent('bsrp-banking:client:update', src, balancePayload(src))
end)

RegisterNetEvent('bsrp-banking:server:transfer', function(targetId, amount, note)
    local src = source
    targetId = tonumber(targetId)
    amount = math.floor(tonumber(amount) or 0)
    note = type(note) == 'string' and note:sub(1, 48) or 'Transfer'

    if not targetId or amount <= 0 then return end
    if targetId == src then
        notify(src, 'Cannot transfer to yourself', 'error')
        return
    end
    if not getPlayer(src) or not getPlayer(targetId) then
        notify(src, 'Player not online', 'error')
        return
    end

    if not removeMoney(src, 'bank', amount, 'bank_transfer_out') then
        notify(src, 'Insufficient bank balance', 'error')
        return
    end
    addMoney(targetId, 'bank', amount, 'bank_transfer_in')

    local from = getPlayer(src)
    local to = getPlayer(targetId)
    pushHistory(src, {
        type = 'transfer_out',
        amount = amount,
        note = ('To %s — %s'):format(to and to.name or targetId, note),
    })
    pushHistory(targetId, {
        type = 'transfer_in',
        amount = amount,
        note = ('From %s — %s'):format(from and from.name or src, note),
    })

    notify(src, ('Sent $%s to ID %s'):format(amount, targetId), 'success')
    notify(targetId, ('Received $%s from %s'):format(amount, from and from.name or src), 'success')
    TriggerClientEvent('bsrp-banking:client:update', src, balancePayload(src))
    TriggerClientEvent('bsrp-banking:client:update', targetId, balancePayload(targetId))
end)

-- Phone / other resources
exports('GetBankBalance', function(src)
    return getMoney(src, 'bank')
end)

exports('OpenBank', function(src, mode)
    if not getPlayer(src) then return false end
    TriggerClientEvent('bsrp-banking:client:open', src, mode or 'bank', balancePayload(src))
    return true
end)

exports('GetHistory', function(src)
    return slimHistory(src)
end)
