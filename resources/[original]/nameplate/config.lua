Config = {}

-- 表示距離 (メートル)
Config.DrawDistance = 20.0

-- 自分自身の名前も表示するか
Config.ShowSelf = true

-- デフォルトの名前色 (R, G, B, A)
Config.DefaultNameColor  = {255, 255, 255, 255}

-- デフォルトの称号色 (R, G, B, A)
Config.DefaultTitleColor = {255, 215, 0, 255}

-- 名前の最大文字数
Config.MaxNameLength = 30

-- QBCoreを使用するか
Config.UseQBCore = true

-- 称号付与コマンドを使えるグループ
Config.AdminGroups = { 'admin', 'superadmin', 'god' }

-- ─────────────────────────────────────────────────────────────────
-- 利用可能な称号一覧
-- /givetitle [playerID] [id] で付与する
-- ─────────────────────────────────────────────────────────────────
Config.Titles = {
    { id = 'newcomer',   label = '新人'          },
    { id = 'veteran',    label = 'ベテラン'      },
    { id = 'legend',     label = '伝説'          },
    { id = 'outlaw',     label = 'アウトロー'    },
    { id = 'sheriff',    label = '保安官'        },
    { id = 'mechanic',   label = 'メカニック'    },
    { id = 'doctor',     label = '医師'          },
    { id = 'hunter',     label = 'ハンター'      },
    { id = 'racer',      label = 'レーサー'      },
    { id = 'boss',       label = 'ボス'          },
    { id = 'gangster',   label = 'ギャング'      },
    { id = 'millionaire',label = '億万長者'      },
    { id = 'admin'      ,label = '管理者'        },
    { id = 'sanada'     ,label = 'たまたま現場にいた'        },
    { id = 'gotou'      ,label = '軟弱なる腹痛の伝道師'        },
}
