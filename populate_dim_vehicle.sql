/****** Object:  StoredProcedure [sp_data].[populate_dim_vehicle]    Script Date: 11/01/2022 6:58:56 pm ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [sp_data].[populate_dim_vehicle]
AS
BEGIN
declare @end_date datetime ;
SET @end_date = (Select max(date_value) from data.dim_date);
	SET NOCOUNT ON;
	SET IDENTITY_INSERT data.dim_vehicle ON
INSERT [Data].dim_vehicle ([vehicle_key],[vehicle_id],policy_id
      ,[record_start_datetime], [record_end_datetime], [record_current_flag])
SELECT -1, 0,0
, CAST(N'1900-01-01T00:00:00.000' AS DateTime), @end_date, 1
	WHERE NOT EXISTS
	(SELECT [vehicle_key] FROM  data.dim_vehicle WHERE [vehicle_key] = -1)
SET IDENTITY_INSERT  data.dim_vehicle OFF


select * into #vehicle from (

select 
         [vehicle_id],id as [policy_id], year as [manufactured_year],[vehicle_make_id], make as [vehicle_make_name],[vehicle_model_id],model_family as [vehicle_model_family_description],
	  model as [vehicle_model_description]
      ,Try_convert(float,cc_rating) as [vehicle_cc_rating],null as [vehicle_odometer_reading],registration_plate as [vehicle_registration_number],vin as [vehicle_identification_number],[stock_number],
	  null as [vehicle_purchase_date_time],motor_type as [vehicle_motor_type_name]
      ,null as [vehicle_engine_cylinders_number],null as [is_turbo_super_flag],null as [is_4wd_flag],null as [vehicle_origin_country_name],is_modified as [is_vehicle_modified_flag],
	  modifications as [vehicle_modification_notes],null as [vehicle_usage_code]
      ,null as [manufacturers_warranty_remaining_in_months],null as [manufacturers_warranty_limited_to_kms],null as [original_odometer_reading],null as [original_manufactured_year],null as [mycar_authentication_code]
      ,null as [mycar_authentication_code_used_flag],rb_default_value as [rb_default_value_amount],rb_AvgWholesale as [rb_avg_wholesale],rb_AvgRetail as [rb_avg_retail],rb_AvgWholesale as [rb_good_wholesale],
	  rb_GoodRetail as [rb_good_retail],
	  rb_NewPrice as [rb_new_price],[rb_vehicle_key]
      ,modified as [posm_vehicle_modified_flag],modified_details as [posm_vehicle_modified_details],vehicle_type as [vehicle_type_code],vehicle_type_details as [vehicle_type_details],
	  vehicle_dealer_group as [vehicle_dealer_group_name],
	  vehicle_new_used as [vehicle_new_flag],vehicle_condition as [vehicle_condition_code]
      ,valuation_type_id as [valuation_type_id],valuation_type as [valuation_type_code],vehicle_has_alarm as [vehicle_has_alarm_flag],vehicle_has_immobiliser as [vehicle_has_immobiliser_flag],
	  vehicle_mod_body_kit as [vehicle_mod_body_kit_flag],
	  vehicle_mod_decoration as [vehicle_mod_decoration_flag],vehicle_mod_engine as [vehicle_mod_engine_flag]
      ,vehicle_mod_exhaust as [vehicle_mod_exhaust_flag],vehicle_mod_gauges as [vehicle_mod_gauges_flag],vehicle_mod_glass as [vehicle_mod_glass_flag],vehicle_mod_suspension as [vehicle_mod_suspension_flag],
	  vehicle_mod_mags_value as [vehicle_mod_mags_amount],
	  vehicle_mod_stereo_value as [vehicle_mod_stereo_amount],vehicle_mod_other_value as [vehicle_mod_other_amount]
      ,null as [tyre_brand_id],null as [tyre_brand_name],null as [tyre_name_id] ,null as [tyre_name],null as [tyre_front_width_in_mm_number],null as [tyre_front_profile_percentage],
	  null as [tyre_front_rim_size_in_inches_number],null as [tyre_staggered_fitment_flag]
      ,null as [tyre_rear_tyre_width_in_mm_number],null as [tyre_rear_profile],null as [tyre_rear_rim_size],last_updated as [last_updated_date] 
from ext_piclos.posm_policy 
union
select 
      [vehicle_id],id as [policy_id], year as [manufactured_year], null as [vehicle_make_id], make as [vehicle_make_name],null as [vehicle_model_id],model_family as [vehicle_model_family_description],
	  model as [vehicle_model_description]
      ,null as [vehicle_cc_rating],null as [vehicle_odometer_reading],registration_plate as [vehicle_registration_number],vin as [vehicle_identification_number],[stock_number],
	  null as [vehicle_purchase_date_time],null as [vehicle_motor_type_name]
      ,null as [vehicle_engine_cylinders_number],null as [is_turbo_super_flag],null as [is_4wd_flag],null as [vehicle_origin_country_name],null as [is_vehicle_modified_flag],
	  null as [vehicle_modification_notes],null as [vehicle_usage_code]
      ,null as [manufacturers_warranty_remaining_in_months],null as [manufacturers_warranty_limited_to_kms],null as [original_odometer_reading],null as [original_manufactured_year],null as [mycar_authentication_code]
      ,null as [mycar_authentication_code_used_flag],null as [rb_default_value_amount],null as [rb_avg_wholesale],null as [rb_avg_retail],null as [rb_good_wholesale],null as [rb_good_retail],
	  null as [rb_new_price],null as [rb_vehicle_key]
      ,null as [posm_vehicle_modified_flag],null as [posm_vehicle_modified_details],null as [vehicle_type_code],null as [vehicle_type_details],null as [vehicle_dealer_group_name],
	  null as [vehicle_new_flag],null as [vehicle_condition_code]
      ,null as [valuation_type_id],null as [valuation_type_code],null as [vehicle_has_alarm_flag],null as [vehicle_has_immobiliser_flag],null as [vehicle_mod_body_kit_flag],
	  null as [vehicle_mod_decoration_flag],null as [vehicle_mod_engine_flag]
      ,null as [vehicle_mod_exhaust_flag],null as [vehicle_mod_gauges_flag],null as [vehicle_mod_glass_flag],null as [vehicle_mod_suspension_flag],null as [vehicle_mod_mags_amount],
	  null as [vehicle_mod_stereo_amount],null as [vehicle_mod_other_amount]
      ,null as [tyre_brand_id],null as [tyre_brand_name],null as [tyre_name_id] ,null as [tyre_name],null as [tyre_front_width_in_mm_number],null as [tyre_front_profile_percentage],
	  null as [tyre_front_rim_size_in_inches_number],null as [tyre_staggered_fitment_flag]
      ,null as [tyre_rear_tyre_width_in_mm_number],null as [tyre_rear_profile],null as [tyre_rear_rim_size]
	  ,last_updated as [last_updated_date] 
from ext_piclos.gap_policy
union 
select 
          [vehicle_id],id as [policy_id], year as [manufactured_year], null as [vehicle_make_id], make as [vehicle_make_name],null as [vehicle_model_id],model_family as [vehicle_model_family_description],
	  model as [vehicle_model_description]
      ,cast(cc_rating as float) as [vehicle_cc_rating],odometer as [vehicle_odometer_reading],registration_plate as [vehicle_registration_number],vin as [vehicle_identification_number],[stock_number],
	 case when date_vehicle_purchased < '1900-01-01 00:00:00' then null else date_vehicle_purchased end as [vehicle_purchase_date_time]  ,motor_type as [vehicle_motor_type_name]
      ,number_of_cylinders as [vehicle_engine_cylinders_number],is_turbo_super as [is_turbo_super_flag],is_4wd as [is_4wd_flag],country_of_origin as [vehicle_origin_country_name],
	  is_modified as [is_vehicle_modified_flag],
	  modifications as [vehicle_modification_notes],vehicle_usage as [vehicle_usage_code]
      ,manufacturers_warranty_months_remaining as [manufacturers_warranty_remaining_in_months],manufacturers_warranty_limited_to_kms as [manufacturers_warranty_limited_to_kms],
	  original_odometer as [original_odometer_reading],original_year as [original_manufactured_year],mycar_authentication_code as [mycar_authentication_code]
      ,mycar_authentication_code_used as [mycar_authentication_code_used_flag],null as [rb_default_value_amount],null as [rb_avg_wholesale],null as [rb_avg_retail],null as [rb_good_wholesale],
	  null as [rb_good_retail],null as [rb_new_price],null as [rb_vehicle_key]
      ,null as [posm_vehicle_modified_flag],null as [posm_vehicle_modified_details],null as [vehicle_type_code],null as [vehicle_type_details],null as [vehicle_dealer_group_name],
	  null as [vehicle_new_flag],null as [vehicle_condition_code]
      ,null as [valuation_type_id],null as [valuation_type_code],null as [vehicle_has_alarm_flag],null as [vehicle_has_immobiliser_flag],null as [vehicle_mod_body_kit_flag],
	  null as [vehicle_mod_decoration_flag],null as [vehicle_mod_engine_flag]
      ,null as [vehicle_mod_exhaust_flag],null as [vehicle_mod_gauges_flag],null as [vehicle_mod_glass_flag],null as [vehicle_mod_suspension_flag],null as [vehicle_mod_mags_amount],
	  null as [vehicle_mod_stereo_amount],null as [vehicle_mod_other_amount]
      ,null as [tyre_brand_id],null as [tyre_brand_name],null as [tyre_name_id] ,null as [tyre_name],null as [tyre_front_width_in_mm_number],null as [tyre_front_profile_percentage],
	  null as [tyre_front_rim_size_in_inches_number],null as [tyre_staggered_fitment_flag]
      ,null as [tyre_rear_tyre_width_in_mm_number],null as [tyre_rear_profile],null as [tyre_rear_rim_size]
	  ,last_updated as [last_updated_date] 
from ext_piclos.mbi_policy 


union 

select 
     [vehicle_id],id as [policy_id], year as [manufactured_year], null as [vehicle_make_id], make as [vehicle_make_name],null as [vehicle_model_id],model_family as [vehicle_model_family_description],
	  model as [vehicle_model_description]
      ,null as [vehicle_cc_rating],null as [vehicle_odometer_reading],registration_plate as [vehicle_registration_number],vin as [vehicle_identification_number],[stock_number],
	  case when date_vehicle_purchased < '1900-01-01 00:00:00' then null else date_vehicle_purchased end as [vehicle_purchase_date_time],null as [vehicle_motor_type_name]
      ,null as [vehicle_engine_cylinders_number],null as [is_turbo_super_flag],null as [is_4wd_flag],null as [vehicle_origin_country_name],null as [is_vehicle_modified_flag],
	  null as [vehicle_modification_notes],vehicle_usage as [vehicle_usage_code]
      ,null as [manufacturers_warranty_remaining_in_months],null as [manufacturers_warranty_limited_to_kms],original_odometer as [original_odometer_reading],
	  original_year as [original_manufactured_year],null as [mycar_authentication_code]
      ,null as [mycar_authentication_code_used_flag],null as [rb_default_value_amount],null as [rb_avg_wholesale],null as [rb_avg_retail],null as [rb_good_wholesale],null as [rb_good_retail],
	  null as [rb_new_price],null as [rb_vehicle_key]
      ,null as [posm_vehicle_modified_flag],null as [posm_vehicle_modified_details],null as [vehicle_type_code],null as [vehicle_type_details],null as [vehicle_dealer_group_name],
	  null as [vehicle_new_flag],null as [vehicle_condition_code]
      ,null as [valuation_type_id],null as [valuation_type_code],null as [vehicle_has_alarm_flag],null as [vehicle_has_immobiliser_flag],null as [vehicle_mod_body_kit_flag],
	  null as [vehicle_mod_decoration_flag],null as [vehicle_mod_engine_flag]
      ,null as [vehicle_mod_exhaust_flag],null as [vehicle_mod_gauges_flag],null as [vehicle_mod_glass_flag],null as [vehicle_mod_suspension_flag],null as [vehicle_mod_mags_amount],
	  null as [vehicle_mod_stereo_amount],null as [vehicle_mod_other_amount]
      , [tyre_brand_id],tyre_brand_other as [tyre_brand_name],[tyre_name_id] ,tyre_name_other as [tyre_name],tyre_front_tyre_width as [tyre_front_width_in_mm_number],
	  tyre_front_profile as [tyre_front_profile_percentage],
	  tyre_front_rim_size as [tyre_front_rim_size_in_inches_number],tyre_staggered_fitment as [tyre_staggered_fitment_flag]
      ,tyre_rear_tyre_width as [tyre_rear_tyre_width_in_mm_number],tyre_rear_profile as [tyre_rear_profile],tyre_rear_rim_size as [tyre_rear_rim_size],last_updated as [last_updated_date] 
from ext_piclos.tar_policy 
) vehicle 

MERGE
	data.[dim_vehicle] 
USING
  (
  select * from #vehicle
  ) vehicles

on 
data.[dim_vehicle].[policy_id] = vehicles.[policy_id] AND
data.[dim_vehicle].is_deleted = 0 AND
data.[dim_vehicle].record_current_flag = 1 

WHEN NOT MATCHED BY TARGET THEN
	INSERT
		([vehicle_id],[policy_id],[manufactured_year],[vehicle_make_id],[vehicle_make_name],[vehicle_model_id],[vehicle_model_family_description]
      ,[vehicle_model_description],[vehicle_cc_rating],[vehicle_odometer_reading],[vehicle_registration_number],[vehicle_identification_number],[stock_number]
      ,[vehicle_purchase_date_time],[vehicle_motor_type_name],[vehicle_engine_cylinders_number],[is_turbo_super_flag],[is_4wd_flag],[vehicle_origin_country_name]
      ,[is_vehicle_modified_flag],[vehicle_modification_notes],[vehicle_usage_code],[manufacturers_warranty_remaining_in_months],[manufacturers_warranty_limited_to_kms]
      ,[original_odometer_reading],[original_manufactured_year],[mycar_authentication_code],[mycar_authentication_code_used_flag],[rb_default_value_amount]
      ,[rb_avg_wholesale],[rb_avg_retail],[rb_good_wholesale],[rb_good_retail],[rb_new_price],[rb_vehicle_key],[posm_vehicle_modified_flag],[posm_vehicle_modified_details]
      ,[vehicle_type_code],[vehicle_type_details],[vehicle_dealer_group_name],[vehicle_new_flag],[vehicle_condition_code],[valuation_type_id],[valuation_type_code]
      ,[vehicle_has_alarm_flag],[vehicle_has_immobiliser_flag],[vehicle_mod_body_kit_flag],[vehicle_mod_decoration_flag],[vehicle_mod_engine_flag],[vehicle_mod_exhaust_flag]
      ,[vehicle_mod_gauges_flag],[vehicle_mod_glass_flag],[vehicle_mod_suspension_flag],[vehicle_mod_mags_amount],[vehicle_mod_stereo_amount],[vehicle_mod_other_amount]
      ,[tyre_brand_id],[tyre_brand_name],[tyre_name_id],[tyre_name],[tyre_front_width_in_mm_number],[tyre_front_profile_percentage],[tyre_front_rim_size_in_inches_number]
      ,[tyre_staggered_fitment_flag],[tyre_rear_tyre_width_in_mm_number],[tyre_rear_profile],[tyre_rear_rim_size],[last_updated_date] ,record_end_datetime
	  )
	  VALUES 
	  (
	  [vehicle_id],[policy_id],[manufactured_year],[vehicle_make_id],[vehicle_make_name],[vehicle_model_id],[vehicle_model_family_description]
      ,[vehicle_model_description],[vehicle_cc_rating],[vehicle_odometer_reading],[vehicle_registration_number],[vehicle_identification_number],[stock_number]
      ,[vehicle_purchase_date_time],[vehicle_motor_type_name],[vehicle_engine_cylinders_number],[is_turbo_super_flag],[is_4wd_flag],[vehicle_origin_country_name]
      ,[is_vehicle_modified_flag],[vehicle_modification_notes],[vehicle_usage_code],[manufacturers_warranty_remaining_in_months],[manufacturers_warranty_limited_to_kms]
      ,[original_odometer_reading],[original_manufactured_year],[mycar_authentication_code],[mycar_authentication_code_used_flag],[rb_default_value_amount]
      ,[rb_avg_wholesale],[rb_avg_retail],[rb_good_wholesale],[rb_good_retail],[rb_new_price],[rb_vehicle_key],[posm_vehicle_modified_flag],[posm_vehicle_modified_details]
      ,[vehicle_type_code],[vehicle_type_details],[vehicle_dealer_group_name],[vehicle_new_flag],[vehicle_condition_code],[valuation_type_id],[valuation_type_code]
      ,[vehicle_has_alarm_flag],[vehicle_has_immobiliser_flag],[vehicle_mod_body_kit_flag],[vehicle_mod_decoration_flag],[vehicle_mod_engine_flag],[vehicle_mod_exhaust_flag]
      ,[vehicle_mod_gauges_flag],[vehicle_mod_glass_flag],[vehicle_mod_suspension_flag],[vehicle_mod_mags_amount],[vehicle_mod_stereo_amount],[vehicle_mod_other_amount]
      ,[tyre_brand_id],[tyre_brand_name],[tyre_name_id],[tyre_name],[tyre_front_width_in_mm_number],[tyre_front_profile_percentage],[tyre_front_rim_size_in_inches_number]
      ,[tyre_staggered_fitment_flag],[tyre_rear_tyre_width_in_mm_number],[tyre_rear_profile],[tyre_rear_rim_size],[last_updated_date],@end_date
	  )
	  WHEN MATCHED and 
	  data.[dim_vehicle].[last_updated_date] <> vehicles.[last_updated_date]

	  THEN 
	  UPDATE SET data.[dim_vehicle].[record_end_datetime] = getdate() AT TIME ZONE 'UTC' AT TIME ZONE 'New Zealand Standard Time',
      data.[dim_vehicle].[record_current_flag] = 0,
      data.[dim_vehicle].last_updated = getdate() AT TIME ZONE 'UTC' AT TIME ZONE 'New Zealand Standard Time'

	  WHEN NOT MATCHED BY SOURCE AND data.[dim_vehicle].vehicle_key <> -1 and [record_current_flag] = 1 THEN 
      UPDATE SET data.[dim_vehicle].is_deleted = 1,
      data.[dim_vehicle].[record_end_datetime] = getdate() AT TIME ZONE 'UTC' AT TIME ZONE 'New Zealand Standard Time',
      data.[dim_vehicle].[record_current_flag] = 0;

	  INSERT into data.[dim_vehicle] 
		(
		[vehicle_id],[policy_id],[manufactured_year],[vehicle_make_id],[vehicle_make_name],[vehicle_model_id],[vehicle_model_family_description]
      ,[vehicle_model_description],[vehicle_cc_rating],[vehicle_odometer_reading],[vehicle_registration_number],[vehicle_identification_number],[stock_number]
      ,[vehicle_purchase_date_time],[vehicle_motor_type_name],[vehicle_engine_cylinders_number],[is_turbo_super_flag],[is_4wd_flag],[vehicle_origin_country_name]
      ,[is_vehicle_modified_flag],[vehicle_modification_notes],[vehicle_usage_code],[manufacturers_warranty_remaining_in_months],[manufacturers_warranty_limited_to_kms]
      ,[original_odometer_reading],[original_manufactured_year],[mycar_authentication_code],[mycar_authentication_code_used_flag],[rb_default_value_amount]
      ,[rb_avg_wholesale],[rb_avg_retail],[rb_good_wholesale],[rb_good_retail],[rb_new_price],[rb_vehicle_key],[posm_vehicle_modified_flag],[posm_vehicle_modified_details]
      ,[vehicle_type_code],[vehicle_type_details],[vehicle_dealer_group_name],[vehicle_new_flag],[vehicle_condition_code],[valuation_type_id],[valuation_type_code]
      ,[vehicle_has_alarm_flag],[vehicle_has_immobiliser_flag],[vehicle_mod_body_kit_flag],[vehicle_mod_decoration_flag],[vehicle_mod_engine_flag],[vehicle_mod_exhaust_flag]
      ,[vehicle_mod_gauges_flag],[vehicle_mod_glass_flag],[vehicle_mod_suspension_flag],[vehicle_mod_mags_amount],[vehicle_mod_stereo_amount],[vehicle_mod_other_amount]
      ,[tyre_brand_id],[tyre_brand_name],[tyre_name_id],[tyre_name],[tyre_front_width_in_mm_number],[tyre_front_profile_percentage],[tyre_front_rim_size_in_inches_number]
      ,[tyre_staggered_fitment_flag],[tyre_rear_tyre_width_in_mm_number],[tyre_rear_profile],[tyre_rear_rim_size],[last_updated_date] ,record_end_datetime
	  )
	  SELECT         #vehicle.[vehicle_id],#vehicle.[policy_id],#vehicle.[manufactured_year],#vehicle.[vehicle_make_id],#vehicle.[vehicle_make_name],#vehicle.[vehicle_model_id],#vehicle.[vehicle_model_family_description]
      ,#vehicle.[vehicle_model_description],#vehicle.[vehicle_cc_rating],#vehicle.[vehicle_odometer_reading],#vehicle.[vehicle_registration_number],#vehicle.[vehicle_identification_number],#vehicle.[stock_number]
      ,#vehicle.[vehicle_purchase_date_time],#vehicle.[vehicle_motor_type_name],#vehicle.[vehicle_engine_cylinders_number],#vehicle.[is_turbo_super_flag],#vehicle.[is_4wd_flag],#vehicle.[vehicle_origin_country_name]
      ,#vehicle.[is_vehicle_modified_flag],#vehicle.[vehicle_modification_notes],#vehicle.[vehicle_usage_code],#vehicle.[manufacturers_warranty_remaining_in_months],#vehicle.[manufacturers_warranty_limited_to_kms]
      ,#vehicle.[original_odometer_reading],#vehicle.[original_manufactured_year],#vehicle.[mycar_authentication_code],#vehicle.[mycar_authentication_code_used_flag],#vehicle.[rb_default_value_amount]
      ,#vehicle.[rb_avg_wholesale],#vehicle.[rb_avg_retail],#vehicle.[rb_good_wholesale],#vehicle.[rb_good_retail],#vehicle.[rb_new_price],#vehicle.[rb_vehicle_key],#vehicle.[posm_vehicle_modified_flag],#vehicle.[posm_vehicle_modified_details]
      ,#vehicle.[vehicle_type_code],#vehicle.[vehicle_type_details],#vehicle.[vehicle_dealer_group_name],#vehicle.[vehicle_new_flag],#vehicle.[vehicle_condition_code],#vehicle.[valuation_type_id],#vehicle.[valuation_type_code]
      ,#vehicle.[vehicle_has_alarm_flag],#vehicle.[vehicle_has_immobiliser_flag],#vehicle.[vehicle_mod_body_kit_flag],#vehicle.[vehicle_mod_decoration_flag],#vehicle.[vehicle_mod_engine_flag],#vehicle.[vehicle_mod_exhaust_flag]
      ,#vehicle.[vehicle_mod_gauges_flag],#vehicle.[vehicle_mod_glass_flag],#vehicle.[vehicle_mod_suspension_flag],#vehicle.[vehicle_mod_mags_amount],#vehicle.[vehicle_mod_stereo_amount],#vehicle.[vehicle_mod_other_amount]
      ,#vehicle.[tyre_brand_id],#vehicle.[tyre_brand_name],#vehicle.[tyre_name_id],#vehicle.[tyre_name],#vehicle.[tyre_front_width_in_mm_number],#vehicle.[tyre_front_profile_percentage],#vehicle.[tyre_front_rim_size_in_inches_number]
      ,#vehicle.[tyre_staggered_fitment_flag],#vehicle.[tyre_rear_tyre_width_in_mm_number],#vehicle.[tyre_rear_profile],#vehicle.[tyre_rear_rim_size],#vehicle.[last_updated_date] 
	  ,@end_date from #vehicle 
	  left join data.[dim_vehicle] 
	  ON data.[dim_vehicle].[policy_id] = #vehicle.[policy_id] 
	  and data.[dim_vehicle].[record_current_flag] = 1  and data.[dim_vehicle].is_deleted = 0
	  where  data.[dim_vehicle].[policy_id] is null 

	  END
GO


