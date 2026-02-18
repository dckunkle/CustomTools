--;WITH Keys_Foreign 
--    AS(SELECT DISTINCT
--              parent_table					= OPAR.name
--             ,referenced_table				= OREF.name 
--	     FROM QA06_PORTAL.sys.foreign_keys	FK
--         JOIN QA06_PORTAL.sys.objects		OPAR 
--           ON FK.parent_object_id			= OPAR.object_id
--	     JOIN QA06_PORTAL.sys.objects		OREF  
--           ON FK.referenced_object_id		= OREF.object_id
--        WHERE 1								= 1
--          AND OREF.type						= 'U'
--          AND OPAR.type						= 'U'
--          AND OREF.Name						<> OPAR.Name)
;WITH Keys_Foreign
     AS(SELECT DISTINCT
	           OBJECT_NAME(parent_object_id)						AS parent_table
			  ,COL_NAME(parent_object_id, parent_column_id)			AS parent_column
			  ,OBJECT_NAME(referenced_object_id)					AS referenced_table
			  ,COL_NAME(referenced_object_id, referenced_column_id)	AS referenced_column
		  FROM QA06_PORTAL.sys.foreign_key_columns					FK
		 WHERE OBJECT_NAME(parent_object_id) NOT IN ('MAIL'
		                                            ,'MAIL_ATTACHMENT'
													,'MAIL_USER'
													,'QUESTION_ANSWER'
													,'AUTH_REQUEST')
		)

      ,Table_Data 
    AS(SELECT parent_table			= O.name
             ,referenced_table		= FK.referenced_table
		 FROM QA06_PORTAL.sys.objects	O
		 LEFT JOIN Keys_Foreign		FK
           ON O.name				= FK.parent_table
        WHERE 1						= 1
          AND O.type				= 'U'
          AND O.name				NOT LIKE 'sys%')

	  ,Recursive_Data 
	AS(SELECT table_name			= TD.parent_table
             ,table_level			= 1
         FROM Table_Data			TD
        WHERE 1						= 1
          AND TD.referenced_table	IS NULL
        UNION ALL
	   SELECT table_name			= TD.parent_table
             ,Lvl					= RD.table_level + 1
         FROM Table_Data			TD
         JOIN Recursive_Data		RD
           ON TD.referenced_table	= RD.table_name)

SELECT *
  FROM Recursive_Data