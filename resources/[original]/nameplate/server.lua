local playerData = {}
local QBCore     = nil

if Config.UseQBCore then
    local ok, core = pcall(function() return exports['qb-core']:GetCoreObject() end)
    if ok and core then QBCore = core end
end

local function Notify(src, msg, t)
    TriggerClientEvent('QBCore:Notify', src, msg, t or 'primary')
end

local function GetCharName(src)
    if QBCore then
        local ok, p = pcall(function() return QBCore.Functions.GetPlayer(src) end)
        if ok and p then
            local ci = p.PlayerData and p.PlayerData.charinfo
            if ci and ci.firstname then
                return ci.firstname .. ' ' .. (ci.lastname or '')
            end
        end
    end
    return GetPlayerName(src) or ('Player ' .. src)
end

-- QBCoreメタデータから保有称号IDリストを取得
local function GetEarnedIds(src)
    if not QBCore then return {} end
    local ok, p = pcall(function() return QBCore.Functions.GetPlayer(src) end)
    if ok and p then
        return p.Functions.GetMetaData('nameplate_titles') or {}
    end
    return {}
end

local function IsAdmin(src)
    if src == 0 then return true end
    if not QBCore then return false end
    local ok, p = pcall(function() return QBCore.Functions.GetPlayer(src) end)
    if ok and p then
        local g = p.PlayerData.group
        for _, ag in ipairs(Config.AdminGroups) do
            if g == ag then return true end
        end
    end
    return false
end

local function Broadcast(src)
    local d = playerData[src]
    if not d then return end
    TriggerClientEvent('nameplate:update', -1, src, d.name, d.title, d.nameColor, d.titleColor)
end

