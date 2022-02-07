CREATE PROCEDURE sp_metadata.[etl_run_history_log_start]
	 (@PROCESSID varchar(100)
  , @ENTITY_NAME VARCHAR(100)
  , @ETL_FROMDATE datetime
  , @PROCESS_TYPE VARCHAR(20))
AS
	begin

    
    --Insert information into the etl_run_history table

      insert into metadata.etl_run_history 
      (processid, entity_name, etl_fromdate, run_information, created_datetime, process_type)
      values 
      (@processid,@ENTITY_NAME,@ETL_FROMDATE,'started',getdate() AT TIME ZONE 'UTC' AT TIME ZONE 'New Zealand Standard Time',@PROCESS_TYPE)
    
    
    end