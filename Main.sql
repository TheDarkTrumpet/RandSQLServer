-- Enable RServices (Needs to be done once)
Exec sp_configure  'external scripts enabled', 1  
Reconfigure  with  override  


-- 4: Return 1 string from 2 column input
DECLARE @RScript NVARCHAR(MAX) = N' 
	myString <- paste(Input$FirstName, Input$LastName)
	Output <- as.data.frame(myString)' 

DECLARE @SQLScript NVARCHAR(MAX) = N'
	SELECT ''Hello'' AS FirstName, ''World!'' AS LastName'

EXECUTE sp_execute_external_script
	@language=N'R',
	@script = @RScript,
	@input_data_1 = @SQLScript,
	@input_data_1_name = N'Input',
	@output_data_1_name = N'Output'
WITH RESULT SETS ((myPhrase VARCHAR(20)));
GO

-- 2: Get some really basic information, in a comma separated list
declare @RScript NVARCHAR(MAX) = N'
	require(plyr)
	names <- data.frame(
		paste(
			adply(dataOut, 1, function(x) { 
				paste(x$FirstName, x$LastName, sep='' '') })$V1, 
				collapse='', '' )[1])
	'

declare @SQLScript NVARCHAR(MAX) = N'
	select * from Sales.vSalesPerson
		'
EXECUTE sp_execute_external_script
	@language=N'R',
	@script = @RScript,
	@input_data_1 = @SQLScript,
	@input_data_1_name = N'dataOut',
	@output_data_1_name = N'names'
WITH RESULT SETS ((myPhrase VARCHAR(MAX)));
GO


-- 3: Run K-Means Example

declare @RScript NVARCHAR(MAX) = N'
	kmeans <- kmeans(dataIn$SalesYTD, 3)
	dataOut <- data.frame(kmeans$size)
	'

declare @SQLScript NVARCHAR(MAX) = N'
	select * from Sales.vSalesPerson
		'
EXECUTE sp_execute_external_script
	@language=N'R',
	@script = @RScript,
	@input_data_1 = @SQLScript,
	@input_data_1_name = N'dataIn',
	@output_data_1_name = N'dataOut'
WITH RESULT SETS ((clusters float not null));

go

-- 4: Execute as a stored procedure
exec dbo.__rclusterExample

-- 5: Plot a graph
declare @RScript NVARCHAR(MAX) = N'
	require(plyr)
	names <- data.frame(
		paste(
			adply(dataOut, 1, function(x) { 
				paste(x$FirstName, x$LastName, sep='' '') })$V1, 
				collapse='', '' )[1])
	'

declare @SQLScript NVARCHAR(MAX) = N'
	select * from Sales.vSalesPerson
		'
EXECUTE sp_execute_external_script
	@language=N'R',
	@script = @RScript,
	@input_data_1 = @SQLScript,
	@input_data_1_name = N'dataOut',
	@output_data_1_name = N'names'
WITH RESULT SETS ((myPhrase VARCHAR(MAX)));
GO