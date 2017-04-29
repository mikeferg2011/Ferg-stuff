#of all active where no penny, how many real after doing the z
	# how many could be counted
		# z before real or no real
        # penny can either be after z or not at all
select sum(z_flag) base_users, sum(real_flag) as converted
from user_flag_date
where z_flag = 1
and (z_date < real_date or real_date is null)
and (real_date < penny_date or penny_date is null);

#of all active where penny, how many real after doing the p

select sum(penny_flag) base_users, sum(real_flag) as converted
from user_flag_date
where penny_flag = 1
and (penny_date < real_date or real_date is null);
