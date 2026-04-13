Config = {}

-- 見た目の色・フォントは html/main.css の :root を編集してください。

-- QBCore: キャラ未ロード（マルチキャラ画面・ログアウト直後など）では HUD を出さない
Config.HideDuringCharacterSelect = true

Config.ShowServerName = true -- Set true to show the given Config.ServerName below

Config.ServerName = "SANADA test server" -- Shows this name if Config.ShowServerName = true

Config.ShowPlayerName = false -- Set true to show to player name

Config.ShowPlayerID = false -- Set True to show to player id

-- 追加表示（QBCore から取得）
Config.ShowServerID = true -- 自分のサーバーID
Config.ShowCash = true -- 手持ち金（cash）
Config.ShowBank = true -- 銀行残高（bank）
Config.ShowCurrentMoney = false -- 現行のお金（cash + bank）は使わない

-- One of the following config things below must be set to true

Config.ShowDateAndTime = true -- Set true to show Date and Time

Config.ShowOnlyDate = false -- Set true to show only the Date

Config.ShowOnlyTime = false -- Set true to show only the Time

-- One of the following config things below must be set to true

Config.DayMonthYear = true -- Set true to have DD-MM-YYYY

Config.MonthDayYear = false -- Set true to have MM-DD-YYYY

Config.YearMonthDay = false -- Set true to have YYYY-MM-DD

Config.YearDayMonth = false -- Set true to have YYYY-DD-MM

Config.TimezoneOffset = 0 -- set this to the offset you need.
--example -1 will make the time 1 hour earlier and 1 will make the time one hour later.
