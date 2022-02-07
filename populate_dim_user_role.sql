/****** Object:  StoredProcedure [sp_data].[populate_dim_user_role]    Script Date: 17/11/2021 7:52:51 am ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [sp_data].[populate_dim_user_role]
AS
BEGIN
declare @end_date datetime ;
SET @end_date = (Select max(date_value) from data.dim_date);
	SET NOCOUNT ON;
	SET IDENTITY_INSERT data.[dim_user_role] ON
	INSERT INTO data.[dim_user_role]
		([user_role_key],[user_id],[name_title],[first_name],[last_name],[system_reference_id],[login_id],[email],[encrypted_password],[internal_user_flag],[user_disabled_flag],[user_disabled_datetime],[user_created_datetime]
      ,[user_phone_number],[crm_guid],[role_name],[role_level],[dealer_id],[dealer_name],[dealer_suburb_name],[dealer_city]
      ,[record_start_datetime],[record_end_datetime],[record_current_flag])
	SELECT -1,0,'N/A','N/A','N/A',0,
	        0,'N/A','N/A',1,0,'19000101','19000101','N/A',
			'N/A','N/A',0,0,'N/A','N/A','N/A',
			 '19000101',@end_date,1
	WHERE NOT EXISTS
	(SELECT [user_role_key] FROM  data.[dim_user_role] WHERE [user_role_key] = -1)
SET IDENTITY_INSERT  data.[dim_user_role] OFF


MERGE
	data.[dim_user_role] 
USING
	(
		  select  a.id, a.title, a.first_name, a.last_name, a.system_reference, a.username, a.email, a.[password], a.is_internal_user,
a.is_disabled, a.disabled_timestamp, a.created_timestamp, a.phone, a.crm_guid, r.title as role_name, r.[level], isnull(c.id,0) as dealer_id, c.company_name, 
c.suburb, c.city
from ext_piclos.[user] a
join ext_piclos.user_role  b on a.id = b.user_id
left join (select id, d.company_name, d.suburb, d.city, du.user_id
		from ext_piclos.dealer d 
		join ext_piclos.dealer_user du on d.id = du.dealer_id 
		) c on c.user_id = a.id
 join  ext_piclos.[role] r  on b.role_key = r.[key]

	) user_role
ON
	data.[dim_user_role].user_id = user_role.id
	and data.[dim_user_role].role_name = user_role.role_name
	and data.[dim_user_role].dealer_id = user_role.dealer_id
	and data.[dim_user_role].is_deleted = 0 
	and data.[dim_user_role].[record_current_flag] = 1 
WHEN NOT MATCHED BY TARGET THEN
	INSERT
		(
			 [user_id],[name_title],[first_name],[last_name],[system_reference_id],[login_id],[email],[encrypted_password],[internal_user_flag],[user_disabled_flag],[user_disabled_datetime],[user_created_datetime]
      ,[user_phone_number],[crm_guid],[role_name],[role_level],[dealer_id],[dealer_name],[dealer_suburb_name],[dealer_city]
	  ,[record_end_datetime]
		)
	VALUES
		(
	  id, title, first_name, last_name, system_reference, username, email, [password], is_internal_user,
is_disabled, disabled_timestamp, created_timestamp, phone, crm_guid, role_name, [level], dealer_id, company_name, suburb, city
	  ,@end_date
			
		)

WHEN MATCHED and( isnull(data.[dim_user_role].[user_id],-999) <> isnull(user_role.id,-999) OR
   isnull(data.[dim_user_role].[name_title],'NIL') <> isnull(user_role.title,'NIL') OR
   isnull(data.[dim_user_role].[first_name],'NIL') <> isnull(user_role.first_name,'NIL') OR
   isnull(data.[dim_user_role].[last_name],'NIL') <> isnull(user_role.last_name,'NIL') OR
   isnull(data.[dim_user_role].[system_reference_id],'NIL') <> isnull(user_role.system_reference,'NIL') OR
   isnull(data.[dim_user_role].[login_id],'NIL') <> isnull(user_role.username,'NIL') OR
   isnull(data.[dim_user_role].[email],'NIL') <> isnull(user_role.email,'NIL') OR
   isnull(data.[dim_user_role].[encrypted_password],'NIL') <> isnull(user_role.[password],'NIL') OR
   isnull(data.[dim_user_role].[internal_user_flag],0) <> isnull(user_role.is_internal_user,0) OR
   isnull(data.[dim_user_role].[user_disabled_flag],0) <> isnull(user_role.is_disabled,0) OR
   isnull(data.[dim_user_role].[user_disabled_datetime],0) <> isnull(user_role.disabled_timestamp,0) OR
   isnull(data.[dim_user_role].[user_created_datetime],'19000101') <> isnull(user_role.created_timestamp,'19000101') OR
   isnull(data.[dim_user_role].[user_phone_number],'NIL') <> isnull(user_role.phone,'NIL') OR
   isnull(data.[dim_user_role].[crm_guid],'NIL') <> isnull(user_role.crm_guid,'NIL') OR
   isnull(data.[dim_user_role].[role_level],-999) <> isnull(user_role.[level],-999) OR
   isnull(data.[dim_user_role].[dealer_id],-999) <> isnull(user_role.dealer_id,-999) OR
   isnull(data.[dim_user_role].[dealer_name],'NIL') <> isnull(user_role.company_name,'NIL') OR
   isnull(data.[dim_user_role].[dealer_suburb_name],'NIL') <> isnull(user_role.suburb,'NIL') OR
   isnull(data.[dim_user_role].[dealer_city],'NIL') <> isnull(user_role.city,'NIL') 
)

THEN 
UPDATE SET data.[dim_user_role].[record_end_datetime] = getdate() AT TIME ZONE 'UTC' AT TIME ZONE 'New Zealand Standard Time',
data.[dim_user_role].[record_current_flag] = 0,
data.[dim_user_role].last_updated = getdate() AT TIME ZONE 'UTC' AT TIME ZONE 'New Zealand Standard Time'


WHEN NOT MATCHED BY SOURCE AND data.[dim_user_role].user_role_key <> -1 and [record_current_flag] = 1 THEN 
UPDATE SET data.[dim_user_role].is_deleted = 1,
data.[dim_user_role].[record_end_datetime] = getdate() AT TIME ZONE 'UTC' AT TIME ZONE 'New Zealand Standard Time',
data.[dim_user_role].[record_current_flag] = 0;

INSERT into data.dim_user_role 
		(
			  [user_id],[name_title],[first_name],[last_name],[system_reference_id],[login_id],[email],[encrypted_password],[internal_user_flag],[user_disabled_flag],[user_disabled_datetime],[user_created_datetime]
      ,[user_phone_number],[crm_guid],[role_name],[role_level],[dealer_id],[dealer_name],[dealer_suburb_name],[dealer_city]
	  ,[record_end_datetime]
		)
	
       Select z.* from (   select  a.id, a.title, a.first_name, a.last_name, a.system_reference, a.username, a.email, a.[password], a.is_internal_user,
a.is_disabled, a.disabled_timestamp, a.created_timestamp, a.phone, a.crm_guid, r.title as role_name, r.[level], isnull(c.id,0) as dealer_id, c.company_name, 
c.suburb, c.city, @end_date as record_date_time
from ext_piclos.[user] a
join ext_piclos.user_role  b on a.id = b.user_id
left join (select id, d.company_name, d.suburb, d.city, du.user_id
		from ext_piclos.dealer d 
		join ext_piclos.dealer_user du on d.id = du.dealer_id 
		) c on c.user_id = a.id
 join  ext_piclos.[role] r  on b.role_key = r.[key] ) z
	left join data.dim_user_role u 
	on z.[id] = u.user_id
	and u.[record_current_flag] = 1  and u.is_deleted = 0
	where u.user_id  is null 


End
GO


