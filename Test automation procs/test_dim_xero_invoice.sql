select top 10* from data.dim_xero_invoice_line_item

select xero_invoice_line_item_key, count(*) from [Data].[dim_xero_invoice_line_item] 
group by xero_invoice_line_item_key having count(*) > 1


select top 10* from [Data].[dim_xero_invoice]

select xero_invoice_type_code, count(*) from [Data].[dim_xero_invoice]
group by xero_invoice_type_code having count(*) > 1

-- 1. Create back up table this will be used for comparison to see if there is update
IF EXISTS (select * from sys.sysobjects where name = 'dim_xero_invoice')
	DROP TABLE dbo.dim_xero_invoice

select * 
into dbo.dim_xero_invoice
from Data.dim_xero_invoice


select top 100 * from ext_piclos.invoice order by created_date desc

select * from data.dim_xero_invoice_line_item where xero_line_item_full_description LIKE '|' and xero_line_item_policy_number is null
select * from data.dim_xero_invoice_line_item where xero_line_item_full_description LIKE '|' and xero_line_item_customer_name is null
select * from data.dim_xero_invoice_line_item where xero_line_item_full_description LIKE '|' and xero_line_item_vehicle_number is null
select * from data.dim_xero_invoice_line_item where xero_line_item_full_description LIKE '|' and xero_line_item_fee_type is null
