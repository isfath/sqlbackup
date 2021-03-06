CREATE TABLE blacklist(
  sch VARCHAR(64),
  tbl VARCHAR(64),
  reason TINYTEXT,
  ignore_data BOOLEAN NOT NULL,
  PRIMARY KEY (sch, tbl)
);

CREATE VIEW batch AS
SELECT CONCAT('mysqldump ',
  COALESCE(GROUP_CONCAT(DISTINCT CONCAT('--ignore-table=', TABLE_SCHEMA, '.', t.tbl, ' ') SEPARATOR ''), ''),
  COALESCE(GROUP_CONCAT(DISTINCT CONCAT('--ignore-table-data=', TABLE_SCHEMA, '.', d.tbl, ' ') SEPARATOR ''), ''),
  TABLE_SCHEMA, ' >', TABLE_SCHEMA, '.sql'
) `REM generated by sqlbackup`
FROM information_schema.tables i
LEFT JOIN blacklist d ON d.sch=i.TABLE_SCHEMA AND d.ignore_data
LEFT JOIN blacklist t ON t.sch=i.TABLE_SCHEMA AND NOT t.ignore_data
WHERE TABLE_SCHEMA NOT IN ('information_schema', 'mysql', 'performance_schema', 'sys')
GROUP BY i.TABLE_SCHEMA;

CREATE TABLE log(
  id INT PRIMARY KEY AUTO_INCREMENT,
  cmd TEXT NOT NULL,
  err TINYTEXT,
  errorlevel INT NOT NULL,
  ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT IGNORE INTO blacklist VALUES ('sqlbackup', 'log', 'useless', 1);
