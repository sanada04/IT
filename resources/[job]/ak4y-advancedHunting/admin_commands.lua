--[[
    ox_inventory は QBCore の UseItem を橋渡しするが、念のため従来の登録も維持。
    クライアントイベントはリソース固有プレフィックス（他スクリプトと衝突しない）。
]]

local QBCore = exports['qb-core']:GetCoreObject()

local function bait(src, animal, quality, itemName)
    TriggerClientEvent('ak4y-advancedHunting:clientBait', src, animal, quality, itemName)
end

QBCore.Functions.CreateUseableItem('deer_bait', function(source, item)
    bait(source, 'a_c_deer', 'bad', 'deer_bait')
end)

QBCore.Functions.CreateUseableItem('deer_bait2', function(source, item)
    bait(source, 'a_c_deer', 'good', 'deer_bait2')
end)

QBCore.Functions.CreateUseableItem('pig_bait', function(source, item)
    bait(source, 'a_c_pig', 'bad', 'pig_bait')
end)

QBCore.Functions.CreateUseableItem('pig_bait2', function(source, item)
    bait(source, 'a_c_pig', 'good', 'pig_bait2')
end)

QBCore.Functions.CreateUseableItem('chicken_bait', function(source, item)
    bait(source, 'a_c_hen', 'bad', 'chicken_bait')
end)

QBCore.Functions.CreateUseableItem('chicken_bait2', function(source, item)
    bait(source, 'a_c_hen', 'good', 'chicken_bait2')
end)

QBCore.Functions.CreateUseableItem('hunting_knife', function(source, item)
    TriggerClientEvent('ak4y-advancedHunting:clientKnife', source)
end)