/****** Object:  StoredProcedure [dbo].[udsp_test_dim_dealer]    Script Date: 22/10/2021 9:52:16 am ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[udsp_test_dim_dealer] --@sql nvarchar(max) with execute as owner

AS
BEGIN
	declare @vsqletlsp varchar(255) = '[sp_data].[populate_dim_dealer]'
			,@vtablename varchar(255) = 'dim_dealer'
			,@vcolumnname varchar(255) 
			,@vstartdatetime datetime
			,@venddatetime	datetime
			--- C2 columns
			,@vTypeKey int
			,@vGenID int
			,@vDealerSpecID varchar(100)
			,@vDealerID int
			,@vCompName varchar(100)
			,@vrecord_startdatetime datetime
			,@vrecord_enddatetime	datetime
			,@vrecord_currentflag	int
			--- C1 variables
			,@VDestinationTable		varchar(255)
			,@vDestinationColumn	varchar(255)
			,@vSourceTableName		varchar(255)
			,@vSourceColumnName		varchar(255)
			,@vsqlnotes			nvarchar(max)
			---- temp table variables
			,@vcurrentflagpass varchar(1)
			,@vrecord_start_datetpass varchar(1)
			,@vrecord_end_datepass varchar(1) 
			,@numberofrows			int = 0


	declare  @dim_dealer_test_results TABLE
		(
			tablename varchar(255) NOT NULL,
			columnname varchar(255) NOT NULL,
			sourcetablename varchar(255) NOT NULL,
			sourcecolumnname varchar(255) NOT NULL,
			dealerkey		int  null,
			genericcovertypeid int  null,
			dealerspecificcovertypeid	int  null,
			dealerid int  null,
			companyname	varchar(255) null,
			currentflagpass varchar(1) NOT NULL,
			record_start_datetpass varchar(1) NOT NULL,
			record_end_datepass varchar(1) NOT NULL,
			update_datetime	datetime null
		)
	
	declare  c1 cursor for 
				select DestinationTable, DestinationColumn, SourceTableName, SourceColumnName, sqlnotes
				from dbo.dim_dealer_test_case
	
	declare c2 cursor for 
				select dealer_key, a.[generic_cover_type_id], a.dealer_specific_cover_type_id,a.dealer_id ,a.[company_name], record_start_datetime, record_end_datetime, record_current_flag
				from Data.dim_dealer a 
					where last_updated is null
					and dealer_id in (select max(id) from ext_piclos.dealer)
	
	open c1
	fetch c1 into @vDestinationTable, @vDestinationColumn, @vSourceTableName, @vSourceColumnName, @vsqlnotes
	WHILE @@FETCH_STATUS = 0  
	BEGIN
		set @vstartdatetime = getdate() AT TIME ZONE 'UTC' AT TIME ZONE 'New Zealand Standard Time'

		EXEC sp_execute_remote @data_source_name  = N'linked_sourcedb', 
		@stmt = @vsqlnotes

		exec @vsqletlsp

		set @venddatetime = getdate() AT TIME ZONE 'UTC' AT TIME ZONE 'New Zealand Standard Time'

		open c2
		fetch c2 into  @vTypeKey, @vGenID, @vDealerSpecID, @vDealerID, @vCompName, @vrecord_startdatetime, @vrecord_enddatetime, @vrecord_currentflag
		WHILE @@FETCH_STATUS = 0  
		BEGIN
			IF @vTypeKey IS NOT NULL
			BEGIN
				-- FOR DEBUGGING
				set @numberofrows = @numberofrows + 1
				--SELECT  @vTypeKey, @vGenID, @vDealerSpecID, @vDealerID, @vCompName, @vrecord_startdatetime, @vrecord_enddatetime, @vrecord_currentflag
				--PRINT @vDestinationTable + ' ' +  @vDestinationColumn + ' ' +  @vSourceTableName + ' ' +  @vSourceColumnName + ' ' +  @vsqlnotes
				-- END
				if @vrecord_startdatetime > @vstartdatetime and @vrecord_startdatetime < @venddatetime
				   set @vrecord_start_datetpass = '1'
				else 
				   set @vrecord_start_datetpass = '0'

				if @vrecord_enddatetime = '2049-12-31 00:00:00.000'
				   set @vrecord_end_datepass = '1'
				else 
				   set @vrecord_end_datepass = '0'

				if @vrecord_currentflag = '1'
				   set @vcurrentflagpass = '1'
				else 
				   set @vcurrentflagpass = '0'

				insert into @dim_dealer_test_results 
					(tablename, columnname, sourcetablename, sourcecolumnname, dealerkey,genericcovertypeid, dealerspecificcovertypeid, dealerid, companyname, currentflagpass, record_start_datetpass, record_end_datepass, update_datetime)
					values (@vDestinationTable, @vDestinationColumn, @vSourceTableName, @vSourceColumnName, @vTypeKey, @vGenID, @vDealerSpecID, @vDealerID, @vCompName, @vcurrentflagpass, @vrecord_start_datetpass, @vrecord_end_datepass, @venddatetime)
			END
			fetch c2 into  @vTypeKey, @vGenID, @vDealerSpecID, @vDealerID, @vCompName, @vrecord_startdatetime, @vrecord_enddatetime, @vrecord_currentflag
		END
		--print @numberofrows
		if @numberofrows = 0 
			   insert into @dim_dealer_test_results 
					(tablename, columnname, sourcetablename, sourcecolumnname, dealerkey,genericcovertypeid, dealerspecificcovertypeid, dealerid, companyname, currentflagpass, record_start_datetpass, record_end_datepass, update_datetime)
					values (@vDestinationTable, @vDestinationColumn, @vSourceTableName, @vSourceColumnName, @vTypeKey, @vGenID, @vDealerSpecID, @vDealerID, @vCompName, @vcurrentflagpass, @vrecord_start_datetpass, @vrecord_end_datepass, @venddatetime)
		else
			set @numberofrows = 0
		close c2
		fetch c1 into @vDestinationTable, @vDestinationColumn, @vSourceTableName, @vSourceColumnName, @vsqlnotes
	END
	close c1
	deallocate c1
	deallocate c2
	select * from @dim_dealer_test_results order by update_datetime
END
GO

exec [dbo].[udsp_test_dim_dealer]

exec [sp_data].[populate_dim_dealer]

--select incentive_account_start_date, incentive_account_end_date, disabled_date from ext_piclos.dealer where incentive_account_start_date like '0001%' or incentive_account_end_date like '0001%' or disabled_date like '0001%' 
--select b.* from data.dim_dealer a
--full join ext_piclos.dealer b on a.dealer_id = b.id
--where dealer_id is null

--select a.* from data.dim_dealer a
--full join ext_piclos.dealer b on a.dealer_id = b.id
--where id is null
--and dealer_key <> -1

select accounts_receivable_email, * from data.dim_dealer where dealer_id in (select max(id) from ext_piclos.dealer) and record_current_flag = 1
select accounts_receivable_email, * from ext_piclos.dealer  where id in (select max(id) from ext_piclos.dealer)


IF EXISTS (select * from sys.sysobjects where name = 'dim_dealer_test_case')
	DROP TABLE dbo.dim_dealer_test_case

CREATE TABLE dbo.dim_dealer_test_case
(DestinationTable		varchar(255),
 DestinationColumn		varchar(255),
 SourceTableName		varchar(255),
 SourceColumnName		varchar(255),
 sqlnotes				nvarchar(max),
CONSTRAINT [PK_dim_dealer_ts] PRIMARY KEY CLUSTERED 
(
	DestinationTable ASC,
	DestinationColumn ASC,
	SourceTableName ASC,
	SourceColumnName ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

delete from dbo.dim_dealer_test_case 
--select * from dbo.dim_dealer_test_case 

--exec [dbo].[udsp_test_dim_dealer]

INSERT INTO dbo.dim_dealer_test_case VALUES 

('dim_dealer','company_name','dealer','company_name',N'update piclos.dealer set company_name = company_name + ''1'', last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.dealer where id in (select max(id) from piclos.dealer )')
,('dim_dealer','registered_company_name','dealer','registered_company_name',N'update piclos.dealer set registered_company_name = registered_company_name + ''1'', last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.dealer  where id in (select max(id) from piclos.dealer )')
,('dim_dealer','registration_number','dealer','registration_number',N'update piclos.dealer set registration_number = registration_number + ''1'', last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time''  from piclos.dealer where id in (select max(id) from piclos.dealer )')
,('dim_dealer','gst_number','dealer','gst_number',N'update piclos.dealer set gst_number = gst_number + ''1'', last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time''  from piclos.dealer where id in (select max(id) from piclos.dealer )')
,('dim_dealer','manager_name','dealer','manager_name',N'update piclos.dealer set manager_name = manager_name + ''1'', last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time''  from piclos.dealer where id in (select max(id) from piclos.dealer )')
,('dim_dealer','physical_address_street_name','dealer','street',N'update piclos.dealer set street = street + ''1'', last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time''  from piclos.dealer where id in (select max(id) from piclos.dealer )')
,('dim_dealer','physical_address_suburb_name','dealer','suburb',N'update piclos.dealer set suburb = suburb + ''1'', last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time''  from piclos.dealer where id in (select max(id) from piclos.dealer )')
,('dim_dealer','physical_address_city','dealer','city',N'update piclos.dealer set city = city + ''1'', last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time''  from piclos.dealer where id in (select max(id) from piclos.dealer )')
,('dim_dealer','physical_address_region_id','dealer','region_id',N'update piclos.dealer set region_id = region_id + 1, last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time''  from piclos.dealer where id in (select max(id) from piclos.dealer )')
,('dim_dealer','physical_address_postcode','dealer','postcode',N'update piclos.dealer set postcode = postcode + ''1'', last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time''  from piclos.dealer where id in (select max(id) from piclos.dealer )')
,('dim_dealer','postal_address_1','dealer','postal_address_1',N'update piclos.dealer set postal_address_1 = postal_address_1 + ''1'', last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time''  from piclos.dealer where id in (select max(id) from piclos.dealer )')
,('dim_dealer','postal_address_2','dealer','postal_address_2',N'update piclos.dealer set postal_address_2 = postal_address_2 + ''1'', last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time''  from piclos.dealer where id in (select max(id) from piclos.dealer )')
,('dim_dealer','postal_address_3','dealer','postal_address_3',N'update piclos.dealer set postal_address_3 = postal_address_3 + ''1'', last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time''  from piclos.dealer where id in (select max(id) from piclos.dealer )')
,('dim_dealer','postal_postcode','dealer','postal_postcode',N'update piclos.dealer set postal_postcode = postal_postcode + ''1'', last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time''  from piclos.dealer where id in (select max(id) from piclos.dealer )')
,('dim_dealer','phone_number','dealer','phone',N'update piclos.dealer set phone = phone + ''1'', last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time''  from piclos.dealer where id in (select max(id) from piclos.dealer )')
,('dim_dealer','fax_number','dealer','fax',N'update piclos.dealer set fax = fax + ''1'', last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time''  from piclos.dealer where id in (select max(id) from piclos.dealer )')
,('dim_dealer','accounts_receivable_email','dealer','accounts_receivable_email',N'update piclos.dealer set accounts_receivable_email = accounts_receivable_email + ''1'', last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time''  from piclos.dealer where id in (select max(id) from piclos.dealer )')
,('dim_dealer','website_name','dealer','website',N'update piclos.dealer set website = website + ''1'', last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time''  from piclos.dealer where id in (select max(id) from piclos.dealer )')
,('dim_dealer','dms_list','dealer','dms_list',N'update piclos.dealer set dms_list = dms_list + ''1'', last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time''  from piclos.dealer where id in (select max(id) from piclos.dealer )')
,('dim_dealer','primary_contact_firstname','dealer','contact_firstname_1',N'update piclos.dealer set contact_firstname_1 = contact_firstname_1 + ''1'', last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time''  from piclos.dealer where id in (select max(id) from piclos.dealer )')
,('dim_dealer','primary_contact_lastname','dealer','contact_lastname_1',N'update piclos.dealer set contact_lastname_1 = contact_lastname_1 + ''1'', last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time''  from piclos.dealer where id in (select max(id) from piclos.dealer )')
,('dim_dealer','primary_contact_email','dealer','email_1',N'update piclos.dealer set email_1 = email_1 + ''1'', last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.dealer where id in (select max(id) from piclos.dealer )')
,('dim_dealer','primary_contract_mobile','dealer','mobile_1',N'update piclos.dealer set mobile_1 = mobile_1 + ''1'', last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time''  from piclos.dealer where id in (select max(id) from piclos.dealer )')
,('dim_dealer','primary_contact_guid','dealer','contact_guid_1',N'update piclos.dealer set contact_guid_1 = contact_guid_1 + ''1'', last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time''  from piclos.dealer where id in (select max(id) from piclos.dealer )')
,('dim_dealer','secondary_contact_firstname','dealer','contact_firstname_2',N'update piclos.dealer set contact_firstname_2 = contact_firstname_2 + ''1'', last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time''  from piclos.dealer where id in (select max(id) from piclos.dealer )')
,('dim_dealer','secondary_contact_lastname','dealer','contact_lastname_2',N'update piclos.dealer set contact_lastname_2 = contact_lastname_2 + ''1'', last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time''  from piclos.dealer where id in (select max(id) from piclos.dealer )')
,('dim_dealer','secondary_contact_email','dealer','email_2',N'update piclos.dealer set email_2 = email_2 + ''1'', last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time''  from piclos.dealer where id in (select max(id) from piclos.dealer )')
,('dim_dealer','secondary_contract_mobile','dealer','mobile_2',N'update piclos.dealer set mobile_2 = mobile_2 + ''1'', last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time''  from piclos.dealer where id in (select max(id) from piclos.dealer )')
,('dim_dealer','secondary_contact_guid','dealer','contact_guid_2',N'update piclos.dealer set contact_guid_2 = contact_guid_2 + ''1'', last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time''  from piclos.dealer where id in (select max(id) from piclos.dealer )')
,('dim_dealer','third_contact_firstname','dealer','contact_firstname_3',N'update piclos.dealer set contact_firstname_3 = contact_firstname_3 + ''1'', last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time''  from piclos.dealer where id in (select max(id) from piclos.dealer )')
,('dim_dealer','third_contact_lastname','dealer','contact_lastname_3',N'update piclos.dealer set contact_lastname_3 = contact_lastname_3 + ''1'', last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time''  from piclos.dealer where id in (select max(id) from piclos.dealer )')
,('dim_dealer','third_contact_email','dealer','email_3',N'update piclos.dealer set email_3 = email_3 + ''1'', last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time''  from piclos.dealer where id in (select max(id) from piclos.dealer )')
,('dim_dealer','third_contract_mobile','dealer','mobile_3',N'update piclos.dealer set mobile_3 = mobile_3 + ''1'', last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time''  from piclos.dealer where id in (select max(id) from piclos.dealer )')
,('dim_dealer','third_contact_guid','dealer','contact_guid_3',N'update piclos.dealer set contact_guid_3 = contact_guid_3 + ''1'', last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time''  from piclos.dealer where id in (select max(id) from piclos.dealer )')
,('dim_dealer','dealer_disabled_flag','dealer','is_disabled',N'update piclos.dealer  set is_disabled = case when is_disabled = 1 then 0 when is_disabled = 0 then 1 end, last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time''   from piclos.dealer where id in (select max(id) from piclos.dealer )')
,('dim_dealer','dealer_active_flag','dealer','is_active',N'update piclos.dealer set is_active = case when is_active = 1 then 0 when is_active = 0 then 1 end, last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time''   from piclos.dealer where id in (select max(id) from piclos.dealer )')
,('dim_dealer','dealer_created_date','dealer','created_date',N'update piclos.dealer set created_date = dateadd(d,1,created_date), last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time''  from piclos.dealer where id in (select max(id) from piclos.dealer )')
,('dim_dealer','dealer_disabled_date','dealer','disabled_date',N'update piclos.dealer set disabled_date = dateadd(d,1,getdate()), last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time''  from piclos.dealer where id in (select max(id) from piclos.dealer )')
,('dim_dealer','has_signed_agency_agreement_flag','dealer','has_signed_agency_agreement',N'update piclos.dealer set has_signed_agency_agreement = case when has_signed_agency_agreement = 1 then 0 when has_signed_agency_agreement = 0 then 1 end, last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time''   from piclos.dealer where id in (select max(id) from piclos.dealer )')
,('dim_dealer','has_signed_posm_agreement_flag','dealer','has_signed_posm_agreement',N'update piclos.dealer set has_signed_posm_agreement = case when has_signed_posm_agreement = 1 then 0 when has_signed_posm_agreement = 0 then 1 end, last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.dealer where id in (select max(id) from piclos.dealer )')
,('dim_dealer','has_posm_luxury_matrix_flag','dealer','has_posm_luxury_matrix',N'update piclos.dealer set has_posm_luxury_matrix = case when has_posm_luxury_matrix = 1 then 0 when has_posm_luxury_matrix = 0 then 1 end, last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time''   from piclos.dealer where id in (select max(id) from piclos.dealer )')
,('dim_dealer','has_signed_incentive_agreement_flag','dealer','has_signed_incentive_agreement',N'update piclos.dealer set has_signed_incentive_agreement = case when has_signed_incentive_agreement = 1 then 0 when has_signed_incentive_agreement = 0 then 1 end, last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.dealer where id in (select max(id) from piclos.dealer )')
,('dim_dealer','dealer_closed_flag','dealer','dealer_closed',N'update piclos.dealer set dealer_closed = case when dealer_closed = 1 then 0 when dealer_closed = 0 then 1 end, last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time''  from piclos.dealer where id in (select max(id) from piclos.dealer )')
,('dim_dealer','dealer_liquidated_flag','dealer','dealer_liquidated',N'update piclos.dealer set dealer_liquidated = case when dealer_liquidated = 1 then 0 when dealer_liquidated = 0 then 1 end, last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time''   from piclos.dealer where id in (select max(id) from piclos.dealer )')
,('dim_dealer','dealer_to_competitor_flag','dealer','dealer_to_competitor',N'update piclos.dealer set dealer_to_competitor = case when dealer_to_competitor = 1 then 0 when dealer_to_competitor = 0 then 1 end, last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time''  from piclos.dealer where id in (select max(id) from piclos.dealer )')
,('dim_dealer','dealer_disabled_status_description','dealer','dealer_status_reason',N'update piclos.dealer set dealer_status_reason = dealer_status_reason + ''1'', last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time''  from piclos.dealer where id in (select max(id) from piclos.dealer )')
,('dim_dealer','incentive_account_start_date','dealer','incentive_account_start_date',N'update piclos.dealer set incentive_account_start_date = dateadd(d,1,getdate()), last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time''  from piclos.dealer where id in (select max(id) from piclos.dealer )')
,('dim_dealer','incentive_account_end_date','dealer','incentive_account_end_date',N'update piclos.dealer set incentive_account_end_date = dateadd(d,1,getdate()), last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time''  from piclos.dealer where id in (select max(id) from piclos.dealer )')
,('dim_dealer','cci_wholesale_premium_flag','dealer','use_wholesale_premium',N'update piclos.dealer set use_wholesale_premium = case when use_wholesale_premium = 1 then 0 when use_wholesale_premium = 0 then 1 end, last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time''   from piclos.dealer where id in (select max(id) from piclos.dealer )')
,('dim_dealer','cci_retail_premium_flag','dealer','use_cci_retail_premium',N'update piclos.dealer set use_cci_retail_premium = case when use_cci_retail_premium = 1 then 0 when use_cci_retail_premium = 0 then 1 end, last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time''   from piclos.dealer where id in (select max(id) from piclos.dealer )')
,('dim_dealer','dd_invoice_flag','dealer','use_dd_invoice',N'update piclos.dealer set use_dd_invoice = case when use_dd_invoice = 1 then 0 when use_dd_invoice = 0 then 1 end, last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time''   from piclos.dealer where id in (select max(id) from piclos.dealer )')
,('dim_dealer','automated_policy_creation_flag','dealer','automated_policy_creation',N'update piclos.dealer set automated_policy_creation = case when automated_policy_creation = 1 then 0 when automated_policy_creation = 0 then 1 end, last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time''  from piclos.dealer where id in (select max(id) from piclos.dealer )')
,('dim_dealer','automated_motorcentral_flag','dealer','automated_motorcentral',N'update piclos.dealer set automated_motorcentral = case when automated_motorcentral = 1 then 0 when automated_motorcentral = 0 then 1 end, last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time''  from piclos.dealer where id in (select max(id) from piclos.dealer )')
,('dim_dealer','motorcentral_account_code','dealer','motorcentral_account_code',N'update piclos.dealer set motorcentral_account_code = motorcentral_account_code + ''1'', last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.dealer where id in (select max(id) from piclos.dealer )')
,('dim_dealer','cci_18_month_flag','dealer','cci_18_month_term',N'update piclos.dealer set cci_18_month_term = case when cci_18_month_term = 1 then 0 when cci_18_month_term = 0 then 1 end, last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time''  from piclos.dealer where id in (select max(id) from piclos.dealer )')
,('dim_dealer','policy_import_flag','dealer','policy_import',N'update piclos.dealer set policy_import = case when policy_import = 1 then 0 when policy_import = 0 then 1 end, last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time''  from piclos.dealer where id in (select max(id) from piclos.dealer )')
,('dim_dealer','has_contract_no_flag','dealer','use_contract_no',N'update piclos.dealer set use_contract_no = case when use_contract_no = 1 then 0 when use_contract_no = 0 then 1 end, last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time''  from piclos.dealer where id in (select max(id) from piclos.dealer )')
,('dim_dealer','cannot_apply_mbi_roadside_assist_flag','dealer','not_has_mbi_roadside_assist',N'update piclos.dealer set not_has_mbi_roadside_assist = case when not_has_mbi_roadside_assist = 1 then 0 when not_has_mbi_roadside_assist = 0 then 1 end , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time''  from piclos.dealer where id in (select max(id) from piclos.dealer )')
,('dim_dealer','has_prorata_calculator_mbi_refund_flag','dealer','has_mbi_refund_prorata',N'update piclos.dealer set has_mbi_refund_prorata = case when has_mbi_refund_prorata = 1 then 0 when has_mbi_refund_prorata = 0 then 1 end , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time''  from piclos.dealer where id in (select max(id) from piclos.dealer )')
,('dim_dealer','use_posm_annual_invoice_flag','dealer','use_posm_annual_invoice',N'update piclos.dealer set use_posm_annual_invoice = case when use_posm_annual_invoice = 1 then 0 when use_posm_annual_invoice = 0 then 1 end , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time''  from piclos.dealer where id in (select max(id) from piclos.dealer )')
,('dim_dealer','send_invoice_by_spreadsheet_flag','dealer','use_invoice_by_spreadsheet',N'update piclos.dealer set use_invoice_by_spreadsheet = case when use_invoice_by_spreadsheet = 1 then 0 when use_invoice_by_spreadsheet = 0 then 1 end , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time''  from piclos.dealer where id in (select max(id) from piclos.dealer )')
,('dim_dealer','mbi_motorcover_agreement_signed_flag','dealer','mbi_motorcover_agreement',N'update piclos.dealer set mbi_motorcover_agreement = case when mbi_motorcover_agreement = 1 then 0 when mbi_motorcover_agreement = 0 then 1 end, last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time''   from piclos.dealer where id in (select max(id) from piclos.dealer )')
,('dim_dealer','has_giltrap_business_use_enabled_flag','dealer','has_business_use',N'update piclos.dealer set has_business_use = case when has_business_use = 1 then 0 when has_business_use = 0 then 1 end, last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time''   from piclos.dealer where id in (select max(id) from piclos.dealer )')
,('dim_dealer','credit_union_flag','dealer','is_credit_union',N'update piclos.dealer set is_credit_union = case when is_credit_union = 1 then 0 when is_credit_union = 0 then 1 end , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time''  from piclos.dealer where id in (select max(id) from piclos.dealer )')
,('dim_dealer','provident_brand_disabled_flag','dealer','provident_brand_disabled',N'update piclos.dealer set provident_brand_disabled = case when provident_brand_disabled = 1 then 0 when provident_brand_disabled = 0 then 1 end , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time''  from piclos.dealer where id in (select max(id) from piclos.dealer )')
,('dim_dealer','default_brand_id','dealer','default_brand_id',N'update piclos.dealer set default_brand_id = isnull(default_brand_id,0) + 1 , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.dealer where id in (select max(id) from piclos.dealer )')
,('dim_dealer','rating_card_id','dealer','rating_card_id',N'update piclos.dealer set rating_card_id = isnull(rating_card_id,0) + 1, last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time''  from piclos.dealer where id in (select max(id) from piclos.dealer )')
,('dim_dealer','crm_guid','dealer','crm_guid',N'update piclos.dealer set crm_guid = crm_guid + ''1'', last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time''  from piclos.dealer where id in (select max(id) from piclos.dealer )')
,('dim_dealer','uses_epb_flag','dealer','uses_epb',N'update piclos.dealer set uses_epb = case when uses_epb = 1 then 0 when uses_epb = 0 then 1 end, last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time''   from piclos.dealer where id in (select max(id) from piclos.dealer )')
