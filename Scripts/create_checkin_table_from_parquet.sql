
IF NOT EXISTS (SELECT * FROM sys.external_file_formats WHERE name = 'SynapseParquetFormat') 
	CREATE EXTERNAL FILE FORMAT [SynapseParquetFormat] 
	WITH ( FORMAT_TYPE = PARQUET)
GO

IF NOT EXISTS (SELECT * FROM sys.external_data_sources WHERE name = 'synapse_b11wcdsynapse_dfs_core_windows_net') 
	CREATE EXTERNAL DATA SOURCE [synapse_b11wcdsynapse_dfs_core_windows_net] 
	WITH (
		LOCATION = 'abfss://synapse@b11wcdsynapse.dfs.core.windows.net' 
	)
GO

CREATE EXTERNAL TABLE dbo.checkin (
	[business_id] nvarchar(4000),
	[dates] varchar(MAX)
	)
	WITH (
	LOCATION = 'de-yelp/checkin/checkin.parquet',
	DATA_SOURCE = [synapse_b11wcdsynapse_dfs_core_windows_net],
	FILE_FORMAT = [SynapseParquetFormat]
	)
GO


SELECT TOP 100 * FROM dbo.checkin
GO