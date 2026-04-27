DELETE FROM items WHERE name = 'burncream';
DELETE FROM items WHERE name = 'defib';
DELETE FROM items WHERE name = 'icepack';
DELETE FROM items WHERE name = 'medbag';
DELETE FROM items WHERE name = 'medikit';
DELETE FROM items WHERE name = 'sedative';
DELETE FROM items WHERE name = 'suturekit';
DELETE FROM items WHERE name = 'tweezers';


INSERT INTO `items` (`name`, `label`, `weight`) VALUES
	('burncream', '火傷治療クリーム', 1),
	('defib', '除細動器', 1),
	('icepack', 'アイスパック', 1),
	('medbag', '救急バッグ', 1),
	('medikit', '救急キット', 1),
	('sedative', '鎮静剤', 1),
	('suturekit', '縫合キット', 1),
	('tweezers', 'ピンセット', 1)
;