-- 保有称号IDリストからラベル付きテーブルに変換してクライアントへ送信
local function SendEarnedTitles(src, ids)
    local result = {}
    for _, id in ipairs(ids) do
        for _, t in ipairs(Config.Titles) do
            if t.id == id then
                result[#result + 1] = { id = id, label = t.label }
                break
            end
        end
    end
    TriggerClientEvent('nameplate:earnedTitles', src, result)
end

-- ─── QBCoreキャラクター読み込み ───────────────────────────────────
AddEventHandler('QBCore:Server:PlayerLoaded', function(Player)
    local src = Player.PlayerData.source
    local ci  = Player.PlayerData.charinfo
    if ci and ci.firstname then
        local prev = playerData[src]
        playerData[src] = {
            name       = ci.firstname .. ' ' .. (ci.lastname or ''),
            title      = prev and prev.title      or '',
            nameColor  = prev and prev.nameColor  or Config.DefaultNameColor,
            titleColor = prev and prev.titleColor or Config.DefaultTitleColor,
        }
        Broadcast(src)
    end
    local ids = Player.Functions.GetMetaData('nameplate_titles') or {}
    SendEarnedTitles(src, ids)
end)

-- ─── 同期リクエスト ───────────────────────────────────────────────
RegisterNetEvent('nameplate:requestSync', function()
    local src = source
    if not playerData[src] then
        playerData[src] = {
            name       = GetCharName(src),
            title      = '',
            nameColor  = Config.DefaultNameColor,
            titleColor = Config.DefaultTitleColor,
        }
    end
    TriggerClientEvent('nameplate:sync', src, playerData)
    Broadcast(src)
    SendEarnedTitles(src, GetEarnedIds(src))
end)

-- ─── UIからの保存 ─────────────────────────────────────────────────
-- titleId: 選択した称号のID ('' = 称号なし)
RegisterNetEvent('nameplate:saveAll', function(name, titleId, nameColor, titleColor)
    local src = source
    name = tostring(name or ''):gsub('[<>{}|]', '')
    if name == '' then
        Notify(src, '名前が無効です', 'error')
        return
    end

    -- 選択された称号IDを検証し、ラベルを取得
    local titleLabel = ''
    if titleId and titleId ~= '' then
        local ids = GetEarnedIds(src)
        for _, earned in ipairs(ids) do
            if earned == titleId then
                for _, t in ipairs(Config.Titles) do
                    if t.id == titleId then
                        titleLabel = t.label
                        break
                    end
                end
                break
            end
        end
    end

    playerData[src] = {
        name       = name,
        title      = titleLabel,
        nameColor  = nameColor  or Config.DefaultNameColor,
        titleColor = titleColor or Config.DefaultTitleColor,
    }
    Broadcast(src)
    Notify(src, '名前プレートを更新しました', 'success')
end)

-- ─── 称号付与コマンド ─────────────────────────────────────────────
-- 使用方法: /givetitle [serverID] [titleId]
RegisterCommand('givetitle', function(source, args)
    local src = source
    if not IsAdmin(src) then
        if src ~= 0 then Notify(src, '権限がありません', 'error') end
        return
    end

    local targetSrc = tonumber(args[1])
    local titleId   = args[2]

    if not targetSrc or not titleId then
        if src ~= 0 then Notify(src, '使用方法: /givetitle [serverID] [titleId]', 'error') end
        return
    end

    local titleLabel = nil
    for _, t in ipairs(Config.Titles) do
        if t.id == titleId then titleLabel = t.label; break end
    end

    if not titleLabel then
        if src ~= 0 then Notify(src, '無効な称号ID: ' .. titleId, 'error') end
        return
    end

    if not QBCore then return end
    local ok, tp = pcall(function() return QBCore.Functions.GetPlayer(targetSrc) end)
    if not ok or not tp then
        if src ~= 0 then Notify(src, 'プレイヤーが見つかりません', 'error') end
        return
    end

    local ids = tp.Functions.GetMetaData('nameplate_titles') or {}
    for _, id in ipairs(ids) do
        if id == titleId then
            if src ~= 0 then Notify(src, 'すでに保有している称号です', 'error') end
            return
        end
    end

    ids[#ids + 1] = titleId
    tp.Functions.SetMetaData('nameplate_titles', ids)
    SendEarnedTitles(targetSrc, ids)

    if src ~= 0 then Notify(src, '「' .. titleLabel .. '」を付与しました', 'success') end
    Notify(targetSrc, '称号「' .. titleLabel .. '」を獲得しました！', 'success')
end, false)

-- ─── 称号削除コマンド ─────────────────────────────────────────────
-- 使用方法: /removetitle [serverID] [titleId]
RegisterCommand('removetitle', function(source, args)
    local src = source
    if not IsAdmin(src) then
        if src ~= 0 then Notify(src, '権限がありません', 'error') end
        return
    end

    local targetSrc = tonumber(args[1])
    local titleId   = args[2]

    if not targetSrc or not titleId then
        if src ~= 0 then Notify(src, '使用方法: /removetitle [serverID] [titleId]', 'error') end
        return
    end

    if not QBCore then return end
    local ok, tp = pcall(function() return QBCore.Functions.GetPlayer(targetSrc) end)
    if not ok or not tp then
        if src ~= 0 then Notify(src, 'プレイヤーが見つかりません', 'error') end
        return
    end

    local ids = tp.Functions.GetMetaData('nameplate_titles') or {}
    local newIds = {}
    local found  = false
    for _, id in ipairs(ids) do
        if id == titleId then found = true
        else newIds[#newIds + 1] = id end
    end

    if not found then
        if src ~= 0 then Notify(src, 'そのプレイヤーはこの称号を持っていません', 'error') end
        return
    end

    tp.Functions.SetMetaData('nameplate_titles', newIds)
    SendEarnedTitles(targetSrc, newIds)

    -- 現在装備中の称号が削除された場合、解除する
    local titleLabel = nil
    for _, t in ipairs(Config.Titles) do
        if t.id == titleId then titleLabel = t.label; break end
    end
    if titleLabel and playerData[targetSrc] and playerData[targetSrc].title == titleLabel then
        playerData[targetSrc].title = ''
        Broadcast(targetSrc)
        Notify(targetSrc, '装備中の称号が削除されたため解除されました', 'error')
    end

    if src ~= 0 then Notify(src, '称号を削除しました', 'success') end
end, false)

-- ─── 切断時 ───────────────────────────────────────────────────────
AddEventHandler('playerDropped', function()
    local src = source
    playerData[src] = nil
    TriggerClientEvent('nameplate:remove', -1, src)
end)
