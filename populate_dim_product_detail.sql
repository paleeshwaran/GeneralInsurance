/****** Object:  StoredProcedure [sp_data].[populate_dim_product_detail]    Script Date: 16/09/2021 11:05:53 am ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [sp_data].[populate_dim_product_detail]
AS
BEGIN
	SET NOCOUNT ON;
	SET IDENTITY_INSERT data.[dim_product_detail] ON
	INSERT INTO data.[dim_product_detail]
		(product_detail_key,product_id,product_code,product_name,policy_booklet_version,policy_booklet_name,product_active_flag)
	SELECT -1,0,'N/A','N/A',0,'(unknown)',1
	WHERE NOT EXISTS
	(SELECT product_detail_key FROM  data.[dim_product_detail] WHERE product_detail_key = -1)
SET IDENTITY_INSERT  data.[dim_product_detail] OFF

MERGE
	data.[dim_product_detail] 
USING
	(
		SELECT
		    id,product_type,product_name,[policy_booklet_version],[policy_booklet_name],is_enabled

		FROM
			[ext_piclos].[insurance_product]
			
		
	) [insurance_product]
ON
	data.[dim_product_detail].product_id = [insurance_product].id
	and data.[dim_product_detail].is_deleted = 0 
WHEN NOT MATCHED BY TARGET THEN
	INSERT
		(
			product_id,product_code,product_name,policy_booklet_version,policy_booklet_name,product_active_flag,
			[bi_created],
            [last_updated],
			[is_deleted]
		)
	VALUES
		(
			id,product_type,product_name,policy_booklet_version,policy_booklet_name,is_enabled,
			getdate(),
			null,
			0
		)

WHEN MATCHED and( data.[dim_product_detail].product_code <> [insurance_product].product_type OR
data.[dim_product_detail].product_name <> [insurance_product].product_name OR
data.[dim_product_detail].policy_booklet_version <> [insurance_product].policy_booklet_version OR
data.[dim_product_detail].policy_booklet_name <> [insurance_product].policy_booklet_name OR
data.[dim_product_detail].product_active_flag <> [insurance_product].is_enabled )

THEN 
UPDATE SET data.[dim_product_detail].product_code = [insurance_product].product_type,
data.[dim_product_detail].product_name = [insurance_product].product_name,
data.[dim_product_detail].policy_booklet_version = [insurance_product].policy_booklet_version,
data.[dim_product_detail].policy_booklet_name = [insurance_product].policy_booklet_name,
data.[dim_product_detail].product_active_flag = [insurance_product].is_enabled,
data.[dim_product_detail].last_updated = getdate()


WHEN NOT MATCHED BY SOURCE AND data.[dim_product_detail].product_detail_key <> -1 THEN UPDATE SET data.[dim_product_detail].is_deleted = 1;

End
GO


