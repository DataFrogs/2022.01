SELECT R.Session_Id, Th.os_thread_id FROM sys.dm_exec_requests R 
JOIN sys.dm_exec_sessions S ON R.session_id = S.session_id 
JOIN sys.dm_os_tasks T ON R.task_address = T.task_address 
JOIN sys.dm_os_workers W ON T.worker_address = W.worker_address 
JOIN sys.dm_os_threads Th ON W.thread_address = Th.thread_address 
WHERE S.is_user_process = 1
GO

