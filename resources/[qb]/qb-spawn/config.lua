QB = {}

QB.Spawns = {
    ["legion"] = {
        coords = vector4(195.17, -933.77, 29.7, 144.5),
        location = "legion",
        label = "Legion Square",
        pos = {top = 46, left = 60}
    },
    ["lspd"] = {
        coords = vector4(428.23, -984.28, 29.76, 3.5),
        location = "lspd",
        label = "本署",
        pos = {top = 41, left = 61},
    },
    ["cityhall"] = {
        coords = vector4(-541.3518, -210.5296, 37.6499, 207.1905),
        location = "cityhall",
        label = "市役所",
        pos = {top = 51, left = 56.5},
    },
    ["paleto"] = {
        coords = vector4(80.35, 6424.12, 31.67, 45.5),
        location = "paleto",
        label = "Paleto Bay",
        pos = {top = 42, left = 7}
    },

    ["motel"] = {
        coords = vector4(-3238.03, 1013.9, 12.26, 268.43),
        location = "motel",
        label = "Barbareno Road",
        pos = {top = 86, left = 46}
    },
    ["sandy"] = {
        coords = vector4(2050.31, 3727.03, 32.91, 219.25),
        location = "sandy",
        label = "Sandy Shores",
        pos = {top = 22, left = 29},
    },
}

QB.SpawnAccess = { --To disable the buttons
    ['apartments'] = false,
    ['houses'] = false,
    ['lastLoc'] = true,
}

--[[
  初回キャラ（市役所のみのスポーン UI）完了時に実行する処理用。
  - マルチキャラ作成直後のルーティングバケット解除
  - apartments テーブルへスターターアパート登録（無いと次回ログインもずっと「初回」扱いになる）
  - qb-clothing の初回キャラクター作成 UI
  使わない場合は false（その場合は qb-apartments の Apartments.Starting も false 推奨）
]]
QB.FirstSpawnApartmentType = 'apartment1'