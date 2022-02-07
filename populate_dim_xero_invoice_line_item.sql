/****** Object:  StoredProcedure [sp_data].[populate_dim_xero_invoice_line_item]    Script Date: 7/02/2022 6:44:56 pm ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [sp_data].[populate_dim_xero_invoice_line_item]
AS
BEGIN
declare @end_date datetime ;
SET @end_date = (Select max(date_value) from data.dim_date);
	SET NOCOUNT ON;
	SET IDENTITY_INSERT data.dim_xero_invoice_line_item ON
INSERT [Data].dim_xero_invoice_line_item (xero_invoice_line_item_key,xero_invoice_id,xero_line_item_id,xero_line_item_policy_number,xero_line_amount_type_code
      )
SELECT -1, 'N/A','N/A','N/A','N/A'
	WHERE NOT EXISTS
	(SELECT xero_invoice_line_item_key FROM  data.dim_xero_invoice_line_item WHERE xero_invoice_line_item_key = -1)
SET IDENTITY_INSERT  data.dim_xero_invoice_line_item OFF

  SELECT invoice_id,[Invoice_Number]
,[Line_Amount_Types],cs.value as [line_Item_ID], DATEADD(second, CONVERT(float, SUBSTRING([Updated_Date_UTC],7,10) ) , '19700101')  as [Updated_Date_UTC]
into #invoices 
FROM [ext_xero].[invoices]
cross apply STRING_SPLIT (replace(replace(replace([line_Item_ID],'[',''),']',''),'"',''), ',') cs;

SELECT [Description],[UnitAmount],[TaxType],[TaxAmount],[LineAmount],[AccountCode],[Quantity],[LineItemID],b.[Invoice_Number],b.[Updated_Date_UTC]
	  ,b.[Line_Amount_Types],b.invoice_id ,data.UFN_SEPARATES_COLUMNS([Description],1,'|') as [Policy_Number],
	  data.UFN_SEPARATES_COLUMNS([Description],2,'|') as customer,
 data.UFN_SEPARATES_COLUMNS([Description],3,'|') as vehicle,
     data.UFN_SEPARATES_COLUMNS([Description],4,'|') as fee_type
	  into #invoice_line_item
  FROM [ext_xero].[invoices_line_item] A
  left join #invoices b
  on A.LineItemID = B.[line_Item_ID];

MERGE
	data.dim_xero_invoice_line_item 
USING
  (
 SELECT invoice_id,[LineItemID], case when len([Policy_Number]) > 200 then null else [Policy_Number] end as [Policy_Number],[Line_Amount_Types], 
customer, vehicle,fee_type ,[Description],[TaxType] ,[Updated_Date_UTC]
FROM #invoice_line_item
  ) invoices

on 
data.dim_xero_invoice_line_item.[xero_line_item_id] = invoices.[LineItemID] and 
data.dim_xero_invoice_line_item.is_deleted = 0 

WHEN NOT MATCHED BY TARGET THEN
	INSERT
		([xero_invoice_id],[xero_line_item_id],xero_line_item_policy_number,[xero_line_amount_type_code],[xero_line_item_customer_name],[xero_line_item_vehicle_number]
      ,[xero_line_item_fee_type],[xero_line_item_full_description],[xero_line_item_tax_type],[xero_last_updated_utc_date]
	  )
	  VALUES 
	  (
	 invoice_id,[LineItemID],[Policy_Number],[Line_Amount_Types], customer ,vehicle ,
     fee_type,[Description],[TaxType],[Updated_Date_UTC]
	  )
	  WHEN MATCHED and 
	  data.dim_xero_invoice_line_item.[xero_last_updated_utc_date] <> invoices.[Updated_Date_UTC]

	  THEN 
	  UPDATE SET 
	   data.dim_xero_invoice_line_item.[xero_invoice_id]                       = invoices.invoice_id,
	   data.dim_xero_invoice_line_item.xero_line_item_policy_number                   = invoices.[Policy_Number],
	   data.dim_xero_invoice_line_item.[xero_line_amount_type_code]                       = invoices.[Line_Amount_Types],
	   data.dim_xero_invoice_line_item.[xero_line_item_customer_name]                      = invoices.customer,
	   data.dim_xero_invoice_line_item.[xero_line_item_vehicle_number]                     = invoices.vehicle,
	   data.dim_xero_invoice_line_item.[xero_line_item_fee_type]                 = invoices.fee_type,
	   data.dim_xero_invoice_line_item.[xero_line_item_full_description]                = invoices.[Description],
	   data.dim_xero_invoice_line_item.[xero_line_item_tax_type]                      = invoices.[TaxType],
	   data.dim_xero_invoice_line_item.[xero_last_updated_utc_date]                         = invoices.[Updated_Date_UTC],
       data.dim_xero_invoice_line_item.last_updated = getdate() AT TIME ZONE 'UTC' AT TIME ZONE 'New Zealand Standard Time'

	  WHEN NOT MATCHED BY SOURCE AND data.dim_xero_invoice_line_item.xero_invoice_line_item_key <> -1  THEN 
      UPDATE SET data.dim_xero_invoice_line_item.is_deleted = 1;

	  END

GO


