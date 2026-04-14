Config = {}
ps = exports.ps_lib:init()

-- 基本設定
Config.Debug = false -- デバッグモードの有効/無効（boolean）
Config.OnlyShowOnDuty = false -- 勤務中のみMDTを開けるようにする（boolean）

-- 市民アクセス設定
Config.CivilianAccess = {
    enabled = true,   -- 市民がMDTを開けるようにする（プロフィール+法令閲覧のみ）
    command = true,   -- 市民に /mdt コマンドを許可
    showWarrants = true, -- 市民プロフィールに有効な令状を表示
    showBolos = true,    -- 市民プロフィールに有効なBOLOを表示
}

-- 時刻と日付の設定
Config.DateTime = {
    GameTime = true, -- trueの場合、サーバー時刻ではなくゲーム内時刻を使用（boolean）
    TimeFormat = '24', -- 時刻表示形式（'24' または '12'）
    DateFormat = "MM-DD-YYYY" -- 日付表示形式（文字列: "MM-DD-YYYY", "DD-MM-YYYY", "YYYY-MM-DD"）
}

-- 部署間データ共有
Config.Sharing = {
    -- 相互共有（双方向）
    -- このグループ内の全部署が互いのデータを閲覧可能
    Mutual = {
        types = {
            'reports',
            'bodycams',
            'evidence',
            'bolos',
            'warrants'
        },
        departments = {
            'lspd',
            'bcso',
            'sahp'
        }
    },

    -- 片方向共有（一方向）
    -- viewers は targets のデータを閲覧可能（逆方向は不可）
    OneWay = {
        { -- 例: FIB と GOV
            viewers = {
                'fib',
                'gov'
            },
            targets = {
                'lspd',
                'bcso',
                'sahp'
            },
            types = {
                'reports',
                'bodycams',
                'evidence',
                'bolos',
                'warrants',
            }
        },
    },
}

-- キーバインド
Config.Keys = {
    -- https://docs.fivem.net/docs/game-references/controls/ | デフォルトQWERTY
    OpenMDT = {
        enabled = true, -- キーバインドの有効/無効（boolean）
        key = 'F11', -- MDTを開くキー（string）
    },
}

-- コマンド
Config.Commands = {
    Open = {
        enabled = true, -- コマンドの有効/無効（boolean）
        command = 'mdt', -- MDTを開くコマンド（string）
    },
    MessageOfTheDay = {
        enabled = true, -- コマンドの有効/無効（boolean）
        command = 'motd', -- 本日のメッセージを設定するコマンド（string）
    },
}

-- ディスパッチ設定
Config.Dispatch = {
    Resource = 'ps-dispatch',
    FilterByJob = true,
}

-- Wolfknight ナンバープレート読取設定
Config.UseWolfknightRadar = true -- Wolfknightレーダー連携の有効/無効
Config.WolfknightNotifyTime = 5000 -- ナンバープレート通知の表示時間（ms）
Config.PlateScanForDriversLicense = true -- ナンバースキャン時に運転免許を確認

-- 指紋設定
Config.FingerprintAutoFilled = false -- 市民プロフィールへ指紋を自動入力（false の場合は警官が手動で追加）

-- 指紋スキャン連携
Config.FingerprintScan = {
    enabled = false,                                         -- MDTからの指紋スキャン起動を有効化
    officerEvent = 'police:client:showFingerprint',          -- 警官側で実行されるクライアントイベント
    suspectEvent = 'police:client:showFingerprint',          -- 容疑者側で実行されるクライアントイベント
}

-- 燃料リソース名
Config.Fuel = 'cdn-fuel' -- 車両燃料管理に使用する燃料リソース名

-- 武器登録
Config.RegisterWeaponsAutomatically = true -- 購入時に武器を自動登録（ox_inventory と qb-inventory/qb-weapons）
Config.RegisterCreatedWeapons = false -- アイテム生成時も武器を自動登録（ox_inventory のみ）

