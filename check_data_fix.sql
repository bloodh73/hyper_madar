-- Check and fix supplier data issues
-- Run this in your MySQL client

-- Step 1: Check what data we actually have
SELECT 
    COUNT(*) as total_products,
    COUNT(DISTINCT supplier) as unique_suppliers,
    COUNT(CASE WHEN supplier IS NULL THEN 1 END) as null_suppliers,
    COUNT(CASE WHEN supplier = '' THEN 1 END) as empty_suppliers
FROM products;

-- Step 2: See some actual supplier names
SELECT DISTINCT supplier, COUNT(*) as count
FROM products
WHERE supplier IS NOT NULL AND supplier != ''
GROUP BY supplier
ORDER BY count DESC
LIMIT 15;

-- Step 3: Check for whitespace issues
SELECT DISTINCT supplier, LENGTH(supplier) as length, COUNT(*) as count
FROM products
WHERE supplier IS NOT NULL AND supplier != ''
GROUP BY supplier
ORDER BY count DESC
LIMIT 10;

-- Step 4: Test the query we're using in the app
SELECT DISTINCT TRIM(supplier) as supplier_name
FROM products
WHERE supplier IS NOT NULL AND TRIM(supplier) != ''
ORDER BY TRIM(supplier);