/****** Object:  StoredProcedure [sp_data].[populate_dim_policy]    Script Date: 12/11/2021 7:58:20 am ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [sp_data].[populate_dim_policy]
AS
BEGIN
declare @end_date datetime ;
SET @end_date = (Select max(date_value) from data.dim_date);
	SET NOCOUNT ON;
	SET IDENTITY_INSERT data.dim_policy ON
INSERT [Data].[dim_policy] ([policy_key],[policy_id],[policy_number],[product_code],[quote_id],[cover_type_id],[cover_type_name],[cover_option_dealer_specific_flag],[cover_option_id],[cover_option_description],[dealer_id],[dealer_user_id]
      ,[dealer_name],[dealer_sales_rep_name],[dealer_rep_code],[dealer_deactivated_flag],[dealer_retail_premium_amount],[dealer_incentive_amount],[rating_card_id],[brand_id],[brand_name],[branch_id],[branch_name]
	  ,[insurance_product_id],[policy_status_code],[insurance_refused_flag],[insurance_refused_details],[refund_amount],[refund_by_wholesale_premium_flag],[refund_datetime],[payment_type_description],[payment_frequency_code]
      ,[payment_reference_number],[dob_1],[dob_2],[primary_driver_accident_free_years],[primary_driver_gender_code],[product_name],[policy_purchase_datetime],[invoiced_datetime],[policy_valid_from_date],[policy_valid_to_date]
      ,[policy_term_in_months],[retail_premium_over_policy_term_amount],[retail_premium_annual_amount],[retail_premium_monthly_amount],[retail_premium_fortnightly_amount],[retail_premium_weekly_amount],[retail_premium_amount]
      ,[retail_premium_incl_gst_amount],[wholesale_premium_over_term_amount],[wholesale_premium_amount],[premium_term_in_months],[premium_amount],[premium_with_gst_amount],[premium_with_gst_payable_amount],[loading_over_policy_term_amount]
      ,[loading_amount],[loading_amount_percent],[additional_risk_premium_amount],[gst_amount],[gst_base_rate_amount],[dps_convenience_fee_amount],[fire_service_levy_amount],[fire_service_levy_base_rate_amount]
	  ,[fire_service_levy_with_gst_payable_amount] ,[life_insurance_fee_amount],[life_insurance_fee_base_rate_percentage],[road_side_assist_fee_amount],[has_road_side_assist_flag],[roadside_assist_amount],[is_roadside_assist_flag]
      ,[roadside_assist_end_datetime],[roadside_assist_original_end_date],[roadside_assist_duration_in_months],[nzra_live_flag],[claim_limit_amount],[roadside_breakdown_notes],[previous_vehicle_insurance_flag]
      ,[other_insurance_with_us_flag],[other_insurance_with_us_details],[sum_insured_amount],[interested_parties_id],[interested_parties_name],[excess_amount],[wind_screen_excess_amount],[under_age21_excess_amount]
      ,[age_21to25_excess_amount],[standard_excess_amount],[mandatory_excess_amount],[excess_optional_id],[excess_optional_amount],[overseas_license_excess_amount],[learners_license_excess_amount],[additional_excess_amount]
      ,[no_claims_modifier_percentage],[max_payable_loss_use_amount],[named_driver_flag],[exclude_under_age25_flag],[accident_flag],[accident_details],[stolen_burnt_flag],[stolen_burnt_details],[underwriting_status]
      ,[underwriting_reason],[underwriting_comments],[duty_of_disclosure_notes],[driving_offence_flag],[driving_offence_details],[licence_cancelled_flag],[licence_cancelled_details],[non_private_use_flag],[non_private_use_details]
      ,[vehicle_modified_flag],[vehicle_modification_details],[claim_withdrawn_flag],[claim_withdrawn_details],[conviction_flag],[conviction_details],[criminal_activity_flag],[criminal_activity_details],[vehicle_owned_by_other_flag]
      ,[vehicle_owned_by_other_details],[other_factors_flag],[other_factors_details],[information_complete_flag],[information_complete_details],[privacy_claims_register_agree_flag],[privacy_disclose_information_agree_flag]
      ,[privacy_obtain_information_agree_flag],[vehicle_location_street],[vehicle_location_suburb],[vehicle_location_city],[vehicle_location_postcode],[vehicle_intended_use_business_flag],[vehicle_kept_region_id]
      ,[vehicle_kept_description],[vehicle_kept_city],[vehicle_kept_suburb],[vehicle_kept_address],[vehicle_has_alarm_flag],[vehicle_has_immobiliser_flag],[vehicle_modifications_description],[vehicle_mod_body_kit_flag]
      ,[vehicle_mod_decoration_flag],[vehicle_mod_engine_flag],[vehicle_mod_exhaust_flag],[vehicle_mod_gauges_flag],[vehicle_mod_glass_flag],[vehicle_mod_suspension_flag],[vehicle_mod_mags_amount],[vehicle_mod_stereo_amount]
      ,[vehicle_mod_other_amount],[pmvs_commission_variable_amount],[pmvs_commission_fixed_amount],[declaration_notes],[xml_seq_number],[is_renewal_flag],[renewal_pending_flag],[is_marsh_renewal_flag],[marsh_id]
	  ,[posm_annual_invoice_flag],[contract_number],[contract_date],[legacy_policy_number],[pmvs_policy_id],[parent_policy_id],[child_policy_id],[policy_type_id],[policy_notes],[policy_holder_licence_type_flag]    
	 ,[policy_holder_has_licence_suspended_flag],[policy_holder_has_previous_claims_flag],[policy_holder_has_vehicle_loss_flag] ,[policy_holder_has_driving_offences_flag],[policy_holder_has_criminal_offence_flag],[policy_holder_has_criminal_offence_bankrupt_flag]
      ,[policy_holder_has_criminal_offence_prosecution_flag],[policy_holder_has_criminal_offence_convicted_flag],[policy_booklet_version],[policy_booklet_name],[is_policy_disabled_flag],[responsible_lending_terms_acknowledge_flag]
      ,[auto_expired_datetime],[cancelled_datetime],[deactivated_datetime],[insurance_type_code],[e_delivery_pref_code],[send_edocs_now_flag],[sent_to_ecm_flag],[created_by_wholesale_premium_flag],[financier_name]
      ,[financed_amount],[balance_payable_amount],[financed_from_datetime],[finance_term_in_months],[monthly_installments_amount],[balloon_payments_notes],[underwriting_premium_amount],[additional_notes],[financial_rating_notes]
      ,[acknowledgment_notes],[other_details],[policy_event_coverage_causes],[alert_backdated_flag],[gap_amount],[special_benefits_amount],[financier_id],[legacy_soi_number],[request_approval_flag],[policyholder_benefit_id]
      ,[loan_number],[which_insured_flag],[new_loan_type_id],[loan_balance_amount],[loan_total_amount],[other_outstanding_loans_flag],[balance_already_covered_amount],[excess_id],[claim_limit_tyres_amount],[claim_limit_rims_amount]
      ,[dispensations_notes],[original_duration_in_months],[original_excess_amount],[original_premium_amount],[original_claim_limit_amount],[original_claim_limit_tyres_amount],[original_claim_limit_rims_amount],[adhoc_set_flag]
      ,[adhoc_dispensation_notes],[adhoc_modified_by_user_id],[adhoc_modified_datetime],[is_transferred_flag],[latest_transfer_id],[premium_funded_flag],[payment_instalment_amount],[recurring_schedule_payment_number]
      ,[recurring_schedule_number_of_months],[payment_total_amount],[commission_code],[commission_rate],[commission_total_amount],[commission_report_file_dump_date],[is_special_extended_cover_flag],[promotion_id],[last_updated_date]
      ,[record_start_datetime], [record_end_datetime], [record_current_flag])
SELECT -1, 0, N'N/A', N'N/A', 0, 0, N'N/A', NULL, NULL, NULL, 0, 0, N'N/A', N'N/A', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, N'N/A', NULL, NULL, NULL, NULL, NULL
, N'N/A', N'N/A', N'N/A', NULL, NULL, NULL, NULL, N'N/A', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL
, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
, CAST(N'1900-01-01T00:00:00.000' AS DateTime), @end_date, 1
	WHERE NOT EXISTS
	(SELECT [policy_key] FROM  data.dim_policy WHERE [policy_key] = -1)
SET IDENTITY_INSERT  data.dim_policy OFF


select * into #policy from (select 
      id,convert(varchar(255), id) as [policy_number],null  as gap_vehicle_insurer_policy_number,'cci' as [product_code],null as [quote_id],[cover_type_id],[cover_type_name],null as [cover_option_dealer_specific_flag],null as [cover_option_id],null as [cover_option_description]
	  ,[dealer_id],[dealer_user_id],[dealer_name],[dealer_sales_rep] as [dealer_sales_rep_name],[dealer_rep_code],cast([dealer_deactivated] as int )as [dealer_deactivated_flag],null as [dealer_retail_premium_amount],null as [dealer_incentive_amount]
      ,null as [rating_card_id],[brand_id],[brand_name],null as [branch_id],null as [branch_name],[insurance_product_id],[status] as [policy_status_code],null as [insurance_refused_flag],null as [insurance_refused_details]
	  ,[refund] as [refund_amount],cast([refund_by_wholesale_premium] as int) as [refund_by_wholesale_premium_flag],case when [refund_timestamp] < '1900-01-01 00:00:00' then null else [refund_timestamp] end as [refund_datetime],null as [payment_type_description],null as [payment_frequency_code]
	  ,null as [payment_reference_number],case when [dob_1] < '1900-01-01' then null else [dob_1] end as [dob_1],case when [dob_2] = '0001-01-01' then null else [dob_2] end as [dob_2],null as [primary_driver_accident_free_years],null as [primary_driver_gender_code],[product_name],case when [purchase_timestamp] < '1900-01-01 00:00:00' then null else [purchase_timestamp] end as [policy_purchase_datetime]
      ,case when [invoiced_timestamp] < '1900-01-01 00:00:00' then null else [invoiced_timestamp] end as [invoiced_datetime], case when [from_timestamp] < '1900-01-01 00:00:00' then null else [from_timestamp] end as [policy_valid_from_date]
	  ,case when [to_timestamp] < '1900-01-01 00:00:00' then null else [to_timestamp] end as [policy_valid_to_date],[term] as [policy_term_in_months],null as [retail_premium_over_policy_term_amount]

	  ,null as [retail_premium_annual_amount],null as [retail_premium_monthly_amount],null as [retail_premium_fortnightly_amount],null as [retail_premium_weekly_amount],[retail_premium] as [retail_premium_amount]
      ,[retail_premium_incl_gst] as [retail_premium_incl_gst_amount],null as [wholesale_premium_over_term_amount],null as [wholesale_premium_amount],[premium_term] as [premium_term_in_months],[premium] as [premium_amount]
      ,null as [premium_with_gst_amount],null as [premium_with_gst_payable_amount],null as [loading_over_policy_term_amount],null as [loading_amount],null as [loading_amount_percent],null as [additional_risk_premium_amount]
      ,null as [gst_amount],null as [gst_base_rate_amount],null as [dps_convenience_fee_amount],null as [fire_service_levy_amount],null as [fire_service_levy_base_rate_amount],null as [fire_service_levy_with_gst_payable_amount] 
	  ,null as [life_insurance_fee_amount],null as [life_insurance_fee_base_rate_percentage],null as [road_side_assist_fee_amount],null as [has_road_side_assist_flag],null as [roadside_assist_amount],null as [is_roadside_assist_flag]
      ,null as [roadside_assist_end_datetime],null as [roadside_assist_original_end_date],null as [roadside_assist_duration_in_months],null as [nzra_live_flag],null as [claim_limit_amount],null as [roadside_breakdown_notes]
	  ,null as [previous_vehicle_insurance_flag],null as [other_insurance_with_us_flag],null as [other_insurance_with_us_details],null as [sum_insured_amount],null as [interested_parties_id],null as [interested_parties_name]
      ,null as [excess_amount],null as [wind_screen_excess_amount],null as [under_age21_excess_amount],null as [age_21to25_excess_amount],null as [standard_excess_amount],null as [mandatory_excess_amount],null as [excess_optional_id]
      ,null as [excess_optional_amount],null as [overseas_license_excess_amount],null as [learners_license_excess_amount],null as [additional_excess_amount],null as [no_claims_modifier_percentage],null as [max_payable_loss_use_amount]
      ,null as [named_driver_flag],null as [exclude_under_age25_flag],null as [accident_flag],null as [accident_details],null as [stolen_burnt_flag],null as [stolen_burnt_details],null as [underwriting_status]
      ,null as [underwriting_reason],null as [underwriting_comments],null as [duty_of_disclosure_notes],null as [driving_offence_flag],null as [driving_offence_details],null as [licence_cancelled_flag]
	  ,null as [licence_cancelled_details],null as [non_private_use_flag],null as [non_private_use_details],null as [vehicle_modified_flag],null as [vehicle_modification_details],null as [claim_withdrawn_flag]
	  ,null as [claim_withdrawn_details],null as [conviction_flag],null as [conviction_details],null as [criminal_activity_flag],null as [criminal_activity_details],null as [vehicle_owned_by_other_flag]
      ,null as [vehicle_owned_by_other_details],null as [other_factors_flag],null as [other_factors_details],null as [information_complete_flag],null as [information_complete_details],null as [privacy_claims_register_agree_flag]
	  ,null as [privacy_disclose_information_agree_flag],null as [privacy_obtain_information_agree_flag],null as [vehicle_location_street],null as [vehicle_location_suburb],null as [vehicle_location_city]
	  ,null as [vehicle_location_postcode],null as [vehicle_intended_use_business_flag],null as [vehicle_kept_region_id],null as [vehicle_kept_description],null as [vehicle_kept_city],null as [vehicle_kept_suburb]
      ,null as [vehicle_kept_address],null as [vehicle_has_alarm_flag],null as [vehicle_has_immobiliser_flag],null as [vehicle_modifications_description],null as [vehicle_mod_body_kit_flag]
      ,null as [vehicle_mod_decoration_flag],null as [vehicle_mod_engine_flag],null as [vehicle_mod_exhaust_flag],null as [vehicle_mod_gauges_flag],null as [vehicle_mod_glass_flag],null as [vehicle_mod_suspension_flag]
	  ,null as [vehicle_mod_mags_amount],null as [vehicle_mod_stereo_amount],null as [vehicle_mod_other_amount],null as [pmvs_commission_variable_amount],null as [pmvs_commission_fixed_amount],null as [declaration_notes]
      ,null as [xml_seq_number],null as [is_renewal_flag],null as [renewal_pending_flag],null as [is_marsh_renewal_flag],null as [marsh_id],null as [posm_annual_invoice_flag],[contract_no] as [contract_number],null as [contract_date]
	  ,null as [legacy_policy_number],null as [pmvs_policy_id],null as [parent_policy_id],null as [child_policy_id],null as [policy_type_id],null as [policy_notes],null as [policy_holder_licence_type_flag]
	 
	  ,null as [policy_holder_has_licence_suspended_flag],null as [policy_holder_has_previous_claims_flag],null as [policy_holder_has_vehicle_loss_flag] ,null as [policy_holder_has_driving_offences_flag],null as [policy_holder_has_criminal_offence_flag]
	  ,null as [policy_holder_has_criminal_offence_bankrupt_flag],null as [policy_holder_has_criminal_offence_prosecution_flag],null as [policy_holder_has_criminal_offence_convicted_flag],[policy_booklet_version],[policy_booklet_name]
	  ,[is_disabled] as [is_policy_disabled_flag],cast([responsible_lending_terms_acknowledge] as int) as [responsible_lending_terms_acknowledge_flag],case when [auto_expired_timestamp] < '1900-01-01 00:00:00' then null else [auto_expired_timestamp] end as [auto_expired_datetime],null as [cancelled_datetime]
      ,case when [deactivated_timestamp] < '1900-01-01 00:00:00' then null else [deactivated_timestamp] end as [deactivated_datetime],[insurance_type] as [insurance_type_code],[e_delivery_pref] as [e_delivery_pref_code]
	  ,cast([send_edocs_now] as int) as [send_edocs_now_flag],cast([sent_to_ecm] as int) as [sent_to_ecm_flag]
	  ,cast ([created_by_wholesale_premium] as int) as [created_by_wholesale_premium_flag],[financier] as [financier_name],[amount_financed] as [financed_amount],[balance_payable] as [balance_payable_amount]
	  ,case when [finance_from_timestamp] < '1900-01-01 00:00:00' then null else [finance_from_timestamp] end as[financed_from_datetime],[finance_term] as [finance_term_in_months],[monthly_installments] as [monthly_installments_amount],[balloon_payments] as [balloon_payments_notes]
	  ,[underwriting_premium] as [underwriting_premium_amount], [please_note] as [additional_notes],[financial_rating] as [financial_rating_notes],[acknowledgments] as [acknowledgment_notes],[other_details] as [other_details]
      ,[causes] as [policy_event_coverage_causes],cast([alert_backdated] as int) as [alert_backdated_flag],null as [gap_amount],null as [special_benefits_amount],null as [financier_id],null as [legacy_soi_number]
	  ,null as [request_approval_flag],null as [policyholder_benefit_id],null as [loan_number],null as [which_insured_flag],null as [new_loan_type_id],null as [loan_balance_amount],null as [loan_total_amount]
	  ,null as [other_outstanding_loans_flag],null as [balance_already_covered_amount],null as [excess_id],null as [claim_limit_tyres_amount],null as [claim_limit_rims_amount],null as [dispensations_notes]
      ,null as [original_duration_in_months],null as [original_excess_amount],null as [original_premium_amount],null as [original_claim_limit_amount],null as [original_claim_limit_tyres_amount],null as [original_claim_limit_rims_amount]
	  ,null as [adhoc_set_flag],null as [adhoc_dispensation_notes],null as [adhoc_modified_by_user_id],null as [adhoc_modified_datetime],null as [is_transferred_flag],null as [latest_transfer_id],null as [premium_funded_flag]
	  ,null as [payment_instalment_amount],null as [recurring_schedule_payment_number],null as [recurring_schedule_number_of_months],null as [payment_total_amount],null as [commission_code],null as [commission_rate]
      ,null as [commission_total_amount],null as [commission_report_file_dump_date],null as [is_special_extended_cover_flag],null as [promotion_id],[last_updated] as [last_updated_date] 
from ext_piclos.cci_policy

union 
select 
      ext_piclos.gap_policy.id,convert(varchar(255), ext_piclos.gap_policy.id) as [policy_number], policy_number as gap_vehicle_insurer_policy_number ,'gap' as [product_code],null as [quote_id],[cover_type_id],ext_piclos.gap_cover_type.title as [cover_type_name],CAST([cover_option_dealer_specific] as int) as [cover_option_dealer_specific_flag], [cover_option_id]
	  ,[cover_option_title] as [cover_option_description],[dealer_id],[dealer_user_id],[dealer_name],[dealer_sales_rep] as [dealer_sales_rep_name],[dealer_rep_code],cast([dealer_deactivated] as int ) as [dealer_deactivated_flag]
	  ,[dealer_retail_premium]as [dealer_retail_premium_amount],null as [dealer_incentive_amount],null as [rating_card_id],[brand_id],[brand_name],null as [branch_id],null as [branch_name],ext_piclos.gap_policy.[insurance_product_id]
      ,[status] as [policy_status_code],null as [insurance_refused_flag],null as [insurance_refused_details],[refund] as [refund_amount],null as [refund_by_wholesale_premium_flag],case when [refund_timestamp] < '1900-01-01 00:00:00' then null else [refund_timestamp] end as [refund_datetime]
	  ,null as [payment_type_description],null as [payment_frequency_code],null as [payment_reference_number],case when [dob_1] < '1900-01-01' then null else [dob_1] end as [dob_1]
	  ,case when [dob_2] = '0001-01-01' then null else [dob_2] end as [dob_2],null as [primary_driver_accident_free_years],null as [primary_driver_gender_code]
	  ,[product_name],case when [purchase_timestamp] < '1900-01-01 00:00:00' then null else [purchase_timestamp] end as [policy_purchase_datetime]
	  ,case when [invoiced_timestamp] < '1900-01-01 00:00:00' then null else [invoiced_timestamp] end as [invoiced_datetime]
	  ,case when [from_timestamp] < '1900-01-01 00:00:00' then null else [from_timestamp] end as [policy_valid_from_date],case when [to_timestamp] < '1900-01-01 00:00:00' then null else [to_timestamp] end as [policy_valid_to_date]
	  ,[term] as [policy_term_in_months],null as [retail_premium_over_policy_term_amount],null as [retail_premium_annual_amount],null as [retail_premium_monthly_amount],null as [retail_premium_fortnightly_amount]
      ,null as [retail_premium_weekly_amount],null as [retail_premium_amount],null as [retail_premium_incl_gst_amount],null as [wholesale_premium_over_term_amount],null as [wholesale_premium_amount],null as [premium_term_in_months]
      ,[premium] as [premium_amount],null as [premium_with_gst_amount],null as [premium_with_gst_payable_amount],null as [loading_over_policy_term_amount],null as [loading_amount],null as [loading_amount_percent]
      ,null as [additional_risk_premium_amount],null as [gst_amount],null as [gst_base_rate_amount],null as [dps_convenience_fee_amount],null as [fire_service_levy_amount],null as [fire_service_levy_base_rate_amount]
	  ,null as [fire_service_levy_with_gst_payable_amount] ,null as [life_insurance_fee_amount],null as [life_insurance_fee_base_rate_percentage],null as [road_side_assist_fee_amount],null as [has_road_side_assist_flag]
	  ,null as [roadside_assist_amount],null as [is_roadside_assist_flag],null as [roadside_assist_end_datetime],null as [roadside_assist_original_end_date],null as [roadside_assist_duration_in_months],null as [nzra_live_flag]
      ,null as [claim_limit_amount],null as [roadside_breakdown_notes],null as [previous_vehicle_insurance_flag],null as [other_insurance_with_us_flag],null as [other_insurance_with_us_details],[sum_insured] as [sum_insured_amount]	  
	  ,null as [interested_parties_id],null as [interested_parties_name],null as [excess_amount],null as [wind_screen_excess_amount],null as [under_age21_excess_amount],null as [age_21to25_excess_amount],null as [standard_excess_amount]
      ,null as [mandatory_excess_amount],null as [excess_optional_id],null as [excess_optional_amount],null as [overseas_license_excess_amount],null as [learners_license_excess_amount],null as [additional_excess_amount]
      ,null as [no_claims_modifier_percentage],null as [max_payable_loss_use_amount],null as [named_driver_flag],null as [exclude_under_age25_flag],null as [accident_flag],null as [accident_details],null as [stolen_burnt_flag]
	  ,null as [stolen_burnt_details],null as [underwriting_status],null as [underwriting_reason],null as [underwriting_comments],null as [duty_of_disclosure_notes],null as [driving_offence_flag],null as [driving_offence_details]
	  ,null as [licence_cancelled_flag],null as [licence_cancelled_details],null as [non_private_use_flag],null as [non_private_use_details],null as [vehicle_modified_flag],null as [vehicle_modification_details]
      ,null as [claim_withdrawn_flag],null as [claim_withdrawn_details],null as [conviction_flag],null as [conviction_details],null as [criminal_activity_flag],null as [criminal_activity_details],null as [vehicle_owned_by_other_flag]
      ,null as [vehicle_owned_by_other_details],null as [other_factors_flag],null as [other_factors_details],null as [information_complete_flag],null as [information_complete_details],null as [privacy_claims_register_agree_flag]
	  ,null as [privacy_disclose_information_agree_flag],null as [privacy_obtain_information_agree_flag],null as [vehicle_location_street],null as [vehicle_location_suburb],null as [vehicle_location_city]
	  ,null as [vehicle_location_postcode],null as [vehicle_intended_use_business_flag],null as [vehicle_kept_region_id],null as [vehicle_kept_description],null as [vehicle_kept_city],null as [vehicle_kept_suburb]
      ,null as [vehicle_kept_address],null as [vehicle_has_alarm_flag],null as [vehicle_has_immobiliser_flag],null as [vehicle_modifications_description],null as [vehicle_mod_body_kit_flag],null as [vehicle_mod_decoration_flag]
      ,null as [vehicle_mod_engine_flag],null as [vehicle_mod_exhaust_flag],null as [vehicle_mod_gauges_flag],null as [vehicle_mod_glass_flag],null as [vehicle_mod_suspension_flag],null as [vehicle_mod_mags_amount]
	  ,null as [vehicle_mod_stereo_amount],null as [vehicle_mod_other_amount],null as [pmvs_commission_variable_amount],null as [pmvs_commission_fixed_amount],null as [declaration_notes],null as [xml_seq_number]
      ,null as [is_renewal_flag],null as [renewal_pending_flag],null as [is_marsh_renewal_flag],null as [marsh_id],null as [posm_annual_invoice_flag],[contract_no] as [contract_number],null as [contract_date]
	
	,null as [legacy_policy_number],null as [pmvs_policy_id],null as [parent_policy_id],null as [child_policy_id],null as [policy_type_id],null as [policy_notes],null as [policy_holder_licence_type_flag]
      ,null as [policy_holder_has_licence_suspended_flag],null as [policy_holder_has_previous_claims_flag],null as [policy_holder_has_vehicle_loss_flag] ,null as [policy_holder_has_driving_offences_flag],null as [policy_holder_has_criminal_offence_flag]
	  ,null as [policy_holder_has_criminal_offence_bankrupt_flag],null as [policy_holder_has_criminal_offence_prosecution_flag],null as [policy_holder_has_criminal_offence_convicted_flag],[policy_booklet_version],[policy_booklet_name]
	  ,[is_disabled] as [is_policy_disabled_flag],cast([responsible_lending_terms_acknowledge] as int) as [responsible_lending_terms_acknowledge_flag],case when [auto_expired_timestamp] < '1900-01-01 00:00:00' then null else [auto_expired_timestamp] end as [auto_expired_datetime]
	  ,null as [cancelled_datetime]
	  ,case when [deactivated_timestamp] < '1900-01-01 00:00:00' then null else [deactivated_timestamp] end as [deactivated_datetime],null as [insurance_type_code],[e_delivery_pref] as [e_delivery_pref_code]
	  ,cast([send_edocs_now] as int) as [send_edocs_now_flag],cast([sent_to_ecm] as int) as [sent_to_ecm_flag]
	  ,null as [created_by_wholesale_premium_flag],[financier] as [financier_name],[amount_financed] as [financed_amount],[balance_payable] as [balance_payable_amount],case when [finance_from_timestamp] < '1900-01-01 00:00:00' then null else [finance_from_timestamp] end as[financed_from_datetime]
      ,[finance_term] as [finance_term_in_months],null as [monthly_installments_amount],[balloon_payments] as [balloon_payments_notes],[underwriting_premium] as [underwriting_premium_amount],ext_piclos.gap_policy.[please_note] as [additional_notes]
	  ,ext_piclos.gap_policy.[financial_rating] as [financial_rating_notes],ext_piclos.gap_policy.[acknowledgments] as [acknowledgment_notes],ext_piclos.gap_policy.[other_details] as [other_details],null as [policy_event_coverage_causes],cast([alert_backdated] as int) as [alert_backdated_flag], [gap_amount]
      ,[special_benefits] as [special_benefits_amount],[financier_id],null as [legacy_soi_number],null as [request_approval_flag],null as [policyholder_benefit_id] ,null as [loan_number],null as [which_insured_flag]
	  ,null as [new_loan_type_id],null as [loan_balance_amount],null as [loan_total_amount],null as [other_outstanding_loans_flag],null as [balance_already_covered_amount],null as [excess_id],null as [claim_limit_tyres_amount]
	  ,null as [claim_limit_rims_amount],null as [dispensations_notes],null as [original_duration_in_months],null as [original_excess_amount],null as [original_premium_amount],null as [original_claim_limit_amount]
	  ,null as [original_claim_limit_tyres_amount],null as [original_claim_limit_rims_amount],null as [adhoc_set_flag],null as [adhoc_dispensation_notes],null as [adhoc_modified_by_user_id],null as [adhoc_modified_datetime]
      ,null as [is_transferred_flag],null as [latest_transfer_id],null as [premium_funded_flag],null as [payment_instalment_amount],null as [recurring_schedule_payment_number],null as [recurring_schedule_number_of_months]
      ,null as [payment_total_amount],null as [commission_code],null as [commission_rate],null as [commission_total_amount],null as [commission_report_file_dump_date],null as [is_special_extended_cover_flag],null as [promotion_id]
	  ,[last_updated] as [last_updated_date]	
from ext_piclos.gap_policy
left join ext_piclos.gap_cover_type 
on ext_piclos.gap_policy.cover_type_id = ext_piclos.gap_cover_type.id 
union 
select 
      id, convert(varchar(255), id) as [policy_number],null  as gap_vehicle_insurer_policy_number,'lnm' as [product_code],null as [quote_id],[cover_type_id],[cover_type_name],null as [cover_option_dealer_specific_flag],null as [cover_option_id]
	  ,null as [cover_option_description],[dealer_id],[dealer_user_id],[dealer_name],[dealer_sales_rep] as [dealer_sales_rep_name],null as [dealer_rep_code],null as [dealer_deactivated_flag]
	  ,null as [dealer_retail_premium_amount],null as [dealer_incentive_amount],null as [rating_card_id],null as[brand_id],null as [brand_name],null as [branch_id],null as [branch_name],[insurance_product_id]
      ,[status] as [policy_status_code],null as [insurance_refused_flag],null as [insurance_refused_details],null as [refund_amount],null as [refund_by_wholesale_premium_flag],null as [refund_datetime]
	  ,null as [payment_type_description],null as [payment_frequency_code],null as [payment_reference_number],CASE WHEN Derived_Date_10 is not null  THEN  TRY_CONVERT(date, Derived_Date_10,103)  ELSE null end as[dob_1]
	  ,null as [dob_2],null as [primary_driver_accident_free_years],null as [primary_driver_gender_code]
	  ,[product_name],case when [purchase_timestamp] < '1900-01-01 00:00:00' then null else [purchase_timestamp] end as [policy_purchase_datetime],null as [invoiced_datetime]
	  ,case when [from_timestamp] < '1900-01-01 00:00:00' then null else [from_timestamp] end as [policy_valid_from_date],case when [to_timestamp] < '1900-01-01 00:00:00' then null else [to_timestamp] end as [policy_valid_to_date]
	  
	  ,null as [policy_term_in_months],null as [retail_premium_over_policy_term_amount],null as [retail_premium_annual_amount],null as [retail_premium_monthly_amount],null as [retail_premium_fortnightly_amount]
      ,null as [retail_premium_weekly_amount],null as [retail_premium_amount],null as [retail_premium_incl_gst_amount],null as [wholesale_premium_over_term_amount],null as [wholesale_premium_amount],null as [premium_term_in_months]
      ,null as [premium_amount],null as [premium_with_gst_amount],null as [premium_with_gst_payable_amount],null as [loading_over_policy_term_amount],null as [loading_amount],null as [loading_amount_percent]
      ,null as [additional_risk_premium_amount],null as [gst_amount],null as [gst_base_rate_amount],null as [dps_convenience_fee_amount],null as [fire_service_levy_amount],null as [fire_service_levy_base_rate_amount]
	  ,null as [fire_service_levy_with_gst_payable_amount] ,null as [life_insurance_fee_amount],null as [life_insurance_fee_base_rate_percentage],null as [road_side_assist_fee_amount],null as [has_road_side_assist_flag]
	  ,null as [roadside_assist_amount],null as [is_roadside_assist_flag],null as [roadside_assist_end_datetime],null as [roadside_assist_original_end_date],null as [roadside_assist_duration_in_months],null as [nzra_live_flag]
      ,null as [claim_limit_amount],null as [roadside_breakdown_notes],null as [previous_vehicle_insurance_flag],null as [other_insurance_with_us_flag],null as [other_insurance_with_us_details],null as [sum_insured_amount]	 
	  
	  ,null as [interested_parties_id],null as [interested_parties_name],null as [excess_amount],null as [wind_screen_excess_amount],null as [under_age21_excess_amount],null as [age_21to25_excess_amount],null as [standard_excess_amount]
      ,null as [mandatory_excess_amount],null as [excess_optional_id],null as [excess_optional_amount],null as [overseas_license_excess_amount],null as [learners_license_excess_amount],null as [additional_excess_amount]
      ,null as [no_claims_modifier_percentage],null as [max_payable_loss_use_amount],null as [named_driver_flag],null as [exclude_under_age25_flag],null as [accident_flag],null as [accident_details],null as [stolen_burnt_flag]
	  ,null as [stolen_burnt_details],null as [underwriting_status],null as [underwriting_reason],null as [underwriting_comments],null as [duty_of_disclosure_notes],null as [driving_offence_flag],null as [driving_offence_details]
	  ,null as [licence_cancelled_flag],null as [licence_cancelled_details],null as [non_private_use_flag],null as [non_private_use_details],null as [vehicle_modified_flag],null as [vehicle_modification_details]
      ,null as [claim_withdrawn_flag],null as [claim_withdrawn_details],null as [conviction_flag],null as [conviction_details],null as [criminal_activity_flag],null as [criminal_activity_details],null as [vehicle_owned_by_other_flag]
      ,null as [vehicle_owned_by_other_details],null as [other_factors_flag],null as [other_factors_details],null as [information_complete_flag],null as [information_complete_details],null as [privacy_claims_register_agree_flag]
	  ,null as [privacy_disclose_information_agree_flag],null as [privacy_obtain_information_agree_flag],null as [vehicle_location_street],null as [vehicle_location_suburb],null as [vehicle_location_city]
	  ,null as [vehicle_location_postcode],null as [vehicle_intended_use_business_flag],null as [vehicle_kept_region_id],null as [vehicle_kept_description],null as [vehicle_kept_city],null as [vehicle_kept_suburb]
      ,null as [vehicle_kept_address],null as [vehicle_has_alarm_flag],null as [vehicle_has_immobiliser_flag],null as [vehicle_modifications_description],null as [vehicle_mod_body_kit_flag],null as [vehicle_mod_decoration_flag]
      ,null as [vehicle_mod_engine_flag],null as [vehicle_mod_exhaust_flag],null as [vehicle_mod_gauges_flag],null as [vehicle_mod_glass_flag],null as [vehicle_mod_suspension_flag],null as [vehicle_mod_mags_amount]
	  ,null as [vehicle_mod_stereo_amount],null as [vehicle_mod_other_amount],null as [pmvs_commission_variable_amount],null as [pmvs_commission_fixed_amount],null as [declaration_notes],null as [xml_seq_number]
      ,null as [is_renewal_flag],null as [renewal_pending_flag],null as [is_marsh_renewal_flag],null as [marsh_id],null as [posm_annual_invoice_flag],null as [contract_number],null as [contract_date]
	  ,null as [legacy_policy_number],null as [pmvs_policy_id],null as [parent_policy_id],null as [child_policy_id],null as [policy_type_id],null as [policy_notes],null as [policy_holder_licence_type_flag]
      ,null as [policy_holder_has_licence_suspended_flag],null as [policy_holder_has_previous_claims_flag],null as [policy_holder_has_vehicle_loss_flag] ,null as [policy_holder_has_driving_offences_flag],null as [policy_holder_has_criminal_offence_flag]
	  ,null as [policy_holder_has_criminal_offence_bankrupt_flag],null as [policy_holder_has_criminal_offence_prosecution_flag],null as [policy_holder_has_criminal_offence_convicted_flag],[policy_booklet_version],null as [policy_booklet_name]
	  ,null as [is_policy_disabled_flag],null as [responsible_lending_terms_acknowledge_flag],null as [auto_expired_datetime],null as [cancelled_datetime]	 
	  ,null as [deactivated_datetime],null as [insurance_type_code],null as [e_delivery_pref_code],null as [send_edocs_now_flag],null as [sent_to_ecm_flag] 
	  ,null as [created_by_wholesale_premium_flag],null as [financier_name],null as [financed_amount],null as [balance_payable_amount],null as[financed_from_datetime]
      ,null as [finance_term_in_months],null as [monthly_installments_amount],null as [balloon_payments_notes],null as [underwriting_premium_amount],null as [additional_notes]
	  ,null as [financial_rating_notes],null as [acknowledgment_notes],null as [other_details],null as [policy_event_coverage_causes],[alert_backdated] as [alert_backdated_flag],null as [gap_amount]

      ,null as [special_benefits_amount],null as [financier_id],[legacy_soi_number],[request_approval] as [request_approval_flag],[benefit_for_policyholder] as [policyholder_benefit_id],[loan_number],[which_insured] as [which_insured_flag]
	  ,[new_loan_type] as [new_loan_type_id],[loan_balance] as [loan_balance_amount],[loan_total] as [loan_total_amount],[other_outstanding_loans] as [other_outstanding_loans_flag]
	  ,[balance_already_covered] as [balance_already_covered_amount],null as [excess_id],null as [claim_limit_tyres_amount]
	  ,null as [claim_limit_rims_amount],null as [dispensations_notes],null as [original_duration_in_months],null as [original_excess_amount],null as [original_premium_amount],null as [original_claim_limit_amount]
	  ,null as [original_claim_limit_tyres_amount],null as [original_claim_limit_rims_amount],null as [adhoc_set_flag],null as [adhoc_dispensation_notes],null as [adhoc_modified_by_user_id],null as [adhoc_modified_datetime]
      ,null as [is_transferred_flag],null as [latest_transfer_id],null as [premium_funded_flag],null as [payment_instalment_amount],null as [recurring_schedule_payment_number],null as [recurring_schedule_number_of_months]
      ,null as [payment_total_amount],null as [commission_code],null as [commission_rate],null as [commission_total_amount],null as [commission_report_file_dump_date],null as [is_special_extended_cover_flag],null as [promotion_id]
	  ,[last_updated] as [last_updated_date] 
from ext_piclos.lnm_policy
 Cross apply (Select patindex('%[0123][0-9]/[0123][0-9]/[0-9][0-9]%', dob) as MMDDXX_Pos) as CA1
  Cross apply (Select Case When MMDDXX_Pos > 0 and SubString(dob, MMDDXX_Pos + 8, 2) like '[[0-9][0-9]' then 'T' else 'F' End as MMDDCCYY_Found) as CA2
  Cross apply (	Select Case 
				   When MMDDXX_Pos > 0 and MMDDCCYY_Found = 'T' Then SubString(dob, MMDDXX_Pos, 10)
				   When MMDDXX_Pos > 0 and MMDDCCYY_Found = 'F' Then SubString(dob, MMDDXX_Pos, 8)
				   Else dob
				  End as Derived_Date
			   ) as CA3
  
  Cross apply (Select patindex('[1-9]/[0123][0-9]/[0-9][0-9]%', Derived_Date) as MMDDXX_Pos_1) as CA4
  Cross apply (	Select Case 
				   When MMDDXX_Pos_1 > 0 Then concat('0',Derived_Date)
				   Else Derived_Date
				  End as Derived_Date_1
			   ) as CA5
  Cross apply (Select patindex('[0123][0-9]/[1-9]/[0-9][0-9][0-9][0-9]', Derived_Date_1) as MMDDXX_Pos_2) as CA6
  Cross apply (	Select Case 
				   When MMDDXX_Pos_2 > 0 Then stuff(Derived_Date_1,4,0,'0')
				   Else Derived_Date_1
				  End as Derived_Date_2
			   ) as CA7
  Cross apply (Select patindex('[1-9]/[1-9]/[0-9][0-9][0-9][0-9]', dob) as MMDDXX_Pos_3) as CA8
  Cross apply (	Select Case 
				   When MMDDXX_Pos_3 > 0 Then stuff(concat('0',dob),4,0,'0')
				   Else Derived_Date_2
				  End as Derived_Date_3
			   ) as CA9
  
  Cross apply (select patindex('[0-9]/[0-9]/[3-9][0-9]', dob) as MMDDXX_Pos_4) as CA10
  Cross apply (	Select Case 
				   When MMDDXX_Pos_4 > 0 Then  stuff(stuff(concat('0',dob),4,0,'0'),7,0,'19')
				   Else Derived_Date_3
				  End as Derived_Date_4
			   ) as CA11

   Cross apply (select patindex('[0-9][0-9]/[0-9][0-9]/[3-9][0-9]', dob) as MMDDXX_Pos_5) as CA12
  Cross apply (	Select Case 
				   When MMDDXX_Pos_5 > 0 Then  stuff(dob,7,0,'19')
				   Else Derived_Date_4
				  End as Derived_Date_5
			   ) as CA13
     Cross apply (select patindex('[0-9][0-9]/[0-9]/[3-9][0-9]', dob) as MMDDXX_Pos_6) as CA14
  Cross apply (	Select Case 
				   When MMDDXX_Pos_6 > 0 Then  stuff(stuff(dob,6,0,'19'),4,0,'0')
				   Else Derived_Date_5
				  End as Derived_Date_6
			   ) as CA15
  Cross apply (select patindex('[0-9][0-9][0-9][0-9][1-9][0-9][0-9][0-9]', dob) as MMDDXX_Pos_7) as CA16
  Cross apply (	Select Case 
				   When MMDDXX_Pos_7 > 0 Then  SUBSTRING(dob, 1, 2)+ '/' + SUBSTRING(dob, 3, 2) + '/' + SUBSTRING(dob, 5, 4)
				   Else Derived_Date_6
				  End as Derived_Date_7
			   ) as CA17
  Cross apply (select patindex('[0-9][0-9]/[0-9][0-9][1-9][0-9][0-9][0-9]', dob) as MMDDXX_Pos_8) as CA18
  Cross apply (	Select Case 
				   When MMDDXX_Pos_8 > 0 Then  stuff(dob,6,0,'/')
				   Else Derived_Date_7
				  End as Derived_Date_8
			   ) as CA19  
   Cross apply (select patindex('[0-9]/[0-9][0-9]/[3-9][0-9]', dob) as MMDDXX_Pos_9) as CA20
  Cross apply (	Select Case 
				   When MMDDXX_Pos_9 > 0 Then  stuff(concat('0',dob),7,0,'19')
				   Else Derived_Date_8
				  End as Derived_Date_9
			   ) as CA21 
 Cross apply (select patindex('[0-9][0-9]/[0-9][0-9]/[1-9][0-9][0-9][0-9]', Derived_Date_9) as MMDDXX_Pos_10) as CA22
  Cross apply (	Select Case 
				   When MMDDXX_Pos_10 > 0 Then  Derived_Date_9
				   Else null 
				  End as Derived_Date_10
			   ) as CA23
union 

select 
      id, convert(varchar(255), id) as [policy_number],null  as gap_vehicle_insurer_policy_number,'mbi' as [product_code],null as [quote_id],[cover_type_id],[cover_type_name],null as [cover_option_dealer_specific_flag],null as [cover_option_id]
	  ,null as [cover_option_description],[dealer_id],[dealer_user_id],[dealer_name],[dealer_salesrep] as [dealer_sales_rep_name],null as [dealer_rep_code],[dealer_deactivated] as [dealer_deactivated_flag]
	  ,[dealer_retail_premium]as [dealer_retail_premium_amount],[dealer_incentive] as [dealer_incentive_amount],null as [rating_card_id],[brand_id],[brand_name],[branch_id],[branch_name],[insurance_product_id]
      ,[status] as [policy_status_code],null as [insurance_refused_flag],null as [insurance_refused_details],[refund] as [refund_amount],null as [refund_by_wholesale_premium_flag],case when [refund_timestamp] < '1900-01-01 00:00:00' then null else [refund_timestamp] end as [refund_datetime]
	  ,null as [payment_type_description],[payment_frequency] as [payment_frequency_code],null as [payment_reference_number],case when [dob_1] < '1900-01-01' then null else [dob_1] end as[dob_1]
	  ,case when [dob_2] = '0001-01-01' then null else [dob_2] end as [dob_2],null as [primary_driver_accident_free_years],null as [primary_driver_gender_code]
      ,[product_name],case when [purchase_timestamp] < '1900-01-01 00:00:00' then null else [purchase_timestamp] end as [policy_purchase_datetime]
	  ,case when [invoiced_timestamp] < '1900-01-01 00:00:00' then null else [invoiced_timestamp] end as [invoiced_datetime]
	  ,case when [from_timestamp] < '1900-01-01 00:00:00' then null else [from_timestamp] end as [policy_valid_from_date],case when [to_timestamp] < '1900-01-01 00:00:00' then null else [to_timestamp] end as [policy_valid_to_date]
	  ,[term] as [policy_term_in_months],null as [retail_premium_over_policy_term_amount],null as [retail_premium_annual_amount],null as [retail_premium_monthly_amount],null as [retail_premium_fortnightly_amount]
      ,null as [retail_premium_weekly_amount],null as [retail_premium_amount],null as [retail_premium_incl_gst_amount],null as [wholesale_premium_over_term_amount],null as [wholesale_premium_amount],null as [premium_term_in_months]
      ,[premium] as [premium_amount],null as [premium_with_gst_amount],null as [premium_with_gst_payable_amount],null as [loading_over_policy_term_amount],null as [loading_amount],null as [loading_amount_percent]
      ,null as [additional_risk_premium_amount],null as [gst_amount],null as [gst_base_rate_amount],null as [dps_convenience_fee_amount],null as [fire_service_levy_amount],null as [fire_service_levy_base_rate_amount]
	  ,null as [fire_service_levy_with_gst_payable_amount] ,null as [life_insurance_fee_amount],null as [life_insurance_fee_base_rate_percentage],null as [road_side_assist_fee_amount],null as [has_road_side_assist_flag]
	  ,[roadside_assist] as [roadside_assist_amount],[is_roadside_assist] as [is_roadside_assist_flag],case when [roadside_assist_end_date] < '1900-01-01 00:00:00' then null else [roadside_assist_end_date] end  as [roadside_assist_end_datetime]
	  ,case when [roadside_assist_original_end_date]  < '1900-01-01 00:00:00' then null else [roadside_assist_original_end_date] end as [roadside_assist_original_end_date] ,[roadside_assist_term] as [roadside_assist_duration_in_months],[nzra_live] as [nzra_live_flag]
      ,[claim_limit] as [claim_limit_amount],[roadside_breakdown] as [roadside_breakdown_notes],null as [previous_vehicle_insurance_flag],null as [other_insurance_with_us_flag],null as [other_insurance_with_us_details]
	  ,null as [sum_insured_amount],null as [interested_parties_id],null as [interested_parties_name],[excess] as [excess_amount],null as [wind_screen_excess_amount],null as [under_age21_excess_amount]
	  ,null as [age_21to25_excess_amount],null as [standard_excess_amount],null as [mandatory_excess_amount],null as [excess_optional_id],null as [excess_optional_amount],null as [overseas_license_excess_amount]
      ,null as [learners_license_excess_amount],null as [additional_excess_amount],null as [no_claims_modifier_percentage],null as [max_payable_loss_use_amount],null as [named_driver_flag],null as [exclude_under_age25_flag]
      ,null as [accident_flag],null as [accident_details],null as [stolen_burnt_flag],null as [stolen_burnt_details],null as [underwriting_status],null as [underwriting_reason],null as [underwriting_comments]
	  ,null as [duty_of_disclosure_notes] ,null as [driving_offence_flag],null as [driving_offence_details],null as [licence_cancelled_flag],null as [licence_cancelled_details],null as [non_private_use_flag]
	  ,null as [non_private_use_details],is_modified as [vehicle_modified_flag],null as [vehicle_modification_details],null as [claim_withdrawn_flag],null as [claim_withdrawn_details],null as [conviction_flag]
	  ,null as [conviction_details] ,null as [criminal_activity_flag],null as [criminal_activity_details],null as [vehicle_owned_by_other_flag],null as [vehicle_owned_by_other_details]
      ,null as [other_factors_flag],null as [other_factors_details],null as [information_complete_flag],null as [information_complete_details],null as [privacy_claims_register_agree_flag]
	  ,null as [privacy_disclose_information_agree_flag],null as [privacy_obtain_information_agree_flag],null as [vehicle_location_street],null as [vehicle_location_suburb],null as [vehicle_location_city]
	  ,null as [vehicle_location_postcode],null as [vehicle_intended_use_business_flag],null as [vehicle_kept_region_id],null as [vehicle_kept_description],null as [vehicle_kept_city],null as [vehicle_kept_suburb]
      ,null as [vehicle_kept_address],null as [vehicle_has_alarm_flag],null as [vehicle_has_immobiliser_flag],null as [vehicle_modifications_description],null as [vehicle_mod_body_kit_flag],null as [vehicle_mod_decoration_flag]
      ,null as [vehicle_mod_engine_flag],null as [vehicle_mod_exhaust_flag],null as [vehicle_mod_gauges_flag],null as [vehicle_mod_glass_flag],null as [vehicle_mod_suspension_flag],null as [vehicle_mod_mags_amount]
	  ,null as [vehicle_mod_stereo_amount],null as [vehicle_mod_other_amount],null as [pmvs_commission_variable_amount],null as [pmvs_commission_fixed_amount],null as [declaration_notes],null as [xml_seq_number]
      ,null as [is_renewal_flag],null as [renewal_pending_flag],null as [is_marsh_renewal_flag],null as [marsh_id],null as [posm_annual_invoice_flag],[contract_no] as [contract_number]
	  ,case when [contract_date] < '1900-01-01 00:00:00' then null else [contract_date] end as [contract_date]
	  ,null as [legacy_policy_number],null as [pmvs_policy_id],null as [parent_policy_id],null as [child_policy_id],null as [policy_type_id],null as [policy_notes],null as [policy_holder_licence_type_flag]
      ,null as [policy_holder_has_licence_suspended_flag],null as [policy_holder_has_previous_claims_flag],null as [policy_holder_has_vehicle_loss_flag] ,null as [policy_holder_has_driving_offences_flag],null as [policy_holder_has_criminal_offence_flag]
	  ,null as [policy_holder_has_criminal_offence_bankrupt_flag],null as [policy_holder_has_criminal_offence_prosecution_flag],null as [policy_holder_has_criminal_offence_convicted_flag],[policy_booklet_version],[policy_booklet_name]
      ,[is_disabled] as [is_policy_disabled_flag],[responsible_lending_terms_acknowledge] as [responsible_lending_terms_acknowledge_flag],case when [auto_expired_timestamp] < '1900-01-01 00:00:00' then null else [auto_expired_timestamp] end as [auto_expired_datetime]
	  ,null as [cancelled_datetime]
	  ,case when [deactivated_timestamp] < '1900-01-01 00:00:00' then null else [deactivated_timestamp] end as [deactivated_datetime],null as [insurance_type_code],[e_delivery_pref] as [e_delivery_pref_code],[send_edocs_now] as [send_edocs_now_flag],[sent_to_ecm] as [sent_to_ecm_flag]
	  ,null as [created_by_wholesale_premium_flag],null as [financier_name],null as [financed_amount],null as [balance_payable_amount],null as[financed_from_datetime],null as [finance_term_in_months]
      ,null as [monthly_installments_amount],null as [balloon_payments_notes],null as [underwriting_premium_amount],[please_note] as [additional_notes],[financial_rating] as [financial_rating_notes]
	  ,[acknowledgments] as [acknowledgment_notes],[other_details] as [other_details],null as [policy_event_coverage_causes],[alert_backdated] as [alert_backdated_flag],null as [gap_amount]  
      ,null as [special_benefits_amount],null as [financier_id],null as [legacy_soi_number],null as [request_approval_flag],null as [policyholder_benefit_id] ,null as [loan_number],null as [which_insured_flag]
	  ,null as [new_loan_type_id],null as [loan_balance_amount],null as [loan_total_amount],null as [other_outstanding_loans_flag],null as [balance_already_covered_amount],[excess_id],null as [claim_limit_tyres_amount]
	  ,null as [claim_limit_rims_amount],[dispensations] as [dispensations_notes],[original_term] as [original_duration_in_months],[original_excess] as [original_excess_amount],[original_premium] as [original_premium_amount]
	  ,[original_claim_limit] as [original_claim_limit_amount],null as [original_claim_limit_tyres_amount],null as [original_claim_limit_rims_amount],[adhoc_set] as [adhoc_set_flag]
	  ,[adhoc_dispensation] as [adhoc_dispensation_notes],[adhoc_modified_by] as [adhoc_modified_by_user_id],case when [adhoc_modified_timestamp] < '1900-01-01 00:00:00' then null else [adhoc_modified_timestamp] end  as [adhoc_modified_datetime]
	  ,[is_transferred] as [is_transferred_flag]
	  ,[latest_transfer_id] as [latest_transfer_id],[premium_funded] as [premium_funded_flag],[payment_instalment] as [payment_instalment_amount],[payment_number_of_payments] as [recurring_schedule_payment_number]  
	  ,[payment_number_of_months] as [recurring_schedule_number_of_months],[payment_total_amount] as [payment_total_amount],[commission_type] as [commission_code],[commission_rate] as [commission_rate]
	  ,[commission_total] as [commission_total_amount],[commission_report_file_dump_date] as [commission_report_file_dump_date],[is_special_extended_cover] as [is_special_extended_cover_flag],[promotion_id] as [promotion_id]
	  ,[last_updated] as [last_updated_date] 
from ext_piclos.mbi_policy


union

select 
      ext_piclos.posm_policy.id, [policy_number],null  as gap_vehicle_insurer_policy_number,'posm' as [product_code], [quote_id],[cover_type_id], ext_piclos.posm_cover_type.title as [cover_type_name],[cover_option_dealer_specific] as [cover_option_dealer_specific_flag], [cover_option_id]
	  ,[cover_option_title] as [cover_option_description],[dealer_id],[dealer_user_id],[dealer_name],[dealer_sales_rep] as [dealer_sales_rep_name],null as [dealer_rep_code],null as [dealer_deactivated_flag]
	  ,null as [dealer_retail_premium_amount],null as [dealer_incentive_amount], [rating_card_id],[brand_id],[brand_name],[branch_id],[branch_name],[insurance_product_id]
      ,[status] as [policy_status_code],insurance_refused as [insurance_refused_flag],[insurance_refused_details],[refund] as [refund_amount],null as [refund_by_wholesale_premium_flag]
	  ,case when [refund_timestamp] < '1900-01-01 00:00:00' then null else [refund_timestamp] end as [refund_datetime]
	  ,payment_type as [payment_type_description],
	  case when payment_freq = 'W' then 'Weekly' 
	  when payment_freq = 'F' then 'Fortnightly' 
	  when payment_freq = 'Y' then 'Yearly' 
	  when payment_freq = 'M' then 'Monthly' 
	  else null 
	  end as [payment_frequency_code],payment_ref as [payment_reference_number],case when [dob_1] < '1900-01-01' then null else [dob_1] end as[dob_1]
	  ,case when [dob_2] = '0001-01-01' then null else [dob_2] end as [dob_2], [primary_driver_accident_free_years]
	  ,primary_driver_gender as [primary_driver_gender_code]
	  ,[product_name],case when [purchase_timestamp] < '1900-01-01 00:00:00' then null else [purchase_timestamp] end as [policy_purchase_datetime]
	  ,case when [invoiced_timestamp] < '1900-01-01 00:00:00' then null else [invoiced_timestamp] end as [invoiced_datetime]
	  ,case when [from_timestamp] < '1900-01-01 00:00:00' then null else [from_timestamp] end as [policy_valid_from_date],case when [to_timestamp] < '1900-01-01 00:00:00' then null else [to_timestamp] end as [policy_valid_to_date]
	  ,ext_piclos.posm_policy.[term] as [policy_term_in_months],retail_premium_over_term as [retail_premium_over_policy_term_amount],retail_premium_annual as [retail_premium_annual_amount]	  
	  ,retail_premium_monthly as [retail_premium_monthly_amount],retail_premium_fortnightly as [retail_premium_fortnightly_amount]
      ,retail_premium_weekly as [retail_premium_weekly_amount],null as [retail_premium_amount],null as [retail_premium_incl_gst_amount],wholesalepremium_over_term as [wholesale_premium_over_term_amount]
	   ,wholesalepremium as [wholesale_premium_amount],null as [premium_term_in_months]
      ,[premium] as [premium_amount],premium_with_gst as [premium_with_gst_amount],premium_with_gst_payable as [premium_with_gst_payable_amount],loading_amount_over_term as [loading_over_policy_term_amount]
	  ,loading_amount as [loading_amount],loading_amount_percent as [loading_amount_percent]
      ,additional_risk_premium as [additional_risk_premium_amount],gst as [gst_amount],gst_base_rate as [gst_base_rate_amount],dps_convenience_fee as [dps_convenience_fee_amount],fire_service_levy as [fire_service_levy_amount]
	  ,fire_service_levy_base_rate as [fire_service_levy_base_rate_amount]
	  ,fire_service_levy_with_gst_payable as [fire_service_levy_with_gst_payable_amount] ,life_insurance_fee as [life_insurance_fee_amount],life_insurance_fee_base_rate as [life_insurance_fee_base_rate_percentage]
	  ,road_side_assist_fee as [road_side_assist_fee_amount],ext_piclos.posm_policy.has_road_side_assist as [has_road_side_assist_flag]
	  ,null as [roadside_assist_amount],null as [is_roadside_assist_flag],null as [roadside_assist_end_datetime],null as [roadside_assist_original_end_date]	  
	  ,null as [roadside_assist_duration_in_months],null as [nzra_live_flag]
      ,null as [claim_limit_amount],null as [roadside_breakdown_notes],previous_vehicle_insurance as [previous_vehicle_insurance_flag],other_insurance_with_us as [other_insurance_with_us_flag]	  
	  ,other_insurance_with_us_details as [other_insurance_with_us_details],[sum_insured] as [sum_insured_amount]	  
	  ,[interested_parties_id],interested_parties as [interested_parties_name],ext_piclos.posm_policy.excess as [excess_amount],excess_windscreen as [wind_screen_excess_amount],excess_under21 as [under_age21_excess_amount]	  
	  ,excess_21to25 as [age_21to25_excess_amount],excess_std as [standard_excess_amount]
      ,excess_mandatory_value as [mandatory_excess_amount],excess_optional_id as [excess_optional_id],excess_optional_value as [excess_optional_amount],excess_overseas as [overseas_license_excess_amount]  
	  ,excess_learners as [learners_license_excess_amount],excess_additional as [additional_excess_amount]
      ,no_claims_modifier as [no_claims_modifier_percentage],max_payable_loss_use as [max_payable_loss_use_amount],named_driver as [named_driver_flag],exclude_under_25 as [exclude_under_age25_flag],accident as [accident_flag]  
	  ,accident_details as [accident_details],stolen_burnt as [stolen_burnt_flag]
	  ,stolen_burnt_details as [stolen_burnt_details],uw_status as [underwriting_status],uw_reason as [underwriting_reason],uw_comment as [underwriting_comments],duty_of_disclosure as [duty_of_disclosure_notes]	  
	  ,driving_offence as [driving_offence_flag],driving_offence_details as [driving_offence_details]
	  ,licence_cancelled as [licence_cancelled_flag],licence_cancelled_details as [licence_cancelled_details],non_private_use as [non_private_use_flag],non_private_use_details as [non_private_use_details]
	  ,modified as [vehicle_modified_flag],modified_details as [vehicle_modification_details]
      ,claim_withdrawn as [claim_withdrawn_flag],claim_withdrawn_details as [claim_withdrawn_details],conviction as [conviction_flag],conviction_details as [conviction_details],criminal_activity as [criminal_activity_flag]	  
	  ,criminal_activity_details as [criminal_activity_details],vehicle_owned_by_other as [vehicle_owned_by_other_flag]
      ,vehicle_owned_by_other_details as [vehicle_owned_by_other_details],other_factors as [other_factors_flag],other_factors_details as [other_factors_details],information_complete as [information_complete_flag]	  
	  ,information_complete_details as [information_complete_details],privacy_claims_register_agree as [privacy_claims_register_agree_flag]
	  ,privacy_disclose_information_agree as [privacy_disclose_information_agree_flag],privacy_obtain_information_agree as [privacy_obtain_information_agree_flag],vehicle_location_street as [vehicle_location_street]	  
	  ,vehicle_location_suburb as [vehicle_location_suburb],vehicle_location_city as [vehicle_location_city]
	  ,vehicle_location_postcode as [vehicle_location_postcode],vehicle_intended_use_business as [vehicle_intended_use_business_flag],vehicle_kept_region_id as [vehicle_kept_region_id],vehicle_kept as [vehicle_kept_description]	  
	  ,vehicle_kept_city as [vehicle_kept_city],vehicle_kept_suburb as [vehicle_kept_suburb]
      ,vehicle_kept_address as [vehicle_kept_address],vehicle_has_alarm as [vehicle_has_alarm_flag],vehicle_has_immobiliser as [vehicle_has_immobiliser_flag],modifications as [vehicle_modifications_description]	  
	  ,vehicle_mod_body_kit as [vehicle_mod_body_kit_flag],vehicle_mod_decoration as [vehicle_mod_decoration_flag]
      ,vehicle_mod_engine as [vehicle_mod_engine_flag],vehicle_mod_exhaust as [vehicle_mod_exhaust_flag],vehicle_mod_gauges as [vehicle_mod_gauges_flag],vehicle_mod_glass as [vehicle_mod_glass_flag]	  
	  ,vehicle_mod_suspension as [vehicle_mod_suspension_flag],vehicle_mod_mags_value as [vehicle_mod_mags_amount]
	  ,vehicle_mod_stereo_value as [vehicle_mod_stereo_amount],vehicle_mod_other_value as [vehicle_mod_other_amount],pmvs_commission_variable as [pmvs_commission_variable_amount],pmvs_commission_fixed as [pmvs_commission_fixed_amount]	  
	  ,declarations as [declaration_notes],xml_seq_no as [xml_seq_number]
      ,is_renewal as [is_renewal_flag],renewal_pending as [renewal_pending_flag],is_marsh_renewal as [is_marsh_renewal_flag],marsh_id as [marsh_id],use_posm_annual_invoice as [posm_annual_invoice_flag]
	  ,[contract_no] as [contract_number],null as [contract_date]
	  ,policy_number_legacy as [legacy_policy_number],pmvs_policy_id as [pmvs_policy_id],policy_id_parent as [parent_policy_id],policy_id_child as [child_policy_id],[policy_type_id],[policy_notes]	  
	  ,[policy_holder_licence_type] as [policy_holder_licence_type_flag] 
      ,[policy_holder_has_licence_suspended] as [policy_holder_has_licence_suspended_flag] ,[policy_holder_has_previous_claims] as [policy_holder_has_previous_claims_flag],[policy_holder_has_vehicle_loss] as   [policy_holder_has_vehicle_loss_flag]
	  , [policy_holder_has_driving_offences] as [policy_holder_has_driving_offences_flag],[policy_holder_has_criminal_offence] as [policy_holder_has_criminal_offence_flag]
	  ,[policy_holder_has_criminal_offence_bankrupt] as [policy_holder_has_criminal_offence_bankrupt_flag],[policy_holder_has_criminal_offence_prosecution] as [policy_holder_has_criminal_offence_prosecution_flag]
	  ,[policy_holder_has_criminal_offence_convicted] as [policy_holder_has_criminal_offence_convicted_flag],[policy_booklet_version],null as [policy_booklet_name]
	  ,[is_disabled] as [is_policy_disabled_flag],[responsible_lending_terms_acknowledge] as [responsible_lending_terms_acknowledge_flag]
	  ,case when [auto_expired_timestamp] < '1900-01-01 00:00:00' then null else [auto_expired_timestamp] end as [auto_expired_datetime],case when [cancelled_timestamp] < '1900-01-01 00:00:00' then null else [cancelled_timestamp] end as [cancelled_datetime]
	  ,case when [deactivated_timestamp] < '1900-01-01 00:00:00' then null else [deactivated_timestamp] end as [deactivated_datetime],null as [insurance_type_code],null as [e_delivery_pref_code],null as [send_edocs_now_flag],null as [sent_to_ecm_flag]
	  ,null as [created_by_wholesale_premium_flag],null as [financier_name],null as [financed_amount],null as [balance_payable_amount],null as[financed_from_datetime]
      ,null as [finance_term_in_months],null as [monthly_installments_amount],null as [balloon_payments_notes],null as [underwriting_premium_amount],null as [additional_notes]
	  ,null as [financial_rating_notes],null as [acknowledgment_notes],null as [other_details],null as [policy_event_coverage_causes],null as [alert_backdated_flag], null as [gap_amount]
      ,null as [special_benefits_amount],null as [financier_id],null as [legacy_soi_number],null as [request_approval_flag],null as [policyholder_benefit_id] ,null as [loan_number],null as [which_insured_flag]
	  ,null as [new_loan_type_id],null as [loan_balance_amount],null as [loan_total_amount],null as [other_outstanding_loans_flag],null as [balance_already_covered_amount],null as [excess_id],null as [claim_limit_tyres_amount]
	  ,null as [claim_limit_rims_amount],null as [dispensations_notes],null as [original_duration_in_months],null as [original_excess_amount],null as [original_premium_amount],null as [original_claim_limit_amount]
	  ,null as [original_claim_limit_tyres_amount],null as [original_claim_limit_rims_amount],null as [adhoc_set_flag],null as [adhoc_dispensation_notes],null as [adhoc_modified_by_user_id],null as [adhoc_modified_datetime]
      ,null as [is_transferred_flag],null as [latest_transfer_id],null as [premium_funded_flag],null as [payment_instalment_amount],null as [recurring_schedule_payment_number],null as [recurring_schedule_number_of_months]
      ,null as [payment_total_amount],null as [commission_code],null as [commission_rate],null as [commission_total_amount],null as [commission_report_file_dump_date],null as [is_special_extended_cover_flag],null as [promotion_id]
	  ,[last_updated] as [last_updated_date] 
from ext_piclos.posm_policy
left join ext_piclos.posm_cover_type 
on ext_piclos.posm_policy.cover_type_id = ext_piclos.posm_cover_type.id 

union 

select 
      id, convert(varchar(255), id) as [policy_number],null  as gap_vehicle_insurer_policy_number,'tar' as [product_code],null as [quote_id],[cover_type_id],[cover_type_name],null as [cover_option_dealer_specific_flag],null as [cover_option_id]
	  ,null as [cover_option_description],[dealer_id],[dealer_user_id],[dealer_name],[dealer_salesrep] as [dealer_sales_rep_name],null as[dealer_rep_code],[dealer_deactivated] as [dealer_deactivated_flag]
	  ,[dealer_retail_premium]as [dealer_retail_premium_amount],null as [dealer_incentive_amount],null as [rating_card_id],[brand_id],[brand_name],[branch_id],[branch_name],[insurance_product_id]
      ,[status] as [policy_status_code],null as [insurance_refused_flag],null as [insurance_refused_details],[refund] as [refund_amount],null as [refund_by_wholesale_premium_flag],case when [refund_timestamp] < '1900-01-01 00:00:00' then null else [refund_timestamp] end as [refund_datetime]
	 ,null as [payment_type_description],null as [payment_frequency_code],null as [payment_reference_number],case when [dob_1] < '1900-01-01' then null else [dob_1] end as [dob_1]
	 ,case when [dob_2] = '0001-01-01' then null else [dob_2] end as [dob_2],null as [primary_driver_accident_free_years],null as [primary_driver_gender_code]
	  ,[product_name],case when [purchase_timestamp] < '1900-01-01 00:00:00' then null else [purchase_timestamp] end as [policy_purchase_datetime],case when [invoiced_timestamp] < '1900-01-01 00:00:00' then null else [invoiced_timestamp] end as [invoiced_datetime]
	  ,case when [from_timestamp] < '1900-01-01 00:00:00' then null else [from_timestamp] end as [policy_valid_from_date],case when [to_timestamp] < '1900-01-01 00:00:00' then null else [to_timestamp] end as [policy_valid_to_date]	  
	  ,[term] as [policy_term_in_months],null as [retail_premium_over_policy_term_amount],null as [retail_premium_annual_amount],null as [retail_premium_monthly_amount],null as [retail_premium_fortnightly_amount]
      ,null as [retail_premium_weekly_amount],null as [retail_premium_amount],null as [retail_premium_incl_gst_amount],null as [wholesale_premium_over_term_amount],null as [wholesale_premium_amount],null as [premium_term_in_months]     
	 ,[premium] as [premium_amount],null as [premium_with_gst_amount],null as [premium_with_gst_payable_amount],null as [loading_over_policy_term_amount],null as [loading_amount],null as [loading_amount_percent]
      ,null as [additional_risk_premium_amount],null as [gst_amount],null as [gst_base_rate_amount],null as [dps_convenience_fee_amount],null as [fire_service_levy_amount],null as [fire_service_levy_base_rate_amount]
	  ,null as [fire_service_levy_with_gst_payable_amount] ,null as [life_insurance_fee_amount],null as [life_insurance_fee_base_rate_percentage],null as [road_side_assist_fee_amount],null as [has_road_side_assist_flag]
	  ,null as [roadside_assist_amount],null as [is_roadside_assist_flag],null as [roadside_assist_end_datetime],null as [roadside_assist_original_end_date],null as [roadside_assist_duration_in_months],null as [nzra_live_flag]
      ,null as [claim_limit_amount],null as [roadside_breakdown_notes],null as [previous_vehicle_insurance_flag],null as [other_insurance_with_us_flag],null as [other_insurance_with_us_details],null as [sum_insured_amount]	
	  ,null as [interested_parties_id],null as [interested_parties_name],null as [excess_amount],null as [wind_screen_excess_amount],null as [under_age21_excess_amount],null as [age_21to25_excess_amount],null as [standard_excess_amount]    
     ,null as [mandatory_excess_amount],null as [excess_optional_id],excess as [excess_optional_amount],null as [overseas_license_excess_amount],null as [learners_license_excess_amount],null as [additional_excess_amount]
      ,null as [no_claims_modifier_percentage],null as [max_payable_loss_use_amount],null as [named_driver_flag],null as [exclude_under_age25_flag],null as [accident_flag],null as [accident_details],null as [stolen_burnt_flag]
	  ,null as [stolen_burnt_details],null as [underwriting_status],null as [underwriting_reason],null as [underwriting_comments],null as [duty_of_disclosure_notes],null as [driving_offence_flag],null as [driving_offence_details]
	  ,null as [licence_cancelled_flag],null as [licence_cancelled_details],null as [non_private_use_flag],null as [non_private_use_details],null as [vehicle_modified_flag],null as [vehicle_modification_details]
      ,null as [claim_withdrawn_flag],null as [claim_withdrawn_details],null as [conviction_flag],null as [conviction_details],null as [criminal_activity_flag],null as [criminal_activity_details],null as [vehicle_owned_by_other_flag]    
	  ,null as [vehicle_owned_by_other_details],null as [other_factors_flag],null as [other_factors_details],null as [information_complete_flag],null as [information_complete_details],null as [privacy_claims_register_agree_flag]
	  ,null as [privacy_disclose_information_agree_flag],null as [privacy_obtain_information_agree_flag],null as [vehicle_location_street],null as [vehicle_location_suburb],null as [vehicle_location_city]
	  ,null as [vehicle_location_postcode],null as [vehicle_intended_use_business_flag],null as [vehicle_kept_region_id],null as [vehicle_kept_description],null as [vehicle_kept_city],null as [vehicle_kept_suburb]
      ,null as [vehicle_kept_address],null as [vehicle_has_alarm_flag],null as [vehicle_has_immobiliser_flag],null as [vehicle_modifications_description],null as [vehicle_mod_body_kit_flag],null as [vehicle_mod_decoration_flag]
      ,null as [vehicle_mod_engine_flag],null as [vehicle_mod_exhaust_flag],null as [vehicle_mod_gauges_flag],null as [vehicle_mod_glass_flag],null as [vehicle_mod_suspension_flag],null as [vehicle_mod_mags_amount]
	  ,null as [vehicle_mod_stereo_amount],null as [vehicle_mod_other_amount],null as [pmvs_commission_variable_amount],null as [pmvs_commission_fixed_amount],null as [declaration_notes],null as [xml_seq_number]
      ,null as [is_renewal_flag],null as [renewal_pending_flag],null as [is_marsh_renewal_flag],null as [marsh_id],null as [posm_annual_invoice_flag],[contract_no] as [contract_number]
	  ,case when [contract_date] < '1900-01-01 00:00:00' then null else [contract_date] end as [contract_date]
	  ,null as [legacy_policy_number],null as [pmvs_policy_id],null as [parent_policy_id],null as [child_policy_id],null as [policy_type_id],null as [policy_notes],null as [policy_holder_licence_type_flag]
      ,null as [policy_holder_has_licence_suspended_flag],null as [policy_holder_has_previous_claims_flag],null as [policy_holder_has_vehicle_loss_flag] ,null as [policy_holder_has_driving_offences_flag],null as [policy_holder_has_criminal_offence_flag]
	  ,null as [policy_holder_has_criminal_offence_bankrupt_flag],null as [policy_holder_has_criminal_offence_prosecution_flag],null as [policy_holder_has_criminal_offence_convicted_flag],[policy_booklet_version],[policy_booklet_name]
	  ,[is_disabled] as [is_policy_disabled_flag],[responsible_lending_terms_acknowledge] as [responsible_lending_terms_acknowledge_flag],case when [auto_expired_timestamp] < '1900-01-01 00:00:00' then null else [auto_expired_timestamp] end as [auto_expired_datetime],null as [cancelled_datetime]
	  ,case when [deactivated_timestamp] < '1900-01-01 00:00:00' then null else [deactivated_timestamp] end as [deactivated_datetime],null as [insurance_type_code],[e_delivery_pref] as [e_delivery_pref_code],[send_edocs_now] as [send_edocs_now_flag],[sent_to_ecm] as [sent_to_ecm_flag]
	  ,null as [created_by_wholesale_premium_flag],null as [financier_name],null as [financed_amount],null as [balance_payable_amount],null as[financed_from_datetime]
      ,null as [finance_term_in_months],null as [monthly_installments_amount],null as [balloon_payments_notes],null as [underwriting_premium_amount],[please_note] as [additional_notes]
	  ,[financial_rating] as [financial_rating_notes],[acknowledgments] as [acknowledgment_notes],[other_details] as [other_details],null as [policy_event_coverage_causes],alert_backdated as [alert_backdated_flag],null as [gap_amount]    
	  ,null as [special_benefits_amount],null as [financier_id],null as [legacy_soi_number],null as [request_approval_flag],null as [policyholder_benefit_id] ,null as [loan_number],null as [which_insured_flag]
	  ,null as [new_loan_type_id],null as [loan_balance_amount],null as [loan_total_amount],null as [other_outstanding_loans_flag],null as [balance_already_covered_amount],[excess_id],claim_limit_tyres as [claim_limit_tyres_amount]	  
	  ,claim_limit_rims as [claim_limit_rims_amount],dispensations as [dispensations_notes],original_term as [original_duration_in_months],original_excess as [original_excess_amount],original_premium as [original_premium_amount]	  
	  ,null as [original_claim_limit_amount]
	  ,original_claim_limit_tyres as [original_claim_limit_tyres_amount],original_claim_limit_rims as [original_claim_limit_rims_amount],adhoc_set as [adhoc_set_flag],adhoc_dispensation as [adhoc_dispensation_notes]	  
	  ,adhoc_modified_by as [adhoc_modified_by_user_id],adhoc_modified_timestamp as [adhoc_modified_datetime]
      ,null as [is_transferred_flag],null as [latest_transfer_id],null as [premium_funded_flag],null as [payment_instalment_amount],null as [recurring_schedule_payment_number],null as [recurring_schedule_number_of_months]
      ,null as [payment_total_amount],null as [commission_code],null as [commission_rate],null as [commission_total_amount],null as [commission_report_file_dump_date],null as [is_special_extended_cover_flag],null as [promotion_id]
	  ,[last_updated] as [last_updated_date] 
from ext_piclos.tar_policy
) policies 

MERGE
	data.[dim_policy] 
USING
  (
  select * from #policy 
  ) POLICIES

on 
data.[dim_policy].[policy_id] = POLICIES.id AND
data.[dim_policy].[policy_number] = POLICIES.[policy_number] AND
data.[dim_policy].[product_code]  = POLICIES.[product_code] AND
data.[dim_policy].is_deleted = 0 AND
data.[dim_policy].record_current_flag = 1 

WHEN NOT MATCHED BY TARGET THEN
	INSERT
		([policy_id],[policy_number],gap_vehicle_insurer_policy_number,[product_code],[quote_id],[cover_type_id],[cover_type_name],[cover_option_dealer_specific_flag],[cover_option_id],[cover_option_description],[dealer_id],[dealer_user_id]
      ,[dealer_name],[dealer_sales_rep_name],[dealer_rep_code],[dealer_deactivated_flag],[dealer_retail_premium_amount],[dealer_incentive_amount],[rating_card_id],[brand_id],[brand_name],[branch_id],[branch_name]
	  ,[insurance_product_id],[policy_status_code],[insurance_refused_flag],[insurance_refused_details],[refund_amount],[refund_by_wholesale_premium_flag],[refund_datetime],[payment_type_description],[payment_frequency_code]
      ,[payment_reference_number],[dob_1],[dob_2],[primary_driver_accident_free_years],[primary_driver_gender_code],[product_name],[policy_purchase_datetime],[invoiced_datetime],[policy_valid_from_date],[policy_valid_to_date]
      ,[policy_term_in_months],[retail_premium_over_policy_term_amount],[retail_premium_annual_amount],[retail_premium_monthly_amount],[retail_premium_fortnightly_amount],[retail_premium_weekly_amount],[retail_premium_amount]
      ,[retail_premium_incl_gst_amount],[wholesale_premium_over_term_amount],[wholesale_premium_amount],[premium_term_in_months],[premium_amount],[premium_with_gst_amount],[premium_with_gst_payable_amount],[loading_over_policy_term_amount]
      ,[loading_amount],[loading_amount_percent],[additional_risk_premium_amount],[gst_amount],[gst_base_rate_amount],[dps_convenience_fee_amount],[fire_service_levy_amount],[fire_service_levy_base_rate_amount]
	  ,[fire_service_levy_with_gst_payable_amount] ,[life_insurance_fee_amount],[life_insurance_fee_base_rate_percentage],[road_side_assist_fee_amount],[has_road_side_assist_flag],[roadside_assist_amount],[is_roadside_assist_flag]
      ,[roadside_assist_end_datetime],[roadside_assist_original_end_date],[roadside_assist_duration_in_months],[nzra_live_flag],[claim_limit_amount],[roadside_breakdown_notes],[previous_vehicle_insurance_flag]
      ,[other_insurance_with_us_flag],[other_insurance_with_us_details],[sum_insured_amount],[interested_parties_id],[interested_parties_name],[excess_amount],[wind_screen_excess_amount],[under_age21_excess_amount]
      ,[age_21to25_excess_amount],[standard_excess_amount],[mandatory_excess_amount],[excess_optional_id],[excess_optional_amount],[overseas_license_excess_amount],[learners_license_excess_amount],[additional_excess_amount]
      ,[no_claims_modifier_percentage],[max_payable_loss_use_amount],[named_driver_flag],[exclude_under_age25_flag],[accident_flag],[accident_details],[stolen_burnt_flag],[stolen_burnt_details],[underwriting_status]
      ,[underwriting_reason],[underwriting_comments],[duty_of_disclosure_notes],[driving_offence_flag],[driving_offence_details],[licence_cancelled_flag],[licence_cancelled_details],[non_private_use_flag],[non_private_use_details]
      ,[vehicle_modified_flag],[vehicle_modification_details],[claim_withdrawn_flag],[claim_withdrawn_details],[conviction_flag],[conviction_details],[criminal_activity_flag],[criminal_activity_details],[vehicle_owned_by_other_flag]
      ,[vehicle_owned_by_other_details],[other_factors_flag],[other_factors_details],[information_complete_flag],[information_complete_details],[privacy_claims_register_agree_flag],[privacy_disclose_information_agree_flag]
      ,[privacy_obtain_information_agree_flag],[vehicle_location_street],[vehicle_location_suburb],[vehicle_location_city],[vehicle_location_postcode],[vehicle_intended_use_business_flag],[vehicle_kept_region_id]
      ,[vehicle_kept_description],[vehicle_kept_city],[vehicle_kept_suburb],[vehicle_kept_address],[vehicle_has_alarm_flag],[vehicle_has_immobiliser_flag],[vehicle_modifications_description],[vehicle_mod_body_kit_flag]
      ,[vehicle_mod_decoration_flag],[vehicle_mod_engine_flag],[vehicle_mod_exhaust_flag],[vehicle_mod_gauges_flag],[vehicle_mod_glass_flag],[vehicle_mod_suspension_flag],[vehicle_mod_mags_amount],[vehicle_mod_stereo_amount]
      ,[vehicle_mod_other_amount],[pmvs_commission_variable_amount],[pmvs_commission_fixed_amount],[declaration_notes],[xml_seq_number],[is_renewal_flag],[renewal_pending_flag],[is_marsh_renewal_flag],[marsh_id]
	  ,[posm_annual_invoice_flag],[contract_number],[contract_date],[legacy_policy_number],[pmvs_policy_id],[parent_policy_id],[child_policy_id],[policy_type_id],[policy_notes],[policy_holder_licence_type_flag]    
	 
	  ,[policy_holder_has_licence_suspended_flag],[policy_holder_has_previous_claims_flag],[policy_holder_has_vehicle_loss_flag] ,[policy_holder_has_driving_offences_flag],[policy_holder_has_criminal_offence_flag],[policy_holder_has_criminal_offence_bankrupt_flag]
      ,[policy_holder_has_criminal_offence_prosecution_flag],[policy_holder_has_criminal_offence_convicted_flag],[policy_booklet_version],[policy_booklet_name],[is_policy_disabled_flag],[responsible_lending_terms_acknowledge_flag]
      ,[auto_expired_datetime],[cancelled_datetime],[deactivated_datetime],[insurance_type_code],[e_delivery_pref_code],[send_edocs_now_flag],[sent_to_ecm_flag],[created_by_wholesale_premium_flag],[financier_name]
      ,[financed_amount],[balance_payable_amount],[financed_from_datetime],[finance_term_in_months],[monthly_installments_amount],[balloon_payments_notes],[underwriting_premium_amount],[additional_notes],[financial_rating_notes]
      ,[acknowledgment_notes],[other_details],[policy_event_coverage_causes],[alert_backdated_flag],[gap_amount],[special_benefits_amount],[financier_id],[legacy_soi_number],[request_approval_flag],[policyholder_benefit_id]
      ,[loan_number],[which_insured_flag],[new_loan_type_id],[loan_balance_amount],[loan_total_amount],[other_outstanding_loans_flag],[balance_already_covered_amount],[excess_id],[claim_limit_tyres_amount],[claim_limit_rims_amount]
      ,[dispensations_notes],[original_duration_in_months],[original_excess_amount],[original_premium_amount],[original_claim_limit_amount],[original_claim_limit_tyres_amount],[original_claim_limit_rims_amount],[adhoc_set_flag]
      ,[adhoc_dispensation_notes],[adhoc_modified_by_user_id],[adhoc_modified_datetime],[is_transferred_flag],[latest_transfer_id],[premium_funded_flag],[payment_instalment_amount],[recurring_schedule_payment_number]
      ,[recurring_schedule_number_of_months],[payment_total_amount],[commission_code],[commission_rate],[commission_total_amount],[commission_report_file_dump_date],[is_special_extended_cover_flag],[promotion_id],[last_updated_date]
      ,[record_end_datetime]
	  )
	  VALUES 
	  (
	   POLICIES.[id],POLICIES.[policy_number],POLICIES.gap_vehicle_insurer_policy_number,POLICIES.[product_code],POLICIES.[quote_id],POLICIES.[cover_type_id],POLICIES.[cover_type_name],POLICIES.[cover_option_dealer_specific_flag],POLICIES.[cover_option_id],POLICIES.[cover_option_description],POLICIES.[dealer_id],POLICIES.[dealer_user_id]
      ,POLICIES.[dealer_name],POLICIES.[dealer_sales_rep_name],POLICIES.[dealer_rep_code],POLICIES.[dealer_deactivated_flag],POLICIES.[dealer_retail_premium_amount],POLICIES.[dealer_incentive_amount],POLICIES.[rating_card_id],POLICIES.[brand_id],POLICIES.[brand_name],POLICIES.[branch_id],POLICIES.[branch_name]
	  ,POLICIES.[insurance_product_id],POLICIES.[policy_status_code],POLICIES.[insurance_refused_flag],POLICIES.[insurance_refused_details],POLICIES.[refund_amount],POLICIES.[refund_by_wholesale_premium_flag],POLICIES.[refund_datetime],POLICIES.[payment_type_description],POLICIES.[payment_frequency_code]
      ,POLICIES.[payment_reference_number],POLICIES.[dob_1],POLICIES.[dob_2],POLICIES.[primary_driver_accident_free_years],POLICIES.[primary_driver_gender_code],POLICIES.[product_name],POLICIES.[policy_purchase_datetime],POLICIES.[invoiced_datetime],POLICIES.[policy_valid_from_date],POLICIES.[policy_valid_to_date]
      ,POLICIES.[policy_term_in_months],POLICIES.[retail_premium_over_policy_term_amount],POLICIES.[retail_premium_annual_amount],POLICIES.[retail_premium_monthly_amount],POLICIES.[retail_premium_fortnightly_amount],POLICIES.[retail_premium_weekly_amount],POLICIES.[retail_premium_amount]
      ,POLICIES.[retail_premium_incl_gst_amount],POLICIES.[wholesale_premium_over_term_amount],POLICIES.[wholesale_premium_amount],POLICIES.[premium_term_in_months],POLICIES.[premium_amount],POLICIES.[premium_with_gst_amount],POLICIES.[premium_with_gst_payable_amount],POLICIES.[loading_over_policy_term_amount]
      ,POLICIES.[loading_amount],POLICIES.[loading_amount_percent],POLICIES.[additional_risk_premium_amount],POLICIES.[gst_amount],POLICIES.[gst_base_rate_amount],POLICIES.[dps_convenience_fee_amount],POLICIES.[fire_service_levy_amount],POLICIES.[fire_service_levy_base_rate_amount]
	  ,POLICIES.[fire_service_levy_with_gst_payable_amount] ,POLICIES.[life_insurance_fee_amount],POLICIES.[life_insurance_fee_base_rate_percentage],POLICIES.[road_side_assist_fee_amount],POLICIES.[has_road_side_assist_flag],POLICIES.[roadside_assist_amount],POLICIES.[is_roadside_assist_flag]
      ,POLICIES.[roadside_assist_end_datetime],POLICIES.[roadside_assist_original_end_date],POLICIES.[roadside_assist_duration_in_months],POLICIES.[nzra_live_flag],POLICIES.[claim_limit_amount],POLICIES.[roadside_breakdown_notes],POLICIES.[previous_vehicle_insurance_flag]
      ,POLICIES.[other_insurance_with_us_flag],POLICIES.[other_insurance_with_us_details],POLICIES.[sum_insured_amount],POLICIES.[interested_parties_id],POLICIES.[interested_parties_name],POLICIES.[excess_amount],POLICIES.[wind_screen_excess_amount],POLICIES.[under_age21_excess_amount]
      ,POLICIES.[age_21to25_excess_amount],POLICIES.[standard_excess_amount],POLICIES.[mandatory_excess_amount],POLICIES.[excess_optional_id],POLICIES.[excess_optional_amount],POLICIES.[overseas_license_excess_amount],POLICIES.[learners_license_excess_amount],POLICIES.[additional_excess_amount]
      ,POLICIES.[no_claims_modifier_percentage],POLICIES.[max_payable_loss_use_amount],POLICIES.[named_driver_flag],POLICIES.[exclude_under_age25_flag],POLICIES.[accident_flag],POLICIES.[accident_details],POLICIES.[stolen_burnt_flag],POLICIES.[stolen_burnt_details],POLICIES.[underwriting_status]
      ,POLICIES.[underwriting_reason],POLICIES.[underwriting_comments],POLICIES.[duty_of_disclosure_notes],POLICIES.[driving_offence_flag],POLICIES.[driving_offence_details],POLICIES.[licence_cancelled_flag],POLICIES.[licence_cancelled_details],POLICIES.[non_private_use_flag],POLICIES.[non_private_use_details]
      ,POLICIES.[vehicle_modified_flag],POLICIES.[vehicle_modification_details],POLICIES.[claim_withdrawn_flag],POLICIES.[claim_withdrawn_details],POLICIES.[conviction_flag],POLICIES.[conviction_details],POLICIES.[criminal_activity_flag],POLICIES.[criminal_activity_details],POLICIES.[vehicle_owned_by_other_flag]
      ,POLICIES.[vehicle_owned_by_other_details],POLICIES.[other_factors_flag],POLICIES.[other_factors_details],POLICIES.[information_complete_flag],POLICIES.[information_complete_details],POLICIES.[privacy_claims_register_agree_flag],POLICIES.[privacy_disclose_information_agree_flag]
      ,POLICIES.[privacy_obtain_information_agree_flag],POLICIES.[vehicle_location_street],POLICIES.[vehicle_location_suburb],POLICIES.[vehicle_location_city],POLICIES.[vehicle_location_postcode],POLICIES.[vehicle_intended_use_business_flag],POLICIES.[vehicle_kept_region_id]
      ,POLICIES.[vehicle_kept_description],POLICIES.[vehicle_kept_city],POLICIES.[vehicle_kept_suburb],POLICIES.[vehicle_kept_address],POLICIES.[vehicle_has_alarm_flag],POLICIES.[vehicle_has_immobiliser_flag],POLICIES.[vehicle_modifications_description],POLICIES.[vehicle_mod_body_kit_flag]
      ,POLICIES.[vehicle_mod_decoration_flag],POLICIES.[vehicle_mod_engine_flag],POLICIES.[vehicle_mod_exhaust_flag],POLICIES.[vehicle_mod_gauges_flag],POLICIES.[vehicle_mod_glass_flag],POLICIES.[vehicle_mod_suspension_flag],POLICIES.[vehicle_mod_mags_amount],POLICIES.[vehicle_mod_stereo_amount]
      ,POLICIES.[vehicle_mod_other_amount],POLICIES.[pmvs_commission_variable_amount],POLICIES.[pmvs_commission_fixed_amount],POLICIES.[declaration_notes],POLICIES.[xml_seq_number],POLICIES.[is_renewal_flag],POLICIES.[renewal_pending_flag],POLICIES.[is_marsh_renewal_flag],POLICIES.[marsh_id]
	  ,POLICIES.[posm_annual_invoice_flag],POLICIES.[contract_number],POLICIES.[contract_date],POLICIES.[legacy_policy_number],POLICIES.[pmvs_policy_id],POLICIES.[parent_policy_id],POLICIES.[child_policy_id],POLICIES.[policy_type_id],POLICIES.[policy_notes],POLICIES.[policy_holder_licence_type_flag]

      ,POLICIES.[policy_holder_has_licence_suspended_flag],POLICIES.[policy_holder_has_previous_claims_flag],POLICIES.[policy_holder_has_vehicle_loss_flag] ,POLICIES.[policy_holder_has_driving_offences_flag],POLICIES.[policy_holder_has_criminal_offence_flag],POLICIES.[policy_holder_has_criminal_offence_bankrupt_flag]
      ,POLICIES.[policy_holder_has_criminal_offence_prosecution_flag],POLICIES.[policy_holder_has_criminal_offence_convicted_flag],POLICIES.[policy_booklet_version],POLICIES.[policy_booklet_name],POLICIES.[is_policy_disabled_flag],POLICIES.[responsible_lending_terms_acknowledge_flag]
      ,POLICIES.[auto_expired_datetime],POLICIES.[cancelled_datetime],POLICIES.[deactivated_datetime],POLICIES.[insurance_type_code],POLICIES.[e_delivery_pref_code],POLICIES.[send_edocs_now_flag],POLICIES.[sent_to_ecm_flag],POLICIES.[created_by_wholesale_premium_flag],POLICIES.[financier_name]
      ,POLICIES.[financed_amount],POLICIES.[balance_payable_amount],POLICIES.[financed_from_datetime],POLICIES.[finance_term_in_months],POLICIES.[monthly_installments_amount],POLICIES.[balloon_payments_notes],POLICIES.[underwriting_premium_amount],POLICIES.[additional_notes],POLICIES.[financial_rating_notes]
      ,POLICIES.[acknowledgment_notes],POLICIES.[other_details],POLICIES.[policy_event_coverage_causes],POLICIES.[alert_backdated_flag],POLICIES.[gap_amount],POLICIES.[special_benefits_amount],POLICIES.[financier_id],POLICIES.[legacy_soi_number],POLICIES.[request_approval_flag],POLICIES.[policyholder_benefit_id]
      ,POLICIES.[loan_number],POLICIES.[which_insured_flag],POLICIES.[new_loan_type_id],POLICIES.[loan_balance_amount],POLICIES.[loan_total_amount],POLICIES.[other_outstanding_loans_flag],POLICIES.[balance_already_covered_amount],POLICIES.[excess_id],POLICIES.[claim_limit_tyres_amount],POLICIES.[claim_limit_rims_amount]
      ,POLICIES.[dispensations_notes],POLICIES.[original_duration_in_months],POLICIES.[original_excess_amount],POLICIES.[original_premium_amount],POLICIES.[original_claim_limit_amount],POLICIES.[original_claim_limit_tyres_amount],POLICIES.[original_claim_limit_rims_amount],POLICIES.[adhoc_set_flag]
      ,POLICIES.[adhoc_dispensation_notes],POLICIES.[adhoc_modified_by_user_id],POLICIES.[adhoc_modified_datetime],POLICIES.[is_transferred_flag],POLICIES.[latest_transfer_id],POLICIES.[premium_funded_flag],POLICIES.[payment_instalment_amount],POLICIES.[recurring_schedule_payment_number]
      ,POLICIES.[recurring_schedule_number_of_months],POLICIES.[payment_total_amount],POLICIES.[commission_code],POLICIES.[commission_rate],POLICIES.[commission_total_amount],POLICIES.[commission_report_file_dump_date],POLICIES.[is_special_extended_cover_flag],POLICIES.[promotion_id],POLICIES.[last_updated_date]
      ,@end_date
	  )
	  WHEN MATCHED and 
	  data.dim_policy.[last_updated_date] <> POLICIES.[last_updated_date]

	  THEN 
	  UPDATE SET data.[dim_policy].[record_end_datetime] = getdate() AT TIME ZONE 'UTC' AT TIME ZONE 'New Zealand Standard Time',
      data.[dim_policy].[record_current_flag] = 0,
      data.[dim_policy].last_updated = getdate() AT TIME ZONE 'UTC' AT TIME ZONE 'New Zealand Standard Time'

	  WHEN NOT MATCHED BY SOURCE AND data.[dim_policy].policy_key <> -1 and [record_current_flag] = 1 THEN 
      UPDATE SET data.[dim_policy].is_deleted = 1,
      data.[dim_policy].[record_end_datetime] = getdate() AT TIME ZONE 'UTC' AT TIME ZONE 'New Zealand Standard Time',
      data.[dim_policy].[record_current_flag] = 0;

	  INSERT into data.[dim_policy] 
		(
		[policy_id],[policy_number],gap_vehicle_insurer_policy_number,[product_code],[quote_id],[cover_type_id],[cover_type_name],[cover_option_dealer_specific_flag],[cover_option_id],[cover_option_description],[dealer_id],[dealer_user_id]
      ,[dealer_name],[dealer_sales_rep_name],[dealer_rep_code],[dealer_deactivated_flag],[dealer_retail_premium_amount],[dealer_incentive_amount],[rating_card_id],[brand_id],[brand_name],[branch_id],[branch_name]
	  ,[insurance_product_id],[policy_status_code],[insurance_refused_flag],[insurance_refused_details],[refund_amount],[refund_by_wholesale_premium_flag],[refund_datetime],[payment_type_description],[payment_frequency_code]
      ,[payment_reference_number],[dob_1],[dob_2],[primary_driver_accident_free_years],[primary_driver_gender_code],[product_name],[policy_purchase_datetime],[invoiced_datetime],[policy_valid_from_date],[policy_valid_to_date]
      ,[policy_term_in_months],[retail_premium_over_policy_term_amount],[retail_premium_annual_amount],[retail_premium_monthly_amount],[retail_premium_fortnightly_amount],[retail_premium_weekly_amount],[retail_premium_amount]
      ,[retail_premium_incl_gst_amount],[wholesale_premium_over_term_amount],[wholesale_premium_amount],[premium_term_in_months],[premium_amount],[premium_with_gst_amount],[premium_with_gst_payable_amount],[loading_over_policy_term_amount]
      ,[loading_amount],[loading_amount_percent],[additional_risk_premium_amount],[gst_amount],[gst_base_rate_amount],[dps_convenience_fee_amount],[fire_service_levy_amount],[fire_service_levy_base_rate_amount]
	  ,[fire_service_levy_with_gst_payable_amount] ,[life_insurance_fee_amount],[life_insurance_fee_base_rate_percentage],[road_side_assist_fee_amount],[has_road_side_assist_flag],[roadside_assist_amount],[is_roadside_assist_flag]
      ,[roadside_assist_end_datetime],[roadside_assist_original_end_date],[roadside_assist_duration_in_months],[nzra_live_flag],[claim_limit_amount],[roadside_breakdown_notes],[previous_vehicle_insurance_flag]
      ,[other_insurance_with_us_flag],[other_insurance_with_us_details],[sum_insured_amount],[interested_parties_id],[interested_parties_name],[excess_amount],[wind_screen_excess_amount],[under_age21_excess_amount]
      ,[age_21to25_excess_amount],[standard_excess_amount],[mandatory_excess_amount],[excess_optional_id],[excess_optional_amount],[overseas_license_excess_amount],[learners_license_excess_amount],[additional_excess_amount]
      ,[no_claims_modifier_percentage],[max_payable_loss_use_amount],[named_driver_flag],[exclude_under_age25_flag],[accident_flag],[accident_details],[stolen_burnt_flag],[stolen_burnt_details],[underwriting_status]
      ,[underwriting_reason],[underwriting_comments],[duty_of_disclosure_notes],[driving_offence_flag],[driving_offence_details],[licence_cancelled_flag],[licence_cancelled_details],[non_private_use_flag],[non_private_use_details]
      ,[vehicle_modified_flag],[vehicle_modification_details],[claim_withdrawn_flag],[claim_withdrawn_details],[conviction_flag],[conviction_details],[criminal_activity_flag],[criminal_activity_details],[vehicle_owned_by_other_flag]
      ,[vehicle_owned_by_other_details],[other_factors_flag],[other_factors_details],[information_complete_flag],[information_complete_details],[privacy_claims_register_agree_flag],[privacy_disclose_information_agree_flag]
      ,[privacy_obtain_information_agree_flag],[vehicle_location_street],[vehicle_location_suburb],[vehicle_location_city],[vehicle_location_postcode],[vehicle_intended_use_business_flag],[vehicle_kept_region_id]
      ,[vehicle_kept_description],[vehicle_kept_city],[vehicle_kept_suburb],[vehicle_kept_address],[vehicle_has_alarm_flag],[vehicle_has_immobiliser_flag],[vehicle_modifications_description],[vehicle_mod_body_kit_flag]
      ,[vehicle_mod_decoration_flag],[vehicle_mod_engine_flag],[vehicle_mod_exhaust_flag],[vehicle_mod_gauges_flag],[vehicle_mod_glass_flag],[vehicle_mod_suspension_flag],[vehicle_mod_mags_amount],[vehicle_mod_stereo_amount]
      ,[vehicle_mod_other_amount],[pmvs_commission_variable_amount],[pmvs_commission_fixed_amount],[declaration_notes],[xml_seq_number],[is_renewal_flag],[renewal_pending_flag],[is_marsh_renewal_flag],[marsh_id]
	  ,[posm_annual_invoice_flag],[contract_number],[contract_date],[legacy_policy_number],[pmvs_policy_id],[parent_policy_id],[child_policy_id],[policy_type_id],[policy_notes],[policy_holder_licence_type_flag]    
	 ,[policy_holder_has_licence_suspended_flag],[policy_holder_has_previous_claims_flag],[policy_holder_has_vehicle_loss_flag] ,[policy_holder_has_driving_offences_flag],[policy_holder_has_criminal_offence_flag],[policy_holder_has_criminal_offence_bankrupt_flag]
      ,[policy_holder_has_criminal_offence_prosecution_flag],[policy_holder_has_criminal_offence_convicted_flag],[policy_booklet_version],[policy_booklet_name],[is_policy_disabled_flag],[responsible_lending_terms_acknowledge_flag]
      ,[auto_expired_datetime],[cancelled_datetime],[deactivated_datetime],[insurance_type_code],[e_delivery_pref_code],[send_edocs_now_flag],[sent_to_ecm_flag],[created_by_wholesale_premium_flag],[financier_name]
      ,[financed_amount],[balance_payable_amount],[financed_from_datetime],[finance_term_in_months],[monthly_installments_amount],[balloon_payments_notes],[underwriting_premium_amount],[additional_notes],[financial_rating_notes]
      ,[acknowledgment_notes],[other_details],[policy_event_coverage_causes],[alert_backdated_flag],[gap_amount],[special_benefits_amount],[financier_id],[legacy_soi_number],[request_approval_flag],[policyholder_benefit_id]
      ,[loan_number],[which_insured_flag],[new_loan_type_id],[loan_balance_amount],[loan_total_amount],[other_outstanding_loans_flag],[balance_already_covered_amount],[excess_id],[claim_limit_tyres_amount],[claim_limit_rims_amount]
      ,[dispensations_notes],[original_duration_in_months],[original_excess_amount],[original_premium_amount],[original_claim_limit_amount],[original_claim_limit_tyres_amount],[original_claim_limit_rims_amount],[adhoc_set_flag]
      ,[adhoc_dispensation_notes],[adhoc_modified_by_user_id],[adhoc_modified_datetime],[is_transferred_flag],[latest_transfer_id],[premium_funded_flag],[payment_instalment_amount],[recurring_schedule_payment_number]
      ,[recurring_schedule_number_of_months],[payment_total_amount],[commission_code],[commission_rate],[commission_total_amount],[commission_report_file_dump_date],[is_special_extended_cover_flag],[promotion_id],[last_updated_date]
      ,[record_end_datetime]
	  )
	  SELECT  #policy.[id],#policy.[policy_number],#policy.gap_vehicle_insurer_policy_number,#policy.[product_code],#policy.[quote_id],#policy.[cover_type_id],#policy.[cover_type_name]
	  ,#policy.[cover_option_dealer_specific_flag],#policy.[cover_option_id],#policy.[cover_option_description],#policy.[dealer_id],#policy.[dealer_user_id]
      ,#policy.[dealer_name],#policy.[dealer_sales_rep_name],#policy.[dealer_rep_code],#policy.[dealer_deactivated_flag]  
	  ,#policy.[dealer_retail_premium_amount],#policy.[dealer_incentive_amount],#policy.[rating_card_id],#policy.[brand_id],#policy.[brand_name],#policy.[branch_id],#policy.[branch_name]
	  ,#policy.[insurance_product_id],#policy.[policy_status_code],#policy.[insurance_refused_flag],#policy.[insurance_refused_details],#policy.[refund_amount]
	  ,#policy.[refund_by_wholesale_premium_flag],#policy.[refund_datetime],#policy.[payment_type_description],#policy.[payment_frequency_code]
      ,#policy.[payment_reference_number],#policy.[dob_1],#policy.[dob_2],#policy.[primary_driver_accident_free_years],#policy.[primary_driver_gender_code]
	  ,#policy.[product_name],#policy.[policy_purchase_datetime],#policy.[invoiced_datetime],#policy.[policy_valid_from_date],#policy.[policy_valid_to_date]
      ,#policy.[policy_term_in_months],#policy.[retail_premium_over_policy_term_amount],#policy.[retail_premium_annual_amount],#policy.[retail_premium_monthly_amount]
	  ,#policy.[retail_premium_fortnightly_amount],#policy.[retail_premium_weekly_amount],#policy.[retail_premium_amount]
      ,#policy.[retail_premium_incl_gst_amount],#policy.[wholesale_premium_over_term_amount],#policy.[wholesale_premium_amount],#policy.[premium_term_in_months]
	  ,#policy.[premium_amount],#policy.[premium_with_gst_amount],#policy.[premium_with_gst_payable_amount],#policy.[loading_over_policy_term_amount]
      ,#policy.[loading_amount],#policy.[loading_amount_percent],#policy.[additional_risk_premium_amount],#policy.[gst_amount],#policy.[gst_base_rate_amount]
	  ,#policy.[dps_convenience_fee_amount],#policy.[fire_service_levy_amount],#policy.[fire_service_levy_base_rate_amount]
	  ,#policy.[fire_service_levy_with_gst_payable_amount] ,#policy.[life_insurance_fee_amount],#policy.[life_insurance_fee_base_rate_percentage],#policy.[road_side_assist_fee_amount]
	  ,#policy.[has_road_side_assist_flag],#policy.[roadside_assist_amount],#policy.[is_roadside_assist_flag]
      ,#policy.[roadside_assist_end_datetime],#policy.[roadside_assist_original_end_date],#policy.[roadside_assist_duration_in_months],#policy.[nzra_live_flag],#policy.[claim_limit_amount]
	  ,#policy.[roadside_breakdown_notes],#policy.[previous_vehicle_insurance_flag]
      ,#policy.[other_insurance_with_us_flag],#policy.[other_insurance_with_us_details],#policy.[sum_insured_amount],#policy.[interested_parties_id],#policy.[interested_parties_name]
	  ,#policy.[excess_amount],#policy.[wind_screen_excess_amount],#policy.[under_age21_excess_amount]
      ,#policy.[age_21to25_excess_amount],#policy.[standard_excess_amount],#policy.[mandatory_excess_amount],#policy.[excess_optional_id],#policy.[excess_optional_amount]
	  ,#policy.[overseas_license_excess_amount],#policy.[learners_license_excess_amount],#policy.[additional_excess_amount]
      ,#policy.[no_claims_modifier_percentage],#policy.[max_payable_loss_use_amount],#policy.[named_driver_flag],#policy.[exclude_under_age25_flag],#policy.[accident_flag]
	  ,#policy.[accident_details],#policy.[stolen_burnt_flag],#policy.[stolen_burnt_details],#policy.[underwriting_status]
      ,#policy.[underwriting_reason],#policy.[underwriting_comments],#policy.[duty_of_disclosure_notes],#policy.[driving_offence_flag],#policy.[driving_offence_details]
	  ,#policy.[licence_cancelled_flag],#policy.[licence_cancelled_details],#policy.[non_private_use_flag],#policy.[non_private_use_details]
      ,#policy.[vehicle_modified_flag],#policy.[vehicle_modification_details],#policy.[claim_withdrawn_flag],#policy.[claim_withdrawn_details],#policy.[conviction_flag]
	  ,#policy.[conviction_details],#policy.[criminal_activity_flag],#policy.[criminal_activity_details],#policy.[vehicle_owned_by_other_flag]
      ,#policy.[vehicle_owned_by_other_details],#policy.[other_factors_flag],#policy.[other_factors_details],#policy.[information_complete_flag],#policy.[information_complete_details]
	  ,#policy.[privacy_claims_register_agree_flag],#policy.[privacy_disclose_information_agree_flag]
      ,#policy.[privacy_obtain_information_agree_flag],#policy.[vehicle_location_street],#policy.[vehicle_location_suburb],#policy.[vehicle_location_city],#policy.[vehicle_location_postcode]
	  ,#policy.[vehicle_intended_use_business_flag],#policy.[vehicle_kept_region_id]
      ,#policy.[vehicle_kept_description],#policy.[vehicle_kept_city],#policy.[vehicle_kept_suburb],#policy.[vehicle_kept_address],#policy.[vehicle_has_alarm_flag]
	  ,#policy.[vehicle_has_immobiliser_flag],#policy.[vehicle_modifications_description],#policy.[vehicle_mod_body_kit_flag]
      ,#policy.[vehicle_mod_decoration_flag],#policy.[vehicle_mod_engine_flag],#policy.[vehicle_mod_exhaust_flag],#policy.[vehicle_mod_gauges_flag],#policy.[vehicle_mod_glass_flag]
	  ,#policy.[vehicle_mod_suspension_flag],#policy.[vehicle_mod_mags_amount],#policy.[vehicle_mod_stereo_amount]
      ,#policy.[vehicle_mod_other_amount],#policy.[pmvs_commission_variable_amount],#policy.[pmvs_commission_fixed_amount],#policy.[declaration_notes],#policy.[xml_seq_number]
	  ,#policy.[is_renewal_flag],#policy.[renewal_pending_flag],#policy.[is_marsh_renewal_flag],#policy.[marsh_id]
	  ,#policy.[posm_annual_invoice_flag],#policy.[contract_number],#policy.[contract_date],#policy.[legacy_policy_number],#policy.[pmvs_policy_id],#policy.[parent_policy_id]
	  ,#policy.[child_policy_id],#policy.[policy_type_id],#policy.[policy_notes],#policy.[policy_holder_licence_type_flag]
      ,#policy.[policy_holder_has_licence_suspended_flag],#policy.[policy_holder_has_previous_claims_flag],#policy.[policy_holder_has_vehicle_loss_flag] ,#policy.[policy_holder_has_driving_offences_flag]
	  ,#policy.[policy_holder_has_criminal_offence_flag],#policy.[policy_holder_has_criminal_offence_bankrupt_flag]
      ,#policy.[policy_holder_has_criminal_offence_prosecution_flag],#policy.[policy_holder_has_criminal_offence_convicted_flag],#policy.[policy_booklet_version],#policy.[policy_booklet_name]
	  ,#policy.[is_policy_disabled_flag],#policy.[responsible_lending_terms_acknowledge_flag]
      ,#policy.[auto_expired_datetime],#policy.[cancelled_datetime],#policy.[deactivated_datetime],#policy.[insurance_type_code],#policy.[e_delivery_pref_code]
	  ,#policy.[send_edocs_now_flag],#policy.[sent_to_ecm_flag],#policy.[created_by_wholesale_premium_flag],#policy.[financier_name]
      ,#policy.[financed_amount],#policy.[balance_payable_amount],#policy.[financed_from_datetime],#policy.[finance_term_in_months],#policy.[monthly_installments_amount]
	  ,#policy.[balloon_payments_notes],#policy.[underwriting_premium_amount],#policy.[additional_notes],#policy.[financial_rating_notes]
      ,#policy.[acknowledgment_notes],#policy.[other_details],#policy.[policy_event_coverage_causes],#policy.[alert_backdated_flag],#policy.[gap_amount]
	  ,#policy.[special_benefits_amount],#policy.[financier_id],#policy.[legacy_soi_number],#policy.[request_approval_flag],#policy.[policyholder_benefit_id]
      ,#policy.[loan_number],#policy.[which_insured_flag],#policy.[new_loan_type_id],#policy.[loan_balance_amount],#policy.[loan_total_amount],#policy.[other_outstanding_loans_flag]
	  ,#policy.[balance_already_covered_amount],#policy.[excess_id],#policy.[claim_limit_tyres_amount],#policy.[claim_limit_rims_amount]
      ,#policy.[dispensations_notes],#policy.[original_duration_in_months],#policy.[original_excess_amount],#policy.[original_premium_amount],#policy.[original_claim_limit_amount]
	  ,#policy.[original_claim_limit_tyres_amount],#policy.[original_claim_limit_rims_amount],#policy.[adhoc_set_flag]
      ,#policy.[adhoc_dispensation_notes],#policy.[adhoc_modified_by_user_id],#policy.[adhoc_modified_datetime],#policy.[is_transferred_flag],#policy.[latest_transfer_id]
	  ,#policy.[premium_funded_flag],#policy.[payment_instalment_amount],#policy.[recurring_schedule_payment_number]
      ,#policy.[recurring_schedule_number_of_months],#policy.[payment_total_amount],#policy.[commission_code],#policy.[commission_rate],#policy.[commission_total_amount]
	  ,#policy.[commission_report_file_dump_date],#policy.[is_special_extended_cover_flag],#policy.[promotion_id],#policy.[last_updated_date]
      ,@end_date from #policy 
	  left join data.dim_policy 
	  ON
	  data.[dim_policy].[policy_id] = #policy.id
      AND data.[dim_policy].[policy_number] = #policy.[policy_number]
      AND data.[dim_policy].[product_code]  = #policy.[product_code] 
	  and data.[dim_policy].[record_current_flag] = 1  and data.[dim_policy].is_deleted = 0
	  where data.[dim_policy].policy_id  is null 

	  END
GO


