USE AdventureWorks;
GO

SELECT DB_ID();

CREATE EVENT SESSION [Reads] 
ON SERVER 
ADD EVENT sqlserver.file_read_completed
( 
	WHERE ([database_id]=(5))
) 
ADD TARGET package0.histogram
(
	SET filtering_event_name = N'sqlserver.file_read_completed', 
	source=N'size',
	source_type=(0)
) 
WITH 
( 
	MAX_MEMORY=4096 KB,
	EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS, 
	MAX_DISPATCH_LATENCY=30 SECONDS, 
	MAX_EVENT_SIZE=0 KB,
	MEMORY_PARTITION_MODE=NONE,
	TRACK_CAUSALITY=OFF, 
	STARTUP_STATE=ON
) 
GO 
