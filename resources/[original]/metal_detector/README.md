# 金属探知機スクリプト（Metal Detector）

FiveM 用の金属探知機で宝探し・お金稼ぎができる QBCore スクリプトです。

---

## 機能

- **金属探知**: 設定したスポットに近づくと「金属反応」表示、さらに近づくと「掘る」で掘削可能
- **掘削報酬**: 現金（ランダム）＋ 通常アイテム／レアアイテムのドロップ
- **ランキング**: 宝商人 NPC で「レアアイテム発見数」ランキングを表示
- **金属探知機アイテム**: オプションで「金属探知機」所持時のみ探知可能にできる

---

## 必要環境

- **FiveM サーバー**（QBCore フレームワーク）
- **oxmysql**（MySQL 接続）
- **Laragon**（ローカル開発・MySQL 用）

---

## oxmysql を resources に入れたあと（詳しい手順）

oxmysql を `resources` フォルダに入れたら、次の順で進めます。

### ステップ 1: server.cfg の場所を確認する

- FiveM サーバーの **ルートフォルダ**（`server-data` や `cfx-server` など）に **server.cfg** があります。
- テキストエディタ（メモ帳・VS Code など）で **server.cfg** を開きます。

### ステップ 2: MySQL の接続設定を書く（Laragon 用）

**oxmysql** は MySQL に接続するために「接続文字列」が必要です。  
**server.cfg** の **いちばん上付近**（他の `set` の前でもOK）に、次のどちらかで書きます。

**Laragon の MySQL でパスワードが空の場合（よくあるパターン）:**

```cfg
set mysql_connection_string "mysql://root@localhost/qbcore?charset=utf8mb4"
```

- `root` … Laragon の MySQL のユーザー名（通常は root）
- `localhost` … 同じPCで動かすので localhost
- `qbcore` … **データベース名**。QBCore で使っている DB 名に合わせて変えてください（例: `qb` / `fivem` など）

**Laragon の MySQL にパスワードを設定している場合:**

```cfg
set mysql_connection_string "mysql://root:あなたのパスワード@localhost/qbcore?charset=utf8mb4"
```

- `root:あなたのパスワード` の部分を、実際のユーザー名とパスワードに変えてください。
- パスワードに `@` や `#` が含まれる場合は、その文字を **URL エンコード** する必要があることがあります（例: `@` → `%40`）。

**書く場所の例（server.cfg のイメージ）:**

```cfg
# サーバー名など
sv_hostname "My Server"

# MySQL 接続（oxmysql 用）※ ここに追加
set mysql_connection_string "mysql://root@localhost/qbcore?charset=utf8mb4"

# 以下、ensure など
```

### ステップ 3: oxmysql と metal_detector を起動する（ensure）

**server.cfg** の **ensure** が並んでいる部分**に、次の 2 行を追加**します。

- **oxmysql** は **qb-core より前**に書くことが多いです（QBCore が DB を使うため）。
- **metal_detector** は **qb-core と oxmysql の後**に書きます。

**追加する行の例:**

```cfg
ensure oxmysql
ensure qb-core
# ... 他の qb- 系リソース ...
ensure metal_detector
```

**すでに `ensure qb-core` がある場合の例:**

```cfg
# もともとこうなっている場合
ensure qb-core
ensure qb-inventory
# ...

# 先頭付近に oxmysql を追加し、最後に metal_detector を追加
ensure oxmysql
ensure qb-core
ensure qb-inventory
# ... 他のリソース ...
ensure metal_detector
```

- **フォルダ名**を変えている場合は、`ensure metal_detector` の `metal_detector` を、実際のフォルダ名に合わせてください。
- **oxmysql** のフォルダ名が `oxmysql` なら、`ensure oxmysql` のままで大丈夫です。

### ステップ 4: 接続先のデータベースとテーブルを作る（Laragon）

1. **Laragon** を起動し、**MySQL** を起動します。
2. **HeidiSQL** を開く（Laragon メニュー → MySQL → HeidiSQL）。
3. 左側で、**server.cfg で指定したデータベース名**（例: `qbcore`）を選択します。  
   まだなければ **右クリック → 新しいデータベースを作成** で作成します。
