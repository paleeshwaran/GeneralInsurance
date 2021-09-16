/****** Object:  StoredProcedure [sp_data].[populate_dim_cover_type]    Script Date: 16/09/2021 11:04:49 am ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [sp_data].[populate_dim_cover_type]
AS
BEGIN
	SET NOCOUNT ON;
	SET IDENTITY_INSERT data.[dim_cover_type] ON
	INSERT INTO data.[dim_cover_type]
		([cover_type_key],[cover_type_id],[cover_description],[cover_active_flag],[product_id],[product_code],[dealer_group_id],[dealer_id],[original_cover_type_id],[vehicle_category_id]
      ,[record_start_datetime],[record_end_datetime],[record_current_flag])
	SELECT -1,0,'N/A',1,0,'N/A',0,0,0,0,'19000101','20491231',1
	WHERE NOT EXISTS
	(SELECT cover_type_key FROM  data.[dim_cover_type] WHERE cover_type_key = -1)
SET IDENTITY_INSERT  data.[dim_cover_type] OFF

MERGE
	data.[dim_cover_type] 
USING
	(
		
	Select cover_type.*,p.[product_type] from (	select  [id],[title],[is_enabled],[insurance_product_id],null as dealer_group_id,null as dealer_id,null as [original_cover_type_id],null as [vehicle_category],null as max_age,
       null as min_kms , null as max_kms, null as [roadside_assist],null as [roadside_assist_max_term],null as [service_interval_petrol],null as[service_km_petrol],
	   null as [service_interval_diesel],null as [service_km_diesel],null as [service_interval_hybrid],null as [service_km_hybrid],null as [service_interval_electric],
	   null as[service_km_electric],null as [premium_funded],null as [is_flexible_term], null as [is_special_extended], null as [gwp_account_code], null as [cancellation_account_code],
	   null as [claims_account_code], null as [has_road_side_assist], null as [term],null as [excess], [other_details],[please_note],[financial_rating],[acknowledgments],
	   [contact_details],[use_wholesale_premium],[rate_percentage_12],[rate_percentage_18],[rate_percentage_24],[rate_percentage_36],[rate_percentage_48],[rate_percentage_60],
	   [rate_double],[rate_retail_commission],[enable_timestamp] as create_date,[enabled_timestamp],null as created_by
        from [ext_piclos].[cci_cover_type]
union 
select [id],[title],[is_enabled],[insurance_product_id],null as dealer_group_id,null as dealer_id,null as [original_cover_type_id],null as [vehicle_category],null as max_age,
       null as min_kms , null as max_kms, null as [roadside_assist],null as [roadside_assist_max_term],null as [service_interval_petrol],null as[service_km_petrol],
	   null as [service_interval_diesel],null as [service_km_diesel],null as [service_interval_hybrid],null as [service_km_hybrid],null as [service_interval_electric],
	   null as[service_km_electric],null as [premium_funded],null as [is_flexible_term], null as [is_special_extended], null as [gwp_account_code], null as [cancellation_account_code],
	   null as [claims_account_code], null as [has_road_side_assist], null as [term],null as [excess], null as[other_details],[please_note],[financial_rating],[acknowledgments],
	   null as[contact_details],null as[use_wholesale_premium],null as[rate_percentage_12],null as[rate_percentage_18],null as[rate_percentage_24],null as[rate_percentage_36],
	   null as[rate_percentage_48],null as[rate_percentage_60],null as[rate_double],null as[rate_retail_commission],[created_timestamp] as create_date,[enabled_timestamp],created_by
      from [ext_piclos].[gap_cover_type]
union 
select [id],[title],[is_enabled],[insurance_product_id],null as dealer_group_id,null as dealer_id,null as [original_cover_type_id],null as [vehicle_category],null as max_age,
       null as min_kms , null as max_kms, null as [roadside_assist],null as [roadside_assist_max_term],null as [service_interval_petrol],null as[service_km_petrol],
	   null as [service_interval_diesel],null as [service_km_diesel],null as [service_interval_hybrid],null as [service_km_hybrid],null as [service_interval_electric],
	   null as[service_km_electric],null as [premium_funded],null as [is_flexible_term], null as [is_special_extended], null as [gwp_account_code], null as [cancellation_account_code],
	   null as [claims_account_code], null as [has_road_side_assist], null as [term],null as [excess], null as[other_details],null as[please_note],null as[financial_rating],null as[acknowledgments],
	   null as[contact_details],null as[use_wholesale_premium],null as[rate_percentage_12],null as[rate_percentage_18],null as[rate_percentage_24],null as[rate_percentage_36],
	   null as[rate_percentage_48],null as[rate_percentage_60],null as[rate_double],null as[rate_retail_commission],[created_timestamp] as create_date,null as[enabled_timestamp],null as created_by
       from [ext_piclos].[lnm_cover_type]
union
select [id],[title],[is_enabled],[insurance_product_id],[dealer_group_id],[dealer_id],[original_cover_type_id],[vehicle_category]
      ,[max_age],[min_kms],[max_kms],[roadside_assist],[roadside_assist_max_term],[service_interval_petrol],[service_km_petrol],[service_interval_diesel]
      ,[service_km_diesel],[service_interval_hybrid],[service_km_hybrid],[service_interval_electric],[service_km_electric],[premium_funded],[is_flexible_term],
	  [is_special_extended],null as [gwp_account_code], null as [cancellation_account_code],null as [claims_account_code], null as [has_road_side_assist], 
	   null as [term],null as [excess], null as[other_details],null as [please_note],null as [financial_rating],null as [acknowledgments],
	   null as[contact_details],null as[use_wholesale_premium],null as[rate_percentage_12],null as[rate_percentage_18],null as[rate_percentage_24],null as[rate_percentage_36],
	   null as[rate_percentage_48],null as[rate_percentage_60],null as[rate_double],null as[rate_retail_commission],
	  [created_timestamp] as create_date,[enabled_timestamp],[created_by] from [ext_piclos].[mbi_cover_type]
union
select [id],[title],[is_enabled],18 as [insurance_product_id],null as dealer_group_id,null as dealer_id,null as [original_cover_type_id],null as [vehicle_category],null as max_age,
       null as min_kms , null as max_kms, null as [roadside_assist],null as [roadside_assist_max_term],null as [service_interval_petrol],null as[service_km_petrol],
	   null as [service_interval_diesel],null as [service_km_diesel],null as [service_interval_hybrid],null as [service_km_hybrid],null as [service_interval_electric],
	   null as[service_km_electric],null as [premium_funded],null as [is_flexible_term], null as [is_special_extended],  [gwp_account_code], [cancellation_account_code],
	   [claims_account_code], [has_road_side_assist], [term],[excess], [other_details],null as[please_note],null as[financial_rating],null as[acknowledgments],
	   null as[contact_details],null as[use_wholesale_premium],null as[rate_percentage_12],null as[rate_percentage_18],null as[rate_percentage_24],null as[rate_percentage_36],
	   null as[rate_percentage_48],null as[rate_percentage_60],null as[rate_double],null as[rate_retail_commission],null as create_date,
	   null as [enabled_timestamp],null as created_by
        from [ext_piclos].[posm_cover_type]
union
select [id],[title],[is_enabled],[insurance_product_id],null as dealer_group_id,[dealer_id],[original_cover_type_id],null as [vehicle_category],[max_age],[min_kms],
       [max_kms], null as [roadside_assist],null as [roadside_assist_max_term],null as [service_interval_petrol],null as[service_km_petrol],
	   null as [service_interval_diesel],null as [service_km_diesel],null as [service_interval_hybrid],null as [service_km_hybrid],null as [service_interval_electric],
	   null as[service_km_electric],null as [premium_funded],null as [is_flexible_term], null as [is_special_extended], null as[gwp_account_code], null as[cancellation_account_code],
	   null as [claims_account_code], null as [has_road_side_assist], null as [term],null as [excess],null as [other_details],null as [please_note],null as[financial_rating],null as[acknowledgments],
	   null as[contact_details],null as[use_wholesale_premium],null as[rate_percentage_12],null as[rate_percentage_18],null as[rate_percentage_24],null as[rate_percentage_36],
	   null as[rate_percentage_48],null as[rate_percentage_60],null as[rate_double],null as[rate_retail_commission],
	   [created_timestamp] as create_date,[enabled_timestamp],[created_by] from [ext_piclos].[tar_cover_type]		
		
	) cover_type 
	join ext_piclos.insurance_product P
	on p.id = cover_type.[insurance_product_id]) cover_type
ON
	data.[dim_cover_type].[cover_type_id] = cover_type.id
	and data.[dim_cover_type].product_id = cover_type.[insurance_product_id]
	and data.[dim_cover_type].is_deleted = 0 
	and data.[dim_cover_type].[record_current_flag] = 1 
WHEN NOT MATCHED BY TARGET THEN
	INSERT
		(
			 [cover_type_id],[cover_description],[cover_active_flag],[product_id],product_code,[dealer_group_id],[dealer_id],[original_cover_type_id],[vehicle_category_id]
      ,[maximum_age],[minimum_kms],[maximum_kms],[roadside_assist_top_up_amount],[roadside_assist_maximum_term_in_months],[petrol_vehicle_service_interval_in_months],[petrol_vehicle_service_kms]
      ,[diesel_vehicle_service_interval_in_months],[diesel_vehicle_service_kms],[hybrid_vehicle_service_interval_in_months],[hybrid_vehicle_service_kms],[electric_vehicle_service_interval_in_months]
      ,[electric_vehicle_service_kms],[premium_funded_flag],[flexible_term_flag],[special_extended_flag],[gwp_account_number],[cancellation_account_number],[claims_account_number],[posm_roadside_assit_flag]
      ,[posm_term_in_month],[posm_excess_amount],[other_details],[additional_notes],[financial_rating_notes],[acknowledgment_notes],[contact_details],[use_wholesale_premium_flag],[rate_12_months_percentage]
      ,[rate_18_months_percentage],[rate_24_months_percentage],[rate_36_months_percentage],[rate_48_months_percentage],[rate_60_months_percentage],[rate_double_cover_percentage],[rate_retail_commission_percentage]
     ,[cover_created_date]
	 ,[cover_enabled_date]
	 ,[created_by_user_id]
		)
	VALUES
		(
			[id],[title],[is_enabled],[insurance_product_id],[product_type],dealer_group_id,[dealer_id],[original_cover_type_id], [vehicle_category],[max_age],[min_kms],
       [max_kms], [roadside_assist],[roadside_assist_max_term],[service_interval_petrol],[service_km_petrol],
	   [service_interval_diesel],[service_km_diesel],[service_interval_hybrid],[service_km_hybrid],[service_interval_electric],
	   [service_km_electric],[premium_funded],[is_flexible_term], [is_special_extended], [gwp_account_code], [cancellation_account_code],
	   [claims_account_code], [has_road_side_assist],[term], [excess],[other_details],[please_note],[financial_rating],[acknowledgments],
	   [contact_details],[use_wholesale_premium],[rate_percentage_12],[rate_percentage_18],[rate_percentage_24],[rate_percentage_36],
	   [rate_percentage_48],[rate_percentage_60],[rate_double],[rate_retail_commission]
	  , create_date
	  ,replace([enabled_timestamp],'0001-01-01 00:00:00.000',null) 
	  ,[created_by]
			
			
		)

WHEN MATCHED and( data.[dim_cover_type].cover_type_id <> cover_type.[id] OR
data.[dim_cover_type].cover_description <> cover_type.[title] OR
isnull(data.[dim_cover_type].cover_active_flag,-999) <> isnull(cover_type.[is_enabled],-999) OR
isnull(data.[dim_cover_type].dealer_group_id,-999) <> isnull(cover_type.dealer_group_id,-999) OR
isnull(data.[dim_cover_type].dealer_id,-999) <> isnull(cover_type.[dealer_id],-999) OR
isnull(data.[dim_cover_type].product_code,-999) <> isnull(cover_type.[product_type],-999) OR
isnull(data.[dim_cover_type].original_cover_type_id,-999) <> isnull(cover_type.[original_cover_type_id],-999) OR
isnull(data.[dim_cover_type].vehicle_category_id,-999) <> isnull(cover_type.[vehicle_category],-999) OR
isnull(data.[dim_cover_type].maximum_age,-999) <> isnull(cover_type.[max_age],-999) OR
isnull(data.[dim_cover_type].minimum_kms,-999) <> isnull(cover_type.[min_kms],-999) OR
isnull(data.[dim_cover_type].maximum_kms,-999) <> isnull(cover_type.[max_kms],-999) OR
isnull(data.[dim_cover_type].roadside_assist_top_up_amount,-999) <> isnull(cover_type.[roadside_assist],-999) OR
isnull(data.[dim_cover_type].roadside_assist_maximum_term_in_months,-999) <> isnull(cover_type.[roadside_assist_max_term],-999) OR
isnull(data.[dim_cover_type].petrol_vehicle_service_interval_in_months,-999) <> isnull(cover_type.[service_interval_petrol],-999) OR
isnull(data.[dim_cover_type].petrol_vehicle_service_kms,-999) <> isnull(cover_type.[service_km_petrol],-999) OR
isnull(data.[dim_cover_type].diesel_vehicle_service_interval_in_months,-999) <> isnull(cover_type.[service_interval_diesel],-999) OR
isnull(data.[dim_cover_type].diesel_vehicle_service_kms,-999) <> isnull(cover_type.[service_km_diesel],-999) OR
isnull(data.[dim_cover_type].hybrid_vehicle_service_interval_in_months,-999) <>isnull( cover_type.[service_interval_hybrid],-999) OR
isnull(data.[dim_cover_type].hybrid_vehicle_service_kms,-999) <> isnull(cover_type.[service_km_hybrid],-999) OR
isnull(data.[dim_cover_type].electric_vehicle_service_interval_in_months,-999) <> isnull(cover_type.[service_interval_electric],-999) OR
isnull(data.[dim_cover_type].electric_vehicle_service_kms,-999) <> isnull(cover_type.[service_km_electric],-999) OR
isnull(data.[dim_cover_type].premium_funded_flag,0) <> isnull(cover_type.[premium_funded],0) OR
isnull(data.[dim_cover_type].flexible_term_flag,0) <> isnull(cover_type.[is_flexible_term],0) OR
isnull(data.[dim_cover_type].special_extended_flag,0) <> isnull(cover_type.[is_special_extended],0) OR
isnull(data.[dim_cover_type].gwp_account_number,-999) <> isnull(cover_type.[gwp_account_code],-999) OR
isnull(data.[dim_cover_type].cancellation_account_number,-999) <> isnull(cover_type.[cancellation_account_code],-999) OR
isnull(data.[dim_cover_type].claims_account_number,-999) <> isnull(cover_type.[claims_account_code],-999) OR
isnull(data.[dim_cover_type].posm_roadside_assit_flag,0) <> isnull(cover_type.[has_road_side_assist],0) OR
isnull(data.[dim_cover_type].posm_term_in_month,-999) <> isnull(cover_type.[term],-999) OR
isnull(data.[dim_cover_type].posm_excess_amount,-999) <> isnull(cover_type.[excess],-999) OR
isnull(data.[dim_cover_type].other_details,'') <> isnull(cover_type.[other_details],'') OR
isnull(data.[dim_cover_type].additional_notes,'') <> isnull(cover_type.[please_note],'') OR
isnull(data.[dim_cover_type].financial_rating_notes,'') <> isnull(cover_type.[financial_rating],'') OR
isnull(data.[dim_cover_type].acknowledgment_notes,'') <> isnull(cover_type.[acknowledgments],'') OR
isnull(data.[dim_cover_type].contact_details,'') <> isnull(cover_type.[contact_details],'') OR
isnull(data.[dim_cover_type].use_wholesale_premium_flag,-999) <> isnull(cover_type.[use_wholesale_premium],-999) OR
isnull(data.[dim_cover_type].rate_12_months_percentage,-999) <> isnull(cover_type.[rate_percentage_12],-999) OR
isnull(data.[dim_cover_type].rate_18_months_percentage,-999) <> isnull(cover_type.[rate_percentage_18],-999) OR
isnull(data.[dim_cover_type].rate_24_months_percentage,-999) <> isnull(cover_type.[rate_percentage_24],-999) OR
isnull(data.[dim_cover_type].rate_36_months_percentage,-999) <> isnull(cover_type.[rate_percentage_36],-999) OR
isnull(data.[dim_cover_type].rate_48_months_percentage,-999) <> isnull(cover_type.[rate_percentage_48],-999) OR

isnull(data.[dim_cover_type].rate_60_months_percentage,-999) <> isnull(cover_type.[rate_percentage_60],-999) OR
isnull(data.[dim_cover_type].rate_double_cover_percentage,-999) <> isnull(cover_type.[rate_double],-999) OR
isnull(data.[dim_cover_type].rate_retail_commission_percentage,-999) <> isnull(cover_type.[rate_retail_commission],-999) 
)

THEN 
UPDATE SET data.[dim_cover_type].[record_end_datetime] = getdate(),
data.[dim_cover_type].[record_current_flag] = 0,
data.[dim_cover_type].last_updated = getdate()


WHEN NOT MATCHED BY SOURCE AND data.[dim_cover_type].cover_type_key <> -1 and [record_current_flag] = 1 THEN UPDATE SET data.[dim_cover_type].is_deleted = 1;

INSERT into data.dim_cover_type 
		(
			 [cover_type_id],[cover_description],[cover_active_flag],[product_id],[dealer_group_id],[dealer_id],[original_cover_type_id],[vehicle_category_id]
      ,[maximum_age],[minimum_kms],[maximum_kms],[roadside_assist_top_up_amount],[roadside_assist_maximum_term_in_months],[petrol_vehicle_service_interval_in_months],[petrol_vehicle_service_kms]
      ,[diesel_vehicle_service_interval_in_months],[diesel_vehicle_service_kms],[hybrid_vehicle_service_interval_in_months],[hybrid_vehicle_service_kms],[electric_vehicle_service_interval_in_months]
      ,[electric_vehicle_service_kms],[premium_funded_flag],[flexible_term_flag],[special_extended_flag],[gwp_account_number],[cancellation_account_number],[claims_account_number],[posm_roadside_assit_flag]
      ,[posm_term_in_month],[posm_excess_amount],[other_details],[additional_notes],[financial_rating_notes],[acknowledgment_notes],[contact_details],[use_wholesale_premium_flag],[rate_12_months_percentage]
      ,[rate_18_months_percentage],[rate_24_months_percentage],[rate_36_months_percentage],[rate_48_months_percentage],[rate_60_months_percentage],[rate_double_cover_percentage],[rate_retail_commission_percentage]
      ,[cover_created_date],[cover_enabled_date],[created_by_user_id],product_code
		)

Select cover_type.*,p.[product_type] from 	(
		
		select  [id],[title],[is_enabled],[insurance_product_id],null as dealer_group_id,null as dealer_id,null as [original_cover_type_id],null as [vehicle_category],null as max_age,
       null as min_kms , null as max_kms, null as [roadside_assist],null as [roadside_assist_max_term],null as [service_interval_petrol],null as[service_km_petrol],
	   null as [service_interval_diesel],null as [service_km_diesel],null as [service_interval_hybrid],null as [service_km_hybrid],null as [service_interval_electric],
	   null as[service_km_electric],null as [premium_funded],null as [is_flexible_term], null as [is_special_extended], null as [gwp_account_code], null as [cancellation_account_code],
	   null as [claims_account_code], null as [has_road_side_assist], null as [term],null as [excess], [other_details],[please_note],[financial_rating],[acknowledgments],
	   [contact_details],[use_wholesale_premium],[rate_percentage_12],[rate_percentage_18],[rate_percentage_24],[rate_percentage_36],[rate_percentage_48],[rate_percentage_60],
	   [rate_double],[rate_retail_commission],[enable_timestamp] as create_date,replace([enabled_timestamp],'0001-01-01 00:00:00.000',null)as [enabled_timestamp] ,null as created_by
        from [ext_piclos].[cci_cover_type]
union 
select [id],[title],[is_enabled],[insurance_product_id],null as dealer_group_id,null as dealer_id,null as [original_cover_type_id],null as [vehicle_category],null as max_age,
       null as min_kms , null as max_kms, null as [roadside_assist],null as [roadside_assist_max_term],null as [service_interval_petrol],null as[service_km_petrol],
	   null as [service_interval_diesel],null as [service_km_diesel],null as [service_interval_hybrid],null as [service_km_hybrid],null as [service_interval_electric],
	   null as[service_km_electric],null as [premium_funded],null as [is_flexible_term], null as [is_special_extended], null as [gwp_account_code], null as [cancellation_account_code],
	   null as [claims_account_code], null as [has_road_side_assist], null as [term],null as [excess], null as[other_details],[please_note],[financial_rating],[acknowledgments],
	   null as[contact_details],null as[use_wholesale_premium],null as[rate_percentage_12],null as[rate_percentage_18],null as[rate_percentage_24],null as[rate_percentage_36],
	   null as[rate_percentage_48],null as[rate_percentage_60],null as[rate_double],null as[rate_retail_commission],[created_timestamp] as create_date
	   ,replace([enabled_timestamp],'0001-01-01 00:00:00.000',null) as [enabled_timestamp],created_by
      from [ext_piclos].[gap_cover_type]
union 
select [id],[title],[is_enabled],[insurance_product_id],null as dealer_group_id,null as dealer_id,null as [original_cover_type_id],null as [vehicle_category],null as max_age,
       null as min_kms , null as max_kms, null as [roadside_assist],null as [roadside_assist_max_term],null as [service_interval_petrol],null as[service_km_petrol],
	   null as [service_interval_diesel],null as [service_km_diesel],null as [service_interval_hybrid],null as [service_km_hybrid],null as [service_interval_electric],
	   null as[service_km_electric],null as [premium_funded],null as [is_flexible_term], null as [is_special_extended], null as [gwp_account_code], null as [cancellation_account_code],
	   null as [claims_account_code], null as [has_road_side_assist], null as [term],null as [excess], null as[other_details],null as[please_note],null as[financial_rating],null as[acknowledgments],
	   null as[contact_details],null as[use_wholesale_premium],null as[rate_percentage_12],null as[rate_percentage_18],null as[rate_percentage_24],null as[rate_percentage_36],
	   null as[rate_percentage_48],null as[rate_percentage_60],null as[rate_double],null as[rate_retail_commission],[created_timestamp] as create_date,null as[enabled_timestamp],null as created_by
       from [ext_piclos].[lnm_cover_type]
union
select [id],[title],[is_enabled],[insurance_product_id],[dealer_group_id],[dealer_id],[original_cover_type_id],[vehicle_category]
      ,[max_age],[min_kms],[max_kms],[roadside_assist],[roadside_assist_max_term],[service_interval_petrol],[service_km_petrol],[service_interval_diesel]
      ,[service_km_diesel],[service_interval_hybrid],[service_km_hybrid],[service_interval_electric],[service_km_electric],[premium_funded],[is_flexible_term],
	  [is_special_extended],null as [gwp_account_code], null as [cancellation_account_code],null as [claims_account_code], null as [has_road_side_assist], 
	   null as [term],null as [excess], null as[other_details],null as [please_note],null as [financial_rating],null as [acknowledgments],
	   null as[contact_details],null as[use_wholesale_premium],null as[rate_percentage_12],null as[rate_percentage_18],null as[rate_percentage_24],null as[rate_percentage_36],
	   null as[rate_percentage_48],null as[rate_percentage_60],null as[rate_double],null as[rate_retail_commission],
	  [created_timestamp] as create_date,replace([enabled_timestamp],'0001-01-01 00:00:00.000',null) as [enabled_timestamp],[created_by] from [ext_piclos].[mbi_cover_type]
union
select [id],[title],[is_enabled],18 as [insurance_product_id],null as dealer_group_id,null as dealer_id,null as [original_cover_type_id],null as [vehicle_category],null as max_age,
       null as min_kms , null as max_kms, null as [roadside_assist],null as [roadside_assist_max_term],null as [service_interval_petrol],null as[service_km_petrol],
	   null as [service_interval_diesel],null as [service_km_diesel],null as [service_interval_hybrid],null as [service_km_hybrid],null as [service_interval_electric],
	   null as[service_km_electric],null as [premium_funded],null as [is_flexible_term], null as [is_special_extended],  [gwp_account_code], [cancellation_account_code],
	   [claims_account_code], [has_road_side_assist], [term],[excess], [other_details],null as[please_note],null as[financial_rating],null as[acknowledgments],
	   null as[contact_details],null as[use_wholesale_premium],null as[rate_percentage_12],null as[rate_percentage_18],null as[rate_percentage_24],null as[rate_percentage_36],
	   null as[rate_percentage_48],null as[rate_percentage_60],null as[rate_double],null as[rate_retail_commission],null as create_date,
	   null as [enabled_timestamp],null as created_by
        from [ext_piclos].[posm_cover_type]
union
select [id],[title],[is_enabled],[insurance_product_id],null as dealer_group_id,[dealer_id],[original_cover_type_id],null as [vehicle_category],[max_age],[min_kms],
       [max_kms], null as [roadside_assist],null as [roadside_assist_max_term],null as [service_interval_petrol],null as[service_km_petrol],
	   null as [service_interval_diesel],null as [service_km_diesel],null as [service_interval_hybrid],null as [service_km_hybrid],null as [service_interval_electric],
	   null as[service_km_electric],null as [premium_funded],null as [is_flexible_term], null as [is_special_extended], null as[gwp_account_code], null as[cancellation_account_code],
	   null as [claims_account_code], null as [has_road_side_assist], null as [term],null as [excess],null as [other_details],null as [please_note],null as[financial_rating],null as[acknowledgments],
	   null as[contact_details],null as[use_wholesale_premium],null as[rate_percentage_12],null as[rate_percentage_18],null as[rate_percentage_24],null as[rate_percentage_36],
	   null as[rate_percentage_48],null as[rate_percentage_60],null as[rate_double],null as[rate_retail_commission],
	   [created_timestamp] as create_date,replace([enabled_timestamp],'0001-01-01 00:00:00.000',null) as [enabled_timestamp],[created_by] from [ext_piclos].[tar_cover_type]			
		
	) cover_type 
	join ext_piclos.insurance_product P
	on p.id = cover_type.[insurance_product_id]
	where cover_type.id not in (select cover_type_id from data.dim_cover_type where [record_current_flag] = 1  )

End
GO