-- 押収車両保管場所（vector4: x, y, z, heading）
Config.ImpoundLocations = {
    [1] = vector4(409.09, -1623.37, 29.29, 232.07), -- LSPD 保管所
    [2] = vector4(-436.42, 5982.29, 31.34, 136.0),  -- パレト保管所
}

-- ジョブ設定
Config.PoliceJobType = "leo"
Config.PoliceJobs = {
    'police',
    'lspd',
    'bcso',
    'sahp',
    'fib',
    'gov'
}

Config.DojJobType = "doj"
Config.DojJobs = {
    'doj',
    'lawyer',
}

Config.MedicalJobType = "ems"
Config.MedicalJobs = {
    'ambulance',
}

Config.Uploads = {
    MaxBytes = 5242880, -- 5 MB
    RateLimitPerMinute = 10, -- プレイヤーごとの1分あたり最大アップロード数（0 = 無制限）
    AllowedAttachmentTypes = {
        'image/jpeg',
        'image/png',
        'image/webp',
        'application/pdf'
    },
    AllowedEvidenceImageTypes = {
        'image/jpeg',
        'image/png',
        'image/webp'
    }
}

-- ページネーション上限
Config.Pagination = {
    Citizens = 20, -- 1ページあたりの市民数
    CitizenSearch = 20, -- 市民検索の最大件数
    Cases = 20, -- 1ページあたりのケース数
}

-- 罰金処理
Config.Fines = {
    MaxAmount = 100000,   -- 経済悪用防止のための罰金上限額（$）
    CooldownMs = 30000,   -- 罰金処理間のスパム防止クールダウン（ミリ秒）
}

-- 令状のデフォルト設定
Config.Warrants = {
    DefaultExpiryDays = 7, -- 日付未指定時の令状有効期限（日数）
}

-- ダッシュボードキャッシュTTL（秒）
Config.CacheTTL = {
    ReportStats = 30,
    ActiveUnits = 10,
    UsageMetrics = 60,
}

-- タブレットアニメーション
Config.Animation = {
    Dict = 'amb@world_human_tourist_map@male@base',
    Name = 'base',
}

-- マグショットカメラ
Config.MugshotCamera = {
    DefaultFov = 50.0,
    FovMin = 15.0,
    FovMax = 80.0,
    FovSpeed = 5.0,
}

-- 監視カメラビューア
Config.CameraViewer = {
    RotationSpeed = 0.15,
    ZoomClamp = { min = 0.25, max = 10.0 },
    StartingZoom = 3.0,
    ZoomStep = 0.1,
    FovMin = 10.0,
    FovMax = 100.0,
    FovStep = 2.0,
}

-- 管理権限とデフォルト値（ジョブグレードごと）
Config.ManagementPermissions = {
    -- 市民
    'citizens_search',
    'citizens_edit_licenses',
    -- BOLO
    'bolos_view',
    'bolos_create',
    -- 車両
    'vehicles_search',
    'vehicles_edit_dmv',
    -- 武器
    'weapons_search',
    -- ケース
    'cases_view',
    'cases_create',
    'cases_edit',
    'cases_delete',
    -- 証拠
    'evidence_view',
    'evidence_create',
    'evidence_transfer',
    'evidence_upload',
    -- レポート
    'reports_view',
    'reports_create',
    'reports_delete',
    -- 令状
    'warrants_view',
    'warrants_issue',
    'warrants_close',
    -- 罪状
    'charges_view',
    'charges_edit',
    -- ディスパッチ
    'dispatch_attach',
    'dispatch_route',
    -- カメラとボディカム
    'cameras_view',
    'bodycams_view',
    -- メモ
    'notes_edit_department',
    -- 名簿
    'roster_manage_certifications',
    'roster_manage_officers',
    -- PPR
    'ppr_view',
    'ppr_manage',
    -- FTO
    'fto_view',
    'fto_manage',
    -- 管理
    'management_permissions',
    'management_bulletins',
    'management_activity',
}

