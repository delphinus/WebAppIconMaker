CREATE TABLE IF NOT EXISTS sessions (
    id           CHAR(72) PRIMARY KEY,
    session_data TEXT
);

DROP TABLE IF EXISTS icons;

CREATE TABLE icons (
    id VARCHAR(32) PRIMARY KEY
    ,ext VARCHAR(255)
    ,content BLOB
    ,created_on INTEGER
);
