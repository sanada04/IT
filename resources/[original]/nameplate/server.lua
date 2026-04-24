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

local function GetEarnedIds(src)
    if not QBCore then return {} end
    local ok, p = pcall(function() return QBCore.Functions.GetPlayer(src) end)
    if ok and p then return p.Functions.GetMetaData('nameplate_titles') or {} end
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

local function SendEarnedTitles(src, ids)
    local result = {}
    for _, id in ipairs(ids) do
        for _, t in ipairs(Config.Titles) do
            if t.id == id then result[#result + 1] = {id = id, label = t.label}; break end
        end
    end
    TriggerClientEvent('nameplate:earnedTitles', src, result)
end

-- 保存済み設定からプレイヤーデータを復元
local function ApplySettings(src, Player, charName)
    local settings = Player.Functions.GetMetaData('nameplate_settings')
    local earnedIds = Player.Functions.GetMetaData('nameplate_titles') or {}

    local displayName  = charName
    local titleLabel   = ''
    local nameColor    = Config.DefaultNameColor
    local titleColor   = Config.DefaultTitleColor

    if settings then
        -- 保存された名前があれば使用
        if settings.name and settings.name ~= '' then
            displayName = settings.name
        end
        if settings.nameColor  then nameColor  = settings.nameColor  end
        if settings.titleColor then titleColor = settings.titleColor end

        -- 称号を復元 (まだ保有しているかチェック)
        if settings.titleId and settings.titleId ~= '' then
            for _, id in ipairs(earnedIds) do
                if id == settings.titleId then
                    for _, t in ipairs(Config.Titles) do
                        if t.id == settings.titleId then titleLabel = t.label; break end
                    end
                    break
                end
            end
        end
    end

    playerData[src] = {
        name       = displayName,
        title      = titleLabel,
        nameColor  = nameColor,
        titleColor = titleColor,
    }
end

-- ─── QBCoreキャラクター読み込み ───────────────────────────────────
AddEventHandler('QBCore:Server:PlayerLoaded', function(Player)
    local src = Player.PlayerData.source
    local ci  = Player.PlayerData.charinfo
    local charName = (ci and ci.firstname) and (ci.firstname .. ' ' .. (ci.lastname or '')) or GetPlayerName(src)

    ApplySettings(src, Player, charName)
    Broadcast(src)

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
RegisterNetEvent('nameplate:saveAll', function(name, titleId, nameColor, titleColor)
    local src = source
    name = tostring(name or ''):gsub('[<>{}|]', '')
    if name == '' then Notify(src, '名前が無効です', 'error'); return end

    -- 称号IDを検証してラベルを取得
    local titleLabel = ''
    if titleId and titleId ~= '' then
        local ids = GetEarnedIds(src)
        for _, earned in ipairs(ids) do
            if earned == titleId then
                for _, t in ipairs(Config.Titles) do
                    if t.id == titleId then titleLabel = t.label; break end
                end
                break
            end
        end
    end

    local nc = nameColor  or Config.DefaultNameColor
    local tc = titleColor or Config.DefaultTitleColor

    playerData[src] = { name = name, title = titleLabel, nameColor = nc, titleColor = tc }
    Broadcast(src)

    -- QBCoreメタデータに設定を保存 (ログイン時に復元される)
    if QBCore then
        local ok, p = pcall(function() return QBCore.Functions.GetPlayer(src) end)
        if ok and p then
            p.Functions.SetMetaData('nameplate_settings', {
                name       = name,
                titleId    = titleId,
                nameColor  = nc,
                titleColor = tc,
            })
        end
    end

    Notify(src, '名前プレートを更新しました', 'success')
end)

-- ─── 称号付与コマンド (/givetitle [serverID] [titleId]) ──────────
RegisterCommand('givetitle', function(source, args)
    local src = source
    if not IsAdmin(src) then
        if src ~= 0 then Notify(src, '権限がありません', 'error') end; return
    end

    local targetSrc = tonumber(args[1])
    local titleId   = args[2]
    if not targetSrc or not titleId then
        if src ~= 0 then Notify(src, '使用方法: /givetitle [serverID] [titleId]', 'error') end; return
    end

    local titleLabel = nil
    for _, t in ipairs(Config.Titles) do
        if t.id == titleId then titleLabel = t.label; break end
    end
    if not titleLabel then
        if src ~= 0 then Notify(src, '無効な称号ID: ' .. titleId, 'error') end; return
    end

    if not QBCore then return end
    local ok, tp = pcall(function() return QBCore.Functions.GetPlayer(targetSrc) end)
    if not ok or not tp then
        if src ~= 0 then Notify(src, 'プレイヤーが見つかりません', 'error') end; return
    end

    local ids = tp.Functions.GetMetaData('nameplate_titles') or {}
    for _, id in ipairs(ids) do
        if id == titleId then
            if src ~= 0 then Notify(src, 'すでに保有している称号です', 'error') end; return
        end
    end

    ids[#ids + 1] = titleId
    tp.Functions.SetMetaData('nameplate_titles', ids)
    SendEarnedTitles(targetSrc, ids)
    if src ~= 0 then Notify(src, '「' .. titleLabel .. '」を付与しました', 'success') end
    Notify(targetSrc, '称号「' .. titleLabel .. '」を獲得しました！', 'success')
end, false)

-- ─── 称号削除コマンド (/removetitle [serverID] [titleId]) ────────
RegisterCommand('removetitle', function(source, args)
    local src = source
    if not IsAdmin(src) then
        if src ~= 0 then Notify(src, '権限がありません', 'error') end; return
    end

    local targetSrc = tonumber(args[1])
    local titleId   = args[2]
    if not targetSrc or not titleId then
        if src ~= 0 then Notify(src, '使用方法: /removetitle [serverID] [titleId]', 'error') end; return
    end

    if not QBCore then return end
    local ok, tp = pcall(function() return QBCore.Functions.GetPlayer(targetSrc) end)
    if not ok or not tp then
        if src ~= 0 then Notify(src, 'プレイヤーが見つかりません', 'error') end; return
    end

    local ids    = tp.Functions.GetMetaData('nameplate_titles') or {}
    local newIds = {}
    local found  = false
    for _, id in ipairs(ids) do
        if id == titleId then found = true
        else newIds[#newIds + 1] = id end
    end
    if not found then
        if src ~= 0 then Notify(src, 'そのプレイヤーはこの称号を持っていません', 'error') end; return
    end

    tp.Functions.SetMetaData('nameplate_titles', newIds)
    SendEarnedTitles(targetSrc, newIds)

    -- 装備中の称号が削除された場合は外す
    local titleLabel = nil
    for _, t in ipairs(Config.Titles) do
        if t.id == titleId then titleLabel = t.label; break end
    end
    if titleLabel and playerData[targetSrc] and playerData[targetSrc].title == titleLabel then
        playerData[targetSrc].title = ''
        -- 保存データも更新
        local settings = tp.Functions.GetMetaData('nameplate_settings')
        if settings then
            settings.titleId = ''
            tp.Functions.SetMetaData('nameplate_settings', settings)
        end
        Broadcast(targetSrc)
        Notify(targetSrc, '装備中の称号が削除されました', 'error')
    end

    if src ~= 0 then Notify(src, '称号を削除しました', 'success') end
end, false)

-- ─── 切断時 ───────────────────────────────────────────────────────
AddEventHandler('playerDropped', function()
    local src = source
    playerData[src] = nil
    TriggerClientEvent('nameplate:remove', -1, src)
end)
