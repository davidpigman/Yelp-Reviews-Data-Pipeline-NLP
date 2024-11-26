# Create Data Factory Pipelines

## Step 0. Pre-requisite:
	- create
	- crea

## Step 1. Create Linked Service
	- ls_my_blob: Azure ADLS storage account in my Azure subscription to copy the parquet files to.
	- ls_wcd_blob: WeCloudData’s wcddestorageexternal Azure Blob Storage account in Azure Data Factory
	- ls_rds_pg: External yelp PostgreSQL database
		- Fully qualified domain name: de-rds.czm23kqmbd60.ca-central-1.rds.amazonaws.com | Port: 5432 | Database name: yelp | User name: postgres | Password: ********

## Step 2. Create Datasets
#### 2.1 create datasets for Source:
	- AzPostgreSQLbusiness
		- Linked service: ls_rds_pg | Table: project.business
	- AzPostgreSQLcheckin
		- Linked service: ls_rds_pg | Table: project.checkin
	- AzPostgreSQLip
		- Linked service: ls_rds_pg | Table: project.tip
	- AzPostgreSQLusers
		- Linked service: ls_rds_pg | Table: project.users
	- AzBlobPrqtPublicdeyelpdaily
		- Connection | Linked service: ls_my_blob | File path: project / de-yelp-daily/reviews / 

#### 2.2 create datasets for intermediary transformation:
	- AzBlobPrqtbusiness
		- Linked service: ls_my_blob | File path: project / business / business.parquet
	- AzBlobcheckin
		- Linked service: ls_my_blob | File path: project / business / business.parquet
	- AzBlobPrqttip
		- Linked service: ls_my_blob | File path: project / tip / tip.parquet
	- AzBlobPrqtusers
		- Linked service: ls_my_blob | File path: project / users / users.parquet
	- AzBlobPrqtlsmyblobdeyelpdaily_projectdate
		- Connection | Linked service: ls_my_blob | File path: project / @dataset().folder_name / Compression type: snappy
		- Parameters | Name: folder_name | Type: String | Default value:

## Step 3. Create Pipeline
#### 3.1 CopyOnceWeek: delete then copy business, checkin, tips and users parquet files
copyOnceWeek: Deletes business, checkin, tips, users parquet files in target ADLS storagewcdb11c then transforms AWS PostgreSQL SQL tables to parquet folder/files: project/business/business.parquet, project/checkin/checkin.parquet, project/users/users/parquet, project/tips/tips.parquet.

	- business parquet file | Activity: Delete
		- Source | Dataset: AzBlobPrqtbusiness | File path type: File path in dataset 
		- Logging settings | Enable logging: check | Logging account linked service: ls_my_blob | Folder path: bd-project/logging
	- tip parquet file | Activity: Delete
		- Source | Dataset: AzBlobPrqttip | File path type: File path in dataset 
		- Logging settings | Enable logging: check | Logging account linked service: ls_my_blob | Folder path: bd-project/logging
	- checkin parquet file | Activity: Delete
		- Source | Dataset: AzBlobPrqtcheckin | File path type: File path in dataset 
		- Logging settings | Enable logging: check | Logging account linked service: ls_my_blob | Folder path: bd-project/loggin
	- users parquet file | Activity: Delete
		- Source | Dataset: AzBlobPrqtusers | File path type: File path in dataset 
		- Logging settings | Enable logging: check | Logging account linked service: ls_my_blob | Folder path: bd-project/logging
	- business PostgreSQL to ADLS parquet | Activity: Copy
		- Source | Source dataset: AzPostgreSQLbusiness | Use Query: Table | Partion option | None
		- Sink | Sink dataset: AzBlobPrqtbusiness
	- tip Postgre to ADLS parquet | Activity: Copy
		- Source | Source dataset: AzPostgreSQLtip | Use Query: Table | Partion option | None
		- Sink | Sink dataset: AzBlobPrqttip
	- checkin Postgre to ADLS parquet | Activity: Copy
		- Source | Source dataset: AzPostgreSQLcheckin | Use Query: Table | Partion option | None
		- Sink | Sink dataset: AzBlobPrqtbusiness
	- users Postgre to ADLS | Activity: Copy
		- Source | Source dataset: AzPostgreSQLusers | Use Query: Table | Partion option | None
		- Sink | Sink dataset: AzBlobPrqtbusiness

#### 3.2 copyPostsAllDatestoReview: Copy all yelp review dates as a one time load
copyPostsAllDatestoReview: Copies yelp reviews from all date stamped folders into ADLS project de-yelp-daily/reviews/* folder without the subdirectories for a larger dataset.
Variables | Name: Date | Type: String | Default value: Value

	- Delete Yelp Folder Contents | Activity: Delete
		- Source | Dataset: AzBlobPrqtlsmyblobdeyelpdaily  | File path type: File path in dataset
	- Copy All Yelp Reviews | Activity: Copy
		- Source | Source dataset: AzblobprqtPublicdeyelpdaily | File path type: Wildcard file path: de-yelp-daily / output *.parquet
		- Sink | Sink dataset: AzBlobprqtlsmyblobdeyelpdaily

#### 3.3 copyPostsTodayEverydaywDBNotebook: Copy reviews and consolidate into a single subfolder every day
copyPostsTodayEverydaywDBNotebook: Copies yelp reviews from today's date stamped folders into ADLS project de-yelp-daily/reviews/* folder without the subdirectories for a larger dataset.
Variables | Name: Date | Type: String | Default value: Value

	- Get List of Folders | Activity: Get Metadata
		- Settings | Dataset: AzBlobPrqtPublicdeyelpdaily | Field List: Child items, Item name
	- For Each Folder | Activity: For Each
		- Settings | Sequential: Check | Items: @activity('Get List of Folders').output.childItems
		- Activities | Case: ForEach | Activity: If Condition1
		- If Condition 1 | Activity: If Condition
			- Activities | Expression: @equals(substring(item().Name,3,10),formatDateTime('2024-10-29','yyyy-MM-dd')) | Case: True, Activity: Copy Todays Directory | Case: False, No Activities
				- Copy Today's Directory | Activity: Copy data
					- Source | Source Dataset: AzBlobPrqtPublicdeyelpdaily | File path type: Wildcard file path | Wildcard file path: de-yelp-daily / @concat('output/dt=',formatDateTime('2024-10-29','yyyy-MM-dd')) / *.* | Recursively: check
					- Sink | Sink dataset: AzBlobPrqtlsmyblobdeyelpdaily_projectdate | Dataset properties, Name: folder name | Value: de-yelp-daily/reviews/@{item().Name} | Type: string
	- Notebook | Activity: Notebook
		- Azure Databricks | Databricks linked service: AzDBricks_b11_db_cc_02
		- Settings | Notebook path: /Users/david_b_pigman@hotmail.com/bd-project/model_inference-3-Static-20241104





