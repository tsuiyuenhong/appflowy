-- Your SQL goes here
CREATE TABLE op_table (
    doc_id TEXT NOT NULL PRIMARY KEY,
    base_rev_id BIGINT NOT NULL DEFAULT 0,
    rev_id BIGINT NOT NULL DEFAULT 0,
    data BLOB NOT NULL DEFAULT (x''),
    md5 TEXT NOT NULL DEFAULT '',
    state INTEGER NOT NULL DEFAULT 0
);