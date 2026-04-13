local Translations = {
    error = {
        not_in_range = '市役所から離れすぎています'
    },
    success = {
        recived_license = '%{value} を $50 で受け取りました'
    },
    info = {
        new_job_app = '応募内容を (%{job}) の責任者に送信しました',
        bilp_text = '市民サービス',
        city_services_menu = '~g~E~w~ - 市民サービスメニュー',
        id_card = '身分証明書',
        driver_license = '運転免許',
        weaponlicense = '銃器所持許可',
        new_job = '新しい職に就きました！ (%{job})',
    },
    email = {
        jobAppSender = "%{job}",
        jobAppSub = "%{job} への応募ありがとうございます。",
        jobAppMsg = "%{gender} %{lastname} 様<br /><br />%{job} に応募が届きました。<br /><br />担当者が内容を確認し、面接のご連絡を順次行います。<br /><br />ご応募ありがとうございました。",
        mr = 'Mr',
        mrs = 'Ms',
        sender = '市役所',
        subject = '運転教習の依頼',
        message = '%{gender} %{lastname} 様<br /><br />運転教習を希望する方から連絡がありました。<br />ご対応いただける場合はご連絡ください。<br />氏名: <strong>%{firstname} %{lastname}</strong><br />電話: <strong>%{phone}</strong><br/><br/>敬具<br />ロスサントス市役所'
    }
}

Lang = Locale:new({
    phrases = Translations,
    warnOnMissing = true,
    fallbackLang = Lang,
})
