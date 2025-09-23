-- Safe Index Creation Script
-- This script checks if indexes exist before creating them

DELIMITER $$

-- Procedure to create index only if it doesn't exist
CREATE PROCEDURE CreateIndexIfNotExists(
    IN tableName VARCHAR(64),
    IN indexName VARCHAR(64),
    IN indexColumns VARCHAR(255)
)
BEGIN
    DECLARE indexCount INT DEFAULT 0;
    
    -- Check if index exists
    SELECT COUNT(*) INTO indexCount
    FROM information_schema.STATISTICS 
    WHERE table_schema = DATABASE() 
    AND table_name = tableName 
    AND index_name = indexName;
    
    -- Create index only if it doesn't exist
    IF indexCount = 0 THEN
        SET @sql = CONCAT('CREATE INDEX ', indexName, ' ON ', tableName, ' (', indexColumns, ')');
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
        SELECT CONCAT('Index ', indexName, ' created successfully') as result;
    ELSE
        SELECT CONCAT('Index ', indexName, ' already exists - skipped') as result;
    END IF;
END$$

DELIMITER ;

-- Create indexes safely
call CreateIndexIfNotExists('products', 'idx_supplier', 'supplier');
call CreateIndexIfNotExists('products', 'idx_barcode', 'barcode');
call CreateIndexIfNotExists('products', 'idx_product_name', 'product_name');
call CreateIndexIfNotExists('products', 'idx_supplier_product_name', 'supplier, product_name');
call CreateIndexIfNotExists('products', 'idx_created_at', 'created_at');

-- Drop the procedure after use
DROP PROCEDURE CreateIndexIfNotExists;