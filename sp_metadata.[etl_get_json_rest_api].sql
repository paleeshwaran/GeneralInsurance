CREATE PROCEDURE [sp_metadata].[etl_get_json_rest_api]
  @entity_name VARCHAR(100)
AS
BEGIN
DECLARE @collection_reference varchar(20);


SET @collection_reference = 'Reports''][0][''Rows';



  DECLARE @json_construct varchar(MAX) = '{"type": "TabularTranslator", "mappings": {X},"collectionReference": "$['''+@collection_reference+''']","mapComplexValuesToString": true}';
  DECLARE @json VARCHAR(MAX);
  DECLARE @source_column_rest_api VARCHAR(MAX) ;
  SET @source_column_rest_api =(SELECT source_column_rest_api 
                    FROM   [Metadata].[etl_source_landing_control] where entity_name = @entity_name );
  DECLARE @source_column_type_rest_api VARCHAR(MAX) ;
  SET @source_column_type_rest_api =(SELECT source_column_type_rest_api 
                    FROM   [Metadata].[etl_source_landing_control] where entity_name = @entity_name);
  DECLARE @source_columns VARCHAR(MAX) ;
  SET @source_columns =(SELECT source_columns 
                    FROM   [Metadata].[etl_source_landing_control] where entity_name = @entity_name);
  DECLARE @SEPARATOR CHAR(1) ;
  SET @SEPARATOR=','
    
  SET @json = (
     select s1.item AS 'source.path'
      
      ,s3.item AS 'sink.name'
	  ,s2.item  AS 'sink.type' 
from metadata.fn_StringSplit(@source_column_rest_api,@SEPARATOR,null) as s1
    join metadata.fn_StringSplit(@source_column_type_rest_api,@SEPARATOR,null) as s2
      on s1.rn = s2.rn
    join metadata.fn_StringSplit(@source_columns,@SEPARATOR,null) as s3
      on s1.rn = s3.rn
    FOR JSON PATH );
 
    SELECT REPLACE(@json_construct,'{X}', @json) AS json_output;

END