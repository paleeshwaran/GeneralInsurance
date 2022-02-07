/****** Object:  StoredProcedure [sp_data].[populate_dim_cover_type]    Script Date: 21/09/2021 7:32:19 am ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


IF EXISTS (select * from sys.sysobjects where name = 'udsp_test_dim_cover_type')
	DROP PROCEDURE [dbo].[udsp_test_dim_cover_type]
GO

CREATE PROCEDURE [dbo].[udsp_test_dim_cover_type] --@sql nvarchar(max) with execute as owner

AS
BEGIN
	declare @vsqletlsp varchar(255) = '[sp_data].[populate_dim_cover_type]'
			,@vtablename varchar(255) = 'dim_cover_type'
			,@vcolumnname varchar(255) 
			,@vstartdatetime datetime
			,@venddatetime	datetime
			--- C2 columns
			,@vCoverTypeKey int
			,@vCoverTypeID int
			,@vProductCode varchar(4)
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


	declare  @dim_cover_type_test_results TABLE
		(
			tablename varchar(255) NOT NULL,
			columnname varchar(255) NOT NULL,
			sourcetablename varchar(255) NOT NULL,
			sourcecolumnname varchar(255) NOT NULL,
			currentflagpass varchar(1) NOT NULL,
			record_start_datetpass varchar(1) NOT NULL,
			record_end_datepass varchar(1) NOT NULL
		)
	set @vstartdatetime = getdate() AT TIME ZONE 'UTC' AT TIME ZONE 'New Zealand Standard Time'
	declare  c1 cursor for 
				select DestinationTable, DestinationColumn, SourceTableName, SourceColumnName, sqlnotes
				from dbo.dim_cover_type_test_case
	
	declare c2 cursor for 
				select cover_type_key, a.cover_type_id, a.product_code, record_start_datetime, record_end_datetime, record_current_flag
				from Data.dim_cover_type a 
				join (select max(cover_type_id) cover_type_id, product_code 
							from Data.dim_cover_type 
							where product_code in ('cci','gap','lnm','mbi','posm','tar')
							group by product_code) b
					on a.cover_type_id = b.cover_type_id and a.product_code = b.product_code
					where last_updated is null
	
	open c1
	fetch c1 into @vDestinationTable, @vDestinationColumn, @vSourceTableName, @vSourceColumnName, @vsqlnotes
	WHILE @@FETCH_STATUS = 0  
	BEGIN
		EXEC sp_execute_remote @data_source_name  = N'linked_sourcedb', 
		@stmt = @vsqlnotes

		exec @vsqletlsp

		set @venddatetime = getdate() AT TIME ZONE 'UTC' AT TIME ZONE 'New Zealand Standard Time'

		open c2
		fetch c2 into  @vCoverTypeKey, @vCoverTypeID, @vProductCode, @vrecord_startdatetime, @vrecord_enddatetime, @vrecord_currentflag
		WHILE @@FETCH_STATUS = 0  
		BEGIN
			IF LEFT (@vProductCode,3) = LEFT(@vSourceTableName,3)
			BEGIN
				-- FOR DEBUGGING
				set @numberofrows = @numberofrows + 1
				--SELECT @vCoverTypeKey, @vCoverTypeID, @vProductCode, @vrecord_startdatetime, @vrecord_enddatetime, @vrecord_currentflag
				--		, @vstartdatetime, @venddatetime
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

				insert into @dim_cover_type_test_results 
					(tablename, columnname, sourcetablename, sourcecolumnname, currentflagpass, record_start_datetpass, record_end_datepass)
					values (@vDestinationTable, @vDestinationColumn, @vSourceTableName, @vSourceColumnName, @vcurrentflagpass, @vrecord_start_datetpass, @vrecord_end_datepass)
			END
			fetch c2 into  @vCoverTypeKey, @vCoverTypeID, @vProductCode, @vrecord_startdatetime, @vrecord_enddatetime, @vrecord_currentflag
		END
		--print @numberofrows
		if @numberofrows = 0 
			   insert into @dim_cover_type_test_results 
					(tablename, columnname, sourcetablename, sourcecolumnname, currentflagpass, record_start_datetpass, record_end_datepass)
					values (@vDestinationTable, @vDestinationColumn, @vSourceTableName, @vSourceColumnName, 0, 0, 0)
		else
			set @numberofrows = 0
		close c2
		fetch c1 into @vDestinationTable, @vDestinationColumn, @vSourceTableName, @vSourceColumnName, @vsqlnotes
	END
	close c1
	deallocate c1
	deallocate c2
	select * from @dim_cover_type_test_results
END
GO

select * from dbo.dim_cover_type_test_case
select * from data.dim_cover_type

exec [dbo].[udsp_test_dim_cover_type] 

exec sp_data.[populate_dim_cover_type]

select top 2 cover_type_key, cover_type_id, product_code, cover_description, posm_roadside_assit_flag, record_start_datetime, record_end_datetime
,record_current_flag, bi_created, last_updated, is_deleted
from data.dim_cover_type 
where  (cover_type_id  = 4 and product_code = 'posm')
order by record_start_datetime desc, record_end_datetime desc

select has_road_side_assist, * from ext_piclos.posm_cover_type where id in (select max(id) from ext_piclos.posm_cover_type)

select title, * from ext_piclos.tar_cover_type where id in (select max(id) from ext_piclos.tar_cover_type)
select title, * from ext_piclos.cci_cover_type where id in (select max(id) from ext_piclos.cci_cover_type)
select title, * from ext_piclos.gap_cover_type where id in (select max(id) from ext_piclos.gap_cover_type)
select title, * from ext_piclos.lnm_cover_type where id in (select max(id) from ext_piclos.lnm_cover_type)
select title, * from ext_piclos.mbi_cover_type where id in (select max(id) from ext_piclos.mbi_cover_type)
select title, * from ext_piclos.posm_cover_type where id in (select max(id) from ext_piclos.posm_cover_type)

--IF EXISTS (select * from sys.sysobjects where name = 'dim_cover_type_test_case')
--	DROP TABLE dbo.dim_cover_type_test_case

--CREATE TABLE dbo.dim_cover_type_test_case
--(DestinationTable		varchar(255),
-- DestinationColumn		varchar(255),
-- SourceTableName		varchar(255),
-- SourceColumnName		varchar(255),
-- sqlnotes				nvarchar(max),
--CONSTRAINT [PK_dim_cover_type_ts] PRIMARY KEY CLUSTERED 
--(
--	DestinationTable ASC,
--	DestinationColumn ASC,
--	SourceTableName ASC,
--	SourceColumnName ASC
--)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
--) ON [PRIMARY]
--GO

--delete from dbo.dim_cover_type_test_case 

--INSERT INTO dbo.dim_cover_type_test_case VALUES 
---- cover_type_id
-- ('dim_cover_type','cover_type_id','cci_cover_type','id',N'update piclos.cci_cover_type set id = id + 1 from piclos.cci_cover_type where id in (select max(id) from piclos.cci_cover_type )')
--,('dim_cover_type','cover_type_id','gap_cover_type','id',N'update piclos.gap_cover_type set id = id + 1 from piclos.gap_cover_type where id in (select max(id) from piclos.gap_cover_type )')
--,('dim_cover_type','cover_type_id','lnm_cover_type','id',N'update piclos.lnm_cover_type set id = id + 1 from piclos.lnm_cover_type where id in (select max(id) from piclos.lnm_cover_type )')
--,('dim_cover_type','cover_type_id','mbi_cover_type','id',N'update piclos.mbi_cover_type set id = id + 1 from piclos.mbi_cover_type where id in (select max(id) from piclos.mbi_cover_type )')
--,('dim_cover_type','cover_type_id','posm_cover_type','id',N'update piclos.posm_cover_type set id = id + 1 from piclos.posm_cover_type where id in (select max(id) from piclos.posm_cover_type )')
--,('dim_cover_type','cover_type_id','tar_cover_type','id',N'update piclos.tar_cover_type set id = id + 1 from piclos.tar_cover_type where id in (select max(id) from piclos.tar_cover_type )')
----product_type
-- ,('dim_cover_type','product_code','cci_cover_type','product_type',N'update piclos.insurance_product set product_type = product_type + ''1'' from piclos.insurance_product where id in (select max(id) from piclos.gap_cover_type )')
--,('dim_cover_type','product_code','gap_cover_type','product_type',N'update piclos.gap_cover_type set product_type = product_type +  ''1''  from piclos.gap_cover_type where id in (select max(id) from piclos.gap_cover_type )')
--,('dim_cover_type','product_code','lnm_cover_type','product_type',N'update piclos.lnm_cover_type set product_type = product_type +  ''1''  from piclos.lnm_cover_type where id in (select max(id) from piclos.lnm_cover_type )')
--,('dim_cover_type','product_code','mbi_cover_type','product_type',N'update piclos.mbi_cover_type set product_type = product_type +  ''1''  from piclos.mbi_cover_type where id in (select max(id) from piclos.mbi_cover_type )')
--,('dim_cover_type','product_code','posm_cover_type','product_type',N'update piclos.posm_cover_type set product_type = product_type +  ''1'' from piclos.posm_cover_type where id in (select max(id) from piclos.posm_cover_type )')
--,('dim_cover_type','product_code','tar_cover_type','product_type',N'update piclos.tar_cover_type set product_type = product_type +  ''1'' from piclos.tar_cover_type where id in (select max(id) from piclos.tar_cover_type )')
----cover_description
-- ,('dim_cover_type','cover_description','cci_cover_type','title',N'update piclos.cci_cover_type set title = title + ''1'' from piclos.cci_cover_type where id in (select max(id) from piclos.cci_cover_type)')
--,('dim_cover_type','cover_description','gap_cover_type','title',N'update piclos.gap_cover_type set title = title + ''1'' from piclos.gap_cover_type where id in (select max(id) from piclos.gap_cover_type)')
--,('dim_cover_type','cover_description','lnm_cover_type','title',N'update piclos.lnm_cover_type set title = title + ''1'' from piclos.lnm_cover_type where id in (select max(id) from piclos.lnm_cover_type)')
--,('dim_cover_type','cover_description','mbi_cover_type','title',N'update piclos.mbi_cover_type set title = title + ''1'' from piclos.mbi_cover_type where id in (select max(id) from piclos.mbi_cover_type)')
--,('dim_cover_type','cover_description','posm_cover_type','title',N'update piclos.posm_cover_type set title = title + ''1'' from piclos.posm_cover_type where id in (select max(id) from piclos.posm_cover_type)')
--,('dim_cover_type','cover_description','tar_cover_type','title',N'update piclos.tar_cover_type set title = title + ''1'' from piclos.tar_cover_type where id in (select max(id) from piclos.tar_cover_type)')
----cover_active_flag 
-- ,('dim_cover_type','cover_active_flag','cci_cover_type','is_enabled ',N'update piclos.cci_cover_type set is_enabled = case when is_enabled = 1 then 0 when is_enabled = 0 then 1 end from piclos.cci_cover_type where id in (select max(id) from piclos.cci_cover_type)')
--,('dim_cover_type','cover_active_flag','gap_cover_type','is_enabled ',N'update piclos.gap_cover_type set is_enabled = case when is_enabled = 1 then 0 when is_enabled = 0 then 1 end from piclos.gap_cover_type where id in (select max(id) from piclos.gap_cover_type)')
--,('dim_cover_type','cover_active_flag','lnm_cover_type','is_enabled ',N'update piclos.lnm_cover_type set is_enabled = case when is_enabled = 1 then 0 when is_enabled = 0 then 1 end from piclos.lnm_cover_type where id in (select max(id) from piclos.lnm_cover_type)')
--,('dim_cover_type','cover_active_flag','mbi_cover_type','is_enabled ',N'update piclos.mbi_cover_type set is_enabled = case when is_enabled = 1 then 0 when is_enabled = 0 then 1 end from piclos.mbi_cover_type where id in (select max(id) from piclos.mbi_cover_type)')
--,('dim_cover_type','cover_active_flag','posm_cover_type','is_enabled ',N'update piclos.posm_cover_type set is_enabled = case when is_enabled = 1 then 0 when is_enabled = 0 then 1 end from piclos.posm_cover_type where id in (select max(id) from piclos.posm_cover_type)')
--,('dim_cover_type','cover_active_flag','tar_cover_type','is_enabled',N'update piclos.tar_cover_type set is_enabled = case when is_enabled = 1 then 0 when is_enabled = 0 then 1 end from piclos.tar_cover_type where id in (select max(id) from piclos.tar_cover_type)')
----dealer_group_id
--,('dim_cover_type','dealer_group_id','mbi_cover_type','dealer_group_id',N'update piclos.mbi_cover_type set dealer_group_id = dealer_group_id + 1 from piclos.mbi_cover_type where id in (select max(id) from piclos.mbi_cover_type)')
----dealer_id
--,('dim_cover_type','dealer_id','mbi_cover_type','dealer_id',N'update piclos.mbi_cover_type set dealer_id  = dealer_id  + 1 from piclos.mbi_cover_type where id in (select max(id) from piclos.mbi_cover_type)')
--,('dim_cover_type','dealer_id','tar_cover_type','dealer_id',N'update piclos.tar_cover_type set dealer_id  = dealer_id  + 1 from piclos.tar_cover_type where id in (select max(id) from piclos.tar_cover_type)')
----original_cover_type_id
--,('dim_cover_type','original_cover_type_id','mbi_cover_type','original_cover_type_id',N'update piclos.mbi_cover_type set original_cover_type_id  = original_cover_type_id  + 1 from piclos.mbi_cover_type where id in (select max(id) from piclos.mbi_cover_type)')
--,('dim_cover_type','original_cover_type_id','tar_cover_type','original_cover_type_id',N'update piclos.tar_cover_type set original_cover_type_id  = original_cover_type_id  + 1 from piclos.tar_cover_type where id in (select max(id) from piclos.tar_cover_type)')
----vehicle_category_id
--,('dim_cover_type','vehicle_category_id','mbi_cover_type','vehicle_category',N'update piclos.mbi_cover_type set vehicle_category = vehicle_category + 1 from piclos.mbi_cover_type where id in (select max(id) from piclos.mbi_cover_type)')
----maximum_age
--,('dim_cover_type','maximum_age','mbi_cover_type','max_age',N'update piclos.mbi_cover_type set max_age = max_age  + 1 from piclos.mbi_cover_type where id in (select max(id) from piclos.mbi_cover_type)')
--,('dim_cover_type','maximum_age','tar_cover_type','max_age',N'update piclos.tar_cover_type set max_age = max_age  + 1 from piclos.tar_cover_type where id in (select max(id) from piclos.tar_cover_type)')
----minimum_kms
--,('dim_cover_type','minimum_kms','mbi_cover_type','min_kms',N'update piclos.mbi_cover_type set min_kms = min_kms  + 1 from piclos.mbi_cover_type where id in (select max(id) from piclos.mbi_cover_type)')
--,('dim_cover_type','minimum_kms','tar_cover_type','min_kms',N'update piclos.tar_cover_type set min_kms = min_kms  + 1 from piclos.tar_cover_type where id in (select max(id) from piclos.tar_cover_type)')
----maximum_kms
--,('dim_cover_type','maximum_kms','mbi_cover_type','max_kms',N'update piclos.mbi_cover_type set max_kms = max_kms + 1 from piclos.mbi_cover_type where id in (select max(id) from piclos.mbi_cover_type)')
--,('dim_cover_type','maximum_kms','tar_cover_type','max_kms',N'update piclos.tar_cover_type set max_kms = max_kms + 1 from piclos.tar_cover_type where id in (select max(id) from piclos.tar_cover_type)')
----roadside_assist_top_up_amount
--,('dim_cover_type','roadside_assist_top_up_amount','mbi_cover_type','roadside_assist',N'update piclos.mbi_cover_type set roadside_assist = roadside_assist + 1 from piclos.mbi_cover_type where id in (select max(id) from piclos.mbi_cover_type)')
----roadside_assist_maximum_term_in_months
--,('dim_cover_type','roadside_assist_maximum_term_in_months','mbi_cover_type','roadside_assist_max_term',N'update piclos.mbi_cover_type set roadside_assist_max_term = roadside_assist_max_term + 1 from piclos.mbi_cover_type where id in (select max(id) from piclos.mbi_cover_type)')
----petrol_vehicle_service_interval_in_months
--,('dim_cover_type','petrol_vehicle_service_interval_in_months','mbi_cover_type','service_interval_petrol',N'update piclos.mbi_cover_type set service_interval_petrol = service_interval_petrol + 1 from piclos.mbi_cover_type where id in (select max(id) from piclos.mbi_cover_type)')
----petrol_vehicle_service_kms
--,('dim_cover_type','petrol_vehicle_service_kms','mbi_cover_type','service_km_petrol',N'update piclos.mbi_cover_type set service_km_petrol = service_km_petrol + 1 from piclos.mbi_cover_type where id in (select max(id) from piclos.mbi_cover_type)')
----diesel_vehicle_service_interval_in_months
--,('dim_cover_type','diesel_vehicle_service_interval_in_months','mbi_cover_type','service_interval_diesel',N'update piclos.mbi_cover_type set service_interval_diesel = service_interval_diesel + 1 from piclos.mbi_cover_type where id in (select max(id) from piclos.mbi_cover_type)')
----diesel_vehicle_service_kms
--,('dim_cover_type','diesel_vehicle_service_kms','mbi_cover_type','service_km_diesel',N'update piclos.mbi_cover_type set service_km_diesel = service_km_diesel + 1 from piclos.mbi_cover_type where id in (select max(id) from piclos.mbi_cover_type)')
----hybrid_vehicle_service_interval_in_months
--,('dim_cover_type','hybrid_vehicle_service_interval_in_months','mbi_cover_type','service_interval_hybrid',N'update piclos.mbi_cover_type set service_interval_hybrid = service_interval_hybrid + 1 from piclos.mbi_cover_type where id in (select max(id) from piclos.mbi_cover_type)')
----hybrid_vehicle_service_kms
--,('dim_cover_type','hybrid_vehicle_service_kms','mbi_cover_type','service_km_hybrid',N'update piclos.mbi_cover_type set service_km_hybrid = service_km_hybrid + 1 from piclos.mbi_cover_type where id in (select max(id) from piclos.mbi_cover_type)')
----electric_vehicle_service_interval_in_months
--,('dim_cover_type','electric_vehicle_service_interval_in_months','mbi_cover_type','service_interval_electric',N'update piclos.mbi_cover_type set service_interval_electric = service_interval_electric + 1 from piclos.mbi_cover_type where id in (select max(id) from piclos.mbi_cover_type)')
----electric_vehicle_service_kms
--,('dim_cover_type','electric_vehicle_service_kms','mbi_cover_type','service_km_electric',N'update piclos.mbi_cover_type set service_km_electric = service_km_electric + 1 from piclos.mbi_cover_type where id in (select max(id) from piclos.mbi_cover_type)')
----premium_funded_flag
--,('dim_cover_type','premium_funded_flag','mbi_cover_type','premium_funded',N'update piclos.mbi_cover_type set premium_funded = premium_funded + 1 from piclos.mbi_cover_type where id in (select max(id) from piclos.mbi_cover_type)')
----flexible_term_flag
--,('dim_cover_type','flexible_term_flag','mbi_cover_type','is_flexible_term',N'update piclos.mbi_cover_type set is_flexible_term = is_flexible_term + 1 from piclos.mbi_cover_type where id in (select max(id) from piclos.mbi_cover_type)')
----special_extended_flag
--,('dim_cover_type','special_extended_flag','mbi_cover_type','is_special_extended',N'update piclos.mbi_cover_type set is_special_extended = is_special_extended + 1 from piclos.mbi_cover_type where id in (select max(id) from piclos.mbi_cover_type)')
----gwp_account_number
--,('dim_cover_type','gwp_account_number','posm_cover_type','gwp_account_code',N'update piclos.posm_cover_type set gwp_account_code = gwp_account_code + 1 from piclos.posm_cover_type where id in (select max(id) from piclos.posm_cover_type)')
----cancellation_account_number
--,('dim_cover_type','cancellation_account_number','posm_cover_type','cancellation_account_code',N'update piclos.posm_cover_type set cancellation_account_code = cancellation_account_code + 1 from piclos.posm_cover_type where id in (select max(id) from piclos.posm_cover_type)')
----posm_roadside_assit_flag
--,('dim_cover_type','posm_roadside_assit_flag','posm_cover_type','has_road_side_assist',N'update piclos.posm_cover_type set has_road_side_assist = case when has_road_side_assist = 1 then 0 when has_road_side_assist = 0 then 1 end  from piclos.posm_cover_type where id in (select max(id) from piclos.posm_cover_type)')
----posm_term_in_month
--,('dim_cover_type','posm_term_in_month','posm_cover_type','term',N'update piclos.posm_cover_type set term = term + 1 from piclos.posm_cover_type where id in (select max(id) from piclos.posm_cover_type)')
----posm_excess_amount
--,('dim_cover_type','posm_excess_amount','posm_cover_type','excess',N'update piclos.posm_cover_type set excess = excess + 1 from piclos.posm_cover_type where id in (select max(id) from piclos.posm_cover_type)')
----other_details
--,('dim_cover_type','other_details','posm_cover_type','other_details',N'update piclos.posm_cover_type set other_details = other_details + ''1'' from piclos.posm_cover_type where id in (select max(id) from piclos.posm_cover_type)')
--,('dim_cover_type','other_details','gap_cover_type','other_details',N'update piclos.gap_cover_type set other_details = isnull(other_details,''0'') + ''1'' from piclos.gap_cover_type where id in (select max(id) from piclos.gap_cover_type)')
--,('dim_cover_type','other_details','cci_cover_type','other_details',N'update piclos.cci_cover_type set other_details = other_details + ''1'' from piclos.cci_cover_type where id in (select max(id) from piclos.cci_cover_type)')
----additional_notes
--,('dim_cover_type','additional_notes','gap_cover_type','please_note',N'update piclos.gap_cover_type set please_note = isnull(please_note,''0'') + ''1'' from piclos.gap_cover_type where id in (select max(id) from piclos.gap_cover_type)')
--,('dim_cover_type','additional_notes','cci_cover_type','please_note',N'update piclos.cci_cover_type set please_note = please_note + ''1'' from piclos.cci_cover_type where id in (select max(id) from piclos.cci_cover_type)')
----financial_rating_notes
--,('dim_cover_type','financial_rating_notes','gap_cover_type','financial_rating',N'update piclos.gap_cover_type set financial_rating = isnull(financial_rating,''0'') + ''1'' from piclos.gap_cover_type where id in (select max(id) from piclos.gap_cover_type)')
--,('dim_cover_type','financial_rating_notes','cci_cover_type','financial_rating',N'update piclos.cci_cover_type set financial_rating = financial_rating + ''1'' from piclos.cci_cover_type where id in (select max(id) from piclos.cci_cover_type)')
----acknowledgment_notes
--,('dim_cover_type','acknowledgment_notes','gap_cover_type','acknowledgments',N'update piclos.gap_cover_type set acknowledgments = isnull(acknowledgments,''0'') + ''1'' from piclos.gap_cover_type where id in (select max(id) from piclos.gap_cover_type)')
--,('dim_cover_type','acknowledgment_notes','cci_cover_type','acknowledgments',N'update piclos.cci_cover_type set acknowledgments = acknowledgments + ''1'' from piclos.cci_cover_type where id in (select max(id) from piclos.cci_cover_type)')
----contact_details
--,('dim_cover_type','contact_details','cci_cover_type','contact_details',N'update piclos.cci_cover_type set contact_details = contact_details + ''1'' from piclos.cci_cover_type where id in (select max(id) from piclos.cci_cover_type)')
----use_wholesale_premium_flag
--,('dim_cover_type','use_wholesale_premium_flag','cci_cover_type','use_wholesale_premium',N'update piclos.cci_cover_type set use_wholesale_premium = case when use_wholesale_premium = 1 then 0 when use_wholesale_premium = 0 then 1 end from piclos.cci_cover_type where id in (select max(id) from piclos.cci_cover_type)')
----rate_12_months_percentage
--,('dim_cover_type','rate_12_months_percentage','cci_cover_type','rate_percentage_12',N'update piclos.cci_cover_type set rate_percentage_12 = rate_percentage_12 + ''1'' from piclos.cci_cover_type where id in (select max(id) from piclos.cci_cover_type)')
----rate_18_months_percentage
--,('dim_cover_type','rate_18_months_percentage','cci_cover_type','rate_percentage_18',N'update piclos.cci_cover_type set rate_percentage_18 = rate_percentage_18 + ''1'' from piclos.cci_cover_type where id in (select max(id) from piclos.cci_cover_type)')
----rate_24_months_percentage
--,('dim_cover_type','rate_24_months_percentage','cci_cover_type','rate_percentage_24',N'update piclos.cci_cover_type set rate_percentage_24 = rate_percentage_24 + ''1'' from piclos.cci_cover_type where id in (select max(id) from piclos.cci_cover_type)')
----rate_36_months_percentage
--,('dim_cover_type','rate_36_months_percentage','cci_cover_type','rate_percentage_36',N'update piclos.cci_cover_type set rate_percentage_36 = rate_percentage_36 + ''1'' from piclos.cci_cover_type where id in (select max(id) from piclos.cci_cover_type)')
----rate_48_months_percentage
--,('dim_cover_type','rate_48_months_percentage','cci_cover_type','rate_percentage_48',N'update piclos.cci_cover_type set rate_percentage_48 = rate_percentage_48 + ''1'' from piclos.cci_cover_type where id in (select max(id) from piclos.cci_cover_type)')
----rate_60_months_percentage
--,('dim_cover_type','rate_60_months_percentage','cci_cover_type','rate_percentage_60',N'update piclos.cci_cover_type set rate_percentage_60 = rate_percentage_60 + ''1'' from piclos.cci_cover_type where id in (select max(id) from piclos.cci_cover_type)')
----rate_double_cover_percentage
--,('dim_cover_type','rate_double_cover_percentage','cci_cover_type','rate_double',N'update piclos.cci_cover_type set rate_double = rate_double + ''1'' from piclos.cci_cover_type where id in (select max(id) from piclos.cci_cover_type)')
----rate_retail_commission_percentage
--,('dim_cover_type','rate_retail_commission_percentage','cci_cover_type','rate_retail_commission',N'update piclos.cci_cover_type set rate_retail_commission = rate_retail_commission + ''1'' from piclos.cci_cover_type where id in (select max(id) from piclos.cci_cover_type)')
----cover_enabled_date
--,('dim_cover_type','cover_enabled_date','cci_cover_type','enabled_timestamp',N'update piclos.cci_cover_type set enabled_timestamp = dateadd(day,1,enabled_timestamp) from piclos.cci_cover_type where id in (select max(id) from piclos.cci_cover_type)')
--,('dim_cover_type','cover_enabled_date','gap_cover_type','enabled_timestamp ',N'update piclos.gap_cover_type set enabled_timestamp = dateadd(day,1,enabled_timestamp) from piclos.gap_cover_type where id in (select max(id) from piclos.gap_cover_type)')
--,('dim_cover_type','cover_enabled_date','mbi_cover_type','enabled_timestamp ',N'update piclos.mbi_cover_type set enabled_timestamp = dateadd(day,1,enabled_timestamp) from piclos.mbi_cover_type where id in (select max(id) from piclos.mbi_cover_type)')
--,('dim_cover_type','cover_enabled_date','tar_cover_type','enabled_timestamp',N'update piclos.tar_cover_type set enabled_timestamp = dateadd(day,1,enabled_timestamp ) from piclos.tar_cover_type where id in (select max(id) from piclos.tar_cover_type)')
