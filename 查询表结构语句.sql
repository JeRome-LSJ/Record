--查询一个表表结构
SELECT /*+ PARALLEL(A,6) */  'SELECT ' ||
       TO_CHAR(WM_CONCAT('A.' || A.COLUMN_NAME || '  "' ||
                         NVL(A.COMMENTS,
                             NVL((SELECT /*+ PARALLEL(AA,6) */  DISTINCT AA.COMMENTS
                                   FROM USER_COL_COMMENTS AA
                                  WHERE AA.COLUMN_NAME = A.COLUMN_NAME
                                    AND AA.COMMENTS IS NOT NULL
                                    AND AA.COMMENTS <> AA.COLUMN_NAME
                                    AND ROWNUM = 1),
                                 A.COLUMN_NAME)) || '" ')) || 'FROM ' ||
       B.TABLE_NAME || ' A;' AS EXEC_SQL
  FROM USER_COL_COMMENTS A, (SELECT UPPER('bta_account') TABLE_NAME FROM DUAL) B --需要修改想要查看的表结构
 WHERE A.TABLE_NAME = B.TABLE_NAME;

--查询多个表表结构 
SELECT 'SELECT ' ||
       TO_CHAR(WM_CONCAT('A.' || AA.COLUMN_NAME || '  "' ||
                         NVL(AA.COMMENTS,
                             NVL((SELECT /*+ PARALLEL(AA,6) */
                                 DISTINCT AAA.COMMENTS
                                   FROM USER_COL_COMMENTS AAA
                                  WHERE AAA.COLUMN_NAME = AA.COLUMN_NAME
                                    AND AAA.COMMENTS IS NOT NULL
                                    AND AAA.COMMENTS <> AAA.COLUMN_NAME
                                    AND ROWNUM = 1),
                                 AA.COLUMN_NAME)) || '" ')) || 'FROM ' ||
       AA.TABLE_NAME || ' A;' AS EXEC_SQL
  FROM (SELECT A.TABLE_NAME, A.COLUMN_NAME, A.COMMENTS
          FROM USER_COL_COMMENTS A,
               (SELECT UPPER('BTA_AGREEMENT,BTA_ACCOUNT') TABLE_NAME
                  FROM DUAL) B
         WHERE INSTR(',' || B.TABLE_NAME || ',', ',' || A.TABLE_NAME || ',') > 0) AA
 GROUP BY AA.TABLE_NAME;


 --查询一个库的表空间
 SELECT T.SEGMENT_NAME,
       T.SEGMENT_TYPE,
       SUM(T.BYTES / 1024 / 1024) "占用空间(M)",
       B.CREATED,
       B.LAST_DDL_TIME,
       B.STATUS
  FROM DBA_SEGMENTS T, DBA_OBJECTS B
 WHERE T.SEGMENT_TYPE = 'TABLE'
   AND T.OWNER = 'BT_ASSET'
   AND T.SEGMENT_NAME = B.OBJECT_NAME
 GROUP BY T.OWNER,
          T.SEGMENT_NAME,
          T.SEGMENT_TYPE,
          B.CREATED,
          B.LAST_DDL_TIME,
          B.STATUS
 ORDER BY SUM(T.BYTES / 1024 / 1024) DESC;

 SELECT T.SEGMENT_NAME,
       T.SEGMENT_TYPE,
       SUM(T.BYTES / 1024 / 1024) "占用空间(M)",
       B.CREATED,
       B.LAST_DDL_TIME,
       B.STATUS
  FROM DBA_SEGMENTS T, DBA_OBJECTS B
 WHERE T.SEGMENT_TYPE = 'TABLE'
   AND T.OWNER = 'BT_ASSET'
   AND T.SEGMENT_NAME = B.OBJECT_NAME
 GROUP BY T.OWNER,
          T.SEGMENT_NAME,
          T.SEGMENT_TYPE,
          B.CREATED,
          B.LAST_DDL_TIME,
          B.STATUS
 ORDER BY SUM(T.BYTES / 1024 / 1024) DESC;

--查询一个表的创建时间等
select * from dba_objects a where a.object_name='BTA_TASK_HISTORY_00120171019';

--查询一个表的行数

