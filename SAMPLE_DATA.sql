

	IF EXISTS(SELECT TABLE_NAME
		FROM TEMPDB.INFORMATION_SCHEMA.TABLES 
		WHERE TABLE_NAME = 'Employee '
		AND TABLE_SCHEMA = 'DBO')
		BEGIN
			DROP TABLE [TEMPDB].[DBO].[Employee ];
		END
		
CREATE TABLE  [TEMPDB].[DBO].Employee 
    (EmpID INT IDENTITY(1,1) ,       
	    Designation VARCHAR(50) NULL, 
        Department VARCHAR(50) NULL, 
        JoiningDate DATETIME NULL,
	    CONSTRAINT [PK_Employee] PRIMARY KEY CLUSTERED (EmpID)
    )
    

DECLARE @row_counter INT = 0
	
WHILE @row_counter < 100

	BEGIN

		INSERT INTO  [TEMPDB].[DBO].Employee 
			(Designation, Department, JoiningDate)
		VALUES 
			('LAB ASSISTANT', 'LAB', GETDATE()),
			('SENIOR ACCOUNTANT', 'ACCOUNTS', GETDATE()),
			('ACCOUNTANT', 'ACCOUNTS', GETDATE()),
			( 'PROGRAMMER', 'IT', GETDATE()),
			('SR. PROGRAMMER', 'IT', GETDATE()),
			('ACCOUNTANT', 'ACCOUNTS', GETDATE()),
			('ACCOUNTANT', 'ACCOUNTS', GETDATE()),
			('PROGRAMMER', 'IT', GETDATE()),
			( 'PROGRAMMER', 'IT', GETDATE()),
			( 'PROGRAMMER', 'IT', GETDATE());
	
		SET @row_counter+=1;	
			
	END