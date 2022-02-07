/****** Object:  StoredProcedure [dbo].[udsp_test_dim_vehicle]    Script Date: 22/10/2021 9:52:16 am ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--- Pre requisite 
		-- 1. Create table for loading test case 
		-- 2. Create table for test results
		-- 3. Data loading for test case
--- Create procedure script 


CREATE PROCEDURE [dbo].[udsp_test_dim_vehicle] --@sql nvarchar(max) with execute as owner

AS
BEGIN
	declare @vsqletlsp varchar(255) = '[sp_data].[populate_dim_vehicle]'
			,@vsqletlsp_policy varchar(255) = '[sp_data].[populate_dim_vehicle]'
			,@vtablename varchar(255) = 'dim_vehicle'
			,@vcolumnname varchar(255) 
			,@vstartdatetime datetime
			,@venddatetime	datetime
			--- C2 columns
			,@vTypeKey int
			,@vPolicyID int
			,@vvehicleID varchar(100)
			,@vProductCode varchar(4)
			--,@vDealerGroupID int
			--,@vCompName varchar(100)
			,@vrecord_startdatetime datetime
			,@vrecord_enddatetime	datetime
			,@vrecord_currentflag	int
			--- C1 variables
			,@VDestinationTable		varchar(255)
			,@vDestinationColumn	varchar(255)
			,@vSourceTableName		varchar(255)
			,@vSourceColumnName		varchar(255)
			,@vSourceDataType		varchar(10)
			,@vsqlnotes			nvarchar(max)
			---- temp table variables
			,@vsqldynamic		nvarchar(max)
			,@vsourcecolumnvalue	varchar(max)
			,@vdestinationcolumnvalue	varchar(max)
			,@vDestinationPrevColumnValue varchar(max)
			,@vcurrentflagpass varchar(1)
			,@vrecord_start_datetpass varchar(1)
			,@vrecord_end_datepass varchar(1) 
			,@vsourcetargetvalues varchar(max)
			,@numberofrows			int = 0
	
	declare  c1 cursor for 
				select DestinationTable, DestinationColumn, SourceTableName, SourceColumnName, SourceDataType, sqlnotes
				from dbo.dim_vehicle_test_case
	
	declare c2 cursor for 
				select vehicle_key, a.policy_id, a.vehicle_id, b.product_code, record_start_datetime, record_end_datetime, record_current_flag
				from Data.dim_vehicle a 
				join (select max(vehicle_id) vehicle_id, 'gap' product_code from ext_piclos.gap_policy 
						union select max(vehicle_id) vehicle_id, 'mbi' product_code  from ext_piclos.mbi_policy  
						union select  max(vehicle_id) vehicle_id, 'posm' product_code  from ext_piclos.posm_policy 
						union select max(vehicle_id) vehicle_id, 'tar' product_code  from ext_piclos.tar_policy
							) b
					on a.vehicle_id = b.vehicle_id
					where last_updated is null
					
	-- Process update statement in Source DB for diffrent scenarios
	open c1
	fetch c1 into @vDestinationTable, @vDestinationColumn, @vSourceTableName, @vSourceColumnName, @vSourceDataType, @vsqlnotes
	WHILE @@FETCH_STATUS = 0  
	BEGIN
		set @vstartdatetime = getdate() AT TIME ZONE 'UTC' AT TIME ZONE 'New Zealand Standard Time'

		EXEC sp_execute_remote @data_source_name  = N'linked_sourcedb', @stmt = @vsqlnotes 

		print @vsqlnotes

		fetch c1 into @vDestinationTable, @vDestinationColumn, @vSourceTableName, @vSourceColumnName, @vSourceDataType, @vsqlnotes
	END
	close c1
	
	-- ETL proc to update target table
	exec @vsqletlsp

	set @venddatetime = getdate() AT TIME ZONE 'UTC' AT TIME ZONE 'New Zealand Standard Time'

	delete from dbo.dim_vehicle_test_results
	--Fetch each scenario again to compare the values against target table
	open c1
	fetch c1 into @vDestinationTable, @vDestinationColumn, @vSourceTableName, @vSourceColumnName, @vSourceDataType, @vsqlnotes
	WHILE @@FETCH_STATUS = 0  
	BEGIN
		if @vSourceDataType = 'Num' 
			set @vSourceColumnName = CONVERT(VARCHAR(255), @vSourceColumnName) 
		else if @vSourceDataType = 'Date'
			set @vSourceColumnName = CONVERT(VARCHAR(255), @vSourceColumnName, 120)
		else 
			set @vSourceColumnName = @vSourceColumnName

		set @vsqldynamic = N'select @vsourcecolumnvalue = ' + @vSourceColumnName 
										+ N' from ext_piclos.' + @vSourceTableName 
										+ N' where vehicle_id in (select max(vehicle_id) from ext_piclos.'+ @vSourceTableName + N')'
		print @vsqldynamic

		-- Fetch updated table/column value from source
		exec sp_executesql 	@vsqldynamic, N'@vsourcecolumnvalue varchar(max) output', @vsourcecolumnvalue=@vsourcecolumnvalue OUTPUT 
		--select @vsourcecolumnvalue
		open c2
		fetch c2 into  @vTypeKey, @vPolicyID, @vvehicleID, @vProductCode, @vrecord_startdatetime, @vrecord_enddatetime, @vrecord_currentflag
		WHILE @@FETCH_STATUS = 0  
		BEGIN
			IF (LEFT (@vProductCode,3) = LEFT(@vSourceTableName,3))
			BEGIN
				
				if @vSourceDataType = 'Num' 
					set @vDestinationColumn = CONVERT(VARCHAR(255), @vDestinationColumn) 
				else if @vSourceDataType = 'Date'
					set @vDestinationColumn = CONVERT(VARCHAR(255), @vDestinationColumn, 120)
				else 
					set @vDestinationColumn = @vDestinationColumn
					
					
				set @vsqldynamic = N'select @vdestinationcolumnvalue = ' + @vDestinationColumn 
										+ N' from data.' +@VDestinationTable 
										+ N' where vehicle_key = ' + convert(nvarchar, @vTypeKey)
										
				--Fetch updated column value from target table
				exec sp_executesql 	@vsqldynamic, N'@vdestinationcolumnvalue varchar(max) output', @vdestinationcolumnvalue=@vdestinationcolumnvalue OUTPUT 
				
				if @vSourceDataType = 'Num' 
					set @vDestinationPrevColumnValue = CONVERT(VARCHAR(255), @vDestinationPrevColumnValue) 
				else if @vSourceDataType = 'Date'
					set @vDestinationPrevColumnValue = CONVERT(VARCHAR(255), @vDestinationPrevColumnValue, 120)
				else 
					set @vDestinationPrevColumnValue = @vDestinationPrevColumnValue
					
					
				set @vsqldynamic = N'select @vDestinationPrevColumnValue = ' + @vDestinationColumn 
										+ N' from data.' +@VDestinationTable 
										+ N' where policy_id = ' + convert(nvarchar, @vPolicyID)
										+ N' and record_end_datetime between ' + N'''' + convert(nvarchar, @vstartdatetime, 121) + N''''  
										+' and ' + + N'''' + convert(nvarchar, @venddatetime, 121) + N'''' 
				print @vsqldynamic						
				--Fetch previous column value from target table
				exec sp_executesql 	@vsqldynamic, N'@vDestinationPrevColumnValue varchar(max) output', @vDestinationPrevColumnValue=@vDestinationPrevColumnValue OUTPUT 

				set @vDestinationPrevColumnValue = isnull(@vDestinationPrevColumnValue,'N/A')

				-- to compare only date up to seconds 'yyyy-mm-dd hh:mm:ss' because source table is datetime2

				--  select auto_expired_timestamp, * from ext_piclos.cci_policy where id in (select max(id) from ext_piclos.cci_policy )
				if @vSourceDataType = 'Date'
				begin
				   --some datetime coversion fails here fail here auto_expired_timestamp is one example
				   set @vdestinationcolumnvalue = LEFT(@vdestinationcolumnvalue, 10)
				   set @vsourcecolumnvalue = LEFT(@vsourcecolumnvalue, 10)
				   --set @vsourcecolumnvalue = CONVERT(datetime, @vsourcecolumnvalue, 120)
				end

				if RIGHT(@vDestinationColumn,6) = 'amount'
				begin
				   set @vdestinationcolumnvalue = CONVERT(decimal(19,5), @vdestinationcolumnvalue)
				   set @vsourcecolumnvalue = CONVERT(decimal(19,5), @vsourcecolumnvalue)
				end
				
				set @vsourcetargetvalues = 'SourceValue:'+ @vsourcecolumnvalue +'|' 
														 +'TargetValue:'+ @vdestinationcolumnvalue +'|' 

														 +'TargetPrevValue:'+ @vDestinationPrevColumnValue +'|'

				-- Compare values to pass or fail the test case
				if @vrecord_startdatetime > @vstartdatetime and @vrecord_startdatetime < @venddatetime
				and @vsourcecolumnvalue = @vdestinationcolumnvalue and @vDestinationPrevColumnValue <> @vdestinationcolumnvalue
				begin
				   set @vrecord_start_datetpass = '1'
					if @vrecord_enddatetime = '2049-12-31 00:00:00.000'
					   set @vrecord_end_datepass = '1'
					else 
					   set @vrecord_end_datepass = '0'

					if @vrecord_currentflag = '1'
					   set @vcurrentflagpass = '1'
					else 
					   set @vcurrentflagpass = '0'
				end
				else 
				begin 
				   set @vrecord_start_datetpass = '0'
				   set @vrecord_end_datepass = '0'
				   set @vcurrentflagpass = '0'
				end
				insert into dbo.dim_vehicle_test_results 
					(tablename, columnname, sourcetablename, sourcecolumnname, vehicle_key, policy_id, vehicle_id, product_code, currentflagpass, record_start_datetpass, record_end_datepass, sourcetargetvalues, update_datetime)
					values (@vDestinationTable, @vDestinationColumn, @vSourceTableName, @vSourceColumnName, @vTypeKey, @vPolicyID, @vvehicleID, @vProductCode, @vcurrentflagpass, @vrecord_start_datetpass, @vrecord_end_datepass, @vsourcetargetvalues, @venddatetime)

			END
			fetch c2 into  @vTypeKey, @vPolicyID, @vvehicleID, @vProductCode, @vrecord_startdatetime, @vrecord_enddatetime, @vrecord_currentflag
		END
		close c2
		fetch c1 into @vDestinationTable, @vDestinationColumn, @vSourceTableName, @vSourceColumnName, @vSourceDataType, @vsqlnotes
	END
	close c1
	deallocate c1
	deallocate c2
	select * from dbo.dim_vehicle_test_results order by update_datetime

END
GO
-- end of stored procedure

select * from dbo.dim_vehicle_test_case
select * from dbo.dim_vehicle_test_results  
--exec [dbo].[udsp_test_dim_vehicle]

--exec [sp_data].[populate_dim_vehicle]

--- 1. First pre requisite create table for loading test results. This table will  be used in udsp

IF EXISTS (select * from sys.sysobjects where name = 'dim_vehicle_test_results')
	DROP TABLE dbo.dim_vehicle_test_results

	CREATE TABLE  dbo.dim_vehicle_test_results 
		(
			tablename varchar(255) NOT NULL,
			columnname varchar(255) NOT NULL,
			sourcetablename varchar(255) NOT NULL,
			sourcecolumnname varchar(255) NOT NULL,
			vehicle_key		int  null,
			policy_id		int  null,
			vehicle_id		int  null,
			product_code varchar(4) null,
			currentflagpass varchar(1) NOT NULL,
			record_start_datetpass varchar(1) NOT NULL,
			record_end_datepass varchar(1) NOT NULL,
			sourcetargetvalues varchar(max) null,
			update_datetime	datetime null
		)

--- 2. Second pre requisite create table for test cases. This table will  be used in udsp

IF EXISTS (select * from sys.sysobjects where name = 'dim_vehicle_test_case')
	DROP TABLE dbo.dim_vehicle_test_case

CREATE TABLE dbo.dim_vehicle_test_case
(DestinationTable		varchar(255),
 DestinationColumn		varchar(255),
 SourceTableName		varchar(255),
 SourceColumnName		varchar(255),
 SourceDataType			varchar(10), 
 sqlnotes				nvarchar(max),
CONSTRAINT [PK_dim_vehicle_ts] PRIMARY KEY CLUSTERED 
(
	DestinationTable ASC,
	DestinationColumn ASC,
	SourceTableName ASC,
	SourceColumnName ASC,
	SourceDataType	ASC 
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


--- 3.a Delete test case from table before loading to avoid duplicate cases

-- the below delete statement is to remove only the test cases that are passed and rerun the test cases that failed. 
DELETE A FROM 
[dbo].[dim_vehicle_test_case] a
INNER JOIN [dbo].[dim_vehicle_test_results]  b on B.tablename = A.DestinationTable and B.columnname = A.DestinationColumn 
 and B.sourcetablename = A.SourceTableName and B.sourcecolumnname = A.SourceColumnName
 where b.currentflagpass = 1

delete from dbo.dim_vehicle_test_case 

--exec [dbo].[udsp_test_dim_vehicle]

INSERT INTO dbo.dim_vehicle_test_case VALUES 
('dim_vehicle','manufactured_year','gap_policy','[year]','Int',N'update piclos.gap_policy set [year] = isnull([year],2000) + 1 , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.gap_policy where vehicle_id in (select max(vehicle_id) from piclos.gap_policy )')
,('dim_vehicle','manufactured_year','mbi_policy','[year]','Int',N'update piclos.mbi_policy set [year] = isnull([year],2000) + 1 , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.mbi_policy where vehicle_id in (select max(vehicle_id) from piclos.mbi_policy )')
,('dim_vehicle','manufactured_year','posm_policy','[year]','Int',N'update piclos.posm_policy set [year] = isnull([year],2000) + 1 , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where vehicle_id in (select max(vehicle_id) from piclos.posm_policy )')
,('dim_vehicle','manufactured_year','tar_policy','[year]','Int',N'update piclos.tar_policy set [year] = isnull([year],2000) + 1 , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.tar_policy where vehicle_id in (select max(vehicle_id) from piclos.tar_policy )')

,('dim_vehicle','vehicle_make_id','posm_policy','vehicle_make_id','Int',N'update piclos.posm_policy set vehicle_make_id = isnull(vehicle_make_id,2000) - 1 , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where vehicle_id in (select max(vehicle_id) from piclos.posm_policy )')

,('dim_vehicle','vehicle_make_name','gap_policy','make','Varchar',N'update piclos.gap_policy set make = isnull(make,''1'') + ''1'', last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.gap_policy where vehicle_id in (select max(vehicle_id) from piclos.gap_policy )')
,('dim_vehicle','vehicle_make_name','mbi_policy','make','Varchar',N'update piclos.mbi_policy set make = isnull(make,''1'') + ''1'', last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.mbi_policy where vehicle_id in (select max(vehicle_id) from piclos.mbi_policy )')
,('dim_vehicle','vehicle_make_name','posm_policy','make','Varchar',N'update piclos.posm_policy set make = isnull(make,''1'') + ''1'', last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where vehicle_id in (select max(vehicle_id) from piclos.posm_policy )')
,('dim_vehicle','vehicle_make_name','tar_policy','make','Varchar',N'update piclos.tar_policy set make = isnull(make,''1'') + ''1'', last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.tar_policy where vehicle_id in (select max(vehicle_id) from piclos.tar_policy )')

,('dim_vehicle','vehicle_model_id','posm_policy','vehicle_model_id','Int',N'update piclos.posm_policy set vehicle_model_id = isnull(vehicle_model_id,1) + 1 , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where vehicle_id in (select max(vehicle_id) from piclos.posm_policy )')

,('dim_vehicle','vehicle_model_family_description','gap_policy','model_family','Varchar',N'update piclos.gap_policy set model_family = isnull(model_family,''1'') + ''1'', last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.gap_policy where vehicle_id in (select max(vehicle_id) from piclos.gap_policy )')
,('dim_vehicle','vehicle_model_family_description','mbi_policy','model_family','Varchar',N'update piclos.mbi_policy set model_family = isnull(model_family,''1'') + ''1'', last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.mbi_policy where vehicle_id in (select max(vehicle_id) from piclos.mbi_policy )')
,('dim_vehicle','vehicle_model_family_description','posm_policy','model_family','Varchar',N'update piclos.posm_policy set model_family = isnull(model_family,''1'') + ''1'', last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where vehicle_id in (select max(vehicle_id) from piclos.posm_policy )')
,('dim_vehicle','vehicle_model_family_description','tar_policy','model_family','Varchar',N'update piclos.tar_policy set model_family = isnull(model_family,''1'') + ''1'', last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.tar_policy where vehicle_id in (select max(vehicle_id) from piclos.tar_policy )')

,('dim_vehicle','vehicle_model_description','gap_policy','model','Varchar',N'update piclos.gap_policy set model = isnull(model,''1'') + ''1'', last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.gap_policy where vehicle_id in (select max(vehicle_id) from piclos.gap_policy )')
,('dim_vehicle','vehicle_model_description','mbi_policy','model','Varchar',N'update piclos.mbi_policy set model = isnull(model,''1'') + ''1'', last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.mbi_policy where vehicle_id in (select max(vehicle_id) from piclos.mbi_policy )')
,('dim_vehicle','vehicle_model_description','posm_policy','model','Varchar',N'update piclos.posm_policy set model = isnull(model,''1'') + ''1'', last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where vehicle_id in (select max(vehicle_id) from piclos.posm_policy )')
,('dim_vehicle','vehicle_model_description','tar_policy','model','Varchar',N'update piclos.tar_policy set model = isnull(model,''1'') + ''1'', last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.tar_policy where vehicle_id in (select max(vehicle_id) from piclos.tar_policy )')

,('dim_vehicle','vehicle_cc_rating','mbi_policy','cc_rating','Varchar',N'update piclos.mbi_policy set cc_rating = isnull(cc_rating,1) + 1, last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.mbi_policy where vehicle_id in (select max(vehicle_id) from piclos.mbi_policy )')
,('dim_vehicle','vehicle_cc_rating','posm_policy','cc_rating','Varchar',N'update piclos.posm_policy set cc_rating = isnull(cc_rating,''1'') + ''1'', last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where vehicle_id in (select max(vehicle_id) from piclos.posm_policy )')

,('dim_vehicle','vehicle_odometer_reading','mbi_policy','odometer','Int',N'update piclos.mbi_policy set odometer = isnull(odometer,1) + 1, last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.mbi_policy where vehicle_id in (select max(vehicle_id) from piclos.mbi_policy )')
,('dim_vehicle','vehicle_odometer_reading','tar_policy','odometer','Int',N'update piclos.tar_policy set odometer = isnull(odometer,1) + 1, last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.tar_policy where vehicle_id in (select max(vehicle_id) from piclos.tar_policy )')

,('dim_vehicle','vehicle_registration_number','gap_policy','registration_plate','Varchar',N'update piclos.gap_policy set registration_plate = isnull(registration_plate,''1'') + ''1'', last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.gap_policy where vehicle_id in (select max(vehicle_id) from piclos.gap_policy )')
,('dim_vehicle','vehicle_registration_number','mbi_policy','registration_plate','Varchar',N'update piclos.mbi_policy set registration_plate = isnull(registration_plate,''1'') + ''1'', last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.mbi_policy where vehicle_id in (select max(vehicle_id) from piclos.mbi_policy )')
,('dim_vehicle','vehicle_registration_number','posm_policy','registration_plate','Varchar',N'update piclos.posm_policy set registration_plate = isnull(registration_plate,''1'') + ''1'', last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where vehicle_id in (select max(vehicle_id) from piclos.posm_policy )')
,('dim_vehicle','vehicle_registration_number','tar_policy','registration_plate','Varchar',N'update piclos.tar_policy set registration_plate = isnull(registration_plate,''1'') + ''1'', last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.tar_policy where vehicle_id in (select max(vehicle_id) from piclos.tar_policy )')

,('dim_vehicle','vehicle_identification_number','gap_policy','vin','Varchar',N'update piclos.gap_policy set vin = isnull(vin,''1'') + ''1'', last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.gap_policy where vehicle_id in (select max(vehicle_id) from piclos.gap_policy )')
,('dim_vehicle','vehicle_identification_number','mbi_policy','vin','Varchar',N'update piclos.mbi_policy set vin = isnull(vin,''1'') + ''1'', last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.mbi_policy where vehicle_id in (select max(vehicle_id) from piclos.mbi_policy )')
,('dim_vehicle','vehicle_identification_number','posm_policy','vin','Varchar',N'update piclos.posm_policy set vin = isnull(vin,''1'') + ''1'', last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where vehicle_id in (select max(vehicle_id) from piclos.posm_policy )')
,('dim_vehicle','vehicle_identification_number','tar_policy','vin','Varchar',N'update piclos.tar_policy set vin = isnull(vin,''1'') + ''1'', last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.tar_policy where vehicle_id in (select max(vehicle_id) from piclos.tar_policy )')

,('dim_vehicle','stock_number','gap_policy','stock_number','Varchar',N'update piclos.gap_policy set stock_number = isnull(stock_number,''1'') + ''1'', last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.gap_policy where vehicle_id in (select max(vehicle_id) from piclos.gap_policy )')
,('dim_vehicle','stock_number','mbi_policy','stock_number','Varchar',N'update piclos.mbi_policy set stock_number = isnull(stock_number,''1'') + ''1'', last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.mbi_policy where vehicle_id in (select max(vehicle_id) from piclos.mbi_policy )')
,('dim_vehicle','stock_number','posm_policy','stock_number','Varchar',N'update piclos.posm_policy set stock_number = isnull(stock_number,''1'') + ''1'', last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where vehicle_id in (select max(vehicle_id) from piclos.posm_policy )')
,('dim_vehicle','stock_number','tar_policy','stock_number','Varchar',N'update piclos.tar_policy set stock_number = isnull(stock_number,''1'') + ''1'', last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.tar_policy where vehicle_id in (select max(vehicle_id) from piclos.tar_policy )')

,('dim_vehicle','vehicle_purchase_date_time','mbi_policy','date_vehicle_purchased','Date',N'update piclos.mbi_policy set date_vehicle_purchased = dateadd(m,-1,date_vehicle_purchased), last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.mbi_policy where vehicle_id in (select max(vehicle_id) from piclos.mbi_policy )')
,('dim_vehicle','vehicle_purchase_date_time','tar_policy','date_vehicle_purchased','Date',N'update piclos.tar_policy set date_vehicle_purchased = dateadd(m,-1,date_vehicle_purchased), last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.tar_policy where vehicle_id in (select max(vehicle_id) from piclos.tar_policy )')

,('dim_vehicle','vehicle_motor_type_name','mbi_policy','motor_type','Varchar',N'update piclos.mbi_policy set motor_type = ''1'', last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.mbi_policy where vehicle_id in (select max(vehicle_id) from piclos.mbi_policy )')
,('dim_vehicle','vehicle_motor_type_name','posm_policy','motor_type','Varchar',N'update piclos.posm_policy set motor_type = ''1'', last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where vehicle_id in (select max(vehicle_id) from piclos.posm_policy )')

,('dim_vehicle','vehicle_engine_cylinders_number','number_of_cylinders','motor_type','Int',N'update piclos.mbi_policy set number_of_cylinders = number_of_cylinders + ''1'', last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.mbi_policy where vehicle_id in (select max(vehicle_id) from piclos.mbi_policy )')

,('dim_vehicle','vehicle_engine_cylinders_number','mbi_policy','number_of_cylinders','Int',N'update piclos.mbi_policy set number_of_cylinders = number_of_cylinders + ''1'', last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.mbi_policy where vehicle_id in (select max(vehicle_id) from piclos.mbi_policy )')
,('dim_vehicle','is_turbo_super_flag','mbi_policy','is_turbo_super','Int',N'update piclos.mbi_policy set is_turbo_super = case when is_turbo_super = 0 then 1 when is_turbo_super = 1 then 0 end, last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.mbi_policy where vehicle_id in (select max(vehicle_id) from piclos.mbi_policy )')
,('dim_vehicle','is_4wd_flag','mbi_policy','is_4wd','Int',N'update piclos.mbi_policy set is_4wd = case when is_4wd = 0 then 1 when is_4wd = 1 then 0 end, last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.mbi_policy where vehicle_id in (select max(vehicle_id) from piclos.mbi_policy )')
,('dim_vehicle','vehicle_origin_country_name','mbi_policy','country_of_origin','Varchar',N'update piclos.mbi_policy set country_of_origin = country_of_origin + ''1'', last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.mbi_policy where vehicle_id in (select max(vehicle_id) from piclos.mbi_policy )')

,('dim_vehicle','is_vehicle_modified_flag','mbi_policy','is_modified','Int',N'update piclos.mbi_policy set is_modified = case when is_modified = 0 then 1 when is_modified = 1 then 0 end, last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.mbi_policy where vehicle_id in (select max(vehicle_id) from piclos.mbi_policy )')
,('dim_vehicle','is_vehicle_modified_flag','posm_policy','is_modified','Int',N'update piclos.posm_policy set is_modified = case when is_modified = 0 then 1 when is_modified = 1 then 0 end, last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where vehicle_id in (select max(vehicle_id) from piclos.posm_policy )')

,('dim_vehicle','vehicle_modification_notes','mbi_policy','modifications','Varchar',N'update piclos.mbi_policy set modifications = modifications + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.mbi_policy where vehicle_id in (select max(vehicle_id) from piclos.mbi_policy )')
,('dim_vehicle','vehicle_modification_notes','posm_policy','modifications','Varchar',N'update piclos.posm_policy set modifications = modifications + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where vehicle_id in (select max(vehicle_id) from piclos.posm_policy )')

,('dim_vehicle','vehicle_usage_code','mbi_policy','vehicle_usage','Varchar',N'update piclos.mbi_policy set vehicle_usage = vehicle_usage + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.mbi_policy where vehicle_id in (select max(vehicle_id) from piclos.mbi_policy )')
,('dim_vehicle','vehicle_usage_code','tar_policy','vehicle_usage','Varchar',N'update piclos.tar_policy set vehicle_usage = vehicle_usage + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.tar_policy where vehicle_id in (select max(vehicle_id) from piclos.tar_policy )')

,('dim_vehicle','manufacturers_warranty_remaining_in_months','mbi_policy','manufacturers_warranty_months_remaining','Int',N'update piclos.mbi_policy set manufacturers_warranty_months_remaining = manufacturers_warranty_months_remaining + 1 , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.mbi_policy where vehicle_id in (select max(vehicle_id) from piclos.mbi_policy )')
,('dim_vehicle','manufacturers_warranty_limited_to_kms','mbi_policy','manufacturers_warranty_limited_to_kms','Int',N'update piclos.mbi_policy set manufacturers_warranty_limited_to_kms = manufacturers_warranty_limited_to_kms + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.mbi_policy where vehicle_id in (select max(vehicle_id) from piclos.mbi_policy )')

,('dim_vehicle','original_odometer_reading','mbi_policy','original_odometer','Int',N'update piclos.mbi_policy set original_odometer = original_odometer + 1 , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.mbi_policy where vehicle_id in (select max(vehicle_id) from piclos.mbi_policy )')
,('dim_vehicle','original_odometer_reading','tar_policy','original_odometer','Int',N'update piclos.tar_policy set original_odometer = original_odometer + 1 , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.tar_policy where vehicle_id in (select max(vehicle_id) from piclos.tar_policy )')

,('dim_vehicle','original_manufactured_year','mbi_policy','original_year','Int',N'update piclos.mbi_policy set original_year = original_year + 1 , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.mbi_policy where vehicle_id in (select max(vehicle_id) from piclos.mbi_policy )')
,('dim_vehicle','original_manufactured_year','tar_policy','original_year','Int',N'update piclos.tar_policy set original_year = original_year + 1 , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.tar_policy where vehicle_id in (select max(vehicle_id) from piclos.tar_policy )')

,('dim_vehicle','mycar_authentication_code','mbi_policy','mycar_authentication_code','Varchar',N'update piclos.mbi_policy set mycar_authentication_code = mycar_authentication_code + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.mbi_policy where vehicle_id in (select max(vehicle_id) from piclos.mbi_policy )')
,('dim_vehicle','mycar_authentication_code_used_flag','mbi_policy','mycar_authentication_code_used','Int',N'update piclos.mbi_policy set mycar_authentication_code_used = case when mycar_authentication_code_used = 0 then 1 when mycar_authentication_code_used = 1 then 0 end, last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.mbi_policy where vehicle_id in (select max(vehicle_id) from piclos.mbi_policy )')

,('dim_vehicle','rb_default_value_amount','posm_policy','rb_default_value','Int',N'update piclos.posm_policy set rb_default_value = isnull(rb_default_value,0) + 1 , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where vehicle_id in (select max(vehicle_id) from piclos.posm_policy )')
,('dim_vehicle','rb_Avg_Wholesale','posm_policy','rb_AvgWholesale','Int',N'update piclos.posm_policy set rb_AvgWholesale = isnull(rb_AvgWholesale,0) + 1 , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where vehicle_id in (select max(vehicle_id) from piclos.posm_policy )')
,('dim_vehicle','rb_Avg_Retail','posm_policy','rb_AvgRetail','Int',N'update piclos.posm_policy set rb_AvgRetail = isnull(rb_AvgRetail,0) + 1 , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where vehicle_id in (select max(vehicle_id) from piclos.posm_policy )')
,('dim_vehicle','rb_Good_Wholesale','posm_policy','rb_GoodWholesale','Int',N'update piclos.posm_policy set rb_GoodWholesale = isnull(rb_GoodWholesale,0) + 1 , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where vehicle_id in (select max(vehicle_id) from piclos.posm_policy )')
,('dim_vehicle','rb_Good_Retail','posm_policy','rb_GoodRetail','Int',N'update piclos.posm_policy set rb_GoodRetail = isnull(rb_GoodRetail,0) + 1 , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where vehicle_id in (select max(vehicle_id) from piclos.posm_policy )')
,('dim_vehicle','rb_New_Price','posm_policy','rb_NewPrice','Int',N'update piclos.posm_policy set rb_NewPrice = isnull(rb_NewPrice,0) + 1 , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where vehicle_id in (select max(vehicle_id) from piclos.posm_policy )')
,('dim_vehicle','rb_vehicle_key','posm_policy','rb_vehicle_key','Varchar',N'update piclos.posm_policy set rb_vehicle_key = rb_vehicle_key + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where vehicle_id in (select max(vehicle_id) from piclos.posm_policy )')

,('dim_vehicle','posm_vehicle_modified_flag','posm_policy','modified','Int',N'update piclos.posm_policy set modified = case when modified = 0 then 1 when modified = 1 then 0 end , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where vehicle_id in (select max(vehicle_id) from piclos.posm_policy )')
,('dim_vehicle','posm_vehicle_modified_details','posm_policy','modified_details','Varchar',N'update piclos.posm_policy set modified_details = isnull(modified_details,''1'') + ''1'', last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where vehicle_id in (select max(vehicle_id) from piclos.posm_policy )')
,('dim_vehicle','vehicle_type_code','posm_policy','vehicle_type','Varchar',N'update piclos.posm_policy set vehicle_type = isnull(vehicle_type,''1'') + ''1'', last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where vehicle_id in (select max(vehicle_id) from piclos.posm_policy )')
,('dim_vehicle','vehicle_type_details','posm_policy','vehicle_type_details','Varchar',N'update piclos.posm_policy set vehicle_type_details = isnull(vehicle_type_details,''1'') + ''1'', last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where vehicle_id in (select max(vehicle_id) from piclos.posm_policy )')
,('dim_vehicle','vehicle_dealer_group_name','posm_policy','vehicle_dealer_group','Varchar',N'update piclos.posm_policy set vehicle_dealer_group = isnull(vehicle_dealer_group,''1'') + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where vehicle_id in (select max(vehicle_id) from piclos.posm_policy )')
,('dim_vehicle','vehicle_new_flag','posm_policy','vehicle_new_used','Int',N'update piclos.posm_policy set vehicle_new_used = case when vehicle_new_used = 0 then 1 when vehicle_new_used = 1 then 0 end, last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where vehicle_id in (select max(vehicle_id) from piclos.posm_policy )')
,('dim_vehicle','vehicle_condition_code','posm_policy','vehicle_condition','Varchar',N'update piclos.posm_policy set vehicle_condition = isnull(vehicle_condition,''1'') + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where vehicle_id in (select max(vehicle_id) from piclos.posm_policy )')

,('dim_vehicle','valuation_type_id','posm_policy','valuation_type_id','Int',N'update piclos.posm_policy set valuation_type_id = isnull(valuation_type_id,1) + 1, last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where vehicle_id in (select max(vehicle_id) from piclos.posm_policy )')
,('dim_vehicle','valuation_type_code','posm_policy','valuation_type','Int',N'update piclos.posm_policy set valuation_type = isnull(valuation_type,1) + 1, last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where vehicle_id in (select max(vehicle_id) from piclos.posm_policy )')
,('dim_vehicle','vehicle_has_alarm_flag','posm_policy','vehicle_has_alarm','Int',N'update piclos.posm_policy set vehicle_has_alarm = case when vehicle_has_alarm = 0 then 1 when vehicle_has_alarm = 1 then 0 end , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where vehicle_id in (select max(vehicle_id) from piclos.posm_policy )')
,('dim_vehicle','vehicle_has_immobiliser_flag','posm_policy','vehicle_has_immobiliser','Int',N'update piclos.posm_policy set vehicle_has_immobiliser = case when vehicle_has_immobiliser = 0 then 1 when vehicle_has_immobiliser = 1 then 0 end , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where vehicle_id in (select max(vehicle_id) from piclos.posm_policy )')
,('dim_vehicle','vehicle_mod_body_kit_flag','posm_policy','vehicle_mod_body_kit','Int',N'update piclos.posm_policy set vehicle_mod_body_kit = case when vehicle_mod_body_kit = 0 then 1 when vehicle_mod_body_kit = 1 then 0 end , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where vehicle_id in (select max(vehicle_id) from piclos.posm_policy )')
,('dim_vehicle','vehicle_mod_decoration_flag','posm_policy','vehicle_mod_decoration','Int',N'update piclos.posm_policy set vehicle_mod_decoration = case when vehicle_mod_decoration = 0 then 1 when vehicle_mod_decoration = 1 then 0 end , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where vehicle_id in (select max(vehicle_id) from piclos.posm_policy )')
,('dim_vehicle','vehicle_mod_engine_flag','posm_policy','vehicle_mod_engine','Int',N'update piclos.posm_policy set vehicle_mod_engine = case when vehicle_mod_engine = 0 then 1 when vehicle_mod_engine = 1 then 0 end , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where vehicle_id in (select max(vehicle_id) from piclos.posm_policy )')
,('dim_vehicle','vehicle_mod_exhaust_flag','posm_policy','vehicle_mod_exhaust','Int',N'update piclos.posm_policy set vehicle_mod_exhaust = case when vehicle_mod_exhaust = 0 then 1 when vehicle_mod_exhaust = 1 then 0 end , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where vehicle_id in (select max(vehicle_id) from piclos.posm_policy )')
,('dim_vehicle','vehicle_mod_gauges_flag','posm_policy','vehicle_mod_gauges','Int',N'update piclos.posm_policy set vehicle_mod_gauges = case when vehicle_mod_gauges = 0 then 1 when vehicle_mod_gauges = 1 then 0 end , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where vehicle_id in (select max(vehicle_id) from piclos.posm_policy )')
,('dim_vehicle','vehicle_mod_glass_flag','posm_policy','vehicle_mod_glass','Int',N'update piclos.posm_policy set vehicle_mod_glass = case when vehicle_mod_glass = 0 then 1 when vehicle_mod_glass = 1 then 0 end , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where vehicle_id in (select max(vehicle_id) from piclos.posm_policy )')
,('dim_vehicle','vehicle_mod_suspension_flag','posm_policy','vehicle_mod_suspension','Int',N'update piclos.posm_policy set vehicle_mod_suspension = case when vehicle_mod_suspension = 0 then 1 when vehicle_mod_suspension = 1 then 0 end , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where vehicle_id in (select max(vehicle_id) from piclos.posm_policy )')

,('dim_vehicle','vehicle_mod_mags_amount','posm_policy','vehicle_mod_mags_value','Int',N'update piclos.posm_policy set vehicle_mod_mags_value = isnull(vehicle_mod_mags_value,1) + 1, last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where vehicle_id in (select max(vehicle_id) from piclos.posm_policy )')
,('dim_vehicle','vehicle_mod_stereo_amount','posm_policy','vehicle_mod_stereo_value','Int',N'update piclos.posm_policy set vehicle_mod_stereo_value = isnull(vehicle_mod_stereo_value,1) + 1, last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where vehicle_id in (select max(vehicle_id) from piclos.posm_policy )')
,('dim_vehicle','vehicle_mod_other_amount','posm_policy','vehicle_mod_other_value','Int',N'update piclos.posm_policy set vehicle_mod_other_value = isnull(vehicle_mod_other_value,1) + 1, last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where vehicle_id in (select max(vehicle_id) from piclos.posm_policy )')

,('dim_vehicle','tyre_brand_id','tar_policy','tyre_brand_id','Int',N'update piclos.tar_policy set tyre_brand_id = isnull(tyre_brand_id,1) + 1, last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.tar_policy where vehicle_id in (select max(vehicle_id) from piclos.tar_policy )')
,('dim_vehicle','tyre_brand_name','tar_policy','tyre_brand_other','Varchar',N'update piclos.tar_policy set tyre_brand_other = isnull(tyre_brand_other,''1'') + ''1'', last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.tar_policy where vehicle_id in (select max(vehicle_id) from piclos.tar_policy )')
,('dim_vehicle','tyre_name_id','tar_policy','tyre_name_id','Int',N'update piclos.tar_policy set tyre_name_id = isnull(tyre_name_id,1) + 1, last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.tar_policy where vehicle_id in (select max(vehicle_id) from piclos.tar_policy )')
,('dim_vehicle','tyre_name','tar_policy','tyre_name_other','Varchar',N'update piclos.tar_policy set tyre_name_other = isnull(tyre_name_other,''1'') + ''1'', last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.tar_policy where vehicle_id in (select max(vehicle_id) from piclos.tar_policy )')
,('dim_vehicle','tyre_front_width_in_mm_number','tar_policy','tyre_front_tyre_width','Varchar',N'update piclos.tar_policy set tyre_front_tyre_width = isnull(tyre_front_tyre_width,''1'') + ''1'', last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.tar_policy where vehicle_id in (select max(vehicle_id) from piclos.tar_policy )')
,('dim_vehicle','tyre_front_profile_percentage','tar_policy','tyre_front_profile','Varchar',N'update piclos.tar_policy set tyre_front_profile = isnull(tyre_front_profile,''1'') + ''1'', last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.tar_policy where vehicle_id in (select max(vehicle_id) from piclos.tar_policy )')
,('dim_vehicle','tyre_front_rim_size_in_inches_number','tar_policy','tyre_front_rim_size','Varchar',N'update piclos.tar_policy set tyre_front_rim_size = isnull(tyre_front_rim_size,''1'') + ''1'', last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.tar_policy where vehicle_id in (select max(vehicle_id) from piclos.tar_policy )')
,('dim_vehicle','tyre_staggered_fitment_flag','tar_policy','tyre_staggered_fitment','Int',N'update piclos.tar_policy set tyre_staggered_fitment = case when tyre_staggered_fitment = 1 then 0 when tyre_staggered_fitment = 0 then 1 end, last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.tar_policy where vehicle_id in (select max(vehicle_id) from piclos.tar_policy )')
,('dim_vehicle','tyre_rear_tyre_width_in_mm_number','tar_policy','tyre_rear_tyre_width','Varchar',N'update piclos.tar_policy set tyre_rear_tyre_width = isnull(tyre_rear_tyre_width,''1'') + ''1'', last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.tar_policy where vehicle_id in (select max(vehicle_id) from piclos.tar_policy )')
,('dim_vehicle','tyre_rear_profile','tar_policy','tyre_rear_profile','Varchar',N'update piclos.tar_policy set tyre_rear_profile = isnull(tyre_rear_profile,''1'') + ''1'', last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.tar_policy where vehicle_id in (select max(vehicle_id) from piclos.tar_policy )')
,('dim_vehicle','tyre_rear_rim_size','tar_policy','tyre_rear_rim_size','Varchar',N'update piclos.tar_policy set tyre_rear_rim_size = isnull(tyre_rear_rim_size,''1'') + ''1'', last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.tar_policy where vehicle_id in (select max(vehicle_id) from piclos.tar_policy )')

