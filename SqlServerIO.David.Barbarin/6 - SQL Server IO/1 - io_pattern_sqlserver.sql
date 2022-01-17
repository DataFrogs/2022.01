USE AdventureWorks;
GO

DBCC TRACEON (3604, 3605, 3505, 3502, 3504, -1);
DBCC TRACESTATUS;
GO

-- Enable IO statistics
SET STATISTICS IO ON; 

DROP TABLE IF EXISTS dbo.NumbersTable;
GO

CREATE TABLE dbo.NumbersTable 
( 
     NumberValue BIGINT NOT NULL 
) 
GO 

-- Procmon get page_id
SELECT 
	DB_NAME(database_id) AS [database_name],
	OBJECT_NAME(object_id) AS table_name,
	index_id,
	[partition_id],
	allocation_unit_type_desc AS allocation_unit,
	allocated_page_file_id AS [file_id],
	allocated_page_iam_page_id AS iam_id,
	allocated_page_page_id AS page_id,
	page_type_desc AS page_type
FROM sys.dm_db_database_page_allocations(5, NULL, NULL, NULL, 'DETAILED')
WHERE allocated_page_page_id = 22632;
GO

-- Bulk insert => Sequential
INSERT INTO dbo.NumbersTable (NumberValue) 
SELECT TOP 500000 NumberValue 
FROM 
(     
	SELECT 
		NumberValue = row_number() over(order by newid() asc) 
    FROM master..spt_values a 
		CROSS APPLY master..spt_values b 
    WHERE a.type = 'P' 
		AND a.number <= 710 
			AND a.number > 0 
				AND b.type = 'P' 
					AND b.number <= 710 
						AND b.number > 0 
) a 
ORDER BY NumberValue ASC 
GO 

-- Flush data to disk
SELECT 
	DB_NAME(bd.database_id) AS [database_name],
	ad.object_id,
	bd.file_id,
	bd.page_id,
	bd.page_type,
	bd.row_count,
	bd.is_modified
FROM sys.dm_os_buffer_descriptors AS bd
JOIN (
	SELECT object_id, allocated_page_page_id, allocated_page_file_id 
	FROM sys.dm_db_database_page_allocations(5, OBJECT_ID('dbo.NumbersTable', 'U'), NULL, NULL, 'DETAILED')
) AS ad ON bd.page_id = ad.allocated_page_page_id 
           AND bd.file_id = ad.allocated_page_file_id
GO

CHECKPOINT;
GO

EXEC xp_readerrorlog 0, 1;
GO

-- Create index - Sequential
CREATE CLUSTERED INDEX ixNumbersTable ON dbo.NumbersTable(NumberValue) 
WITH(MAXDOP=1) 
GO 

-- Checkpoint - Sequential
CHECKPOINT;
GO
DBCC DROPCLEANBUFFERS;
GO
CHECKPOINT;
GO

-- Read-ahead - Sequential
SELECT COUNT(*) FROM NumbersTable 

-- Transaction log ->
CHECKPOINT;
INSERT INTO dbo.NumbersTable (NumberValue) 
SELECT TOP 1 * 
FROM dbo.NumbersTable 

CHECKPOINT;
INSERT INTO dbo.NumbersTable (NumberValue) 
SELECT TOP 10000 * 
FROM dbo.NumbersTable 


-- Index seek
DBCC DROPCLEANBUFFERS;
GO
SELECT *
FROM Person.Person
WHERE BusinessEntityID = 3

-- index 
DBCC DROPCLEANBUFFERS;
GO
select * 
from Production.ProductPhoto
where ProductPhotoID between 1 and 100

-- Backup 
BACKUP DATABASE AdventureWorks to disk = 'NUL'
with stats = 10;
GO

-- DBCC CHECKDB
DBCC CHECKDB('AdventureWorks') WITH PHYSICAL_ONLY;
GO