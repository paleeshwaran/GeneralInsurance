/****** Object:  StoredProcedure [sp_data].[populate_dim_dealer_group]    Script Date: 21/09/2021 7:32:19 am ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


IF EXISTS (select * from sys.sysobjects where name = 'udsp_test_dim_dealer_group')
	DROP PROCEDURE [dbo].[udsp_test_dim_dealer_group]
GO

CREATE PROCEDURE [dbo].[udsp_test_dim_dealer_group] --@sql nvarchar(max) with execute as owner

AS
BEGIN
	declare @vsqletlsp varchar(255) = '[sp_data].[populate_dim_dealer_group]'
			,@vtablename varchar(255) = 'dim_dealer_group'
			,@vcolumnname varchar(255) 
			,@vstartdatetime datetime
			,@venddatetime	datetime
			--- C2 columns
			,@vTypeKey int
			,@vTypeID int
			,@vTypeName varchar(100)
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


	declare  @dim_dealer_group_test_results TABLE
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
				from dbo.dim_dealer_group_test_case
	
	declare c2 cursor for 
				select dealer_group_key, dealer_group_id, dealer_group_name, record_start_datetime, record_end_datetime, record_current_flag
				from Data.dim_dealer_group a 
					where last_updated is null
					and  dealer_group_id in (select max(id) from ext_piclos.dealer_group)
	
	open c1
	fetch c1 into @vDestinationTable, @vDestinationColumn, @vSourceTableName, @vSourceColumnName, @vsqlnotes
	WHILE @@FETCH_STATUS = 0  
	BEGIN
		EXEC sp_execute_remote @data_source_name  = N'linked_sourcedb', 
		@stmt = @vsqlnotes

		exec @vsqletlsp

		set @venddatetime = getdate() AT TIME ZONE 'UTC' AT TIME ZONE 'New Zealand Standard Time'

		open c2
		fetch c2 into  @vTypeKey, @vTypeID, @vTypeName, @vrecord_startdatetime, @vrecord_enddatetime, @vrecord_currentflag
		WHILE @@FETCH_STATUS = 0  
		BEGIN
			--IF LEFT (@vProductCode,3) = LEFT(@vSourceTableName,3)
			--BEGIN
				-- FOR DEBUGGING
				set @numberofrows = @numberofrows + 1
				--SELECT @vTypeKey, @vTypeID, @vProductCode, @vrecord_startdatetime, @vrecord_enddatetime, @vrecord_currentflag
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

				insert into @dim_dealer_group_test_results 
					(tablename, columnname, sourcetablename, sourcecolumnname, currentflagpass, record_start_datetpass, record_end_datepass)
					values (@vDestinationTable, @vDestinationColumn, @vSourceTableName, @vSourceColumnName, @vcurrentflagpass, @vrecord_start_datetpass, @vrecord_end_datepass)
			--END
			fetch c2 into  @vTypeKey, @vTypeID, @vTypeName, @vrecord_startdatetime, @vrecord_enddatetime, @vrecord_currentflag
		END
		--print @numberofrows
		if @numberofrows = 0 
			   insert into @dim_dealer_group_test_results 
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
	select * from @dim_dealer_group_test_results
END
GO

select * from dbo.dim_dealer_group_test_case
select * from data.dim_dealer_group

exec [dbo].[udsp_test_dim_dealer_group] 

exec sp_data.[populate_dim_dealer_group]

select top 2 dealer_group_key, dealer_group_id, logo_2_filename , record_start_datetime, record_end_datetime ,record_current_flag, bi_created, last_updated, is_deleted
from data.dim_dealer_group 
where  dealer_group_id in (select max(id) from ext_piclos.dealer_group)
order by record_start_datetime desc, record_end_datetime desc

select * from ext_piclos.dealer_group where  id in (select max(id) from ext_piclos.dealer_group)

--IF EXISTS (select * from sys.sysobjects where name = 'dim_dealer_group_test_case')
--	DROP TABLE dbo.dim_dealer_group_test_case

--CREATE TABLE dbo.dim_dealer_group_test_case
--(DestinationTable		varchar(255),
-- DestinationColumn		varchar(255),
-- SourceTableName		varchar(255),
-- SourceColumnName		varchar(255),
-- sqlnotes				nvarchar(max),
--CONSTRAINT [PK_dim_dealer_group_ts] PRIMARY KEY CLUSTERED 
--(
--	DestinationTable ASC,
--	DestinationColumn ASC,
--	SourceTableName ASC,
--	SourceColumnName ASC
--)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
--) ON [PRIMARY]
--GO

--delete from dbo.dim_dealer_group_test_case 

--INSERT INTO dbo.dim_dealer_group_test_case VALUES 

-- ('dim_dealer_group','dealer_group_name','dealer_group','title',N'update piclos.dealer_group set title = title + ''1'' from piclos.dealer_group where id in (select max(id) from piclos.dealer_group )')
--,('dim_dealer_group','reporting_group_flag','dealer_group','reporting_group',N'update piclos.dealer_group set reporting_group = case when reporting_group = 1 then 0 when reporting_group = 0 then 1 end  from piclos.dealer_group where id in (select max(id) from piclos.dealer_group )')
--,('dim_dealer_group','group_policies_visible_to_dealers_flag','dealer_group','group_policies_visible_to_dealers',N'update piclos.dealer_group set group_policies_visible_to_dealers = case when group_policies_visible_to_dealers = 1 then 0 when group_policies_visible_to_dealers = 0 then 1 end  from piclos.dealer_group where id in (select max(id) from piclos.dealer_group )')
--,('dim_dealer_group','logo_1_filename','dealer_group','logo_1_filename',N'update piclos.dealer_group set logo_1_filename = logo_1_filename + ''1'' from piclos.dealer_group where id in (select max(id) from piclos.dealer_group )')
--,('dim_dealer_group','logo_2_filename','dealer_group','logo_2_filename',N'update piclos.dealer_group set logo_2_filename = logo_2_filename + ''1'' from piclos.dealer_group where id in (select max(id) from piclos.dealer_group )')

--case when group_policies_visible_to_dealers = 1 then 0 when group_policies_visible_to_dealers = 0 then 1 end 