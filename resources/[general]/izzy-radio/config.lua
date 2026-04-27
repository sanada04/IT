Config = {}

Config.Framework = "qb" -- auto, esx or qb
Config.voipSystem = "pma-voice" -- auto, pma-voice, mumble-voip, saltychat
Config.debug = true
Config.radioName = "radio" -- item name
Config.defaultVolume = 50 -- default volume of the radio, 0 - 100
Config.maxRadioDisplayNameLength = 24 -- max chars for /radioname

Config.RadioProp = 'prop_cs_hand_radio'

Config.jobChannels = { -- channels where only designated jobs can participate
    [1] = {
        frequency = {
            "1",
            "2",
            "3",
            "4",
            "5",
            "6",
            "7",
            "8",
            "9",
            "10",
        },
        jobs = {
            "police",
            "bcso"
        }
    },
    [2] = {
        frequency = {
            "2.0"
        },
        jobs = {
            "ambulance"
        }
    }
}

Config.Locale = {
    created = "チャンネルを作成しました！",
    created_fail = "同じ周波数のチャンネルはすでに作成されています。",

    disconnected = "無線チャンネルから退出しました！",
    disconnected_fail = "無線から切断する際にエラーが発生しました。",

    connected = "無線チャンネルに接続しました！",
    password = "このチャンネルに入るためのパスワードを入力してください！",

    notfound = "参加しようとした周波数が見つかりませんでした！",
    wrong = "パスワードが間違っています！",

    wait = "1秒後にもう一度お試しください。",
    kick = "無線機を所持していないため切断されました。",
    job = "この周波数は特定の職業専用です！",

    volume_up = "音量を上げました。",
    volume_down = "音量を下げました。",
    max = "音量は最大です！",
    min = "音量は最小です！",

    name_updated = "無線表示名を変更しました。",
    name_reset = "無線表示名を初期化しました。",
    name_too_long = "名前が長すぎます。",
    name_invalid = "名前が不正です。"
}

function getFramework()
    if Config.Framework == "esx" then
        return exports['es_extended']:getSharedObject(), "esx"
    elseif Config.Framework == "qb" then
        return exports["qb-core"]:GetCoreObject(), "qb"
    elseif Config.Framework == "auto" then
        if GetResourceState('qb-core') == 'started' then
            return exports["qb-core"]:GetCoreObject(), "qb"
        elseif GetResourceState('es_extended') == 'started' then
            return exports['es_extended']:getSharedObject(), "esx"
        end
    end
end