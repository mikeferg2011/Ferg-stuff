create database reddit;

create table reddit.tile_placements (
	epoch_ts bigint,
	user text,
	x_coordinate int,
	y_coordinate int,
	color_id int,
	ts datetime,
	color_hex text,
	color_name text
);

-- Bash insert all data
-- winpty mysql -h 127.0.0.1 -u root -pferg -e "USE reddit; LOAD DATA LOCAL INFILE 'tile_placements.csv' INTO TABLE tile_placements FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 LINES;"

create table reddit.color_lkp (
	color_id int,
  hex text,
  color_name text
);

insert into reddit.color_lkp values
(0, '#FFFFFF', 'white'),
(1, '#E4E4E4', 'light grey'),
(2, '#888888', 'grey'),
(3, '#222222', 'black'),
(4, '#FFA7D1', 'light pink'),
(5, '#E50000', 'red'),
(6, '#E59500', 'orange'),
(7, '#A06A42', 'brown'),
(8, '#E5D900', 'yellow'),
(9, '#94E044', 'light green'),
(10, '#02BE01', 'green'),
(11, '#00E5F0', 'light blue'),
(12, '#0083C7', 'navy blue'),
(13, '#0000EA', 'blue'),
(14, '#E04AFF', 'pink'),
(15, '#820080', 'purple')
;
