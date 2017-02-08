create database skillz;
use skillz;
create table entries (
	user_id int,
    ds date,
    entry_fee decimal(18,2),
    num_of_players int,
    player_rating decimal(18,2),
    position int,
    prize int,
    tournament_id int
);

LOAD DATA LOCAL INFILE 'C:\\Users\\Mary\\Documents\\entries.csv' INTO TABLE entries FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 LINES;

create table users (
	ds date,
    active int,
	cash int,
	cash_no_penny int
);

LOAD DATA LOCAL INFILE 'C:\\Users\\Mary\\Documents\\users.csv' INTO TABLE users FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 LINES;

select count(*) from entries;
select count(*) from users;
