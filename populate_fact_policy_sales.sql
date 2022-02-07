/****** Object:  StoredProcedure [sp_data].[fact_policy_sales]    Script Date: 23/12/2021 8:36:12 am ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [sp_data].[fact_policy_sales]
AS
BEGIN
  delete from data.fact_policy_sales  where snapshot_date_key < convert(char(8),dateadd(dd,-31,getdate()),112)
  and snapshot_date_key not in (
  select max(date_key)from data.dim_date
  where date_value >= convert(char(10),dateadd(year,-3,getdate()),126) and date_value < convert(char(10),GETDATE(),126)
  group by month_number,cal_year );

 delete from data.fact_policy_sales where snapshot_date_key < convert(char(8),dateadd(dd,-1,getdate()),112) ;

 insert into data.fact_policy_sales ([snapshot_date_key],[product_detail_key],[cover_type_key],[delear_key],[user_role_key],[policy_status_code],[policy_term_in_months],[transaction_type_code]
      ,[total_live_policy_count],[total_policy_count],[total_gwp_amount],[average_gwp_per_policy_amount])
select [snapshot_date_key],[product_detail_key] ,[cover_type_key],[dealer_key],[user_role_key] ,[policy_status_code],[policy_term_in_months],[transaction_type_code],[total_live_policy_count]
      ,[total_policy_count],[total_gwp_amount],[average_gwp_per_policy_amount] from [staging].[staging_policy_sales]
End
GO


