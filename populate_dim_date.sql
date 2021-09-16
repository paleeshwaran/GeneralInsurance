/****** Object:  StoredProcedure [sp_data].[populate_dim_date]    Script Date: 8/09/2021 3:01:20 pm ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [sp_data].[populate_dim_date]
	(
		@StartDate		[DATE],
		@NumberOfYears	[INTEGER]
	) AS

BEGIN
	SET DATEFIRST 1;
	SET DATEFORMAT dmy;

	DECLARE @CutoffDate [DATE] = DATEADD(YEAR, @NumberOfYears, @StartDate);

	DELETE FROM data.[dim_date] WHERE DATE_KEY <> 19000101 

	INSERT INTO data.[dim_date]
		(
			[date_Key] ,
	        [day_number] ,
         	[month_number] ,
        	[fin_month_number],
        	[month_name],
        	[month_short_name] ,
        	cal_year_start_date ,
        	cal_year_end_date ,
        	cal_year_day_number ,
        	fin_year_start_date ,
	        fin_year_end_date ,
	        [cal_year]  ,
	        [fin_year]  ,
	        [cal_quarter] ,
	        [fin_quarter] ,
	        [period_number] ,
	        [period_name] ,
	        [date_value] ,
	        [season] ,
	        [week_day_number] ,
	        [week_day_name] ,
         	[week_day_short_name] ,
        	[week_cal_number],
        	[fin_year_name] 
		)
			SELECT
				CAST(CONVERT(CHAR(8),[d],112) AS INT) AS [date_Key],
				DATEPART(DAY,[d]) AS [day_number],
				DATEPART(MONTH,[d]) AS [month_number]y,
				(DATEPART(MONTH,[d]) + 8)%12 + 1 AS [fin_month_number],
				DATENAME(MONTH,[d]) AS [month_name],
				Convert(char(3), d, 0) as [month_short_name],
				DATEADD(yy, DATEDIFF(yy, 0, d), 0) AS cal_year_start_date,
                DATEADD(yy, DATEDIFF(yy, 0, d) + 1, -1) AS cal_year_end_date,
				DATENAME(dayofyear , d) as cal_year_day_number,
				case when DatePart(Month, d) <= 3
                     then  CONVERT(VARCHAR(4),YEAR(d)-1)+ '-04-01'
                    else   
                    convert(varchar(4),DatePart(Year, d) )+ '-04-01'
                    end as  fin_year_start_date,
				case when DatePart(Month, d) <= 3
                     then  CONVERT(VARCHAR(4),YEAR(d))+ '-03-31'
                    else   
                    convert(varchar(4),DatePart(Year, d) +1)+ '-03-31'
                    end as  fin_year_end_date,
                DATEPART(YEAR,[d]) AS [cal_year],
				CASE WHEN DatePart(Month, d) >= 4
                     THEN DatePart(Year, d) + 1
                     ELSE DatePart(Year, d) END AS [fin_year],
                'Q' + DATENAME(QUARTER,[d]) AS [cal_quarter],
				CASE
					WHEN ((DATEPART(MONTH,[d]) + 8)%12 + 1) IN (1,2,3) THEN 'FQ1'
					WHEN ((DATEPART(MONTH,[d]) + 8)%12 + 1) IN (4,5,6) THEN 'FQ2'
					WHEN ((DATEPART(MONTH,[d]) + 8)%12 + 1) IN (7,8,9) THEN 'FQ3'
					ELSE 'FQ4'
				END AS fin_quarter,
				CAST(CONVERT(CHAR(6),[d],112) AS INT) AS period_number,
				LEFT(DATENAME(MONTH,[d]),3) + ' ' + CAST(DATEPART(YEAR,[d]) AS CHAR(4)) AS period_name,
				[d] as date_value,
				 CASE WHEN DATEPART(MM, [d]) in (12, 1, 2) THEN 'Summer'
				      WHEN DATEPART(MM, [d]) in (3, 4, 5) THEN 'Autumn'
	                  WHEN DATEPART(MM, [d]) in (6, 7, 8) THEN 'Winter'
	                  WHEN DATEPART(MM, [d]) in (9, 10, 11) THEN 'Spring'  END as season,
                DATEPART(WEEKDAY, [d]) as week_day_number,
				DATENAME(WEEKDAY,[d]) AS week_day_name,
				LEFT(DATENAME(WEEKDAY,[d]),3) as week_day_short_name,
				DATEPART(WEEK,[d]) AS week_cal_number,
				CASE
					WHEN ((DATEPART(MONTH,[d]) + 8)%12 + 1) > 6 THEN 'FY' + CAST(DATEPART(YEAR,[d]) AS CHAR(4))
					ELSE 'FY' + CAST(DATEPART(YEAR,[d]) + 1 AS CHAR(4))
				END AS fin_year_name

			FROM
				(
					SELECT
						[d] = DATEADD(DAY, [rn] - 1, @StartDate)
					FROM
						(
							SELECT TOP (DATEDIFF(DAY, @StartDate, @CutoffDate)) 
								[rn] = ROW_NUMBER() OVER (ORDER BY [s1].[object_id])
							FROM
								[sys].[all_objects] AS [s1]
									CROSS JOIN
								[sys].[all_objects] AS [s2]
							ORDER BY
								[s1].[object_id]
						) AS [x]
				) AS [y];



update data.[dim_date]
set week_fin_number =  DATEDIFF(week, fin_year_start_date, DATEADD(DAY, -1, date_value))+1 

   ,
 fin_year_day_number = DATEDIFF(day, fin_year_start_date, DATEADD(DAY, -1, date_value))+1;

END


GO


