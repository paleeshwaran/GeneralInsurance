/****** Object:  StoredProcedure [sp_data].[populate_dim_product]    Script Date: 16/09/2021 11:06:13 am ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [sp_data].[populate_dim_product]
AS
BEGIN
	SET NOCOUNT ON;
	SET IDENTITY_INSERT data.[dim_product] ON
	INSERT INTO data.[dim_product]
		(product_key,product_code,product_description)
	SELECT -1,'N/A','N/A'
	WHERE NOT EXISTS
	(SELECT product_key FROM  data.[dim_product] WHERE product_key = -1)
SET IDENTITY_INSERT  data.[dim_product] OFF

MERGE
	data.[dim_product] 
USING
	(
		SELECT
		    distinct product_type, case when product_type = 'mbi' then 'Mechanical Breakdown Insurnace'
     when product_type = 'posm' then 'Private Motor Vehicle'
when product_type = 'lpi' then 'Loan Protection Insurance'
when product_type = 'cci' then 'Credit Contract Indemnity'
when product_type = 'gap' then 'Guaranteed Asset Protection'
else Product_name end as product_description 

		FROM
			[ext_piclos].[insurance_product]
			
		
	) [insurance_product]
ON
	data.[dim_product].product_code = [insurance_product].product_type
	and data.[dim_product].is_deleted = 0 
WHEN NOT MATCHED BY TARGET THEN
	INSERT
		(
			product_code,product_description,
			[bi_created],
            [last_updated],
			[is_deleted]
		)
	VALUES
		(
			product_type,product_description,
			getdate(),
			null,
			0
		)

WHEN NOT MATCHED BY SOURCE AND data.[dim_product].product_key <> -1 THEN UPDATE SET data.[dim_product].is_deleted = 1;

End
GO


