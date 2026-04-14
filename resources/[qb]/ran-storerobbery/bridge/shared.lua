local qb = GetResourceState('qb-core')
local esx = GetResourceState('es_extended')
local ox = GetResourceState('ox_core')
-- qb-core と ox_core が両方 ensure されている場合、ここで ox を先にすると bridge/ox が無くエラーになる。
-- ox_inventory 利用の QBCore サーバーでは qb ブリッジ（Config.Inventory = "ox"）で足りる。
Framework = qb == 'started' and 'qb' or ox == 'started' and 'ox' or esx == 'started' and 'esx' or nil
