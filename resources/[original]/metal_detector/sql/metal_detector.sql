-- 金属探知機スクリプト用テーブル（ランキング）
-- Laragon の HeidiSQL や phpMyAdmin で実行してください

CREATE TABLE IF NOT EXISTS `metal_detector_players` (
  `citizenid` varchar(50) NOT NULL,
  `rare_items` int NOT NULL DEFAULT 0,
  `xp` int NOT NULL DEFAULT 0,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 既存テーブルに xp を追加する場合（テーブルがすでにあるサーバー用）
-- ALTER TABLE metal_detector_players ADD COLUMN xp int NOT NULL DEFAULT 0;