-- ボディカム設定
Config.Bodycam = {
    DutyEvent = 'QBCore:Server:OnJobUpdate',
    DutyEventMode = 'qbcore',
    MultiJobDutyEvent = 'ps-multijob:server:dutyChanged',
    DutyResource = 'qb-core',
    MultiJobResource = 'ps-multijob',
}

-- ジョブ/グレードごとのロール権限デフォルト（任意）
-- 例:
-- Config.PermissionDefaults = {
--     police = {
--         ['0'] = { 'access_reports' },
--         ['1'] = { 'access_reports', 'view_bodycams' },
--     }
-- }
Config.PermissionDefaults = Config.PermissionDefaults or {
    police = {
        ['0'] = { 'reports_view', 'cases_view', 'bolos_view', 'warrants_view', 'vehicles_search' },
        ['1'] = { 'reports_view', 'reports_create', 'cases_view', 'cases_create', 'bolos_view', 'bolos_create', 'warrants_view', 'vehicles_search', 'dispatch_attach', 'dispatch_route' },
        ['2'] = { 'reports_view', 'reports_create', 'cases_view', 'cases_create', 'cases_edit', 'bolos_view', 'bolos_create', 'warrants_view', 'warrants_issue', 'vehicles_search', 'vehicles_edit_dmv', 'dispatch_attach', 'dispatch_route', 'evidence_view' },
        ['3'] = { 'reports_view', 'reports_create', 'cases_view', 'cases_create', 'cases_edit', 'bolos_view', 'bolos_create', 'warrants_view', 'warrants_issue', 'warrants_close', 'vehicles_search', 'vehicles_edit_dmv', 'dispatch_attach', 'dispatch_route', 'evidence_view', 'evidence_create', 'evidence_transfer', 'cameras_view', 'bodycams_view' },
        ['4'] = { 'reports_view', 'reports_create', 'reports_delete', 'cases_view', 'cases_create', 'cases_edit', 'bolos_view', 'bolos_create', 'warrants_view', 'warrants_issue', 'warrants_close', 'vehicles_search', 'vehicles_edit_dmv', 'dispatch_attach', 'dispatch_route', 'evidence_view', 'evidence_create', 'evidence_transfer', 'evidence_upload', 'charges_view', 'notes_edit_department', 'cameras_view', 'bodycams_view' },
        ['5'] = { 'reports_view', 'reports_create', 'reports_delete', 'cases_view', 'cases_create', 'cases_edit', 'cases_delete', 'bolos_view', 'bolos_create', 'warrants_view', 'warrants_issue', 'warrants_close', 'vehicles_search', 'vehicles_edit_dmv', 'dispatch_attach', 'dispatch_route', 'evidence_view', 'evidence_create', 'evidence_transfer', 'evidence_upload', 'charges_view', 'charges_edit', 'notes_edit_department', 'roster_manage_certifications', 'cameras_view', 'bodycams_view' },
        ['6'] = { 'reports_view', 'reports_create', 'reports_delete', 'cases_view', 'cases_create', 'cases_edit', 'cases_delete', 'bolos_view', 'bolos_create', 'warrants_view', 'warrants_issue', 'warrants_close', 'vehicles_search', 'vehicles_edit_dmv', 'dispatch_attach', 'dispatch_route', 'evidence_view', 'evidence_create', 'evidence_transfer', 'evidence_upload', 'charges_view', 'charges_edit', 'notes_edit_department', 'roster_manage_certifications', 'roster_manage_officers', 'ppr_view', 'cameras_view', 'bodycams_view' },
        ['7'] = { 'reports_view', 'reports_create', 'reports_delete', 'cases_view', 'cases_create', 'cases_edit', 'cases_delete', 'bolos_view', 'bolos_create', 'warrants_view', 'warrants_issue', 'warrants_close', 'vehicles_search', 'vehicles_edit_dmv', 'dispatch_attach', 'dispatch_route', 'evidence_view', 'evidence_create', 'evidence_transfer', 'evidence_upload', 'charges_view', 'charges_edit', 'notes_edit_department', 'roster_manage_certifications', 'roster_manage_officers', 'ppr_view', 'ppr_manage', 'fto_view', 'cameras_view', 'bodycams_view' },
        ['8'] = Config.ManagementPermissions,
    }
}

