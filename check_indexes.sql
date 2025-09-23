-- Check if indexes exist before creating them
-- Run this to see existing indexes on products table

SHOW INDEX FROM products;

-- Alternative: Check specific index
SELECT COUNT(*) as index_exists 
FROM information_schema.STATISTICS 
WHERE table_schema = DATABASE() 
AND table_name = 'products' 
AND index_name = 'idx_supplier';