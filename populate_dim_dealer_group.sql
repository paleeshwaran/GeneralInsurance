/****** Object:  StoredProcedure [sp_data].[populate_dim_dealer_group]    Script Date: 6/10/2021 8:49:41 am ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF EXISTS (SELECT 1 FROM sys.sysobjects where name = 'populate_dim_dealer_group')
 DROP PROCEDURE [sp_data].[populate_dim_dealer_group]

GO

CREATE PROCEDURE [sp_data].[populate_dim_dealer_group]
AS
BEGIN
declare @end_date datetime ;
SET @end_date = (Select max(date_value) from data.dim_date);
	SET NOCOUNT ON;
	SET IDENTITY_INSERT data.dim_dealer_group ON
	INSERT INTO data.dim_dealer_group
		(dealer_group_key,[dealer_group_id],[dealer_group_name],[reporting_group_flag],[group_policies_visible_to_dealers_flag],[logo_1_filename],[logo_2_filename],
		[dealer_group_created_date],[record_end_datetime])
	SELECT -1,0,'N/A',1,1,'N/A','N/A','19000101',@end_date
	WHERE NOT EXISTS
	(SELECT dealer_group_key FROM  data.dim_dealer_group WHERE dealer_group_key = -1)
SET IDENTITY_INSERT  data.dim_dealer_group OFF

MERGE
	data.dim_dealer_group 
USING
	(
		
	Select [id],[title],[reporting_group],[group_policies_visible_to_dealers],[logo_1_filename],[logo_2_filename],[created_date]
        from [ext_piclos].dealer_group
) dealer_group
ON
	data.dim_dealer_group.[dealer_group_id] = dealer_group.id
	and data.dim_dealer_group.is_deleted = 0 
	and data.dim_dealer_group.[record_current_flag] = 1 
WHEN NOT MATCHED BY TARGET THEN
	INSERT
		(
			[dealer_group_id],[dealer_group_name],[reporting_group_flag],[group_policies_visible_to_dealers_flag],[logo_1_filename],[logo_2_filename],[dealer_group_created_date],[record_end_datetime]
		)
	VALUES
		(
			[id],[title],[reporting_group],[group_policies_visible_to_dealers],[logo_1_filename],[logo_2_filename],[created_date],@end_date
			
			
		)

WHEN MATCHED and( data.dim_dealer_group.[dealer_group_name] <> dealer_group.[title] OR
isnull(data.dim_dealer_group.[reporting_group_flag],0) <> isnull(dealer_group.[reporting_group],0) OR
isnull(data.dim_dealer_group.[group_policies_visible_to_dealers_flag],0) <> isnull(dealer_group.[group_policies_visible_to_dealers],0) OR
isnull(data.dim_dealer_group.[logo_1_filename],'') <> isnull(dealer_group.[logo_1_filename],'') OR
isnull(data.dim_dealer_group.[logo_2_filename],'') <> isnull(dealer_group.[logo_2_filename],'')  ) 


THEN 
UPDATE SET data.dim_dealer_group.[record_end_datetime] = getdate(),
data.dim_dealer_group.[record_current_flag] = 0,
data.dim_dealer_group.last_updated = getdate()


WHEN NOT MATCHED BY SOURCE AND data.dim_dealer_group.dealer_group_key <> -1 and [record_current_flag] = 1 THEN
UPDATE SET data.dim_dealer_group.is_deleted = 1,
data.dim_dealer_group.[record_end_datetime] = getdate(),
data.dim_dealer_group.[record_current_flag] = 0;;

INSERT into data.dim_dealer_group 
		(
			[dealer_group_id],[dealer_group_name],[reporting_group_flag],[group_policies_visible_to_dealers_flag],[logo_1_filename],[logo_2_filename],[dealer_group_created_date],[record_end_datetime]
		)

Select [id],[title],[reporting_group],[group_policies_visible_to_dealers],[logo_1_filename],[logo_2_filename],[created_date],@end_date
from ext_piclos.dealer_group 
	where dealer_group.id not in (select dealer_group_id from data.dim_dealer_group where [record_current_flag] = 1 and is_deleted = 0  )

End
GO