4. その DB を選択した状態で **クエリ** タブを開き、次の SQL を貼り付けて **実行（F9）** します。

```sql
CREATE TABLE IF NOT EXISTS `metal_detector_players` (
  `citizenid` varchar(50) NOT NULL,
  `rare_items` int NOT NULL DEFAULT 0,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

5. 実行後、左のテーブル一覧に **metal_detector_players** が表示されていれば OK です。

### ステップ 5: 起動順序の確認（毎回の起動手順）

1. **Laragon** を起動 → **MySQL** が緑（起動中）になっていることを確認。
2. **FiveM サーバー**を起動（バッチファイルや `FXServer.exe` など）。
3. サーバーコンソールで、次のような行が出ていれば読み込み完了です。
   - `[oxmysql] ...` のようなメッセージ（接続成功）
   - `Started resource metal_detector` または `Started resource oxmysql`

**MySQL を先に起動してから** FiveM サーバーを起動するのが重要です。順序が逆だと oxmysql が接続できません。

### ステップ 6: うまくつながらないとき（Laragon の確認）

- **Laragon の MySQL のポート**  
  通常は **3306** です。変更している場合は、接続文字列に `:3306` を付けることがあります。  
  例: `mysql://root@127.0.0.1:3306/qbcore?charset=utf8mb4`

