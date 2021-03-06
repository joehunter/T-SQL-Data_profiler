
USE [tempDB]
GO

DECLARE @PARA_SRC_TABLE NVARCHAR(1000);
DECLARE @PARA_SRC_TABLE_SCHEMA NVARCHAR(1000);
DECLARE @PARA_COLUMNS_TO_PROFILE_AS_CSV NVARCHAR(1000);
DECLARE @UNQ_PRIMARY_KEY NVARCHAR(1000);


DECLARE @SQL NVARCHAR(MAX);
DECLARE @columnName NVARCHAR(MAX);
DECLARE @rowCounter BIGINT;


	SET @PARA_SRC_TABLE_SCHEMA = 'DBO'	--'WARDS';
	SET @PARA_SRC_TABLE = 'Employee '	--'WARD_DATA_MAIN';
	SET @PARA_COLUMNS_TO_PROFILE_AS_CSV = ' ''Designation'', ''Department'' ';
	SET @UNQ_PRIMARY_KEY = 'EmpID'

	IF EXISTS(SELECT TABLE_NAME
		FROM TEMPDB.INFORMATION_SCHEMA.TABLES 
		WHERE TABLE_NAME = 'COLUMN_DISTRIBUTION'
		AND TABLE_SCHEMA = 'DBO')
		BEGIN
			DROP TABLE [TEMPDB].[DBO].[COLUMN_DISTRIBUTION];
		END

	CREATE TABLE [TEMPDB].[DBO].[COLUMN_DISTRIBUTION]
	(
		[IDX] BIGINT IDENTITY(1,1)
		,[ColumnName] NVARCHAR(1000)
		,[Column_Value] NVARCHAR(1000)
		,[AbsFreq] BIGINT
		,[CumFreq] BIGINT
		,[AbsPerc] BIGINT
		,[CumPerc] BIGINT
		,[Histogram]  NVARCHAR(1000)
	);



	IF EXISTS(SELECT TABLE_NAME
		FROM TEMPDB.INFORMATION_SCHEMA.TABLES 
		WHERE TABLE_NAME = 'COLUMN_LISTING_FOR_DISTRIBUTION'
		AND TABLE_SCHEMA = 'DBO')
		BEGIN
			DROP TABLE [TEMPDB].[DBO].[COLUMN_LISTING_FOR_DISTRIBUTION];
		END

	CREATE TABLE [TEMPDB].[DBO].[COLUMN_LISTING_FOR_DISTRIBUTION]
	(
		[IDX] BIGINT IDENTITY(1,1)
		,[ColumnName] NVARCHAR(1000)		
	);

	
	SET @SQL = 'INSERT INTO [TEMPDB].[DBO].[COLUMN_LISTING_FOR_DISTRIBUTION]([ColumnName])'
	SET @SQL += 'SELECT DISTINCT COLUMN_NAME '
	SET @SQL += 'FROM INFORMATION_SCHEMA.COLUMNS  '
	SET @SQL += 'WHERE TABLE_NAME = ''' + @PARA_SRC_TABLE + ''' '
	SET @SQL += 'AND TABLE_SCHEMA = ''' + @PARA_SRC_TABLE_SCHEMA + ''' '
	SET @SQL += 'AND COLUMN_NAME IN (' + @PARA_COLUMNS_TO_PROFILE_AS_CSV + ') ';
	PRINT @SQL;
	EXEC sp_executesql @SQL;

	
	SELECT @rowCounter = MIN([IDX])
	FROM [TEMPDB].[DBO].[COLUMN_LISTING_FOR_DISTRIBUTION];


	WHILE (@rowCounter IS NOT NULL)
		BEGIN

			SET @SQL = '';
			SELECT @columnName = [ColumnName]
			FROM [TEMPDB].[DBO].[COLUMN_LISTING_FOR_DISTRIBUTION]
			WHERE ([IDX] = @rowCounter);

			SET @SQL += 'WITH freqCTE AS '
			SET @SQL += '( '
				SET @SQL += 'SELECT '+QUOTENAME(@columnName)+' as [Column_Value], '
				SET @SQL += 'ROW_NUMBER() OVER(PARTITION BY '+QUOTENAME(@columnName)+' '
				SET @SQL += 'ORDER BY '+QUOTENAME(@columnName)+', '+ QUOTENAME(@UNQ_PRIMARY_KEY) +') AS Rn_AbsFreq, '

				SET @SQL += 'ROW_NUMBER() OVER( '
				SET @SQL += 'ORDER BY '+QUOTENAME(@columnName)+', '+ QUOTENAME(@UNQ_PRIMARY_KEY) +') AS Rn_CumFreq, '

				SET @SQL += 'ROUND(100 * PERCENT_RANK() '
				SET @SQL += 'OVER(ORDER BY '+QUOTENAME(@columnName)+'), 0) AS Pr_AbsPerc, '

				SET @SQL += 'ROUND(100 * CUME_DIST() '
				SET @SQL += 'OVER(ORDER BY '+QUOTENAME(@columnName)+', '+ QUOTENAME(@UNQ_PRIMARY_KEY) +'), 0) AS Cd_CumPerc '
				SET @SQL += 'FROM ' + QUOTENAME(@PARA_SRC_TABLE_SCHEMA) + '.' + QUOTENAME(@PARA_SRC_TABLE)

			SET @SQL += ') '

			SET @SQL += 'INSERT INTO [TEMPDB].[DBO].[COLUMN_DISTRIBUTION] '
			SET @SQL += 'SELECT '''+@columnName+ ''' AS [ColumnName],[Column_Value], '
			SET @SQL += 'MAX(Rn_AbsFreq) AS AbsFreq, '
			SET @SQL += 'MAX(Rn_CumFreq) AS CumFreq, '
			SET @SQL += 'MAX(Cd_CumPerc) - MAX(Pr_Absperc) AS AbsPerc, '
			SET @SQL += 'MAX(Cd_CumPerc) AS CumPerc, '
			SET @SQL += 'CAST(REPLICATE(''*'',MAX(Cd_CumPerc) - MAX(Pr_Absperc)) AS varchar(100)) AS Histogram '
			SET @SQL += 'FROM freqCTE '
			SET @SQL += 'GROUP BY [Column_Value] '
			SET @SQL += 'ORDER BY [Column_Value]; '

			PRINT @SQL;
			EXEC sp_executesql @SQL;


			SELECT @rowCounter = MIN([IDX])
			FROM [TEMPDB].[DBO].[COLUMN_LISTING_FOR_DISTRIBUTION]
			WHERE ([IDX] > @rowCounter);

		END


		SELECT * 
		FROM [TEMPDB].[DBO].[COLUMN_DISTRIBUTION]
		ORDER BY 1 ASC;






