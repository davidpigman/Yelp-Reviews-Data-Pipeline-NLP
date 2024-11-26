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

CREATE EXTERNAL TABLE dbo.users (
	[user_id] nvarchar(4000),
	[name] nvarchar(4000),
	[review_count] int,
	[yelping_since] datetime2(7),
	[useful] int,
	[funny] int,
	[cool] int,
	[fans] int,
	[average_stars] numeric(38,18)
	)
	WITH (
	LOCATION = 'de-yelp/users/users.parquet',
	DATA_SOURCE = [synapse_b11wcdsynapse_dfs_core_windows_net],
	FILE_FORMAT = [SynapseParquetFormat]
	)
GO


SELECT TOP 100 * FROM dbo.users
GO