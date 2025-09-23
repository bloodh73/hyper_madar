-- Simple test to check suppliers
-- Run these commands one by one

-- Check total products
SELECT COUNT(*) as total_products FROM products;

-- Check unique suppliers (simple version)
SELECT DISTINCT supplier FROM products LIMIT 10;

-- Check with NULL values
SELECT 
    supplier,
    CASE 
        WHEN supplier IS NULL THEN 'NULL'
        WHEN supplier = '' THEN 'EMPTY'
        ELSE supplier
    END as supplier_status
FROM products 
WHERE supplier IS NOT NULL
LIMIT 10;

-- Count by supplier (including NULL/empty)
SELECT 
    CASE 
        WHEN supplier IS NULL THEN 'NULL'
        WHEN supplier = '' THEN 'EMPTY'
        ELSE supplier
    END as supplier_name,
    COUNT(*) as count
FROM products
GROUP BY supplier_name
ORDER BY count DESC
LIMIT 20;