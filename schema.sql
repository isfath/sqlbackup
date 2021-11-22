CREATE TABLE blacklist(
  sch VARCHAR(64),
  tbl VARCHAR(64),
  reason TINYTEXT,
  ignore_data BOOLEAN NOT NULL,
  PRIMARY KEY (sch, tbl)
);

CREATE VIEW job AS
SELECT CONCAT('mysqldump ',
  COALESCE(GROUP_CONCAT(DISTINCT CONCAT('--ignore-table=', t.tbl, ' ') SEPARATOR ''), ''),
  COALESCE(GROUP_CONCAT(DISTINCT CONCAT('--ignore-table-data=', d.tbl, ' ') SEPARATOR ''), ''),
  TABLE_SCHEMA
) cmd
FROM information_schema.tables i
LEFT JOIN blacklist d ON d.sch=i.TABLE_SCHEMA AND d.ignore_data
LEFT JOIN blacklist t ON t.sch=i.TABLE_SCHEMA AND NOT t.ignore_data
WHERE TABLE_SCHEMA NOT IN ('information_schema', 'mysql', 'performance_schema', 'sys')
GROUP BY i.TABLE_SCHEMA;
