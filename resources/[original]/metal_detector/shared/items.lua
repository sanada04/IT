--[[
  金属探知機スクリプト用アイテム定義
  ==========================================
  あなたのサーバーで使っているインベントリに合わせて追加してください。

  ■ QBCore (qb-core) を使っている場合
  qb-core/shared/items.lua を開き、既存のアイテムテーブルに
  以下のブロックを追加（または既存の ['] の間に貼り付け）してください。

  ■ ox_inventory を使っている場合
  ox_inventory/data/items.lua に以下と同様の項目を追加してください。
  ox_inventory の形式は ['名前'] = { label = '表示名', weight = 100, ... } です。
]]

-- QBCore 用（qb-core/shared/items.lua に追加する内容）
local MetalDetectorItems = {
    -- 金属探知機（購入・探知に使用）
    ['metal_detector'] = {
        ['name'] = 'metal_detector',
        ['label'] = '金属探知タブレット',
        ['weight'] = 200,
        ['type'] = 'item',
        ['image'] = 'metal_detector.png',
        ['unique'] = false,
        ['useable'] = true,
        ['shouldClose'] = true,
        ['description'] = '特定の場所でお宝をを探せるタブレット。',
    },
    -- レア報酬（metal_detector 専用オリジナル）
    ['md_gold_bar'] = {
        ['name'] = 'md_gold_bar',
        ['label'] = '砂付きの金の延べ棒',
        ['weight'] = 7000,
        ['type'] = 'item',
        ['image'] = 'md_gold_bar.png',
        ['unique'] = false,
        ['useable'] = false,
        ['description'] = '金属探知で掘り当てた金の延べ棒。宝商人に売却できる。',
    },
    ['md_treasure_gem'] = {
        ['name'] = 'md_treasure_gem',
        ['label'] = '砂にまみれた宝石',
        ['weight'] = 500,
        ['type'] = 'item',
        ['image'] = 'md_treasure_gem.png',
        ['unique'] = false,
        ['useable'] = false,
        ['description'] = '金属探知で掘り当てた宝石。宝商人に売却できる。',
    },
    ['md_broken_watch'] = {
        ['name'] = 'md_broken_watch',
        ['label'] = '壊れたロレックス',
        ['weight'] = 1500,
        ['type'] = 'item',
        ['image'] = 'md_broken_watch.png',
        ['unique'] = false,
        ['useable'] = false,
        ['description'] = '金属探知で掘り当てた壊れたロレックス。宝商人に売却できる。',
    },
    -- 通常報酬（metal_detector 専用オリジナル）
    ['md_metal_scrap'] = {
        ['name'] = 'md_metal_scrap',
        ['label'] = '少し錆びた金属スクラップ',
        ['weight'] = 200,
        ['type'] = 'item',
        ['image'] = 'md_metal_scrap.png',
        ['unique'] = false,
        ['useable'] = false,
        ['description'] = '金属探知で掘り出した金属のくず。宝商人に売却できる。',
    },
    ['md_plastic_scrap'] = {
        ['name'] = 'md_plastic_scrap',
        ['label'] = '経年劣化したプラスチック',
        ['weight'] = 100,
        ['type'] = 'item',
        ['image'] = 'md_plastic_scrap.png',
        ['unique'] = false,
        ['useable'] = false,
        ['description'] = '金属探知で掘り出したプラスチック。宝商人に売却できる。',
    },
    ['md_copper_scrap'] = {
        ['name'] = 'md_copper_scrap',
        ['label'] = '錆びた銅スクラップ',
        ['weight'] = 300,
        ['type'] = 'item',
        ['image'] = 'md_copper_scrap.png',
        ['unique'] = false,
        ['useable'] = false,
        ['description'] = '金属探知で掘り出した銅。宝商人に売却できる。',
    },
}

-- このファイルは参照用です。実際には qb-core の items.lua に上記をマージしてください。
-- 既存の QBCore では Items = {} のようなテーブルに追加します。例:
-- for k, v in pairs(MetalDetectorItems) do Items[k] = v end

return MetalDetectorItems
