/****** Object:  StoredProcedure [sp_data].[populate_dim_dealer]    Script Date: 27/10/2021 1:50:20 pm ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [sp_data].[populate_dim_dealer]
AS
BEGIN
declare @end_date datetime ;
SET @end_date = (Select max(date_value) from data.dim_date);
	SET NOCOUNT ON;
	SET IDENTITY_INSERT data.[dim_dealer] ON
	INSERT INTO data.[dim_dealer]
		([dealer_key],[generic_cover_type_id],[dealer_specific_cover_type_id],[dealer_id],[dealer_group_id],[company_name],[registered_company_name],[registration_number]
      ,[gst_number],[manager_name],[physical_address_street_name],[physical_address_suburb_name],[physical_address_city],[physical_address_region_id],[physical_address_postcode]
      ,[postal_address_1],[postal_address_2],[postal_address_3],[postal_postcode],[phone_number],[fax_number],[accounts_receivable_email],[website_name],[dms_list],[primary_contact_firstname]
      ,[primary_contact_lastname],[primary_contact_email],[primary_contract_mobile],[primary_contact_guid],[secondary_contact_firstname],[secondary_contact_lastname],[secondary_contact_email]
      ,[secondary_contract_mobile],[secondary_contact_guid],[third_contact_firstname],[third_contact_lastname],[third_contact_email],[third_contract_mobile],[third_contact_guid],[dealer_disabled_flag]
      ,[dealer_active_flag],[dealer_created_date],[dealer_disabled_date],[has_signed_agency_agreement_flag],[has_signed_posm_agreement_flag],[has_posm_luxury_matrix_flag],[has_signed_incentive_agreement_flag]
      ,[dealer_closed_flag],[dealer_liquidated_flag],[dealer_to_competitor_flag],[dealer_disabled_status_description],[incentive_account_start_date],[incentive_account_end_date],[cci_wholesale_premium_flag]  
	 ,[cci_retail_premium_flag],[dd_invoice_flag],[automated_policy_creation_flag],[automated_motorcentral_flag],[motorcentral_account_code],[cci_18_month_flag],[policy_import_flag],[has_contract_no_flag]
      ,[cannot_apply_mbi_roadside_assist_flag],[has_prorata_calculator_mbi_refund_flag],[use_posm_annual_invoice_flag],[send_invoice_by_spreadsheet_flag],[mbi_motorcover_agreement_signed_flag]
      ,[has_giltrap_business_use_enabled_flag],[credit_union_flag],[provident_brand_disabled_flag],[default_brand_id],[rating_card_id],[source_system_last_updated_date],[crm_guid],[uses_epb_flag]
      ,[record_start_datetime],[record_end_datetime],[record_current_flag])
	SELECT -1,0,0,0,0,'N/A','N/A','N/A',
	        'N/A','N/A','N/A','N/A','N/A',0,'N/A',
			'N/A','N/A','N/A','N/A','N/A','N/A','N/A','N/A','N/A','N/A',
			 'N/A','N/A','N/A','N/A','N/A','N/A','N/A',
			 'N/A','N/A','N/A','N/A','N/A','N/A','N/A',0,
			 1,'19000101',@end_date,1,1,1,1,
			 0,0,0,'N/A','19000101',@end_date,1,
			 1,1,1,1,'N/A',1,1,1,
			 1,1,1,1,1,
			 1,1,1,0,0,'19000101','N/A',1,
			 '19000101',@end_date,1
	WHERE NOT EXISTS
	(SELECT dealer_key FROM  data.[dim_dealer] WHERE dealer_key = -1)
SET IDENTITY_INSERT  data.[dim_dealer] OFF

select * into #temp1  from
(SELECT [dealer_id],[cover_type_id]
  FROM [ext_piclos].[dealer_cci_cover_type]
  union all 
SELECT [dealer_id],[cover_type_id]
  FROM [ext_piclos].[dealer_gap_cover_type]
  union all 
SELECT [dealer_id],[cover_type_id]
  FROM [ext_piclos].[dealer_lnm_cover_type]
  union all 
SELECT [dealer_id],[cover_type_id]
  FROM [ext_piclos].[dealer_mbi_cover_type]
  union all 
SELECT [dealer_id],[cover_type_id]
  FROM [ext_piclos].[dealer_posm_cover_type]
  union all 
SELECT [dealer_id],[cover_type_id]
  FROM [ext_piclos].[dealer_tar_cover_type] ) generic_cover_id;

select * into #temp2  from
(SELECT [dealer_id],cci_cover_type_id as specific_cover_id
  FROM [ext_piclos].cci_cover_type_dealer
  union all 
SELECT [dealer_id],gap_cover_type_id as specific_cover_id
  FROM [ext_piclos].gap_cover_type_dealer
  union all 
SELECT [dealer_id],cover_type_id as specific_cover_id
  FROM [ext_piclos].dealer_lnm_cover_type
  union all 
SELECT [dealer_id],id as specific_cover_id
  FROM [ext_piclos].mbi_cover_type
  union all 
SELECT [dealer_id],posm_cover_type_id as specific_cover_id
  FROM [ext_piclos].posm_cover_type_dealer
  union all 
SELECT [dealer_id],id as specific_cover_id
  FROM [ext_piclos].tar_cover_type ) specific_cover_id;

    Select a.dealer_id as g_d_id,a.[cover_type_id] as generic_cover_id
  ,b.dealer_id as s_d_id , b.specific_cover_id into #temp3 
  from #temp1 a
  right join #temp2 b
  on a.dealer_id = b.dealer_id 
  and a.[cover_type_id] = b.specific_cover_id
  where a.dealer_id is null 
  order by a.dealer_id ,b.dealer_id;

  Select a.dealer_id as g_d_id,a.[cover_type_id] as generic_cover_id
  ,b.dealer_id as s_d_id , b.specific_cover_id into #temp4 
  from #temp1 a
  left join #temp2 b
  on a.dealer_id = b.dealer_id 
  and a.[cover_type_id] = b.specific_cover_id
  where b.dealer_id is null 
  order by a.dealer_id ,b.dealer_id;



  Select a.dealer_id as g_d_id,a.[cover_type_id] as generic_cover_id
  ,b.dealer_id as s_d_id , b.specific_cover_id into #temp5 
  from #temp1 a
   join #temp2 b
  on a.dealer_id = b.dealer_id 
  and a.[cover_type_id] = b.specific_cover_id 
  order by a.dealer_id ,b.dealer_id;


   select case when g_d_id is null then s_d_id else g_d_id end as dealer_id,
        generic_cover_id , specific_cover_id into #temp6 from 
 (
   select * from #temp3
  union
 select* from #temp4
 union
 select* from #temp5
 ) final


MERGE
	data.[dim_dealer] 
USING
	(
		Select d.*,isnull(t1.generic_cover_id,0) as generic_cover_id
		,isnull(t1.specific_cover_id,0) as specific_cover_id
		,isnull(dg.dealergroup_id,0) as dealergroup_id
		from [ext_piclos].dealer d
		left join #temp6 t1
		on d.id = t1.dealer_id 
		left join [ext_piclos].[dealer_dealer_group] dg
		on d.id = dg.dealer_id 
		

	) dealer
ON
	data.[dim_dealer].dealer_id = dealer.id
	and data.[dim_dealer].[generic_cover_type_id] = dealer.generic_cover_id
	and data.[dim_dealer].[dealer_specific_cover_type_id] = dealer.specific_cover_id
	and data.[dim_dealer].[dealer_group_id] = dealer.dealergroup_id
	and data.[dim_dealer].is_deleted = 0 
	and data.[dim_dealer].[record_current_flag] = 1 
WHEN NOT MATCHED BY TARGET THEN
	INSERT
		(
			 [generic_cover_type_id],[dealer_specific_cover_type_id],[dealer_id],[dealer_group_id],[company_name],[registered_company_name],[registration_number]
      ,[gst_number],[manager_name],[physical_address_street_name],[physical_address_suburb_name],[physical_address_city],[physical_address_region_id],[physical_address_postcode]
      ,[postal_address_1],[postal_address_2],[postal_address_3],[postal_postcode],[phone_number],[fax_number],[accounts_receivable_email],[website_name],[dms_list],[primary_contact_firstname]
      ,[primary_contact_lastname],[primary_contact_email],[primary_contract_mobile],[primary_contact_guid],[secondary_contact_firstname],[secondary_contact_lastname],[secondary_contact_email]
      ,[secondary_contract_mobile],[secondary_contact_guid],[third_contact_firstname],[third_contact_lastname],[third_contact_email],[third_contract_mobile],[third_contact_guid],[dealer_disabled_flag]
	  ,[dealer_active_flag],[dealer_created_date],[dealer_disabled_date],[has_signed_agency_agreement_flag],[has_signed_posm_agreement_flag],[has_posm_luxury_matrix_flag],[has_signed_incentive_agreement_flag]
      ,[dealer_closed_flag],[dealer_liquidated_flag],[dealer_to_competitor_flag],[dealer_disabled_status_description],[incentive_account_start_date],[incentive_account_end_date],[cci_wholesale_premium_flag]
      ,[cci_retail_premium_flag],[dd_invoice_flag],[automated_policy_creation_flag],[automated_motorcentral_flag],[motorcentral_account_code],[cci_18_month_flag],[policy_import_flag],[has_contract_no_flag]
      ,[cannot_apply_mbi_roadside_assist_flag],[has_prorata_calculator_mbi_refund_flag],[use_posm_annual_invoice_flag],[send_invoice_by_spreadsheet_flag],[mbi_motorcover_agreement_signed_flag]
      ,[has_giltrap_business_use_enabled_flag],[credit_union_flag],[provident_brand_disabled_flag],[default_brand_id],[rating_card_id],[source_system_last_updated_date],[crm_guid],[uses_epb_flag]
	  ,[record_end_datetime]
		)
	VALUES
		(
	   generic_cover_id,specific_cover_id,[id],dealergroup_id,[company_name],[registered_company_name],[registration_number],
	   [gst_number],[manager_name],[street],[suburb],[city],[region_id],[postcode],
	   [postal_address_1],[postal_address_2],[postal_address_3],[postal_postcode],[phone],[fax],[accounts_receivable_email],[website],[dms_list],[contact_firstname_1],
	   [contact_lastname_1],[email_1],[mobile_1],[contact_guid_1],[contact_firstname_2],[contact_lastname_2],[email_2],
	   [mobile_2],[contact_guid_2],[contact_firstname_3],[contact_lastname_3],[email_3],[mobile_3],[contact_guid_3],[is_disabled],
       [is_active],[created_date],case when [disabled_date] = '0001-01-01 00:00:00.000' then null else [disabled_date] end ,[has_signed_agency_agreement],[has_signed_posm_agreement],[has_posm_luxury_matrix],[has_signed_incentive_agreement],
	   [dealer_closed],[dealer_liquidated],[dealer_to_competitor],[dealer_status_reason],case when [incentive_account_start_date] = '0001-01-01 00:00:00.000' then null else [incentive_account_start_date] end,
	   case when [incentive_account_end_date] = '0001-01-01 00:00:00.000' then null else [incentive_account_end_date] END,[use_wholesale_premium],
	   [use_cci_retail_premium],[use_dd_invoice],[automated_policy_creation],[automated_motorcentral],[motorcentral_account_code],[cci_18_month_term],[policy_import],[use_contract_no],
	   [not_has_mbi_roadside_assist],[has_mbi_refund_prorata],[use_posm_annual_invoice],[use_invoice_by_spreadsheet],[mbi_motorcover_agreement],
	   [has_business_use],[is_credit_union],[provident_brand_disabled],[default_brand_id],[rating_card_id],[last_updated],[crm_guid],[uses_epb]
	  ,@end_date
	  
			
			
		)

WHEN MATCHED and
   data.[dim_dealer].[source_system_last_updated_date] <> dealer.[last_updated]


THEN 
UPDATE SET data.[dim_dealer].[record_end_datetime] = getdate() AT TIME ZONE 'UTC' AT TIME ZONE 'New Zealand Standard Time',
data.[dim_dealer].[record_current_flag] = 0,
data.[dim_dealer].last_updated = getdate() AT TIME ZONE 'UTC' AT TIME ZONE 'New Zealand Standard Time'


WHEN NOT MATCHED BY SOURCE AND data.[dim_dealer].dealer_key <> -1 and [record_current_flag] = 1 THEN 
UPDATE SET data.[dim_dealer].is_deleted = 1,
data.[dim_dealer].[record_end_datetime] = getdate() AT TIME ZONE 'UTC' AT TIME ZONE 'New Zealand Standard Time',
data.[dim_dealer].[record_current_flag] = 0;

INSERT into data.dim_dealer 
		(
			  [generic_cover_type_id],[dealer_specific_cover_type_id],[dealer_id],[dealer_group_id],[company_name],[registered_company_name],[registration_number]
      ,[gst_number],[manager_name],[physical_address_street_name],[physical_address_suburb_name],[physical_address_city],[physical_address_region_id],[physical_address_postcode]
      ,[postal_address_1],[postal_address_2],[postal_address_3],[postal_postcode],[phone_number],[fax_number],[accounts_receivable_email],[website_name],[dms_list],[primary_contact_firstname]
      ,[primary_contact_lastname],[primary_contact_email],[primary_contract_mobile],[primary_contact_guid],[secondary_contact_firstname],[secondary_contact_lastname],[secondary_contact_email]
      ,[secondary_contract_mobile],[secondary_contact_guid],[third_contact_firstname],[third_contact_lastname],[third_contact_email],[third_contract_mobile],[third_contact_guid],[dealer_disabled_flag]
	  ,[dealer_active_flag],[dealer_created_date],[dealer_disabled_date],[has_signed_agency_agreement_flag],[has_signed_posm_agreement_flag],[has_posm_luxury_matrix_flag],[has_signed_incentive_agreement_flag]
      ,[dealer_closed_flag],[dealer_liquidated_flag],[dealer_to_competitor_flag],[dealer_disabled_status_description],[incentive_account_start_date],[incentive_account_end_date],[cci_wholesale_premium_flag]
      ,[cci_retail_premium_flag],[dd_invoice_flag],[automated_policy_creation_flag],[automated_motorcentral_flag],[motorcentral_account_code],[cci_18_month_flag],[policy_import_flag],[has_contract_no_flag]
      ,[cannot_apply_mbi_roadside_assist_flag],[has_prorata_calculator_mbi_refund_flag],[use_posm_annual_invoice_flag],[send_invoice_by_spreadsheet_flag],[mbi_motorcover_agreement_signed_flag]
      ,[has_giltrap_business_use_enabled_flag],[credit_union_flag],[provident_brand_disabled_flag],[default_brand_id],[rating_card_id],[source_system_last_updated_date],[crm_guid],[uses_epb_flag]
	  ,[record_end_datetime]
		)
	
       Select a.* from ( Select isnull(generic_cover_id,0) as generic_cover_id ,isnull(specific_cover_id,0) as specific_cover_id ,[id],isnull(dealergroup_id,0) as dealergroup_id,[company_name],[registered_company_name],[registration_number],
	   [gst_number],[manager_name],[street],[suburb],[city],[region_id],[postcode],
	   [postal_address_1],[postal_address_2],[postal_address_3],[postal_postcode],[phone],[fax],[accounts_receivable_email],[website],[dms_list],[contact_firstname_1],
	   [contact_lastname_1],[email_1],[mobile_1],[contact_guid_1],[contact_firstname_2],[contact_lastname_2],[email_2],
	   [mobile_2],[contact_guid_2],[contact_firstname_3],[contact_lastname_3],[email_3],[mobile_3],[contact_guid_3],[is_disabled],
       [is_active],[created_date],case when [disabled_date] = '0001-01-01 00:00:00.000' then null else [disabled_date] end as [disabled_date],[has_signed_agency_agreement],[has_signed_posm_agreement],[has_posm_luxury_matrix],[has_signed_incentive_agreement],
	   [dealer_closed],[dealer_liquidated],[dealer_to_competitor],[dealer_status_reason],case when [incentive_account_start_date] = '0001-01-01 00:00:00.000' then null else [incentive_account_start_date] end as [incentive_account_start_date],
	   case when [incentive_account_end_date] = '0001-01-01 00:00:00.000' then null else [incentive_account_end_date] END as [incentive_account_end_date] ,[use_wholesale_premium],
	   [use_cci_retail_premium],[use_dd_invoice],[automated_policy_creation],[automated_motorcentral],[motorcentral_account_code],[cci_18_month_term],[policy_import],[use_contract_no],
	   [not_has_mbi_roadside_assist],[has_mbi_refund_prorata],[use_posm_annual_invoice],[use_invoice_by_spreadsheet],[mbi_motorcover_agreement],
	   [has_business_use],[is_credit_union],[provident_brand_disabled],[default_brand_id],[rating_card_id],[last_updated],[crm_guid],[uses_epb],
	   @end_date as [record_end_datetime]
		from [ext_piclos].dealer d
		left join #temp6 t1
		on d.id = t1.dealer_id 
		left join [ext_piclos].[dealer_dealer_group] dg
		on d.id = dg.dealer_id ) a 
	left join data.dim_dealer de 
	on a.[id] = de.dealer_id
	and a.generic_cover_id = de.[generic_cover_type_id]
	and a.specific_cover_id = de.[dealer_specific_cover_type_id]
	and a.dealergroup_id = de.dealer_group_id
	and de.[record_current_flag] = 1  and de.is_deleted = 0
	where de.dealer_id  is null 


End
GO


