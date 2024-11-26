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

CREATE EXTERNAL TABLE dbo.results (
	[business_id] nvarchar(4000),
	[cool] bigint,
	[funny] bigint,
	[review_id] nvarchar(4000),
	[text] nvarchar(4000),
	[useful] bigint,
	[user_id] nvarchar(4000),
	[date] nvarchar(4000),
	[prediction] float,
	[decoded] nvarchar(4000)
	)
	WITH (
	LOCATION = 'de-yelp/results/results.parquet',
	DATA_SOURCE = [synapse_b11wcdsynapse_dfs_core_windows_net],
	FILE_FORMAT = [SynapseParquetFormat]
	)
GO


SELECT TOP 100 * FROM dbo.results
GO