create database reddit;

create table reddit.tile_placements (
	ts bigint,
  user text,
  x_coordinate int,
  y_coordinate int,
  color int
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

-- Error Code: 1206. The total number of locks exceeds the lock table size
-- try splitting by color/hour combo (color alone didnt work)
create table reddit.place as
	select from_unixtime(floor(tp.ts/1000)) dts
		, tp.ts
		, tp.user
		, tp.x_coordinate
		, tp.y_coordinate
		, tp.color
		, cl.hex
		, cl.color_name
	from reddit.tile_placements tp
	join reddit.color_lkp cl
	on tp.color = cl.color_id;

final board
SELECT * FROM (
	SELECT color
		, x_coordinate
		, y_coordinate
	  , ROW_NUMBER() OVER(PARTITION BY x_coordinate, y_coordinate ORDER BY ts DESC) rn
	FROM `reddit-jg-data.place_events.all_tile_placements`
)
WHERE rn=1
ORDER by x_coordinate, y_coordinate;
