-- Ultimate Safe Index Creation Script
-- This script handles ALL duplicate key errors

-- Step 1: Check what indexes already exist
SELECT '=== EXISTING INDEXES ===' as info;
SHOW INDEX FROM products;

-- Step 2: Drop existing indexes that might conflict
SELECT '=== DROPPING EXISTING INDEXES (if they exist) ===' as info;

-- Try to drop indexes if they exist (ignore errors if they don't exist)
-- We use separate blocks to handle each index individually

-- Drop idx_supplier if exists
SET @sql = IF(
    EXISTS(
        SELECT 1 FROM information_schema.STATISTICS 
        WHERE table_schema = DATABASE() 
        AND table_name = 'products' 
        AND index_name = 'idx_supplier'
    ),
    'DROP INDEX idx_supplier ON products',
    'SELECT "idx_supplier does not exist" as message'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Drop idx_barcode if exists  
SET @sql = IF(
    EXISTS(
        SELECT 1 FROM information_schema.STATISTICS 
        WHERE table_schema = DATABASE() 
        AND table_name = 'products' 
        AND index_name = 'idx_barcode'
    ),
    'DROP INDEX idx_barcode ON products',
    'SELECT "idx_barcode does not exist" as message'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Drop idx_product_name if exists
SET @sql = IF(
    EXISTS(
        SELECT 1 FROM information_schema.STATISTICS 
        WHERE table_schema = DATABASE() 
        AND table_name = 'products' 
        AND index_name = 'idx_product_name'
    ),
    'DROP INDEX idx_product_name ON products',
    'SELECT "idx_product_name does not exist" as message'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Drop idx_supplier_product_name if exists
SET @sql = IF(
    EXISTS(
        SELECT 1 FROM information_schema.STATISTICS 
        WHERE table_schema = DATABASE() 
        AND table_name = 'products' 
        AND index_name = 'idx_supplier_product_name'
    ),
    'DROP INDEX idx_supplier_product_name ON products',
    'SELECT "idx_supplier_product_name does not exist" as message'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Drop idx_created_at if exists
SET @sql = IF(
    EXISTS(
        SELECT 1 FROM information_schema.STATISTICS 
        WHERE table_schema = DATABASE() 
        AND table_name = 'products' 
        AND index_name = 'idx_created_at'
    ),
    'DROP INDEX idx_created_at ON products',
    'SELECT "idx_created_at does not exist" as message'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Step 3: Create all fresh indexes
SELECT '=== CREATING FRESH INDEXES ===' as info;

CREATE INDEX idx_supplier ON products(supplier);
CREATE INDEX idx_barcode ON products(barcode);
CREATE INDEX idx_product_name ON products(product_name);
CREATE INDEX idx_supplier_product_name ON products(supplier, product_name);
CREATE INDEX idx_created_at ON products(created_at);

-- Step 4: Verify creation
SELECT '=== VERIFICATION - ALL INDEXES ===' as info;
SHOW INDEX FROM products;