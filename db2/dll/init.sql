CREATE TABLE test_table IF NOT EXISTS(
    id INT PRIMARY KEY,
    name VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO test_table (id, name) VALUES (1, 'Sample Data');
