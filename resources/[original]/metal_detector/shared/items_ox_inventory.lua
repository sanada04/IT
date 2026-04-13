--[[
  ox_inventory 用アイテム定義
  ===========================
  ox_inventory/data/items.lua を開き、return { ... } の中に
  以下のテーブルの中身をコピーして追加してください。
]]

-- ox_inventory の items.lua に追加するアイテム（中身だけコピー）
return {
    ['metal_detector'] = {
        label = '金属探知タブレット',
        weight = 200,
        stack = true,
        close = true,
        description = '特定の場所でお宝をを探せるタブレット。',
    },
    ['md_gold_bar'] = {
        label = '砂付きの金の延べ棒',
        weight = 7000,
        stack = true,
        close = true,
        description = '金属探知で掘り当てた金の延べ棒。宝商人に売却できる。',
    },
    ['md_treasure_gem'] = {
        label = '砂にまみれた宝石',
        weight = 500,
        stack = true,
        close = true,
        description = '金属探知で掘り当てた宝石。宝商人に売却できる。',
    },
    ['md_broken_watch'] = {
        label = '壊れたロレックス',
        weight = 1500,
        stack = true,
        close = true,
        description = '金属探知で掘り当てた壊れたロレックス。宝商人に売却できる。',
    },
    ['md_metal_scrap'] = {
        label = '少し錆びた金属スクラップ',
        weight = 200,
        stack = true,
        close = true,
        description = '金属探知で掘り出した金属のくず。宝商人に売却できる。',
    },
    ['md_plastic_scrap'] = {
        label = '経年劣化したプラスチック',
        weight = 100,
        stack = true,
        close = true,
        description = '金属探知で掘り出したプラスチック。宝商人に売却できる。',
    },
    ['md_copper_scrap'] = {
        label = '錆びた銅スクラップ',
        weight = 300,
        stack = true,
        close = true,
        description = '金属探知で掘り出した銅。宝商人に売却できる。',
    },
}
