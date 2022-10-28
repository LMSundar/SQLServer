USE msdb
Go 
SELECT top 1 j.name JobName,h.step_name StepName, 
CONVERT(CHAR(10), CAST(STR(h.run_date,8, 0) AS dateTIME), 111) RunDate, 
STUFF(STUFF(RIGHT('000000' + CAST ( h.run_time AS VARCHAR(6 ) ) ,6),5,0,':'),3,0,':') RunTime, 
h.run_duration StepDuration,
case h.run_status when 0 then 'failed'
when 1 then 'Succeded' 
when 2 then 'Retry' 
when 3 then 'Cancelled' 
when 4 then 'In Progress' 
end as ExecutionStatus, 
h.message MessageGenerated
FROM sysjobhistory h inner join sysjobs j
ON j.job_id = h.job_id
where j.Name in ('DBMaintenance_Index_Stats','DBMaintenance_Stats') and step_id = 0 and CONVERT(CHAR(10), CAST(STR(h.run_date,8, 0) AS dateTIME), 111) > getdate() - 4
ORDER BY j.name, h.run_date, h.run_time desc
GO
