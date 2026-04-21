local Translations = {
    -- Fuel
    set_fuel_debug = "燃料を設定:",
    cancelled = "キャンセルしました。",
    not_enough_money = "お金が足りません！",
    not_enough_money_in_bank = "銀行の残高が足りません！",
    not_enough_money_in_cash = "所持金が足りません！",
    more_than_zero = "0Lより多く給油してください！",
    emergency_shutoff_active = "緊急遮断のため、現在ポンプは停止しています。",
    nozzle_cannot_reach = "ノズルが届きません！",
    station_no_fuel = "このスタンドは燃料切れです！",
    station_not_enough_fuel = "スタンドにこの量の燃料がありません！",
    show_input_key_special = "車の近くで [G] を押して給油してください！",
    tank_cannot_fit = "タンクに入り切りません！",
    tank_already_full = "車両の燃料は満タンです！",
    need_electric_charger = "電気自動車用の充電器へ行く必要があります！",
    cannot_refuel_inside = "車内からは給油できません！",

    -- 2.1.2 -- Reserves Pickup ---
    fuel_order_ready = "燃料の受け取りが可能です！GPSで受け取り場所を確認してください！",
    draw_text_fuel_dropoff = "[E] トラックを降ろす",
    fuel_pickup_success = "備蓄が %sL まで補充されました",
    fuel_pickup_failed = "Ron Oil がスタンドに燃料を届けました！",
    trailer_too_far = "トレーラーがトラックに取り付けられていないか、離れすぎています！",

    -- 2.1.0
    no_nozzle = "ノズルを持っていません！",
    vehicle_is_damaged = "車両の損傷が激しく、給油できません！",
    vehicle_too_far = "車から離れすぎています！",
    inside_vehicle = "車内からは給油できません！",
    you_are_discount_eligible = "勤務中にすると "..Config.EmergencyServicesDiscount['discount'].."% の割引が受けられます！",
    no_fuel = "燃料がありません..",

    -- Electric
    electric_more_than_zero = "0kWより多く充電してください！",
    electric_vehicle_not_electric = "この車両は電気自動車ではありません！",
    electric_no_nozzle = "この車両は電気自動車ではありません！",

    -- Phone --
    electric_phone_header = "電気充電器",
    electric_phone_notification = "電気料金 合計: $",
    fuel_phone_header = "ガソリンスタンド",
    phone_notification = "合計金額: $",
    phone_refund_payment_label = "ガソリンスタンドでの返金",

    -- Stations
    station_per_liter = " / L に変更しました。",
    station_already_owned = "この拠点は既に所有者がいます！",
    station_cannot_sell = "この拠点は売却できません！",
    station_sold_success = "拠点を売却しました！",
    station_not_owner = "この拠点の所有者ではありません！",
    station_amount_invalid = "数量が無効です！",
    station_more_than_one = "1Lより多く購入してください！",
    station_price_too_high = "価格が高すぎます！",
    station_price_too_low = "価格が低すぎます！",
    station_name_invalid = "名前が無効です！",
    station_name_too_long = "名前は "..Config.NameChangeMaxChar.." 文字以内にしてください。",
    station_name_too_short = "名前は "..Config.NameChangeMinChar.." 文字より長くしてください。",
    station_withdraw_too_much = "スタンドの残高を超えて引き出せません！",
    station_withdraw_too_little = "$1 未満は引き出せません！",
    station_success_withdrew_1 = "$",
    station_success_withdrew_2 = " をスタンド残高から引き出しました！", -- Leave the space @ the front!
    station_deposit_too_much = "所持金を超えて入金できません！",
    station_deposit_too_little = "$1 未満は入金できません！",
    station_success_deposit_1 = "$",
    station_success_deposit_2 = " をスタンド残高に入金しました！", -- Leave the space @ the front!
    station_cannot_afford_deposit = "入金するのに資金が足りません。金額: $",
    station_shutoff_success = "この拠点の遮断バルブの状態を変更しました！",
    station_fuel_price_success = "燃料単価を $",
    station_reserve_cannot_fit = "備蓄に入り切りません！",
    station_reserves_over_max = "最大 "..Config.MaxFuelReserves.." L を超えるため、この量は購入できません",
    station_name_change_success = "名前を次に変更しました: ", -- Leave the space @ the end!
    station_purchased_location_payment_label = "ガソリンスタンド拠点の購入: ",
    station_sold_location_payment_label = "ガソリンスタンド拠点の売却: ",
    station_withdraw_payment_label = "ガソリンスタンドからの出金。拠点: ",
    station_deposit_payment_label = "ガソリンスタンドへの入金。拠点: ",
    -- All Progress Bars
    prog_refueling_vehicle = "給油中..",
    prog_electric_charging = "充電中..",
    prog_jerry_can_refuel = "携行缶に給油中..",
    prog_syphoning = "燃料を吸い出し中..",

    -- Menus

    menu_header_cash = "現金",
    menu_header_bank = "銀行",
    menu_header_close = "キャンセル",
    menu_pay_with_cash = "現金で支払う  \n所持: $",
    menu_pay_with_bank = "銀行で支払う。",
    menu_refuel_header = "ガソリンスタンド",
    menu_refuel_accept = "燃料を購入する。",
    menu_refuel_cancel = "やっぱり給油しない。",
    menu_pay_label_1 = "ガソリン ",
    menu_pay_label_2 = " / L",
    menu_header_jerry_can = "携行缶",
    menu_header_refuel_jerry_can = "携行缶に給油",
    menu_header_refuel_vehicle = "車両に給油",

    menu_electric_cancel = "やっぱり充電しない。",
    menu_electric_header = "電気充電器",
    menu_electric_accept = "電気代を支払う。",
    menu_electric_payment_label_1 = "電気料金 ",
    menu_electric_payment_label_2 = " / kW",


    -- Station Menus

    menu_ped_manage_location_header = "この拠点を管理",
    menu_ped_manage_location_footer = "所有者ならこの拠点を管理できます。",

    menu_ped_purchase_location_header = "この拠点を購入",
    menu_ped_purchase_location_footer = "所有者がいなければ購入できます。",

    menu_ped_emergency_shutoff_header = "緊急遮断の切り替え",
    menu_ped_emergency_shutoff_footer = "緊急時に燃料を止めます。  \n現在のポンプは ",

    menu_ped_close_header = "会話をやめる",
    menu_ped_close_footer = "もう話したくない。",

    menu_station_reserves_header = "備蓄を購入 ",
    menu_station_reserves_purchase_header = "備蓄購入: $",
    menu_station_reserves_purchase_footer = "はい、$ で燃料備蓄を購入します",
    menu_station_reserves_cancel_footer = "備蓄は追加で買わない。",

    menu_purchase_station_header_1 = "合計金額（税込）: $",
    menu_purchase_station_header_2 = " です。",
    menu_purchase_station_confirm_header = "確認",
    menu_purchase_station_confirm_footer = "$ でこの拠点を購入する",
    menu_purchase_station_cancel_footer = "やっぱり買わない。この価格は無理！",

    menu_sell_station_header = "売却 ",
    menu_sell_station_header_accept = "ガソリンスタンドを売却",
    menu_sell_station_footer_accept = "はい、$ でこの拠点を売却する",
    menu_sell_station_footer_close = "もう話すことはない。",

    menu_manage_header = "管理: ",
    menu_manage_reserves_header = "燃料備蓄  \n",
    menu_manage_reserves_footer_1 = " L / 最大 ",
    menu_manage_reserves_footer_2 = " L  \n下から備蓄を追加購入できます！",

    menu_manage_purchase_reserves_header = "備蓄用燃料を追加購入",
    menu_manage_purchase_reserves_footer = "燃料備蓄を $",
    menu_manage_purchase_reserves_footer_2 = " / L で購入する！",

    menu_alter_fuel_price_header = "燃料価格の変更",
    menu_alter_fuel_price_footer_1 = "スタンドの燃料価格を変更したい。  \n現在: $",

    menu_manage_company_funds_header = "会社資金の管理",
    menu_manage_company_funds_footer = "この拠点の資金を管理する。",
    menu_manage_company_funds_header_2 = "資金管理: ",
    menu_manage_company_funds_withdraw_header = "出金",
    menu_manage_company_funds_withdraw_footer = "スタンド口座から出金する。",
    menu_manage_company_funds_deposit_header = "入金",
    menu_manage_company_funds_deposit_footer = "スタンド口座に入金する。",
    menu_manage_company_funds_return_header = "戻る",
    menu_manage_company_funds_return_footer = "別の話をする！",

    menu_manage_change_name_header = "拠点名の変更",
    menu_manage_change_name_footer = "拠点名を変更したい。",

    menu_manage_sell_station_footer = "ガソリンスタンドを $ で売却",

    menu_manage_close = "もう話すことはない！",

    -- Jerry Can Menus
    menu_jerry_can_purchase_header = "携行缶を $ で購入",
    menu_jerry_can_footer_full_gas = "携行缶は満タンです！",
    menu_jerry_can_footer_refuel_gas = "携行缶に給油する！",
    menu_jerry_can_footer_use_gas = "ガソリンを使って車両に給油！",
    menu_jerry_can_footer_no_gas = "携行缶にガソリンがありません！",
    menu_jerry_can_footer_close = "やっぱり携行缶はいらない。",
    menu_jerry_can_close = "やっぱり使わない。",

    -- Syphon Kit Menus
    menu_syphon_kit_full = "サイフォンキットは満杯です！最大 " .. Config.SyphonKitCap .. "L まで！",
    menu_syphon_vehicle_empty = "この車の燃料タンクは空です。",
    menu_syphon_allowed = "油断している相手から燃料を盗む！",
    menu_syphon_refuel = "盗んだガソリンで車両に給油！",
    menu_syphon_empty = "盗んだガソリンで車両に給油！",
    menu_syphon_cancel = "やっぱり使わない。心入れ替えた！",
    menu_syphon_header = "サイフォン",
    menu_syphon_refuel_header = "給油",


    -- Input --
    input_select_refuel_header = "給油量を選択してください。",
    input_refuel_submit = "車両に給油",
    input_refuel_jerrycan_submit = "携行缶に給油",
    input_max_fuel_footer_1 = "最大 ",
    input_max_fuel_footer_2 = "L まで。",
    input_insert_nozzle = "ノズルを差し込む", -- Used for Target as well!

    input_purchase_reserves_header_1 = "備蓄の購入  \n現在の単価: $",
    input_purchase_reserves_header_2 = Config.FuelReservesPrice .. " / L  \n現在の備蓄: ",
    input_purchase_reserves_header_3 = " L  \n満タンまでの費用: $",
    input_purchase_reserves_submit_text = "備蓄を購入",
    input_purchase_reserves_text = '燃料備蓄を購入する。',

    input_alter_fuel_price_header_1 = "燃料価格の変更  \n現在の価格: $",
    input_alter_fuel_price_header_2 = " / L",
    input_alter_fuel_price_submit_text = "価格を変更",

    input_change_name_header_1 = "「",
    input_change_name_header_2 = "」の名前を変更",
    input_change_name_submit_text = "名前変更を送信",
    input_change_name_text = "新しい名前..",

    input_withdraw_funds_header = "出金  \n現在の残高: $",
    input_withdraw_submit_text = "出金",
    input_withdraw_text = "資金を出金",

    input_deposit_funds_header = "入金  \n現在の残高: $",
    input_deposit_submit_text = "入金",
    input_deposit_text = "資金を入金",

    -- Target
    grab_electric_nozzle = "電気ノズルを取る",
    insert_electric_nozzle = "電気ノズルを差し込む",
    grab_nozzle = "ノズルを取る",
    return_nozzle = "ノズルを戻す",
    grab_special_nozzle = "特殊ノズルを取る",
    return_special_nozzle = "特殊ノズルを戻す",
    buy_jerrycan = "携行缶を購入",
    station_talk_to_ped = "ガソリンスタンドについて話す",

    -- Jerry Can
    jerry_can_full = "携行缶は満タンです！",
    jerry_can_refuel = "携行缶に給油してください！",
    jerry_can_not_enough_fuel = "携行缶にその量の燃料がありません！",
    jerry_can_not_fit_fuel = "携行缶にその量は入りません！",
    jerry_can_success = "携行缶に給油しました！",
    jerry_can_success_vehicle = "携行缶で車両に給油しました！",
    jerry_can_payment_label = "携行缶を購入。",

    -- Syphoning
    syphon_success = "車両から燃料を吸い出しました！",
    syphon_success_vehicle = "サイフォンキットで車両に給油しました！",
    syphon_electric_vehicle = "この車は電気自動車です！",
    syphon_no_syphon_kit = "燃料を吸い出す道具が必要です。",
    syphon_inside_vehicle = "車内からは吸い出せません！",
    syphon_more_than_zero = "0Lより多く盗んでください！",
    syphon_kit_cannot_fit_1 = "その量は入りません！入るのは最大: ",
    syphon_kit_cannot_fit_2 = " L です。",
    syphon_not_enough_gas = "その量を給油するには燃料が足りません！",
    syphon_dispatch_string = "(10-90) - ガソリン盗難",
}
Lang = Locale:new({phrases = Translations, warnOnMissing = true})
