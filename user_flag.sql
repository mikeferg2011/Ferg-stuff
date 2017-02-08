create table user_flag
select user_id, max(z_flag_e) as z_flag, max(penny_flag_e) as penny_flag, max(real_flag_e) as real_flag
from(
	select user_id
		, case when entry_fee = 0 then 1 else 0 end as z_flag_e
		, case when entry_fee = 0.01 then 1 else 0 end as penny_flag_e
		, case when entry_fee > 0.01 then 1 else 0 end as real_flag_e
	from entries
) entry_flag
group by 1;

create table user_flag_date
select a.user_id, a.z_flag, a.penny_flag, a.real_flag, z_date, penny_date, real_date
from user_flag a
left join (
	select user_id, min(ds) as z_date
	from entries
	where entry_fee = 0
	group by 1
) z
	on a.user_id = z.user_id
left join (
	select user_id, min(ds) as penny_date
	from entries
	where entry_fee = 0.01
	group by 1
) p
	on a.user_id = p.user_id
left join (
	select user_id, min(ds) as real_date
	from entries
	where entry_fee > 0.01
	group by 1
) r
	on a.user_id = r.user_id;

create table user_flag_date_entries
select a.*, entries, z_entries, penny_entries, real_entries
from user_flag_date a
join (
	select user_id
		, count(entry_fee) as entries
		, count(case when entry_fee = 0 then entry_fee else null end) as z_entries
		, count(case when entry_fee = 0.01 then entry_fee else null end) as penny_entries
		, count(case when entry_fee > 0.01 then entry_fee else null end) as real_entries
	from entries
	group by 1
) b
	on a.user_id = b.user_id;
