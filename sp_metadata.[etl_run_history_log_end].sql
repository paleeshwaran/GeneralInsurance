CREATE PROCEDURE sp_metadata.[etl_run_history_log_end]
	( @PROCESSID VARCHAR(100)
  , @ENTITY_NAME VARCHAR(100)
  , @ETL_TODATE datetime
  , @EXTRACT_ROW_COUNT bigint = null )
  as

  begin
  update metadata.etl_run_history  
      set 
      etl_todate = @ETL_TODATE,
      run_information = 'completed', 
      run_status = 1, 
      modified_datetime = getdate() AT TIME ZONE 'UTC' AT TIME ZONE 'New Zealand Standard Time', 
      extract_row_count = @extract_row_count 
      where  processid = @PROCESSID and entity_name = @ENTITY_NAME

end