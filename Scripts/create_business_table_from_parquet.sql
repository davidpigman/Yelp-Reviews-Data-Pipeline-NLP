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

CREATE EXTERNAL TABLE dbo.business (
	[business_id] nvarchar(4000),
	[name] nvarchar(4000),
	[address] nvarchar(4000),
	[city] nvarchar(4000),
	[state] nvarchar(4000),
	[postal_code] nvarchar(4000),
	[latitude] numeric(38,18),
	[longitude] numeric(38,18),
	[stars] numeric(38,18),
	[review_count] int,
	[is_open] bit,
	[attributes] nvarchar(4000),
	[categories] nvarchar(4000),
	[hours] nvarchar(4000)
	)
	WITH (
	LOCATION = 'de-yelp/business/business.parquet',
	DATA_SOURCE = [synapse_b11wcdsynapse_dfs_core_windows_net],
	FILE_FORMAT = [SynapseParquetFormat]
	)
GO


SELECT TOP 100 * FROM dbo.business
GO