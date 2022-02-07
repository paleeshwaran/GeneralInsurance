CREATE PROCEDURE sp_metadata.[etl_run_history_log_failure]
	 (@PROCESSID VARCHAR(100)
  , @ENTITY_NAME VARCHAR(100)
  ,@RUN_INFORMATION VARCHAR(max) )
AS
	begin

    
    --Insert information into the etl_run_history table

      update metadata.etl_run_history 
      set 
      run_information = @RUN_INFORMATION,
      run_status = 0,
      modified_datetime = getdate() AT TIME ZONE 'UTC' AT TIME ZONE 'New Zealand Standard Time'
      where processid = @PROCESSID   and entity_name =  @ENTITY_NAME;
    
    
    end ;