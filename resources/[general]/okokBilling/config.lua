Config, Locales = {}, {}

Config.Debug = false -- 問題の原因究明に役立ちます

Config.OnlyUnpaidCityInvoices = false -- 未払いの市民請求書のみを表示するかどうか

Config.OnlyUnpaidSocietyInvoices = false -- 未払いの組織請求書のみを表示するかどうか

Config.EventPrefix = 'okokBilling'

Config.Locale = 'ja' -- 言語設定（日本語訳ファイルを追加したら'ja'）

Config.DatabaseTable = 'okokBilling'

Config.ReferencePrefix = 'OK' -- 請求書番号の接頭辞

Config.OpenMenuKey = 168 -- デフォルト 168 (F7キー)

Config.OpenMenuCommand = 'invoices' -- メニューを開くためのコマンド

Config.UseOKOKNotify = true -- trueに設定するとokokNotifyを使用し、falseに設定するとQB通知を使用します

Config.UseOKOKBankingTransactions = false -- trueに設定すると、請求書をokokBankingの取引として登録します

Config.InvoiceDistance = 15 -- 請求書を作成できる距離

Config.AllowPlayersInvoice = true -- プレイヤーがプレイヤー間の請求書を作成できるかどうか

Config.okokRequests = false -- 悪用を防ぐため、プレイヤー間の請求書のみに適用

Config.AuthorReceivesAPercentage = true -- 組織請求書を送信した際に、作成者がパーセンテージを受け取るかどうか

Config.AuthorPercentage = 10 -- 請求書作成者が受け取るパーセンテージ

Config.VATPercentage = 23 -- 消費税のパーセンテージ

Config.SocietyReceivesLessWithVAT = false -- 消費税込みで組織の受取額を減らすかどうか

Config.QBManagement = true -- trueに設定するとqb-managementリソースを使用し、falseに設定するとokokBankingのデータベーステーブルを使用します

Config.UseQBBanking = false -- 最新のQBCoreバージョンで役立ちます

Config.RenewedBanking = false -- Renewed-Bankingを使用している場合はtrueに設定します

Config.SocietyHasSocietyPrefix = false -- *リソースが正常に動作している場合は変更しないでください* trueに設定すると、組織請求書の支払時に `society_police` (例) を検索します

Config.AutoDeletePaidInvoices = true -- true: 支払い済みの請求書を削除します (ラグを減らすため) | false: 支払い済みの請求書を削除しません

Config.DeletePaidInvoicesEvery = 30 -- 支払い済みの請求書を削除する頻度 (分単位)

Config.AuthorReceiveNotification = false -- trueに設定すると、請求書が支払われた際に作成者に通知を送信します

-- 自動支払い

Config.UseAutoPay = true -- 自動支払いを使用するかどうか

Config.AllowMoneyToGoNegative = false -- trueに設定すると、プレイヤーの所持金がマイナスになることを許可します

Config.DefaultLimitDate = 7 -- 支払期限 (日数)

Config.CheckForUnpaidInvoicesEvery = 30 -- 未払い請求書をチェックする頻度 (分)

Config.FeeAfterEachDay = true -- 期限切れ後、毎日手数料を請求するかどうか

Config.FeeAfterEachDayPercentage = 5 -- 毎日請求される手数料のパーセンテージ

-- 自動支払い

Config.JobsWithCityInvoices = { -- 市民請求書を作成できるジョブ (あらゆる請求書を削除できます) | 管理者はデフォルトでアクセスできます
	'court'
}

Config.CityInvoicesAccessRanks = { -- 市民請求書を作成できるジョブ (あらゆる請求書を削除できます)
	'' -- すべてのジョブにアクセス権があります
}

Config.AllowedSocieties = { -- 組織請求書にアクセスできる組織
	'police',
	'ambulance'
}

Config.InspectCitizenSocieties = { -- 市民請求書を閲覧できる組織
	'police'
}

Config.SocietyAccessRanks = { -- 組織請求書と市民請求書にアクセスできる組織のランク
	'Boss',
	'Chief',
}

Config.BillsList = {
	['police'] = {
		{'速度超過違反', 550},
		{'駐停車禁止', 1200},
		{'道路交通法違反', 250},
		{'危険運転', 750},
		{'妨害運転罪', 1000},
		{'Custom'}, -- 値を設定しない場合、プレイヤーはカスタム請求書 (カスタム価格) を作成できます
	},
	['ambulance'] = {
		{'救急車対応', 550},
		{'医療処置1', 750},
		{'医療処置2', 1200},
		{'医療処置3', 250},
		{'医療処置4', 400},
	},
}

Config.AdminGroups = {
	'god',
	'admin',
	'mod',
}

-------------------------- DISCORDログ

-- Discord Webhook URLを設定するには、sv_utils.luaの3行目に移動してください

Config.BotName = 'ServerName' -- 任意のボット名を入力してください

Config.ServerName = 'ServerName' -- あなたのサーバー名を入力してください

Config.IconURL = '' -- 任意の画像リンクを挿入してください

Config.DateFormat = '%d/%m/%Y [%X]' -- 日付形式を変更するには、このウェブサイトを確認してください - https://www.lua.org/pil/22.1.html

-- Webhookの色を変更するには、色の10進数値を設定する必要があります。このウェブサイトを使用して変換できます - https://www.mathsisfun.com/hexadecimal-decimal-colors.html

Config.CreatePersonalInvoiceWebhookColor = '65535' -- 個人請求書作成時のWebhookの色

Config.CreateJobInvoiceWebhookColor = '16776960' -- ジョブ請求書作成時のWebhookの色

Config.CancelInvoiceWebhookColor = '16711680' -- 請求書キャンセル時のWebhookの色

Config.PayInvoiceWebhookColor = '65280' -- 請求書支払い時のWebhookの色

-------------------------- ロケール (変更しないでください)

function _L(id) 
	if Locales[Config.Locale][id] then 
		return Locales[Config.Locale][id] 
	else 
		print('Locale '..id..' doesn\'t exist') 
	end 
end