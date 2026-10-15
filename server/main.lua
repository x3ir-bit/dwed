local QBCore = exports['qb-core']:GetCoreObject()

local PartPrices = {
    car_door = 350,
    car_hood = 400,
    car_battery = 250,
    catalytic_converter = 500,
    car_panel = 300,
}

lib.callback.register('qb-chopshop:server:getParts', function(source)
    local parts = {}
    for itemName, price in pairs(PartPrices) do
        local count = exports.ox_inventory:Search(source, 'count', itemName)
        if count and count > 0 then
            table.insert(parts, {
                name = itemName,
                label = itemName:gsub('_', ' '),
                count = count,
                price = price
            })
        end
    end
    return parts
end)

lib.callback.register('qb-chopshop:server:sellParts', function(source, items)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return { success = false, message = 'Player not found' } end

    local totalEarned = 0
    for _, item in ipairs(items) do
        local itemName = item.name
        local count = item.count or 1

        if PartPrices[itemName] then
            local hasCount = exports.ox_inventory:Search(source, 'count', itemName)
            local toRemove = math.min(count, hasCount or 0)

            if toRemove > 0 then
                for i = 1, toRemove do
                    exports.ox_inventory:RemoveItem(source, itemName, 1)
                end
                totalEarned = totalEarned + (toRemove * PartPrices[itemName])
            end
        end
    end

    if totalEarned > 0 then
        Player.Functions.AddMoney('cash', totalEarned, 'chopshop_sell_parts')
    end

    return { success = true, earned = totalEarned }
end)

lib.callback.register('qb-chopshop:server:tryLockpick', function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return false end

    local hasLockpick = exports.ox_inventory:Search(source, 'count', Config.LockpickItem)
    if not hasLockpick or hasLockpick < 1 then
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Missing Item',
            description = ('You need a %s'):format(Config.LockpickItem),
            type = 'error'
        })
        return false
    end

    local success = exports.ox_inventory:RemoveItem(source, Config.LockpickItem, 1)
    if not success then return false end
    return true
end)

RegisterNetEvent('qb-chopshop:server:givePart', function(itemName)
    local src = source
    local coords = GetEntityCoords(GetPlayerPed(src))
    local dist = #(coords - Config.ChopshopLocation)
    if dist > 15.0 then return end

    exports.ox_inventory:AddItem(src, itemName, 1)
end)

RegisterNetEvent('qb-chopshop:server:collectReward', function(reward, vehicleModel)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local coords = GetEntityCoords(GetPlayerPed(src))
    local dist = #(coords - Config.ChopshopLocation)
    if dist > 15.0 then return end

    Player.Functions.AddMoney('cash', reward, 'chopshop_reward')
    print(('[qb-chopshop] %s collected $%d for %s'):format(Player.PlayerData.citizenid, reward, vehicleModel))
end)   