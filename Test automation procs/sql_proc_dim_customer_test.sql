/****** Object:  StoredProcedure [dbo].[udsp_test_dim_customer]    Script Date: 22/10/2021 9:52:16 am ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--- Pre requisite 
		-- 1. Create table for loading test case 
		-- 2. Create table for test results
		-- 3. Data loading for test case
--- Create procedure script 

CREATE PROCEDURE [dbo].[udsp_test_dim_customer] --@sql nvarchar(max) with execute as owner

AS
BEGIN
	declare @vsqletlsp varchar(255) = '[sp_data].[populate_dim_customer]'
			,@vsqletlsp_policy varchar(255) = '[sp_data].[populate_dim_policy]'
			,@vtablename varchar(255) = 'dim_customer'
			,@vcolumnname varchar(255) 
			,@vstartdatetime datetime
			,@venddatetime	datetime
			--- C2 columns
			,@vTypeKey int
			,@vPolicyID int
			,@vCustomerID varchar(100)
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
				from dbo.dim_customer_test_case
	
	declare c2 cursor for 
				select customer_key, a.policy_id, a.customer_id, b.product_code, record_start_datetime, record_end_datetime, record_current_flag
				from Data.dim_customer a 
				join (select max(policy_id) policy_id, product_code
						from Data.dim_policy
						group by product_code
							) b
					on a.policy_id = b.policy_id 
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
	--exec @vsqletlsp_policy
	exec @vsqletlsp

	set @venddatetime = getdate() AT TIME ZONE 'UTC' AT TIME ZONE 'New Zealand Standard Time'

	delete from dbo.dim_customer_test_results
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
										+ N' where id in (select max(id) from ext_piclos.'+ @vSourceTableName + N')'
		print @vsqldynamic

		-- Fetch updated table/column value from source
		exec sp_executesql 	@vsqldynamic, N'@vsourcecolumnvalue varchar(max) output', @vsourcecolumnvalue=@vsourcecolumnvalue OUTPUT 
		--select @vsourcecolumnvalue
		open c2
		fetch c2 into  @vTypeKey, @vPolicyID, @vCustomerID, @vProductCode, @vrecord_startdatetime, @vrecord_enddatetime, @vrecord_currentflag
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
										+ N' where customer_key = ' + convert(nvarchar, @vTypeKey)
										
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
				--print @vsqldynamic						
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
				insert into dbo.dim_customer_test_results 
					(tablename, columnname, sourcetablename, sourcecolumnname, customer_key, policy_id, policy_number, product_code, currentflagpass, record_start_datetpass, record_end_datepass, sourcetargetvalues, update_datetime)
					values (@vDestinationTable, @vDestinationColumn, @vSourceTableName, @vSourceColumnName, @vTypeKey, @vPolicyID, @vCustomerID, @vProductCode, @vcurrentflagpass, @vrecord_start_datetpass, @vrecord_end_datepass, @vsourcetargetvalues, @venddatetime)

			END
			fetch c2 into  @vTypeKey, @vPolicyID, @vCustomerID, @vProductCode, @vrecord_startdatetime, @vrecord_enddatetime, @vrecord_currentflag
		END
		close c2
		fetch c1 into @vDestinationTable, @vDestinationColumn, @vSourceTableName, @vSourceColumnName, @vSourceDataType, @vsqlnotes
	END
	close c1
	deallocate c1
	deallocate c2
	select * from dbo.dim_customer_test_results order by update_datetime

END
GO
-- end of stored procedure

select * from dbo.dim_customer_test_case
select * from dbo.dim_customer_test_results  
--exec [dbo].[udsp_test_dim_customer]

--exec [sp_data].[populate_dim_customer]

--- 1. First pre requisite create table for loading test results. This table will  be used in udsp

IF EXISTS (select * from sys.sysobjects where name = 'dim_customer_test_results')
	DROP TABLE dbo.dim_customer_test_results

	CREATE TABLE  dbo.dim_customer_test_results 
		(
			tablename varchar(255) NOT NULL,
			columnname varchar(255) NOT NULL,
			sourcetablename varchar(255) NOT NULL,
			sourcecolumnname varchar(255) NOT NULL,
			customer_key		int  null,
			policy_id		int  null,
			policy_number varchar(100)  null,
			product_code varchar(4) null,
			currentflagpass varchar(1) NOT NULL,
			record_start_datetpass varchar(1) NOT NULL,
			record_end_datepass varchar(1) NOT NULL,
			sourcetargetvalues varchar(max) null,
			update_datetime	datetime null
		)

--- 2. Second pre requisite create table for test cases. This table will  be used in udsp

IF EXISTS (select * from sys.sysobjects where name = 'dim_customer_test_case')
	DROP TABLE dbo.dim_customer_test_case

CREATE TABLE dbo.dim_customer_test_case
(DestinationTable		varchar(255),
 DestinationColumn		varchar(255),
 SourceTableName		varchar(255),
 SourceColumnName		varchar(255),
 SourceDataType			varchar(10), 
 sqlnotes				nvarchar(max),
CONSTRAINT [PK_dim_customer_ts] PRIMARY KEY CLUSTERED 
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
[dbo].[dim_customer_test_case] a
INNER JOIN [dbo].[dim_customer_test_results]  b on B.tablename = A.DestinationTable and B.columnname = A.DestinationColumn 
 and B.sourcetablename = A.SourceTableName and B.sourcecolumnname = A.SourceColumnName
 where b.currentflagpass = 1


delete from dbo.dim_customer_test_case 
--select * from dbo.dim_customer_test_case
select * from dbo.dim_customer_test_results

--exec [dbo].[udsp_test_dim_customer]

-- 3.b Load the test cases for Data manipulation in Source DB

INSERT INTO dbo.dim_customer_test_case VALUES 
('dim_customer','primary_customer_name_title','cci_policy','title_1','Varchar',N'update piclos.cci_policy set title_1 = title_1 + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.cci_policy where id in (select max(id) from piclos.cci_policy )')
,('dim_customer','primary_customer_name_title','gap_policy','title_1','Varchar',N'update piclos.gap_policy set title_1 = title_1 + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.gap_policy where id in (select max(id) from piclos.gap_policy )')
,('dim_customer','primary_customer_name_title','lnm_policy','title','Varchar',N'update piclos.lnm_policy set title = title + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.lnm_policy where id in (select max(id) from piclos.lnm_policy )')
--,('dim_customer','primary_customer_name_title','mbi_policy','title_1','Varchar',N'update piclos.mbi_policy set title_1 = title_1 + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.mbi_policy where id in (select max(id) from piclos.mbi_policy )')
,('dim_customer','primary_customer_name_title','posm_policy','title_1','Varchar',N'update piclos.posm_policy set title_1 = title_1 + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')
,('dim_customer','primary_customer_name_title','tar_policy','title_1','Varchar',N'update piclos.tar_policy set title_1 = title_1 + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.tar_policy where id in (select max(id) from piclos.tar_policy )')

,('dim_customer','primary_customer_first_name','cci_policy','first_name_1','Varchar',N'update piclos.cci_policy set first_name_1 =  first_name_1 + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.cci_policy where id in (select max(id) from piclos.cci_policy )')
,('dim_customer','primary_customer_first_name','gap_policy','first_name_1','Varchar',N'update piclos.gap_policy set first_name_1 =  first_name_1 + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.gap_policy where id in (select max(id) from piclos.gap_policy )')
,('dim_customer','primary_customer_first_name','lnm_policy','first_name','Varchar',N'update piclos.lnm_policy set first_name =  first_name + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.lnm_policy where id in (select max(id) from piclos.lnm_policy )')
,('dim_customer','primary_customer_first_name','mbi_policy','first_name_1','Varchar',N'update piclos.mbi_policy set first_name_1 =  first_name_1 + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.mbi_policy where id in (select max(id) from piclos.mbi_policy )')
,('dim_customer','primary_customer_first_name','posm_policy','first_name_1','Varchar',N'update piclos.posm_policy set first_name_1 =  first_name_1 + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')
,('dim_customer','primary_customer_first_name','tar_policy','first_name_1','Varchar',N'update piclos.tar_policy set first_name_1 =  first_name_1 + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.tar_policy where id in (select max(id) from piclos.tar_policy )')

,('dim_customer','primary_customer_last_name','cci_policy','last_name_1','Varchar',N'update piclos.cci_policy set last_name_1 =  last_name_1 + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.cci_policy where id in (select max(id) from piclos.cci_policy )')
,('dim_customer','primary_customer_last_name','gap_policy','last_name_1','Varchar',N'update piclos.gap_policy set last_name_1 =  last_name_1 + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.gap_policy where id in (select max(id) from piclos.gap_policy )')
,('dim_customer','primary_customer_last_name','lnm_policy','last_name','Varchar',N'update piclos.lnm_policy set last_name =  last_name + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.lnm_policy where id in (select max(id) from piclos.lnm_policy )')
,('dim_customer','primary_customer_last_name','mbi_policy','last_name_1','Varchar',N'update piclos.mbi_policy set last_name_1 =  last_name_1 + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.mbi_policy where id in (select max(id) from piclos.mbi_policy )')
,('dim_customer','primary_customer_last_name','posm_policy','last_name_1','Varchar',N'update piclos.posm_policy set last_name_1 =  last_name_1 + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')
,('dim_customer','primary_customer_last_name','tar_policy','last_name_1','Varchar',N'update piclos.tar_policy set last_name_1 =  last_name_1 + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.tar_policy where id in (select max(id) from piclos.tar_policy )')

,('dim_customer','primary_customer_dob','cci_policy','dob_1','Date',N'update piclos.cci_policy set dob_1 = dateadd(m,-1,dob_1), last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.cci_policy where id in (select max(id) from piclos.cci_policy )')
,('dim_customer','primary_customer_dob','mbi_policy','dob_1','Date',N'update piclos.mbi_policy set dob_1 = dateadd(m,-1,dob_1), last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.mbi_policy where id in (select max(id) from piclos.mbi_policy )')
,('dim_customer','primary_customer_dob','posm_policy','dob_1','Date',N'update piclos.posm_policy set dob_1 = dateadd(m,-1,dob_1), last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')

,('dim_customer','primary_customer_occupation','cci_policy','occupation_1','Varchar',N'update piclos.cci_policy set occupation_1 = occupation_1 + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.cci_policy where id in (select max(id) from piclos.cci_policy )')
,('dim_customer','primary_customer_occupation','gap_policy','occupation_1','Varchar',N'update piclos.gap_policy set occupation_1 = occupation_1 + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.gap_policy where id in (select max(id) from piclos.gap_policy )')
,('dim_customer','primary_customer_occupation','lnm_policy','occupation','Varchar',N'update piclos.lnm_policy set occupation = occupation + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.lnm_policy where id in (select max(id) from piclos.lnm_policy )')
,('dim_customer','primary_customer_occupation','mbi_policy','occupation_1','Varchar',N'update piclos.mbi_policy set occupation_1 = occupation_1 + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.mbi_policy where id in (select max(id) from piclos.mbi_policy )')
,('dim_customer','primary_customer_occupation','posm_policy','occupation_1','Varchar',N'update piclos.posm_policy set occupation_1 = occupation_1 + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')
,('dim_customer','primary_customer_occupation','tar_policy','occupation_1','Varchar',N'update piclos.tar_policy set occupation_1 = occupation_1 + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.tar_policy where id in (select max(id) from piclos.tar_policy )')

,('dim_customer','secondary_customer_title','cci_policy','title_2','Varchar',N'update piclos.cci_policy set title_2 = title_2 + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.cci_policy where id in (select max(id) from piclos.cci_policy )')
,('dim_customer','secondary_customer_title','gap_policy','title_2','Varchar',N'update piclos.gap_policy set title_2 = title_2 + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.gap_policy where id in (select max(id) from piclos.gap_policy )')
--,('dim_customer','secondary_customer_title','mbi_policy','title_2','Varchar',N'update piclos.mbi_policy set title_2 = title_2 + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.mbi_policy where id in (select max(id) from piclos.mbi_policy )')
,('dim_customer','secondary_customer_title','posm_policy','title_2','Varchar',N'update piclos.posm_policy set title_2 = title_2 + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')
,('dim_customer','secondary_customer_title','tar_policy','title_2','Varchar',N'update piclos.tar_policy set title_2 = title_2 + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.tar_policy where id in (select max(id) from piclos.tar_policy )')

,('dim_customer','secondary_customer_first_name','cci_policy','first_name_2','Varchar',N'update piclos.cci_policy set first_name_2 = first_name_2 + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.cci_policy where id in (select max(id) from piclos.cci_policy )')
,('dim_customer','secondary_customer_first_name','gap_policy','first_name_2','Varchar',N'update piclos.gap_policy set first_name_2 = first_name_2 + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.gap_policy where id in (select max(id) from piclos.gap_policy )')
,('dim_customer','secondary_customer_first_name','mbi_policy','first_name_2','Varchar',N'update piclos.mbi_policy set first_name_2 = first_name_2 + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.mbi_policy where id in (select max(id) from piclos.mbi_policy )')
,('dim_customer','secondary_customer_first_name','posm_policy','first_name_2','Varchar',N'update piclos.posm_policy set first_name_2 = first_name_2 + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')
,('dim_customer','secondary_customer_first_name','tar_policy','first_name_2','Varchar',N'update piclos.tar_policy set first_name_2 = first_name_2 + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.tar_policy where id in (select max(id) from piclos.tar_policy )')

,('dim_customer','secondary_customer_last_name','cci_policy','last_name_2','Varchar',N'update piclos.cci_policy set last_name_2 = last_name_2 + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.cci_policy where id in (select max(id) from piclos.cci_policy )')
,('dim_customer','secondary_customer_last_name','gap_policy','last_name_2','Varchar',N'update piclos.gap_policy set last_name_2 = last_name_2 + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.gap_policy where id in (select max(id) from piclos.gap_policy )')
,('dim_customer','secondary_customer_last_name','mbi_policy','last_name_2','Varchar',N'update piclos.mbi_policy set last_name_2 = last_name_2 + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.mbi_policy where id in (select max(id) from piclos.mbi_policy )')
,('dim_customer','secondary_customer_last_name','posm_policy','last_name_2','Varchar',N'update piclos.posm_policy set last_name_2 = last_name_2 + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')
,('dim_customer','secondary_customer_last_name','tar_policy','last_name_2','Varchar',N'update piclos.tar_policy set last_name_2 = last_name_2 + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.tar_policy where id in (select max(id) from piclos.tar_policy )')

,('dim_customer','secondary_customer_dob','cci_policy','dob_2','Date',N'update piclos.cci_policy set dob_2 = dateadd(m,-1,dob_2), last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.cci_policy where id in (select max(id) from piclos.cci_policy )')
,('dim_customer','secondary_customer_dob','gap_policy','dob_2','Date',N'update piclos.gap_policy set dob_2 = dateadd(m,-1,dob_2), last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.gap_policy where id in (select max(id) from piclos.gap_policy )')

,('dim_customer','secondary_customer_occupation','cci_policy','occupation_2','Varchar',N'update piclos.cci_policy set occupation_2 = occupation_2 + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.cci_policy where id in (select max(id) from piclos.cci_policy )')
,('dim_customer','secondary_customer_occupation','gap_policy','occupation_2','Varchar',N'update piclos.gap_policy set occupation_2 = occupation_2 + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.gap_policy where id in (select max(id) from piclos.gap_policy )')
,('dim_customer','secondary_customer_occupation','mbi_policy','occupation_2','Varchar',N'update piclos.mbi_policy set occupation_2 = occupation_2 + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.mbi_policy where id in (select max(id) from piclos.mbi_policy )')
,('dim_customer','secondary_customer_occupation','posm_policy','occupation_2','Varchar',N'update piclos.posm_policy set occupation_2 = occupation_2 + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')
,('dim_customer','secondary_customer_occupation','tar_policy','occupation_2','Varchar',N'update piclos.tar_policy set occupation_2 = occupation_2 + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.tar_policy where id in (select max(id) from piclos.tar_policy )')

,('dim_customer','lnm_customer_height','lnm_policy','height','Num',N'update piclos.lnm_policy set height = isnull(height,0) + 1 , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.lnm_policy where id in (select max(id) from piclos.lnm_policy )')
,('dim_customer','lnm_customer_weight','lnm_policy','weight','Num',N'update piclos.lnm_policy set weight = isnull(weight,0) + 1 , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.lnm_policy where id in (select max(id) from piclos.lnm_policy )')
,('dim_customer','lnm_is_smoker_flag','lnm_policy','smoker','Num',N'update piclos.lnm_policy set smoker = case when smoker = 1 then 0 when smoker = 0 then 1 end , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.lnm_policy where id in (select max(id) from piclos.lnm_policy )')

,('dim_customer','company_name','cci_policy','company_name','Varchar',N'update piclos.cci_policy set company_name = company_name + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.cci_policy where id in (select max(id) from piclos.cci_policy )')
,('dim_customer','company_name','gap_policy','company_name','Varchar',N'update piclos.gap_policy set company_name = company_name + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.gap_policy where id in (select max(id) from piclos.gap_policy )')
,('dim_customer','company_name','lnm_policy','company_name','Varchar',N'update piclos.lnm_policy set company_name = company_name + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.lnm_policy where id in (select max(id) from piclos.lnm_policy )')
,('dim_customer','company_name','mbi_policy','company_name','Varchar',N'update piclos.mbi_policy set company_name = company_name + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.mbi_policy where id in (select max(id) from piclos.mbi_policy )')
,('dim_customer','company_name','posm_policy','company_name','Varchar',N'update piclos.posm_policy set company_name = company_name + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')
,('dim_customer','company_name','tar_policy','company_name','Varchar',N'update piclos.tar_policy set company_name = company_name + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.tar_policy where id in (select max(id) from piclos.tar_policy )')

,('dim_customer','customer_address_street','cci_policy','street','Varchar',N'update piclos.cci_policy set street = street + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.cci_policy where id in (select max(id) from piclos.cci_policy )')
,('dim_customer','customer_address_street','gap_policy','street','Varchar',N'update piclos.gap_policy set street = street + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.gap_policy where id in (select max(id) from piclos.gap_policy )')
,('dim_customer','customer_address_street','lnm_policy','street','Varchar',N'update piclos.lnm_policy set street = street + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.lnm_policy where id in (select max(id) from piclos.lnm_policy )')
--,('dim_customer','customer_address_street','mbi_policy','street','Varchar',N'update piclos.mbi_policy set street = street + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.mbi_policy where id in (select max(id) from piclos.mbi_policy )')
,('dim_customer','customer_address_street','posm_policy','street','Varchar',N'update piclos.posm_policy set street = street + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')
,('dim_customer','customer_address_street','tar_policy','street','Varchar',N'update piclos.tar_policy set street = street + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.tar_policy where id in (select max(id) from piclos.tar_policy )')

,('dim_customer','customer_address_suburb','cci_policy','suburb','Varchar',N'update piclos.cci_policy set suburb = suburb + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.cci_policy where id in (select max(id) from piclos.cci_policy )')
,('dim_customer','customer_address_suburb','gap_policy','suburb','Varchar',N'update piclos.gap_policy set suburb = suburb + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.gap_policy where id in (select max(id) from piclos.gap_policy )')
,('dim_customer','customer_address_suburb','lnm_policy','suburb','Varchar',N'update piclos.lnm_policy set suburb = suburb + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.lnm_policy where id in (select max(id) from piclos.lnm_policy )')
,('dim_customer','customer_address_suburb','mbi_policy','suburb','Varchar',N'update piclos.mbi_policy set suburb = suburb + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.mbi_policy where id in (select max(id) from piclos.mbi_policy )')
,('dim_customer','customer_address_suburb','posm_policy','suburb','Varchar',N'update piclos.posm_policy set suburb = suburb + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')
,('dim_customer','customer_address_suburb','tar_policy','suburb','Varchar',N'update piclos.tar_policy set suburb = suburb + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.tar_policy where id in (select max(id) from piclos.tar_policy )')

,('dim_customer','customer_address_city','cci_policy','city','Varchar',N'update piclos.cci_policy set city = city + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.cci_policy where id in (select max(id) from piclos.cci_policy )')
,('dim_customer','customer_address_city','gap_policy','city','Varchar',N'update piclos.gap_policy set city = city + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.gap_policy where id in (select max(id) from piclos.gap_policy )')
,('dim_customer','customer_address_city','lnm_policy','city','Varchar',N'update piclos.lnm_policy set city = city + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.lnm_policy where id in (select max(id) from piclos.lnm_policy )')
--,('dim_customer','customer_address_city','mbi_policy','city','Varchar',N'update piclos.mbi_policy set city = city + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.mbi_policy where id in (select max(id) from piclos.mbi_policy )')
,('dim_customer','customer_address_city','posm_policy','city','Varchar',N'update piclos.posm_policy set city = city + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')
,('dim_customer','customer_address_city','tar_policy','city','Varchar',N'update piclos.tar_policy set city = city + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.tar_policy where id in (select max(id) from piclos.tar_policy )')

,('dim_customer','customer_address_postcode','cci_policy','postcode','Varchar',N'update piclos.cci_policy set postcode = postcode + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.cci_policy where id in (select max(id) from piclos.cci_policy )')
,('dim_customer','customer_address_postcode','gap_policy','postcode','Varchar',N'update piclos.gap_policy set postcode = postcode + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.gap_policy where id in (select max(id) from piclos.gap_policy )')
,('dim_customer','customer_address_postcode','lnm_policy','postcode','Varchar',N'update piclos.lnm_policy set postcode = postcode + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.lnm_policy where id in (select max(id) from piclos.lnm_policy )')
,('dim_customer','customer_address_postcode','mbi_policy','postcode','Varchar',N'update piclos.mbi_policy set postcode = postcode + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.mbi_policy where id in (select max(id) from piclos.mbi_policy )')
,('dim_customer','customer_address_postcode','posm_policy','postcode','Varchar',N'update piclos.posm_policy set postcode = postcode + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')
,('dim_customer','customer_address_postcode','tar_policy','postcode','Varchar',N'update piclos.tar_policy set postcode = postcode + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.tar_policy where id in (select max(id) from piclos.tar_policy )')

,('dim_customer','email_address','cci_policy','email','Varchar',N'update piclos.cci_policy set email = email + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.cci_policy where id in (select max(id) from piclos.cci_policy )')
,('dim_customer','email_address','gap_policy','email','Varchar',N'update piclos.gap_policy set email = email + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.gap_policy where id in (select max(id) from piclos.gap_policy )')
,('dim_customer','email_address','lnm_policy','email','Varchar',N'update piclos.lnm_policy set email = email + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.lnm_policy where id in (select max(id) from piclos.lnm_policy )')
,('dim_customer','email_address','mbi_policy','email','Varchar',N'update piclos.mbi_policy set email = email + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.mbi_policy where id in (select max(id) from piclos.mbi_policy )')
,('dim_customer','email_address','posm_policy','email','Varchar',N'update piclos.posm_policy set email = email + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')
,('dim_customer','email_address','tar_policy','email','Varchar',N'update piclos.tar_policy set email = email + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.tar_policy where id in (select max(id) from piclos.tar_policy )')

,('dim_customer','day_phone_number','cci_policy','day_phone','Varchar',N'update piclos.cci_policy set day_phone = day_phone + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.cci_policy where id in (select max(id) from piclos.cci_policy )')
,('dim_customer','day_phone_number','gap_policy','day_phone','Varchar',N'update piclos.gap_policy set day_phone = day_phone + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.gap_policy where id in (select max(id) from piclos.gap_policy )')
,('dim_customer','day_phone_number','lnm_policy','day_phone','Varchar',N'update piclos.lnm_policy set day_phone = day_phone + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.lnm_policy where id in (select max(id) from piclos.lnm_policy )')
,('dim_customer','day_phone_number','mbi_policy','day_phone','Varchar',N'update piclos.mbi_policy set day_phone = day_phone + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.mbi_policy where id in (select max(id) from piclos.mbi_policy )')
,('dim_customer','day_phone_number','posm_policy','day_phone','Varchar',N'update piclos.posm_policy set day_phone = day_phone + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')
,('dim_customer','day_phone_number','tar_policy','day_phone','Varchar',N'update piclos.tar_policy set day_phone = day_phone + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.tar_policy where id in (select max(id) from piclos.tar_policy )')

,('dim_customer','other_phone_number','cci_policy','other_phone','Varchar',N'update piclos.cci_policy set other_phone = other_phone + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.cci_policy where id in (select max(id) from piclos.cci_policy )')
,('dim_customer','other_phone_number','gap_policy','other_phone','Varchar',N'update piclos.gap_policy set other_phone = other_phone + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.gap_policy where id in (select max(id) from piclos.gap_policy )')
,('dim_customer','other_phone_number','lnm_policy','other_phone','Varchar',N'update piclos.lnm_policy set other_phone = other_phone + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.lnm_policy where id in (select max(id) from piclos.lnm_policy )')
,('dim_customer','other_phone_number','mbi_policy','other_phone','Varchar',N'update piclos.mbi_policy set other_phone = other_phone + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.mbi_policy where id in (select max(id) from piclos.mbi_policy )')
,('dim_customer','other_phone_number','posm_policy','other_phone','Varchar',N'update piclos.posm_policy set other_phone = other_phone + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')
,('dim_customer','other_phone_number','tar_policy','other_phone','Varchar',N'update piclos.tar_policy set other_phone = other_phone + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.tar_policy where id in (select max(id) from piclos.tar_policy )')

,('dim_customer','work_phone_number','posm_policy','work_phone','Varchar',N'update piclos.posm_policy set work_phone = work_phone + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')

,('dim_customer','e_delivery_pref','cci_policy','e_delivery_pref','Varchar',N'update piclos.cci_policy set e_delivery_pref = e_delivery_pref + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.cci_policy where id in (select max(id) from piclos.cci_policy )')
,('dim_customer','e_delivery_pref','gap_policy','e_delivery_pref','Varchar',N'update piclos.gap_policy set e_delivery_pref = e_delivery_pref + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.gap_policy where id in (select max(id) from piclos.gap_policy )')
,('dim_customer','e_delivery_pref','mbi_policy','e_delivery_pref','Varchar',N'update piclos.mbi_policy set e_delivery_pref = e_delivery_pref + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.mbi_policy where id in (select max(id) from piclos.mbi_policy )')
,('dim_customer','e_delivery_pref','tar_policy','e_delivery_pref','Varchar',N'update piclos.tar_policy set e_delivery_pref = e_delivery_pref + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.tar_policy where id in (select max(id) from piclos.tar_policy )')

,('dim_customer','send_edocs_now_flag','cci_policy','send_edocs_now','Num',N'update piclos.cci_policy set send_edocs_now = case when send_edocs_now = 1 then 0 when send_edocs_now = 0 then 1 end, last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.cci_policy where id in (select max(id) from piclos.cci_policy )')
,('dim_customer','send_edocs_now_flag','gap_policy','send_edocs_now','Num',N'update piclos.gap_policy set send_edocs_now = case when send_edocs_now = 1 then 0 when send_edocs_now = 0 then 1 end, last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.gap_policy where id in (select max(id) from piclos.gap_policy )')
,('dim_customer','send_edocs_now_flag','mbi_policy','send_edocs_now','Num',N'update piclos.mbi_policy set send_edocs_now = case when send_edocs_now = 1 then 0 when send_edocs_now = 0 then 1 end, last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.mbi_policy where id in (select max(id) from piclos.mbi_policy )')
,('dim_customer','send_edocs_now_flag','tar_policy','send_edocs_now','Num',N'update piclos.tar_policy set send_edocs_now = case when send_edocs_now = 1 then 0 when send_edocs_now = 0 then 1 end, last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.tar_policy where id in (select max(id) from piclos.tar_policy )')

,('dim_customer','sent_to_ecm_flag','cci_policy','sent_to_ecm','Num',N'update piclos.cci_policy set sent_to_ecm = case when sent_to_ecm = 1 then 0 when sent_to_ecm = 0 then 1 end, last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.cci_policy where id in (select max(id) from piclos.cci_policy )')
,('dim_customer','sent_to_ecm_flag','gap_policy','sent_to_ecm','Num',N'update piclos.gap_policy set sent_to_ecm = case when sent_to_ecm = 1 then 0 when sent_to_ecm = 0 then 1 end, last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.gap_policy where id in (select max(id) from piclos.gap_policy )')
,('dim_customer','sent_to_ecm_flag','mbi_policy','sent_to_ecm','Num',N'update piclos.mbi_policy set sent_to_ecm = case when sent_to_ecm = 1 then 0 when sent_to_ecm = 0 then 1 end, last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.mbi_policy where id in (select max(id) from piclos.mbi_policy )')
,('dim_customer','sent_to_ecm_flag','tar_policy','sent_to_ecm','Num',N'update piclos.tar_policy set sent_to_ecm = case when sent_to_ecm = 1 then 0 when sent_to_ecm = 0 then 1 end, last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.tar_policy where id in (select max(id) from piclos.tar_policy )')

,('dim_customer','contact_notes','mbi_policy','contact_details','Varchar',N'update piclos.mbi_policy set contact_details = contact_details + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.mbi_policy where id in (select max(id) from piclos.mbi_policy )')

,('dim_customer','finance_paid_by_cash_flag','posm_policy','finance_paid_by_cash','Num',N'update piclos.posm_policy set finance_paid_by_cash = case when finance_paid_by_cash = 1 then 0 when finance_paid_by_cash = 0 then 1 end , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')
,('dim_customer','insured_is_company_flag','posm_policy','insured_is_company','Num',N'update piclos.posm_policy set insured_is_company = case when insured_is_company = 1 then 0 when insured_is_company = 0 then 1 end , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')
,('dim_customer','insured_person_interest_notes','posm_policy','insured_person_interest','Varchar',N'update piclos.posm_policy set insured_person_interest = insured_person_interest + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')
,('dim_customer','insured_person2_address','posm_policy','insured_person2_address','Varchar',N'update piclos.posm_policy set insured_person2_address = insured_person2_address + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')
,('dim_customer','insured_person2_suburb','posm_policy','insured_person2_suburb','Varchar',N'update piclos.posm_policy set insured_person2_suburb = insured_person2_suburb + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')
,('dim_customer','insured_person2_city','posm_policy','insured_person2_city','Varchar',N'update piclos.posm_policy set insured_person2_city = insured_person2_city + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')
,('dim_customer','insured_person2_post_code','posm_policy','insured_person2_post_code','Varchar',N'update piclos.posm_policy set insured_person2_post_code = insured_person2_post_code + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')
,('dim_customer','insured_person2_email_address','posm_policy','insured_person2_email_address','Varchar',N'update piclos.posm_policy set insured_person2_email_address = insured_person2_email_address + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')
,('dim_customer','insured_person2_home_phone_number','posm_policy','insured_person2_home_phone','Varchar',N'update piclos.posm_policy set insured_person2_home_phone = insured_person2_home_phone + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')
,('dim_customer','insured_person2_mobile_phone_number','posm_policy','insured_person2_mobile_phone','Varchar',N'update piclos.posm_policy set insured_person2_mobile_phone = insured_person2_mobile_phone + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')
,('dim_customer','insured_person2_work_phone_number','posm_policy','insured_person2_work_phone','Varchar',N'update piclos.posm_policy set insured_person2_work_phone = insured_person2_work_phone + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')
,('dim_customer','registered_owner_title','posm_policy','registered_owner_title','Varchar',N'update piclos.posm_policy set registered_owner_title = registered_owner_title + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')
,('dim_customer','registered_owner_first_name','posm_policy','registered_owner_first_name','Varchar',N'update piclos.posm_policy set registered_owner_first_name = registered_owner_first_name + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')
,('dim_customer','registered_owner_last_name','posm_policy','registered_owner_last_name','Varchar',N'update piclos.posm_policy set registered_owner_last_name = registered_owner_last_name + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')
,('dim_customer','registered_owner_address','posm_policy','registered_owner_address','Varchar',N'update piclos.posm_policy set registered_owner_address = registered_owner_address + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')
,('dim_customer','registered_owner_suburb','posm_policy','registered_owner_suburb','Varchar',N'update piclos.posm_policy set registered_owner_suburb = registered_owner_suburb + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')
,('dim_customer','registered_owner_city','posm_policy','registered_owner_city','Varchar',N'update piclos.posm_policy set registered_owner_city = registered_owner_city + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')
,('dim_customer','registered_owner_post_code','posm_policy','registered_owner_post_code','Varchar',N'update piclos.posm_policy set registered_owner_post_code = registered_owner_post_code + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')

,('dim_customer','primary_driver_accident_free_years','posm_policy','primary_driver_accident_free_years','Num',N'update piclos.posm_policy set primary_driver_accident_free_years = isnull(primary_driver_accident_free_years,0) + 1 , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')
,('dim_customer','primary_driver_gender_flag','posm_policy','primary_driver_gender','Num',N'update piclos.posm_policy set primary_driver_gender = case when primary_driver_gender = 1 then 0 when primary_driver_gender = 0 then 1 end , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')
,('dim_customer','additional_driver_number','posm_policy','other_driver','Num',N'update piclos.posm_policy set other_driver = isnull(other_driver,0) + 1 , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')

,('dim_customer','driver2_first_name','posm_policy','driver2_first_name','Varchar',N'update piclos.posm_policy set driver2_first_name = driver2_first_name + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')
,('dim_customer','driver2_last_name','posm_policy','driver2_last_name','Varchar',N'update piclos.posm_policy set driver2_last_name = driver2_last_name + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')
,('dim_customer','driver2_dob','posm_policy','driver2_dob','Date',N'update piclos.posm_policy set driver2_dob = dateadd(m,1,getdate()), last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')

,('dim_customer','driver3_first_name','posm_policy','driver3_first_name','Varchar',N'update piclos.posm_policy set driver3_first_name = driver3_first_name + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')
,('dim_customer','driver3_last_name','posm_policy','driver3_last_name','Varchar',N'update piclos.posm_policy set driver3_last_name = driver3_last_name + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')
,('dim_customer','driver3_dob','posm_policy','driver3_dob','Date',N'update piclos.posm_policy set driver3_dob = dateadd(m,1,getdate()), last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')

,('dim_customer','driver4_first_name','posm_policy','driver4_first_name','Varchar',N'update piclos.posm_policy set driver4_first_name = driver4_first_name + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')
,('dim_customer','driver4_last_name','posm_policy','driver4_last_name','Varchar',N'update piclos.posm_policy set driver4_last_name = driver4_last_name + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')
,('dim_customer','driver4_dob','posm_policy','driver4_dob','Date',N'update piclos.posm_policy set driver4_dob = dateadd(m,1,getdate()), last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')

,('dim_customer','driver5_first_name','posm_policy','driver5_first_name','Varchar',N'update piclos.posm_policy set driver5_first_name = driver5_first_name + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')
,('dim_customer','driver5_last_name','posm_policy','driver5_last_name','Varchar',N'update piclos.posm_policy set driver5_last_name = driver5_last_name + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')
,('dim_customer','driver5_dob','posm_policy','driver5_dob','Date',N'update piclos.posm_policy set driver5_dob = dateadd(m,1,getdate()), last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')

,('dim_customer','interested_parties_id','posm_policy','interested_parties_id','Num',N'update piclos.posm_policy set interested_parties_id = isnull(interested_parties_id,0) + 1 , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')
,('dim_customer','interested_parties_name','posm_policy','interested_parties','Varchar',N'update piclos.posm_policy set interested_parties = interested_parties + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')
,('dim_customer','insurance_refused_flag','posm_policy','insurance_refused','Num',N'update piclos.posm_policy set insurance_refused = case when insurance_refused = 1 then 0 when insurance_refused = 0 then 1 end , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')
,('dim_customer','insurance_refused_details','posm_policy','insurance_refused_details','Varchar',N'update piclos.posm_policy set insurance_refused_details = insurance_refused_details + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')
,('dim_customer','claim_withdrawn_flag','posm_policy','claim_withdrawn','Num',N'update piclos.posm_policy set claim_withdrawn = case when claim_withdrawn = 1 then 0 when claim_withdrawn = 0 then 1 end , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')
,('dim_customer','claim_withdrawn_details','posm_policy','claim_withdrawn_details','Varchar',N'update piclos.posm_policy set claim_withdrawn_details = claim_withdrawn_details + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')
,('dim_customer','conviction_flag','posm_policy','conviction','Num',N'update piclos.posm_policy set conviction = case when conviction = 1 then 0 when conviction = 0 then 1 end , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')
,('dim_customer','conviction_details','posm_policy','conviction_details','Varchar',N'update piclos.posm_policy set conviction_details = conviction_details + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')
,('dim_customer','criminal_activity_flag','posm_policy','criminal_activity','Num',N'update piclos.posm_policy set criminal_activity = case when criminal_activity = 1 then 0 when criminal_activity = 0 then 1 end , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')
,('dim_customer','criminal_activity_details','posm_policy','criminal_activity_details','Varchar',N'update piclos.posm_policy set criminal_activity_details = criminal_activity_details + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')
,('dim_customer','vehicle_owned_by_other_flag','posm_policy','vehicle_owned_by_other','Num',N'update piclos.posm_policy set vehicle_owned_by_other = case when vehicle_owned_by_other = 1 then 0 when vehicle_owned_by_other = 0 then 1 end , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')
,('dim_customer','vehicle_owned_by_other_details','posm_policy','vehicle_owned_by_other_details','Varchar',N'update piclos.posm_policy set vehicle_owned_by_other_details = vehicle_owned_by_other_details + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')
,('dim_customer','other_factors_flag','posm_policy','other_factors','Num',N'update piclos.posm_policy set other_factors = case when other_factors = 1 then 0 when other_factors = 0 then 1 end , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')
,('dim_customer','other_factors_details','posm_policy','other_factors_details','Varchar',N'update piclos.posm_policy set other_factors_details = other_factors_details + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')
,('dim_customer','declaration_notes','posm_policy','declarations','Varchar',N'update piclos.posm_policy set declarations = declarations + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')
,('dim_customer','policy_holder_choice1_description','posm_policy','policy_holder_choice1','Varchar',N'update piclos.posm_policy set policy_holder_choice1 = policy_holder_choice1 + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')
,('dim_customer','policy_holder_choice2_description','posm_policy','policy_holder_choice2','Varchar',N'update piclos.posm_policy set policy_holder_choice2 = policy_holder_choice2 + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')
--,('dim_customer','policy_holder_credit_union_id','posm_policy','policy_holder_credit_union_id','Varchar',N'update piclos.posm_policy set policy_holder_credit_union_id = policy_holder_credit_union_id + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')
,('dim_customer','policy_holder_credit_union_member_number','posm_policy','policy_holder_credit_union_member_number','Varchar',N'update piclos.posm_policy set policy_holder_credit_union_member_number = policy_holder_credit_union_member_number + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')
,('dim_customer','policy_holder_licence_type','posm_policy','policy_holder_licence_type','Num',N'update piclos.posm_policy set policy_holder_licence_type = case when policy_holder_licence_type = 1 then 0 when policy_holder_licence_type = 0 then 1 end , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')
,('dim_customer','policy_holder_licence_number','posm_policy','policy_holder_licence_number','Varchar',N'update piclos.posm_policy set policy_holder_licence_number = policy_holder_licence_number + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')
,('dim_customer','policy_holder_licence_expiry_date','posm_policy','policy_holder_licence_expiry_date','Date',N'update piclos.posm_policy set policy_holder_licence_expiry_date = dateadd(m,1,getdate()), last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')
,('dim_customer','policy_holder_licence_version','posm_policy','policy_holder_licence_version','Varchar',N'update piclos.posm_policy set policy_holder_licence_version = policy_holder_licence_version + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')
,('dim_customer','policy_holder_has_licence_suspended_flag','posm_policy','policy_holder_has_licence_suspended','Num',N'update piclos.posm_policy set policy_holder_has_licence_suspended = case when policy_holder_has_licence_suspended = 1 then 0 when policy_holder_has_licence_suspended = 0 then 1 end , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')
,('dim_customer','policy_holder_has_previous_claims_flag','posm_policy','policy_holder_has_previous_claims','Num',N'update piclos.posm_policy set policy_holder_has_previous_claims = case when policy_holder_has_previous_claims = 1 then 0 when policy_holder_has_previous_claims = 0 then 1 end , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')
,('dim_customer','policy_holder_has_vehicle_loss_flag','posm_policy','policy_holder_has_vehicle_loss','Num',N'update piclos.posm_policy set policy_holder_has_vehicle_loss = case when policy_holder_has_vehicle_loss = 1 then 0 when policy_holder_has_vehicle_loss = 0 then 1 end , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')
,('dim_customer','policy_holder_has_driving_offences_flag','posm_policy','policy_holder_has_driving_offences','Num',N'update piclos.posm_policy set policy_holder_has_driving_offences = case when policy_holder_has_driving_offences = 1 then 0 when policy_holder_has_driving_offences = 0 then 1 end , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')
,('dim_customer','policy_holder_has_criminal_offence_flag','posm_policy','policy_holder_has_criminal_offence','Num',N'update piclos.posm_policy set policy_holder_has_criminal_offence = case when policy_holder_has_criminal_offence = 1 then 0 when policy_holder_has_criminal_offence = 0 then 1 end , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')
,('dim_customer','policy_holder_has_criminal_offence_bankrupt_flag','posm_policy','policy_holder_has_criminal_offence_bankrupt','Num',N'update piclos.posm_policy set policy_holder_has_criminal_offence_bankrupt = case when policy_holder_has_criminal_offence_bankrupt = 1 then 0 when policy_holder_has_criminal_offence_bankrupt = 0 then 1 end , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')
,('dim_customer','policy_holder_has_criminal_offence_prosecution_flag','posm_policy','policy_holder_has_criminal_offence_prosecution','Num',N'update piclos.posm_policy set policy_holder_has_criminal_offence_prosecution = case when policy_holder_has_criminal_offence_prosecution = 1 then 0 when policy_holder_has_criminal_offence_prosecution = 0 then 1 end , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')
,('dim_customer','policy_holder_has_criminal_offence_convicted_flag','posm_policy','policy_holder_has_criminal_offence_convicted','Num',N'update piclos.posm_policy set policy_holder_has_criminal_offence_convicted = case when policy_holder_has_criminal_offence_convicted = 1 then 0 when policy_holder_has_criminal_offence_convicted = 0 then 1 end , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')
,('dim_customer','policy_event_coverage_causes','cci_policy','causes','Varchar',N'update piclos.cci_policy set causes = causes + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.cci_policy where id in (select max(id) from piclos.cci_policy )')
,('dim_customer','vehicle_insurer_description','gap_policy','vehicle_insurer','Varchar',N'update piclos.gap_policy set vehicle_insurer = vehicle_insurer + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.gap_policy where id in (select max(id) from piclos.gap_policy )')

,('dim_customer','policy_purchase_datetime','cci_policy','purchase_timestamp','Date',N'update piclos.cci_policy set purchase_timestamp = dateadd(m,1,getdate()), last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.cci_policy where id in (select max(id) from piclos.cci_policy )')
,('dim_customer','policy_purchase_datetime','gap_policy','purchase_timestamp','Date',N'update piclos.gap_policy set purchase_timestamp = dateadd(m,1,getdate()), last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.gap_policy where id in (select max(id) from piclos.gap_policy )')
,('dim_customer','policy_purchase_datetime','lnm_policy','purchase_timestamp','Date',N'update piclos.lnm_policy set purchase_timestamp = dateadd(m,1,getdate()), last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.lnm_policy where id in (select max(id) from piclos.lnm_policy )')
,('dim_customer','policy_purchase_datetime','mbi_policy','purchase_timestamp','Date',N'update piclos.mbi_policy set purchase_timestamp = dateadd(m,1,getdate()), last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.mbi_policy where id in (select max(id) from piclos.mbi_policy )')
,('dim_customer','policy_purchase_datetime','posm_policy','purchase_timestamp','Date',N'update piclos.posm_policy set purchase_timestamp = dateadd(m,1,getdate()), last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')
,('dim_customer','policy_purchase_datetime','tar_policy','purchase_timestamp','Date',N'update piclos.tar_policy set purchase_timestamp = dateadd(m,1,getdate()), last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.tar_policy where id in (select max(id) from piclos.tar_policy )')

,('dim_customer','policy_valid_from_date','cci_policy','from_timestamp','Date',N'update piclos.cci_policy set from_timestamp = dateadd(m,1,getdate()), last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.cci_policy where id in (select max(id) from piclos.cci_policy )')
,('dim_customer','policy_valid_from_date','gap_policy','from_timestamp','Date',N'update piclos.gap_policy set from_timestamp = dateadd(m,1,getdate()), last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.gap_policy where id in (select max(id) from piclos.gap_policy )')
,('dim_customer','policy_valid_from_date','lnm_policy','from_timestamp','Date',N'update piclos.lnm_policy set from_timestamp = dateadd(m,1,getdate()), last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.lnm_policy where id in (select max(id) from piclos.lnm_policy )')
,('dim_customer','policy_valid_from_date','mbi_policy','from_timestamp','Date',N'update piclos.mbi_policy set from_timestamp = dateadd(m,1,getdate()), last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.mbi_policy where id in (select max(id) from piclos.mbi_policy )')
,('dim_customer','policy_valid_from_date','posm_policy','from_timestamp','Date',N'update piclos.posm_policy set from_timestamp = dateadd(m,1,getdate()), last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')
,('dim_customer','policy_valid_from_date','tar_policy','from_timestamp','Date',N'update piclos.tar_policy set from_timestamp = dateadd(m,1,getdate()), last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.tar_policy where id in (select max(id) from piclos.tar_policy )')

,('dim_customer','policy_valid_to_date','cci_policy','to_timestamp','Date',N'update piclos.cci_policy set to_timestamp = dateadd(m,1,getdate()), last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.cci_policy where id in (select max(id) from piclos.cci_policy )')
,('dim_customer','policy_valid_to_date','gap_policy','to_timestamp','Date',N'update piclos.gap_policy set to_timestamp = dateadd(m,1,getdate()), last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.gap_policy where id in (select max(id) from piclos.gap_policy )')
,('dim_customer','policy_valid_to_date','lnm_policy','to_timestamp','Date',N'update piclos.lnm_policy set to_timestamp = dateadd(m,1,getdate()), last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.lnm_policy where id in (select max(id) from piclos.lnm_policy )')
,('dim_customer','policy_valid_to_date','mbi_policy','to_timestamp','Date',N'update piclos.mbi_policy set to_timestamp = dateadd(m,1,getdate()), last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.mbi_policy where id in (select max(id) from piclos.mbi_policy )')
,('dim_customer','policy_valid_to_date','posm_policy','to_timestamp','Date',N'update piclos.posm_policy set to_timestamp = dateadd(m,1,getdate()), last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')
,('dim_customer','policy_valid_to_date','tar_policy','to_timestamp','Date',N'update piclos.tar_policy set to_timestamp = dateadd(m,1,getdate()), last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.tar_policy where id in (select max(id) from piclos.tar_policy )')

,('dim_customer','credit_union_member_number','lnm_policy','credit_union_member_number','Varchar',N'update piclos.lnm_policy set credit_union_member_number = credit_union_member_number + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.lnm_policy where id in (select max(id) from piclos.lnm_policy )')
,('dim_customer','policyholder_benefit_id','lnm_policy','benefit_for_policyholder','Num',N'update piclos.lnm_policy set benefit_for_policyholder = isnull(benefit_for_policyholder,0) + 1 , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.lnm_policy where id in (select max(id) from piclos.lnm_policy )')
,('dim_customer','lnm_loan_number','lnm_policy','loan_number','Varchar',N'update piclos.lnm_policy set loan_number = loan_number + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.lnm_policy where id in (select max(id) from piclos.lnm_policy )')
,('dim_customer','which_insured_flag','lnm_policy','which_insured','Num',N'update piclos.lnm_policy set which_insured = case when which_insured = 1 then 0 when which_insured = 0 then 1 end , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.lnm_policy where id in (select max(id) from piclos.lnm_policy )')
,('dim_customer','new_loan_type_id','lnm_policy','new_loan_type','Num',N'update piclos.lnm_policy set new_loan_type = isnull(new_loan_type,0) + 1 , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.lnm_policy where id in (select max(id) from piclos.lnm_policy )')
,('dim_customer','loan_balance_amount','lnm_policy','loan_balance','Num',N'update piclos.lnm_policy set loan_balance = isnull(loan_balance,0) + 1 , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.lnm_policy where id in (select max(id) from piclos.lnm_policy )')
,('dim_customer','loan_total_amount','lnm_policy','loan_total','Num',N'update piclos.lnm_policy set loan_total = isnull(loan_total,0) + 1 , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.lnm_policy where id in (select max(id) from piclos.lnm_policy )')
,('dim_customer','other_outstanding_loans_flag','lnm_policy','other_outstanding_loans','Num',N'update piclos.lnm_policy set other_outstanding_loans = case when other_outstanding_loans = 1 then 0 when other_outstanding_loans = 0 then 1 end , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.lnm_policy where id in (select max(id) from piclos.lnm_policy )')
,('dim_customer','balance_already_covered_amount','lnm_policy','balance_already_covered','Num',N'update piclos.lnm_policy set balance_already_covered = isnull(balance_already_covered,0) + 1 , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.lnm_policy where id in (select max(id) from piclos.lnm_policy )')
,('dim_customer','alert_backdated_flag','lnm_policy','alert_backdated','Num',N'update piclos.lnm_policy set alert_backdated = case when alert_backdated = 1 then 0 when alert_backdated = 0 then 1 end , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.lnm_policy where id in (select max(id) from piclos.lnm_policy )')
,('dim_customer','lnm_loan_created_date','lnm_policy','created_date','Date',N'update piclos.lnm_policy set created_date = dateadd(m,1,getdate()), last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.lnm_policy where id in (select max(id) from piclos.lnm_policy )')

,('dim_customer','primary_driver_title','posm_policy','primary_driver_title','Varchar',N'update piclos.posm_policy set primary_driver_title = primary_driver_title + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')
,('dim_customer','primary_driver_last_name','posm_policy','primary_driver_last_name','Varchar',N'update piclos.posm_policy set primary_driver_last_name = primary_driver_last_name + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')
,('dim_customer','primary_driver_first_name','posm_policy','primary_driver_first_name','Varchar',N'update piclos.posm_policy set primary_driver_first_name = primary_driver_first_name + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')
,('dim_customer','primary_driver_email_address','posm_policy','primary_driver_email_address','Varchar',N'update piclos.posm_policy set primary_driver_email_address = primary_driver_email_address + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')
,('dim_customer','primary_driver_home_phone_number','posm_policy','primary_driver_home_phone','Varchar',N'update piclos.posm_policy set primary_driver_home_phone = primary_driver_home_phone + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')
,('dim_customer','primary_driver_mobile_phone_number','posm_policy','primary_driver_mobile_phone','Varchar',N'update piclos.posm_policy set primary_driver_mobile_phone = primary_driver_mobile_phone + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')
,('dim_customer','primary_driver_work_phone_number','posm_policy','primary_driver_work_phone','Varchar',N'update piclos.posm_policy set primary_driver_work_phone = primary_driver_work_phone + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')
,('dim_customer','registered_owner_home_phone_number','posm_policy','registered_owner_home_phone','Varchar',N'update piclos.posm_policy set registered_owner_home_phone = registered_owner_home_phone + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')
,('dim_customer','registered_owner_mobile_phone_number','posm_policy','registered_owner_mobile_phone','Varchar',N'update piclos.posm_policy set registered_owner_mobile_phone = registered_owner_mobile_phone + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')
,('dim_customer','registered_owner_work_phone_number','posm_policy','registered_owner_work_phone','Varchar',N'update piclos.posm_policy set registered_owner_work_phone = registered_owner_work_phone + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')
,('dim_customer','registered_owner_email_address','posm_policy','registered_owner_email_address','Varchar',N'update piclos.posm_policy set registered_owner_email_address = registered_owner_email_address + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')
,('dim_customer','secondary_customer_dob','mbi_policy','dob_2','Date',N'update piclos.mbi_policy set dob_2 = dateadd(m,-1,getdate()), last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.mbi_policy where id in (select max(id) from piclos.mbi_policy )')
,('dim_customer','secondary_customer_dob','posm_policy','dob_2','Date',N'update piclos.posm_policy set dob_2 = dateadd(m,-1,getdate()), last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')
,('dim_customer','secondary_customer_dob','tar_policy','dob_2','Date',N'update piclos.tar_policy set dob_2 = dateadd(m,-1,getdate()), last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.tar_policy where id in (select max(id) from piclos.tar_policy )')
,('dim_customer','primary_customer_dob','gap_policy','dob_1','Date',N'update piclos.gap_policy set dob_1 = dateadd(m,-1,getdate()), last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.gap_policy where id in (select max(id) from piclos.gap_policy )')
,('dim_customer','primary_customer_dob','tar_policy','dob_1','Date',N'update piclos.tar_policy set dob_1 = dateadd(m,-1,getdate()), last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.tar_policy where id in (select max(id) from piclos.tar_policy )')
,('dim_customer','contact_notes','cci_policy','contact_details','Varchar',N'update piclos.cci_policy set contact_details = contact_details + ''1'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.cci_policy where id in (select max(id) from piclos.cci_policy )')
,('dim_customer','driver_more_flag','posm_policy','driver_more','Num',N'update piclos.posm_policy set driver_more = 1, last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')


select street,* from ext_piclos.mbi_policy where id in (select max(id) from ext_piclos.mbi_policy )
select customer_address_street, * from data.dim_customer where policy_id in (select max(id) from ext_piclos.mbi_policy ) order by record_start_datetime desc

delete from dbo.dim_customer_test_case

INSERT INTO dbo.dim_customer_test_case VALUES 
('dim_customer','customer_address_city','mbi_policy','city','Varchar',N'update piclos.mbi_policy set city = ''Wellington'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.mbi_policy where id in (select max(id) from piclos.mbi_policy )')
,('dim_customer','driver_more_flag','posm_policy','driver_more','Num',N'update piclos.posm_policy set driver_more = 0, last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.posm_policy where id in (select max(id) from piclos.posm_policy )')
,('dim_customer','primary_customer_name_title','mbi_policy','title_1','Varchar',N'update piclos.mbi_policy set title_1 = ''Mrs'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.mbi_policy where id in (select max(id) from piclos.mbi_policy )')
,('dim_customer','primary_customer_name_title','tar_policy','title_1','Varchar',N'update piclos.tar_policy set title_1 = ''Mrs'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.tar_policy where id in (select max(id) from piclos.tar_policy )')
,('dim_customer','secondary_customer_title','mbi_policy','title_2','Varchar',N'update piclos.mbi_policy set title_2 = title_2 + ''Mr'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.mbi_policy where id in (select max(id) from piclos.mbi_policy )')
,('dim_customer','customer_address_postcode','cci_policy','postcode','Varchar',N'update piclos.cci_policy set postcode = ''0627'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.cci_policy where id in (select max(id) from piclos.cci_policy )')
,('dim_customer','customer_address_postcode','lnm_policy','postcode','Varchar',N'update piclos.lnm_policy set postcode = ''0627'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.lnm_policy where id in (select max(id) from piclos.lnm_policy )')
,('dim_customer','customer_address_postcode','mbi_policy','postcode','Varchar',N'update piclos.mbi_policy set postcode =  ''0627'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.mbi_policy where id in (select max(id) from piclos.mbi_policy )')
,('dim_customer','customer_address_postcode','tar_policy','postcode','Varchar',N'update piclos.tar_policy set postcode = ''0627'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.tar_policy where id in (select max(id) from piclos.tar_policy )')
,('dim_customer','customer_address_street','mbi_policy','street','Varchar',N'update piclos.mbi_policy set street = ''Mountbatten Ave'' , last_updated = getdate() AT TIME ZONE ''UTC'' AT TIME ZONE ''New Zealand Standard Time'' from piclos.mbi_policy where id in (select max(id) from piclos.mbi_policy )')
