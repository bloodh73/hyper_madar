-- Debug Suppliers Issue
-- This script helps identify why suppliers are not showing

-- Step 1: Check total products count
SELECT COUNT(*) as total_products FROM products;

-- Step 2: Check products with supplier data
SELECT 
    COUNT(*) as products_with_supplier,
    COUNT(CASE WHEN supplier IS NULL THEN 1 END) as null_suppliers,
    COUNT(CASE WHEN supplier = '' THEN 1 END) as empty_suppliers,
    COUNT(CASE WHEN supplier IS NOT NULL AND supplier != '' THEN 1 END) as valid_suppliers
FROM products;

-- Step 3: See some sample supplier data
SELECT DISTINCT supplier, COUNT(*) as product_count
FROM products 
WHERE supplier IS NOT NULL AND supplier != ''
GROUP BY supplier
ORDER BY product_count DESC
LIMIT 20;

-- Step 4: Check for whitespace issues
SELECT DISTINCT 
    supplier,
    LENGTH(supplier) as length,
    COUNT(*) as count
FROM products 
WHERE supplier IS NOT NULL AND supplier != ''
GROUP BY supplier
ORDER BY count DESC
LIMIT 10;

-- Step 5: Test the exact query used in the app
SELECT DISTINCT supplier 
FROM products 
WHERE supplier IS NOT NULL AND supplier != '' 
ORDER BY supplier;

-- Step 6: Check for any data issues
SELECT 
    supplier,
    HEX(supplier) as hex_value,
    COUNT(*) as count
FROM products 
WHERE supplier IS NOT NULL AND supplier != ''
GROUP BY supplier
ORDER BY count DESC
LIMIT 5;