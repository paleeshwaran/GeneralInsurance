/****** Object:  StoredProcedure [dbo].[udsp_test_dim_user_role]    Script Date: 22/10/2021 9:52:16 am ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[udsp_test_dim_user_role] --@sql nvarchar(max) with execute as owner

AS
BEGIN
	declare @vsqletlsp varchar(255) = '[sp_data].[populate_dim_user_role]'
			,@vtablename varchar(255) = 'dim_user_role'
			,@vcolumnname varchar(255) 
			,@vstartdatetime datetime
			,@venddatetime	datetime
			--- C2 columns
			,@vTypeKey int
			,@vUserID int
			,@vfirstname varchar(100)
			,@vlastname varchar(100)
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
			,@vFromClause		nvarchar(max)
			,@vWhereClause		nvarchar(max)
			,@vsourcecolumnvalue	varchar(max)
			,@vdestinationcolumnvalue	varchar(max)
			,@vDestinationPrevColumnValue varchar(max)
			,@vcurrentflagpass varchar(1)
			,@vrecord_start_datetpass varchar(1)
			,@vrecord_end_datepass varchar(1) 
			,@vsourcetargetvalues varchar(max)
			,@numberofrows			int = 0
			


	declare  @dim_user_role_test_results TABLE
		(
			tablename varchar(255) NOT NULL,
			columnname varchar(255) NOT NULL,
			sourcetablename varchar(255) NOT NULL,
			sourcecolumnname varchar(255) NOT NULL,
			user_role_key		int  null,
			UserID		int  null,
			FirstName varchar(100)  null,
			LastName	varchar(100)  null,
			currentflagpass varchar(1) NOT NULL,
			record_start_datetpass varchar(1) NOT NULL,
			record_end_datepass varchar(1) NOT NULL,
			sourcetargetvalues varchar(max) null,
			update_datetime	datetime null
		)
	
	declare  c1 cursor for 
				select DestinationTable, DestinationColumn, SourceTableName, SourceColumnName, SourceDataType, sqlnotes
				from dbo.dim_user_role_test_case
	
	declare c2 cursor for 
				select user_role_key, a.[user_id], first_name, last_name, record_start_datetime, record_end_datetime, record_current_flag
				from Data.dim_user_role a 
				join (select max(id) userid from ext_piclos.[user]) b
					on a.[user_id] = b.userid
					where last_updated is null
	
	-- Process update statement in Source DB for diffrent scenarios
	open c1
	fetch c1 into @vDestinationTable, @vDestinationColumn, @vSourceTableName, @vSourceColumnName, @vSourceDataType, @vsqlnotes
	WHILE @@FETCH_STATUS = 0  
	BEGIN
		set @vstartdatetime = getdate() AT TIME ZONE 'UTC' AT TIME ZONE 'New Zealand Standard Time'

		-- update source table value
		EXEC sp_execute_remote @data_source_name  = N'linked_sourcedb', @stmt = @vsqlnotes 

		--print @vsqlnotes

		fetch c1 into @vDestinationTable, @vDestinationColumn, @vSourceTableName, @vSourceColumnName, @vSourceDataType, @vsqlnotes
	END
	close c1
	
	-- ETL proc to update target table
	exec @vsqletlsp

	set @venddatetime = getdate() AT TIME ZONE 'UTC' AT TIME ZONE 'New Zealand Standard Time'

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
		
		if @vSourceTableName = 'dealer'
		BEGIN
			set @vFromClause = N' from (select id, d.company_name, d.suburb, d.city, du.[user_id] from ext_piclos.dealer d join ext_piclos.dealer_user du on d.id = du.dealer_id ) a join ext_piclos.[user] c on a.[user_id] = c.id  where [user_id] in (select max(id) from ext_piclos.[user])'
		END
		if @vSourceTableName = '[role]'
		BEGIN
			set @vFromClause = N' from ext_piclos.[role] a join ext_piclos.user_role b on b.role_key = a.[key] join ext_piclos.[user] c on c.[id] = b.[user_id] where user_id in (select max(id) from ext_piclos.[user])'
		END
		if  @vSourceTableName = '[user]'
			set @vsqldynamic = N'select @vsourcecolumnvalue = ' + @vSourceColumnName 
											+ N' from ext_piclos.' +@vSourceTableName 
											+ N' where id in (select max(id) from ext_piclos.'+@vSourceTableName + N')'
		else
			set @vsqldynamic = N'select @vsourcecolumnvalue = a.' + @vSourceColumnName + @vFromClause

		--print @vsqldynamic

		-- Fetch updated table/column value from source
		exec sp_executesql 	@vsqldynamic, N'@vsourcecolumnvalue varchar(max) output', @vsourcecolumnvalue=@vsourcecolumnvalue OUTPUT 
		--select @vsourcecolumnvalue
		open c2
		fetch c2 into  @vTypeKey, @vUserID, @vfirstname, @vlastname, @vrecord_startdatetime, @vrecord_enddatetime, @vrecord_currentflag
		WHILE @@FETCH_STATUS = 0  
		BEGIN
			--IF (LEFT (@vlastname,3) = LEFT(@vSourceTableName,3))
			--BEGIN
				
				if @vSourceDataType = 'Num' 
					set @vDestinationColumn = CONVERT(VARCHAR(255), @vDestinationColumn) 
				else if @vSourceDataType = 'Date'
					set @vDestinationColumn = CONVERT(VARCHAR(255), @vDestinationColumn, 120)
				else 
					set @vDestinationColumn = @vDestinationColumn
					
					
				set @vsqldynamic = N'select @vdestinationcolumnvalue = ' + @vDestinationColumn 
										+ N' from data.' +@VDestinationTable 
										+ N' where user_role_key = ' + convert(nvarchar, @vTypeKey)
										
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
										+ N' where [user_id] = ' + convert(nvarchar, @vUserID)
										+ N' and record_end_datetime between ' + N'''' + convert(nvarchar, @vstartdatetime, 121) + N''''  
										+' and ' + + N'''' + convert(nvarchar, @venddatetime, 121) + N'''' 
				--print @vsqldynamic						
				--Fetch previous column value from target table
				exec sp_executesql 	@vsqldynamic, N'@vDestinationPrevColumnValue varchar(max) output', @vDestinationPrevColumnValue=@vDestinationPrevColumnValue OUTPUT 

				set @vDestinationPrevColumnValue = isnull(@vDestinationPrevColumnValue,'N/A')

				-- to compare only date up to seconds 'yyyy-mm-dd hh:mm:ss' because source table is datetime2
				if @vSourceDataType = 'Date'
				begin
				   set @vdestinationcolumnvalue = CONVERT(datetime, @vdestinationcolumnvalue, 120)
				   set @vsourcecolumnvalue = CONVERT(datetime, @vsourcecolumnvalue, 120)
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
				insert into @dim_user_role_test_results 
					(tablename, columnname, sourcetablename, sourcecolumnname, user_role_key, UserID, FirstName, LastName, currentflagpass, record_start_datetpass, record_end_datepass, sourcetargetvalues, update_datetime)
					values (@vDestinationTable, @vDestinationColumn, @vSourceTableName, @vSourceColumnName, @vTypeKey, @vUserID, @vfirstname, @vlastname, @vcurrentflagpass, @vrecord_start_datetpass, @vrecord_end_datepass, @vsourcetargetvalues, @venddatetime)
			--END
			fetch c2 into  @vTypeKey, @vUserID, @vfirstname, @vlastname, @vrecord_startdatetime, @vrecord_enddatetime, @vrecord_currentflag
		END
		close c2
		fetch c1 into @vDestinationTable, @vDestinationColumn, @vSourceTableName, @vSourceColumnName, @vSourceDataType, @vsqlnotes
	END
	close c1
	deallocate c1
	deallocate c2
	select * from @dim_user_role_test_results order by update_datetime

END
GO

--select * from dbo.dim_user_role_test_case

--exec [dbo].[udsp_test_dim_user_role]

--exec [sp_data].[populate_dim_user_role]


IF EXISTS (select * from sys.sysobjects where name = 'dim_user_role_test_case')
	DROP TABLE dbo.dim_user_role_test_case

CREATE TABLE dbo.dim_user_role_test_case
(DestinationTable		varchar(255),
 DestinationColumn		varchar(255),
 SourceTableName		varchar(255),
 SourceColumnName		varchar(255),
 SourceDataType			varchar(10), 
 sqlnotes				nvarchar(max),
CONSTRAINT [PK_dim_user_role_ts] PRIMARY KEY CLUSTERED 
(
	DestinationTable ASC,
	DestinationColumn ASC,
	SourceTableName ASC,
	SourceColumnName ASC,
	SourceDataType	ASC 
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


--exec [dbo].[udsp_test_dim_user_role]

delete from dbo.dim_user_role_test_case 
INSERT INTO dbo.dim_user_role_test_case VALUES 
('dim_user_role','name_title','[user]','title','Varchar',N'update piclos.[user] set title = title + ''s'' from piclos.[user] where id in (select max(id) from piclos.[user] )')
,('dim_user_role','first_name','[user]','first_name','Varchar',N'update piclos.[user] set first_name = first_name + ''test'' from piclos.[user] where id in (select max(id) from piclos.[user] )')
,('dim_user_role','last_name','[user]','last_name','Varchar',N'update piclos.[user] set last_name = last_name + ''test'' from piclos.[user] where id in (select max(id) from piclos.[user] )')
,('dim_user_role','system_reference_id','[user]','system_reference','Varchar',N'update piclos.[user] set system_reference = system_reference + ''1'' from piclos.[user] where id in (select max(id) from piclos.[user] )')
,('dim_user_role','login_id','[user]','username','Varchar',N'update piclos.[user] set username = username + ''1'' from piclos.[user] where id in (select max(id) from piclos.[user] )')
,('dim_user_role','email','[user]','email','Varchar',N'update piclos.[user] set email = email + ''1'' from piclos.[user] where id in (select max(id) from piclos.[user] )')
,('dim_user_role','encrypted_password','[user]','password','Varchar',N'update piclos.[user] set password = password + ''1'' from piclos.[user] where id in (select max(id) from piclos.[user] )')
,('dim_user_role','internal_user_flag','[user]','is_internal_user','Num',N'update piclos.[user] set is_internal_user = case when is_internal_user = 1 then 0 when is_internal_user = 0 then 1 end from piclos.[user] where id in (select max(id) from piclos.[user] )')
,('dim_user_role','user_disabled_flag','[user]','is_disabled','Num',N'update piclos.[user] set is_disabled = case when is_disabled = 1 then 0 when is_disabled = 0 then 1 end from piclos.[user] where id in (select max(id) from piclos.[user] )')
,('dim_user_role','user_disabled_datetime','[user]','disabled_timestamp','Varchar',N'update piclos.[user] set disabled_timestamp = dateadd(m,1,getdate()) from piclos.[user] where id in (select max(id) from piclos.[user] )')
,('dim_user_role','user_created_datetime','[user]','created_timestamp','Varchar',N'update piclos.[user] set created_timestamp = dateadd(m,1,getdate()) from piclos.[user] where id in (select max(id) from piclos.[user] )')
,('dim_user_role','crm_guid','[user]','crm_guid','Varchar',N'update piclos.[user] set crm_guid = crm_guid + ''1'' from piclos.[user] where id in (select max(id) from piclos.[user] )')
,('dim_user_role','dealer_city','dealer','city','Varchar',N'update piclos.dealer set city = a.city + ''1'' from (select id, d.company_name, d.suburb, d.city, du.[user_id] from piclos.dealer d join piclos.dealer_user du on d.id = du.dealer_id ) a join piclos.[user] c on a.[user_id] = c.id  where [user_id] in (select max(id) from piclos.[user])')
,('dim_user_role','dealer_name','dealer','company_name','Varchar',N'update piclos.dealer set company_name= a.company_name + ''1'' from (select id, d.company_name, d.suburb, d.city, du.[user_id] from piclos.dealer d join piclos.dealer_user du on d.id = du.dealer_id ) a join piclos.[user] c on a.[user_id] = c.id  where [user_id] in (select max(id) from piclos.[user])')
,('dim_user_role','dealer_suburb_name','dealer','suburb','Varchar',N'update piclos.dealer set suburb = a.suburb + ''1'' from (select id, d.company_name, d.suburb, d.city, du.[user_id] from piclos.dealer d join piclos.dealer_user du on d.id = du.dealer_id ) a join piclos.[user] c on a.[user_id] = c.id  where [user_id] in (select max(id) from piclos.[user])')
,('dim_user_role','role_name','[role]','title','Varchar',N'update piclos.role set title = a.title + ''1'' from piclos.[role] a join piclos.user_role b on b.role_key = a.[key] join piclos.[user] c on c.[id] = b.[user_id] where user_id in (select max(id) from piclos.[user])')
,('dim_user_role','role_level','[role]','[level]','Num',N'update piclos.role set [level] = a.[level] + 1 from piclos.[role] a join piclos.user_role b on b.role_key = a.[key] join piclos.[user] c on c.[id] = b.[user_id] where user_id in (select max(id) from piclos.[user])')
,('dim_user_role','user_phone_number','[user]','phone','Varchar',N'update piclos.[user] set phone = phone + ''1'' from piclos.[user] where id in (select max(id) from piclos.[user] )')
