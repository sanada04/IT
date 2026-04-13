local QBCore = exports['qb-core']:GetCoreObject()

lib.callback.register('money_launder_npc:getBlackMoney', function(source)
    return exports.ox_inventory:GetItemCount(source, Config.BlackMoneyItem) or 0
end)

lib.callback.register('money_launder_npc:convertMoney', function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return 0 end

    local dirty = exports.ox_inventory:GetItemCount(source, Config.BlackMoneyItem) or 0
    if dirty < Config.MinConvert then return 0 end

    local removed = exports.ox_inventory:RemoveItem(source, Config.BlackMoneyItem, dirty)
    if not removed then return 0 end

    local clean = math.floor(dirty * Config.Rate)
    if clean <= 0 then return 0 end

    Player.Functions.AddMoney('cash', clean, 'money-launder-npc')
    return clean
end)