-- ネイティブ利用は非推奨です。FiveManage の使用を推奨します。
-- アクティビティ追跡 - 監査ログに記録する操作を制御
-- 各カテゴリはMDTの設定ページでON/OFF切替可能
-- ここはデフォルト値です。実行時の変更は mdt_settings テーブルに保存されます
Config.AuditTracking = {
    authentication = true,   -- ログイン/ログアウトイベント
    reports = true,          -- レポートの作成・更新・削除
    cases = true,            -- ケースCRUD、担当警官割当、添付
    evidence = true,         -- 証拠CRUD、移管、画像
    warrants = true,         -- 令状の発行/クローズ
    vehicles = true,         -- 車両更新、押収/解放
    weapons = true,          -- 武器の作成・更新・削除
    charges = true,          -- 罰金処理、罪状更新
    searches = false,        -- 市民/プレイヤー/警官検索（高頻度）
    dispatch = true,         -- Signal 100 の有効化/無効化
    officers = true,         -- コールサイン変更
    sentencing = true,       -- 収監判決
    arrests = true,          -- 逮捕記録
    icu = true,              -- ICU記録削除
    cameras = true,          -- 監視カメラアクセス
    bodycams = true,         -- 警官ボディカムアクセス
}

-- 固定カメラ設置で利用可能なカメラモデル
Config.CameraModels = {
    ['security_cam_01'] = 'v_serv_securitycam_1a',
    ['security_cam_02'] = 'v_serv_securitycam_03',
    ['security_cam_03'] = 'ba_prop_battle_cctv_cam_01a',
    ['security_cam_04'] = 'prop_cctv_cam_06a',
    ['security_cam_05'] = 'ba_prop_battle_cctv_cam_01b',
    ['security_cam_06'] = 'prop_cctv_cam_01b',
    ['security_cam_07'] = 'ch_prop_ch_cctv_cam_02a',
    ['security_cam_08'] = 'prop_cctv_cam_04c',
    ['security_cam_09'] = 'prop_cctv_cam_03a',
    ['security_cam_10'] = 'ch_prop_ch_cctv_cam_01a',
    ['security_cam_11'] = 'prop_cctv_cam_01a',
    ['security_cam_12'] = 'prop_cctv_cam_05a',
    ['security_cam_13'] = 'prop_cctv_cam_07a',
    ['security_cam_14'] = 'prop_cctv_cam_04b',
    ['security_cam_15'] = 'tr_prop_tr_camhedz_cctv_01a',
    ['security_cam_16'] = 'prop_cctv_cam_02a',
    ['security_cam_17'] = 'prop_cctv_cam_04a',
    ['cctv_cam_01'] = 'm24_1_prop_m24_1_carrier_bank_cctv_02',
    ['cctv_cam_02'] = 'xm_prop_x17_cctv_01a',
    ['cctv_cam_03'] = 'prop_cctv_pole_02',
    ['cctv_cam_04'] = 'm24_1_prop_m24_1_carrier_bank_cctv_01',
    ['cctv_cam_05'] = 'prop_cctv_pole_04',
    ['cctv_cam_06'] = 'xm_prop_x17_server_farm_cctv_01',
    ['cctv_cam_07'] = 'prop_cctv_pole_03',
    ['cctv_cam_08'] = 'p_cctv_s',
    ['cctv_cam_09'] = 'hei_prop_bank_cctv_02',
}