--查询oracle数据库的使用量
SELECT A.TABLESPACE_NAME,
       TOTAL,
       FREE,
       TOTAL - FREE AS USED,
       SUBSTR(FREE / TOTAL * 100, 1, 5) AS "FREE%",
       SUBSTR((TOTAL - FREE) / TOTAL * 100, 1, 5) AS "USED%"
  FROM (SELECT TABLESPACE_NAME, SUM(BYTES) / 1024 / 1024 AS TOTAL
          FROM DBA_DATA_FILES
         GROUP BY TABLESPACE_NAME) A,
       (SELECT TABLESPACE_NAME, SUM(BYTES) / 1024 / 1024 AS FREE
          FROM DBA_FREE_SPACE
         GROUP BY TABLESPACE_NAME) B
 WHERE A.TABLESPACE_NAME = B.TABLESPACE_NAME
 ORDER BY A.TABLESPACE_NAME;

--查询一个表的索引有哪些
select * from all_ind_columns a where table_name ='BTA_ASSETS'

--查询数据库负载压力
SELECT /*+ RULE */ decode(substr(a.event, 1, 25), 'db file scattered read', substr(a.event, 1, 25) || '多块读等待事件', 'db file sequential read', substr(a.event, 1, 25) || '单块读等待事件', 'db file parallel read', substr(a.event, 1, 25) || '并行地物理读取并加载', 'gc cr request', substr(a.event, 1, 25) || '全局节点缓存数据请求', 'direct path read temp', substr(a.event, 1, 25) || '直接请求数据不通过缓存', 'gc cr multi block request', substr(a.event, 1, 25) || '全局扫描读取多节点数据块', 'gc buffer busy', substr(a.event, 1, 25) || '等待事件的热点块', 'latch: cache buffers chai', substr(a.event, 1, 25) || '逻辑读等待事件', 'cr request retry', substr(a.event, 1, 25) || '块丢失事件等待', substr(a.event, 1, 25)) AS event, substr(b.program, 1, 39) AS program, b.sid || ':' || decode(sql_hash_value, 0, prev_hash_value, sql_hash_value) AS sess_sql_hash, b.username, substr(b.osuser || '@' || b.machine || '@' || b.process || '@' || c.spid, 1, 40) AS client
    , to_char(b.logon_time, 'mm-dd hh24:mi') AS logon_time, b.SQL_ADDRESS, d.sql_text, d.sql_Id
FROM v$session_wait a, v$session b, v$process c, v$sql d
WHERE a.sid = b.sid
    AND b.paddr = c.addr
    AND a.event NOT LIKE '%SQL%'
    AND a.event NOT LIKE '%message%'
    AND a.event NOT LIKE '%job%'
    AND a.event NOT LIKE '%time%'
    AND a.event NOT LIKE '%Stream%'
    AND a.event NOT LIKE '%DIAG%'
    AND a.event NOT LIKE '%PX%'
    AND b.username = 'BT_ASSET'
    AND d.ADDRESS = b.SQL_ADDRESS
ORDER BY sql_address DESC;


select /*+ RULE */
 decode(substr(a.event, 1, 25),
        'db file scattered read',
        substr(a.event, 1, 25) || '多块读等待事件',
        'db file sequential read',
        substr(a.event, 1, 25) || '单块读等待事件',
        'db file parallel read',
        substr(a.event, 1, 25) || '并行地物理读取并加载',
        'gc cr request',
        substr(a.event, 1, 25) || '全局节点缓存数据请求',
        'direct path read temp',
        substr(a.event, 1, 25) || '直接请求数据不通过缓存',
        'gc cr multi block request',
        substr(a.event, 1, 25) || '全局扫描读取多节点数据块',
        'gc buffer busy',
        substr(a.event, 1, 25) || '等待事件的热点块',
        'latch: cache buffers chai',
        substr(a.event, 1, 25) || '逻辑读等待事件',
        'cr request retry',
        substr(a.event, 1, 25) || '块丢失事件等待',
        substr(a.event, 1, 25)) event,
 substr(b.program, 1, 39) program,
 b.sid || ':' || decode(sql_hash_value, 0, prev_hash_value, sql_hash_value) sess_sql_hash,
 b.username,
 substr(b.osuser || '@' || b.machine || '@' || b.process || '@' || c.spid,
        1,
        40) client,
 to_char(b.logon_time, 'mm-dd hh24:mi') logon_time,
 d.sql_text
  from v$session_wait a, v$session b, v$process c, v$sql d
 where a.sid = b.sid
   and b.paddr = c.addr
   and a.event not like '%SQL%'
   and a.event not like '%message%'
   and a.event not like '%job%'
   and a.event not like '%time%'
   and a.event not like '%Stream%'
   and a.event not like '%DIAG%'
   and a.event not like '%PX%'
   and b.username = 'BT_ASSET'
   and b.SQL_ADDRESS = d.ADDRESS
 order by sql_address desc;


