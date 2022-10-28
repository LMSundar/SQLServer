# SQLServer - Maintenance Branch

Objective 
	As a SQL DBA, I have tried multiple ways to implement the index and statistics maintenance using different scripts. As most of the SQL community knows that ola.hallengren provides most of the required feature and effective way to do it.
	As I have to implement across 500+ SQL Servers and need to monitor it, I have create the below scripts to create maintenance jobs with steps for each database. This help us to star the job from the failed steps and easy to monitor status using CMS across all the 500+ SQL Servers.
 
Steps
1. Deploy the main MaintenanceSolution.sql from https://ola.hallengren.com/. 
2. Based on the size of the Databases, you need to use any one of the below script. This script will create a jobs with seperate steps for each online database for Index and statistics maintenance with different paramaters
	2.1 Small Size 
		File Name 		:  SQLDBMaintenance1_Small_AutoJobCreationScript
		Job Name  		:  DBMaintenance_Index_Stats
		FragmentationLevel	: 
					   0  - 10  -> No action 
					   10 - 30  -> INDEX_REORGANIZE,INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE
					   30 - 100 -> INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE
		FillFactor 		:  80 
		PageCountLevel 		:  50
		UpdateStatistics	:  All
		StatisticsSample	:  25
		LogToTable		:  Yes
	
	2.2 Medium  
		File Name : SQLDBMaintenance1_Medium_AutoJobCreationScript.sql
		Job Name  : DBMaintenance_Index_Stats
		FragmentationLevel	: 
					   0  - 15  -> No action 
					   15 - 30  -> INDEX_REORGANIZE,INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE
					   30 - 100 -> INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE
		FillFactor 		:  80 
		PageCountLevel 		:  100
		UpdateStatistics	:  All
		StatisticsSample	:  25
		LogToTable		:  Yes

	2.3 Large
		File Name : SQLDBMaintenance1_Big_AutoJobCreationScript.sql
		Job Name  : DBMaintenance_Index_Stats
		FragmentationLevel	: 
					   0  - 20  -> No action 
					   20 - 30  -> INDEX_REORGANIZE,INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE
					   30 - 100 -> INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE
		FillFactor 		:  80 
		PageCountLevel 		:  100
		MaxDOP			:  8
		Note			:  Statistics was handled seperately in Large databases
		LogToTable		:  Yes

3. Deploy this script to create a job for uses database for statistics maintenance
		
		File Name		:  SQLDBMaintenance1_Big_AutoJobCreationScript.sql
		Job Name  		:  DBMaintenance_Stats
		StatisticsSample	:  25
		
4. Deploy this script to create a job to purge the log table in msdb which are older than 185 days
		File Name		:  DBMaintenance_LogPurge.sql

5. This script will help you to check the status of the maintenance job
		File Name		:  Maintenance Job Status.sql


Notes:
	Thank you to ola.hallengren for provide the effective maintenance scripts. 
	Kindly test this script in non production and change the parameters & job schedule as per your requirement. I have used these scripts to deploy the maintenance jobs across 500+ SQL Server using CMS and regular monitor the status using CMS.
		

To know about me : https://www.linkedin.com/in/meenakshisundaram-lakshmanan-ba8a699/


