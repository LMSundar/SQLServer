USE [msdb]
GO
/****** Object:  Job [DBMaintenance_Index_Stats]    Script Date: 06/02/2016 01:40:38 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
DECLARE @DBName varchar(200)
DECLARE @SQLText nvarchar(3000)
Declare @stp_name varchar(200)
Declare @stp_ID int

SELECT @ReturnCode = 0

/****** Object:  JobCategory [DBMaintenance]]    Script Date: 06/02/2016 01:40:38 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Database Maintenance' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Database Maintenance'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

IF EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBMaintenance_Index_Stats')
begin
 EXEC @ReturnCode = msdb.dbo.sp_delete_job @job_name=N'DBMaintenance_Index_Stats', @delete_unused_schedule=1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END
 

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBMaintenance_Index_Stats', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Using ola.hallengren script running the DB Maintenance script for Index and 25% Stats Update', 
		@category_name=N'Database Maintenance', 
		@owner_login_name=N'DisabledRootAdmin', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

set @stp_ID = 0
DECLARE DBName_Cursor CURSOR FOR
SELECT name  FROM master.sys.databases WHERE state = 0 and name not in ('tempdb','model')

OPEN DBName_Cursor  
  
FETCH NEXT FROM DBName_Cursor INTO @DBName
  
WHILE @@FETCH_STATUS = 0  
BEGIN  
	set @stp_ID = @stp_ID + 1
	select @stp_name = 'Step' + cast(@stp_ID as varchar(10))
    set @SQLText = 'DECLARE @ReturnCode INT EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=' + CONVERT(varchar(max),@jobId,1) + ', @step_name=N'''
    set @SQLText = @SQLText + @DBName + ''',@step_id=' + cast(@stp_ID as varchar(10)) + ','
	set @SQLText = @SQLText + '@cmdexec_success_code=0,@on_success_action=3,@on_success_step_id=0,@on_fail_action=2,@on_fail_step_id=0,@retry_attempts=0,@retry_interval=0,@os_run_priority=0,'
	set @SQLText = @SQLText + '@subsystem=N''TSQL'', 	@command=N''EXECUTE dbo.IndexOptimize @Databases = '''''
	set @SQLText = @SQLText +  @DBName +  ''''','
	set @SQLText = @SQLText +  '@FragmentationLow = NULL,@FragmentationMedium = ''''INDEX_REORGANIZE,INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE'''',@FragmentationHigh = ''''INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE'''',
	@FragmentationLevel1 = 15,@FragmentationLevel2 = 30,@FillFactor = 80, @PageCountLevel = 100,@UpdateStatistics = ''''ALL'''',	@OnlyModifiedStatistics = ''''Y'''',@StatisticsSample=25,
	@LogToTable = ''''Y'''',	@SortInTempdb = ''''Y'''''', 	@database_name=N''msdb'', 	@flags=0'
    EXECUTE sp_executesql @SQLText
    
    IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
    FETCH NEXT FROM DBName_Cursor INTO @DBName 
    
END   
CLOSE DBName_Cursor
DEALLOCATE DBName_Cursor 

EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

EXEC @ReturnCode = msdb.dbo.sp_update_jobstep @job_id = @jobId, @step_id = @stp_ID, @on_success_action = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback


EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'DBMaintenance_Index_Stats_Schd1', 
		@enabled=1, 
		@freq_type=32, 
		@freq_interval=7, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=1, 
		@freq_recurrence_factor=1, 
		@active_start_date=20160601, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'289cd159-397e-41ed-ad35-166e50079609'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
	CLOSE DBName_Cursor
	DEALLOCATE DBName_Cursor 
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO


