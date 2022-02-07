/****** Object:  StoredProcedure [sp_staging].[staging_policy_sales]    Script Date: 24/12/2021 1:35:53 pm ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [sp_staging].[staging_policy_sales]
AS
BEGIN
select 
p.product_code,
p.cover_type_id,
p.dealer_id,
--user_role_key,
policy_status_code,
policy_term_in_months,
CASE
WHEN p.product_code = 'cci' AND policy_status_code = 'X' THEN 'CANCELLED'
WHEN p.product_code = 'cci' AND policy_status_code = 'P' THEN 'PENDING'
WHEN p.product_code = 'cci' AND policy_status_code = 'N' THEN 'NEW'
WHEN p.product_code = 'cci' AND policy_status_code = 'E' THEN 'AUTO EXPIRED'
WHEN p.product_code = 'cci' AND policy_status_code = 'C' THEN 'CLOSED'
WHEN p.product_code = 'cci' AND policy_status_code = 'R' THEN 'REFUNDED'
WHEN p.product_code = 'cci' AND policy_status_code = 'F' THEN 'FORCED EXPIRED'
WHEN p.product_code = 'cci' AND policy_status_code = 'V' THEN 'INVOICED'
WHEN p.product_code = 'gap' AND policy_status_code = 'N' THEN 'NEW'
WHEN p.product_code = 'gap' AND policy_status_code = 'C' THEN 'CLOSED'
WHEN p.product_code = 'gap' AND policy_status_code = 'R' THEN 'REFUNDED'
WHEN p.product_code = 'gap' AND policy_status_code = 'E' THEN 'AUTO EXPIRED'
WHEN p.product_code = 'gap' AND policy_status_code = 'P' THEN 'PENDING'
WHEN p.product_code = 'gap' AND policy_status_code = 'X' THEN 'CANCELLED'
WHEN p.product_code = 'gap' AND policy_status_code = 'V' THEN 'INVOICED'
WHEN p.product_code = 'gap' AND policy_status_code = 'F' THEN 'FORCED EXPIRED'
WHEN p.product_code = 'lnm' AND policy_status_code = 'Cancelled' THEN 'CANCELLED'
WHEN p.product_code = 'lnm' AND policy_status_code = 'Approved' THEN 'APPROVED'
WHEN p.product_code = 'lnm' AND policy_status_code = 'Pending' THEN 'PENDING'
WHEN p.product_code = 'lnm' AND policy_status_code = 'Declined' THEN 'DECLINED'
WHEN p.product_code = 'mbi' AND policy_status_code = 'R' THEN 'REFUNDED'
WHEN p.product_code = 'mbi' AND policy_status_code = 'P' THEN 'PENDING'
WHEN p.product_code = 'mbi' AND policy_status_code = 'X' THEN 'CANCELLED'
WHEN p.product_code = 'mbi' AND policy_status_code = 'N' THEN 'NEW'
WHEN p.product_code = 'mbi' AND policy_status_code = 'V' THEN 'INVOICED'
WHEN p.product_code = 'mbi' AND policy_status_code = 'E' THEN 'AUTO EXPIRED'
WHEN p.product_code = 'mbi' AND policy_status_code = 'F' THEN 'FORCED EXPIRED'
WHEN p.product_code = 'mbi' AND policy_status_code = 'C' THEN 'CLOSED'
 WHEN p.product_code = 'N/A' AND policy_status_code = 'N/A' THEN 'N/A'
WHEN p.product_code = 'posm' AND policy_status_code = 'C' THEN 'CLOSED'
WHEN p.product_code = 'posm' AND policy_status_code = 'P' THEN 'PENDING'
WHEN p.product_code = 'posm' AND policy_status_code = 'X' THEN 'CANCELLED'
WHEN p.product_code = 'posm' AND policy_status_code = 'R' THEN 'REFUNDED'
WHEN p.product_code = 'posm' AND policy_status_code = 'F' THEN 'FORCED EXPIRED'
WHEN p.product_code = 'posm' AND policy_status_code = 'E' THEN 'AUTO EXPIRED'
WHEN p.product_code = 'tar' AND policy_status_code = 'E' THEN 'AUTO EXPIRED'
WHEN p.product_code = 'tar' AND policy_status_code = 'V' THEN 'INVOICED'
WHEN p.product_code = 'tar' AND policy_status_code = 'F' THEN 'FORCED EXPIRED'
WHEN p.product_code = 'tar' AND policy_status_code = 'P' THEN 'PENDING'
WHEN p.product_code = 'tar' AND policy_status_code = 'C' THEN 'CLOSED'
WHEN p.product_code = 'tar' AND policy_status_code = 'N' THEN 'NEW'
WHEN p.product_code = 'tar' AND policy_status_code = 'R' THEN 'REFUNDED'
WHEN p.product_code = 'tar' AND policy_status_code = 'X' THEN 'CANCELLED'
WHEN p.product_code = 'POSM' AND parent_policy_id is not NULL AND policy_status_code = 'V' THEN 'Renewal'
WHEN p.product_code = 'posm' AND  parent_policy_id is NULL AND policy_status_code = 'V' THEN 'New Business'
Else policy_status_code
END as transaction_type_code,
count(p.policy_id) as total_policy_count, 
count (case when policy_status_code in( 'V','Approved' )and p.policy_valid_from_date < getdate() and p.policy_valid_to_date > getdate() then (policy_id) else null end) as total_live_policy_count,
case when p.product_code = 'posm' then sum(wholesale_premium_over_term_amount) else sum(premium_amount) end as total_gwp_amount,
case when p.product_code = 'posm' then avg(wholesale_premium_over_term_amount) else avg(premium_amount) end as average_gwp_per_policy_amount

into #temp1 
from data.dim_policy p
where p.record_current_flag = 1 and p.is_deleted = 0 

group by product_code ,
cover_type_id,
dealer_id,
--user_role_key,
policy_status_code,
policy_term_in_months,
CASE
WHEN p.product_code = 'cci' AND policy_status_code = 'X' THEN 'CANCELLED'
WHEN p.product_code = 'cci' AND policy_status_code = 'P' THEN 'PENDING'
WHEN p.product_code = 'cci' AND policy_status_code = 'N' THEN 'NEW'
WHEN p.product_code = 'cci' AND policy_status_code = 'E' THEN 'AUTO EXPIRED'
WHEN p.product_code = 'cci' AND policy_status_code = 'C' THEN 'CLOSED'
WHEN p.product_code = 'cci' AND policy_status_code = 'R' THEN 'REFUNDED'
WHEN p.product_code = 'cci' AND policy_status_code = 'F' THEN 'FORCED EXPIRED'
WHEN p.product_code = 'cci' AND policy_status_code = 'V' THEN 'INVOICED'
WHEN p.product_code = 'gap' AND policy_status_code = 'N' THEN 'NEW'
WHEN p.product_code = 'gap' AND policy_status_code = 'C' THEN 'CLOSED'
WHEN p.product_code = 'gap' AND policy_status_code = 'R' THEN 'REFUNDED'
WHEN p.product_code = 'gap' AND policy_status_code = 'E' THEN 'AUTO EXPIRED'
WHEN p.product_code = 'gap' AND policy_status_code = 'P' THEN 'PENDING'
WHEN p.product_code = 'gap' AND policy_status_code = 'X' THEN 'CANCELLED'
WHEN p.product_code = 'gap' AND policy_status_code = 'V' THEN 'INVOICED'
WHEN p.product_code = 'gap' AND policy_status_code = 'F' THEN 'FORCED EXPIRED'
WHEN p.product_code = 'lnm' AND policy_status_code = 'Cancelled' THEN 'CANCELLED'
WHEN p.product_code = 'lnm' AND policy_status_code = 'Approved' THEN 'APPROVED'
WHEN p.product_code = 'lnm' AND policy_status_code = 'Pending' THEN 'PENDING'
WHEN p.product_code = 'lnm' AND policy_status_code = 'Declined' THEN 'DECLINED'
WHEN p.product_code = 'mbi' AND policy_status_code = 'R' THEN 'REFUNDED'
WHEN p.product_code = 'mbi' AND policy_status_code = 'P' THEN 'PENDING'
WHEN p.product_code = 'mbi' AND policy_status_code = 'X' THEN 'CANCELLED'
WHEN p.product_code = 'mbi' AND policy_status_code = 'N' THEN 'NEW'
WHEN p.product_code = 'mbi' AND policy_status_code = 'V' THEN 'INVOICED'
WHEN p.product_code = 'mbi' AND policy_status_code = 'E' THEN 'AUTO EXPIRED'
WHEN p.product_code = 'mbi' AND policy_status_code = 'F' THEN 'FORCED EXPIRED'
WHEN p.product_code = 'mbi' AND policy_status_code = 'C' THEN 'CLOSED'
WHEN p.product_code = 'N/A' AND policy_status_code = 'N/A' THEN 'N/A'
WHEN p.product_code = 'posm' AND policy_status_code = 'C' THEN 'CLOSED'
WHEN p.product_code = 'posm' AND policy_status_code = 'P' THEN 'PENDING'
WHEN p.product_code = 'posm' AND policy_status_code = 'X' THEN 'CANCELLED'
WHEN p.product_code = 'posm' AND policy_status_code = 'R' THEN 'REFUNDED'
WHEN p.product_code = 'posm' AND policy_status_code = 'F' THEN 'FORCED EXPIRED'
WHEN p.product_code = 'posm' AND policy_status_code = 'E' THEN 'AUTO EXPIRED'
WHEN p.product_code = 'tar' AND policy_status_code = 'E' THEN 'AUTO EXPIRED'
WHEN p.product_code = 'tar' AND policy_status_code = 'V' THEN 'INVOICED'
WHEN p.product_code = 'tar' AND policy_status_code = 'F' THEN 'FORCED EXPIRED'
WHEN p.product_code = 'tar' AND policy_status_code = 'P' THEN 'PENDING'
WHEN p.product_code = 'tar' AND policy_status_code = 'C' THEN 'CLOSED'
WHEN p.product_code = 'tar' AND policy_status_code = 'N' THEN 'NEW'
WHEN p.product_code = 'tar' AND policy_status_code = 'R' THEN 'REFUNDED'
WHEN p.product_code = 'tar' AND policy_status_code = 'X' THEN 'CANCELLED'
WHEN p.product_code = 'POSM' AND parent_policy_id is not NULL AND policy_status_code = 'V' THEN 'Renewal'
WHEN p.product_code = 'posm' AND  parent_policy_id is NULL AND policy_status_code = 'V' THEN 'New Business'
Else policy_status_code
END

select cast(convert(varchar(8),getdate()-1,112) as int)  as snapshot_date_key 
,d.dealer_key
,c.cover_type_key,r.user_role_key,pd.product_detail_key 
,t.policy_status_code,t.policy_term_in_months,t.transaction_type_code,t.total_live_policy_count,t.total_policy_count,t.total_gwp_amount,t.average_gwp_per_policy_amount

into #temp2
from #temp1 t
left join data.dim_dealer d 
on t.dealer_id = d.dealer_id 
and t.cover_type_id = case when d.generic_cover_type_id = 0 then d.dealer_specific_cover_type_id else d.generic_cover_type_id end 
and d.is_deleted = 0 and d.record_current_flag = 1
left join data.dim_cover_type c
on c.cover_type_id = t.cover_type_id and 
t.product_code = c.product_code
and c.is_deleted = 0 and c.record_current_flag = 1 
left join data.dim_product_detail pd
on pd.product_code = t.product_code 
and pd.[product_id] = c.[product_id] and pd.is_deleted = 0 
LEFT JOIN (select distinct USER_ID,user_role_key from [Data].[dim_user_role] 
where record_current_flag = 1 and is_deleted = 0  )r
on r.user_id = d.dealer_salesrep_id 


--drop table #temp2 
--drop table #temp1
truncate table staging.staging_policy_sales ;

insert into staging.staging_policy_sales 
select * 
from #temp2


End
GO


