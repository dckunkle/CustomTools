SELECT OBJECT_NAME(parent_object_id) AS parent_object
      --,OBJECT_NAME(constraint_object_id) AS constraint_object  
	  ,COL_NAME(parent_object_id, parent_column_id) AS parent_column
	  ,OBJECT_NAME(referenced_object_id) AS referenced_object
	  ,COL_NAME(referenced_object_id, referenced_column_id) AS referenced_column
  FROM sys.foreign_key_columns
 WHERE referenced_object_id IN (SELECT object_id FROM sys.tables WHERE name = 'MEMBER')
 ORDER BY OBJECT_NAME(parent_object_id)