- **接続文字列を oxmysql 用 config でやりたい場合**  
  `resources/oxmysql/resource/config.json` や `config.lua` がある場合、そちらに接続情報を書く方式も使えます。  
  その場合は oxmysql の公式ドキュメント（[overextended.dev/oxmysql](https://overextended.dev/oxmysql)）を参照し、**server.cfg の `set mysql_connection_string` と重複しないように**どちらか一方だけに書くようにしてください。

ここまでできていれば、「oxmysql を resources に入れたあと」の設定は完了です。金属探知機スクリプトを動かすには、このあと「アイテムの追加」と「metal_detector の配置」まで行ってください。

---

## Laragon を使った導入方法（ローカルテスト）

### 1. Laragon の準備

1. **Laragon を起動**し、メニューから **MySQL** を起動します。
2. **HeidiSQL** または **phpMyAdmin** で DB に接続します。  
   - Laragon メニュー → **MySQL** → **HeidiSQL** で開くと簡単です。
3. 使用している **QBCore 用データベース**を選択（または新規作成）します。

### 2. データベースの作成

1. HeidiSQL で接続後、左のデータベース一覧で **右クリック → 新しいデータベースを作成** で DB 名を入力（例: `qbcore`）して作成。
2. その DB を選択した状態で、**クエリ** タブを開き、次の SQL を貼り付けて実行します。

```sql
-- sql/metal_detector.sql の内容をそのまま実行
CREATE TABLE IF NOT EXISTS `metal_detector_players` (
  `citizenid` varchar(50) NOT NULL,
  `rare_items` int NOT NULL DEFAULT 0,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

3. 実行後、左のテーブル一覧に `metal_detector_players` が表示されていれば OK です。

### 3. スクリプトの配置

1. この **metal_detector** フォルダを、FiveM サーバーの **resources** フォルダ内に置きます。  
   - 例: `server-data/resources/[qb]/metal_detector/`
2. **oxmysql** が同じサーバーに導入され、`server.cfg` で起動されていることを確認します。

### 4. server.cfg に追加

`server.cfg` の **ensure** 一覧に、次の 1 行を追加します。  
（qb-core や oxmysql の**後**に書くようにします。）

```cfg
ensure qb-core
ensure oxmysql
# ... 他のリソース ...

ensure metal_detector
```

フォルダ名を変えた場合は、その名前に合わせてください（例: `ensure metal_detector` → 実際のフォルダ名）。

### 5. データベース接続の確認

- **oxmysql** の接続設定（`server.cfg` の `set mysql_connection_string` や、oxmysql 用の設定ファイル）が、Laragon の MySQL の **ホスト・ユーザー・パスワード・DB名** と一致しているか確認します。
- Laragon の MySQL は通常:
  - ホスト: `localhost` または `127.0.0.1`
  - ユーザー: `root`
  - パスワード: 空欄のことが多いです（要確認）
  - ポート: `3306`

### 6. アイテムの追加（必須）

**購入・掘削したアイテムがインベントリに入るように、必ずアイテムを登録してください。**

- **ox_inventory** を使っている場合  
  `ox_inventory/data/items.lua` に、**metal_detector/shared/items_ox_inventory.lua** の中身をコピーして追加します。
- **qb-inventory（QBCore）** を使っている場合  
  `qb-core/shared/items.lua` に、**metal_detector/shared/items.lua** 内の `MetalDetectorItems` テーブルを既存の Items にマージします。

このスクリプトは **ox_inventory** または **qb-inventory** が起動していれば、そちらのインベントリに直接アイテムを追加します（購入・掘削報酬・売却が正しく反映されます）。どちらもない場合は QBCore の Player.Functions.AddItem にフォールバックします。

以下は QBCore 用の定義例です。

```lua
-- 金属探知機（レンタルやショップで配布）
['metal_detector'] = {
    ['name'] = 'metal_detector',
    ['label'] = '金属探知機',
    ['weight'] = 500,
    ['type'] = 'item',
    ['image'] = 'metal_detector.png',
    ['unique'] = false,
    ['useable'] = true,
    ['shouldClose'] = true,
    ['description'] = '砂浜や土の上で金属を探せる'
},

-- 報酬で使うアイテム（metal_detector 専用オリジナル。shared/items.lua を参照）
['md_gold_bar'] = { ['name'] = 'md_gold_bar', ['label'] = '宝の金延べ', ... },
['md_treasure_gem'] = { ['name'] = 'md_treasure_gem', ['label'] = '宝の宝石', ... },
['md_broken_watch'] = { ['name'] = 'md_broken_watch', ['label'] = '骨董の腕時計', ... },
['md_metal_scrap'] = { ['name'] = 'md_metal_scrap', ['label'] = '掘り出し金属', ... },
['md_plastic_scrap'] = { ['name'] = 'md_plastic_scrap', ['label'] = '掘り出しプラスチック', ... },
['md_copper_scrap'] = { ['name'] = 'md_copper_scrap', ['label'] = '掘り出し銅', ... },
```

- ドロップ品はすべて **metal_detector 専用のオリジナル名**（`md_`  prefix）です。**shared/items.lua** と **config.lua** の `Config.Rewards` / `Config.SellItems` をそのまま qb-core や ox_inventory に追加してください。

#### 画像の格納場所

アイテム画像は **metal_detector 内ではなく、使用しているインベントリリソースの画像フォルダ** に置きます。

| インベントリ | 画像を置くフォルダ | ファイル名例 |
|--------------|--------------------|--------------|
| **qb-inventory** | `qb-inventory/html/images/` | 下表のファイル名 |
| **ox_inventory** | `ox_inventory/web/images/` | 同上 |

必要な画像（**shared/items.lua** の `['image']` と一致させる）:

- `metal_detector.png` … 金属探知機
- `md_gold_bar.png`, `md_treasure_gem.png`, `md_broken_watch.png` … レア報酬
- `md_metal_scrap.png`, `md_plastic_scrap.png`, `md_copper_scrap.png` … 通常報酬

※ いずれもオリジナルアイテム用の画像なので、上記フォルダに新規で追加してください。

#### 掘ってもアイテムがインベントリに入らない場合

**原因**: ドロップするアイテム（`md_gold_bar` など）が、使っているインベントリに**未登録**です。

- **ox_inventory を使っている場合**  
  `ox_inventory/data/items.lua` を開き、**shared/items_ox_inventory.lua** の中身（`return { ... }` のブロック全体）を、既存の `return { }` の中に**そのままコピーして追加**してください。追加後、リソースを再起動（`ensure ox_inventory` またはサーバー再起動）してください。
- **qb-inventory を使っている場合**  
  `qb-core/shared/items.lua` に **shared/items.lua** のアイテム定義を追加してください。既存の `Items` テーブルに、metal_detector 用のアイテムをマージしてください。

サーバーコンソールに「アイテム 'xxx' が ox_inventory に登録されていません」と出ている場合は、上記のとおりアイテムを追加すれば解消します。

### 7. サーバー起動と動作確認

1. Laragon で **MySQL** が起動していることを確認。
2. FiveM サーバーを起動し、`ensure metal_detector` が読み込まれることを確認。
3. ゲーム内で:
   - **金属探知機**を所持した状態で、**config.lua** の `Config.TreasureZone` で設定したゾーン内（デフォルトは NPC 周辺）へ移動。
   - 「金属反応」→ 近づいて「掘る」で掘削。
   - 宝商人 NPC に近づき **[E]** でランキング UI を開く。

ここまでできていれば、Laragon 上の MySQL と連携した状態でローカルテストができます。

---

## 設定（config.lua）

| 項目 | 説明 |
|------|------|
| `Config.NPC` | 宝商人のモデル・座標・Blip |
| `Config.MetalDetectorItem` | 金属探知機のアイテム名 |
| `Config.RequireMetalDetector` | `true` でアイテム所持時のみ探知可能 |
| `Config.DetectDistance` | 反応表示が出る距離 |
| `Config.DigDistance` | 掘れる距離 |
| `Config.DigDuration` | 掘削にかかる時間（ミリ秒） |
| `Config.Rewards` | 現金の min/max、レア率、レア/通常アイテム名 |
| `Config.TreasureZone` | 宝が湧くゾーン（center, radius, zMin, zMax）。showOnMap=true でマップに範囲を色付き円で表示（mapBlipColor, mapBlipAlpha） |
| `Config.TreasureCount` | 同時に存在する宝の数（取ると別の場所に1つ湧く） |
| `Config.Debug` | `true` で宝の位置にマーカー表示 |

---

## フォルダ構成

```
metal_detector/
├── client/
│   └── client.lua
├── server/
│   └── server.lua
├── shared/
│   ├── items.lua              ← QBCore 用アイテム定義（参照・マージ用）
│   └── items_ox_inventory.lua ← ox_inventory 用アイテム定義（コピー用）
├── html/
│   ├── index.html
│   ├── style.css
│   └── script.js
├── sql/
│   └── metal_detector.sql
├── config.lua
├── fxmanifest.lua
└── README.md
```

---

## トラブルシュート

- **ランキングが表示されない**  
  - `metal_detector_players` テーブルが作成されているか、Laragon の MySQL で確認してください。  
  - oxmysql の接続文字列が、Laragon の MySQL を指しているか確認してください。

- **購入してもインベントリに入らない**  
  - **ox_inventory** または **qb-inventory** が server.cfg で `ensure` され、metal_detector より**先に**起動しているか確認。  
  - **アイテム定義**を追加しましたか？ ox_inventory なら `data/items.lua`、qb-inventory なら qb-core の `shared/items.lua` に、`shared/items_ox_inventory.lua` または `shared/items.lua` の内容を追加してください。  
  - アイテム名（例: `metal_detector`）が、インベントリのアイテム定義と一致しているか確認。

- **掘っても報酬がもらえない**  
  - サーバーコンソールに Lua エラーが出ていないか確認。  
  - `Config.Rewards` のアイテム名が、インベントリのアイテム定義に存在するか確認してください。

- **金属反応が出ない**  
  - `Config.RequireMetalDetector` が `true` の場合は、インベントリに「金属探知機」があるか確認。  
  - テスト時は `Config.RequireMetalDetector = false` にすると、アイテムなしで探知可能になります。

- **Laragon MySQL に接続できない**  
  - Laragon の **MySQL** が起動しているか確認。  
  - `server.cfg`（または oxmysql の設定）のホスト・ユーザー・パスワード・DB名が正しいか確認してください。

---

## ライセンス・注意

- QBCore および oxmysql の利用規約に従ってください。  
- 本スクリプトはサンプルとして提供しています。本番運用時はバランス（報酬額・レア率・スポット数）をサーバーに合わせて調整してください。
