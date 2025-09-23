-- Create Only Missing Indexes
-- This script creates indexes that don't exist yet

-- Check current indexes first
SHOW INDEX FROM products;

-- Create missing indexes only
-- Run these commands one by one, skipping the ones that already exist

-- Index for supplier field (skip if you get duplicate key error)
CREATE INDEX idx_supplier ON products(supplier);

-- Index for barcode field (skip if you get duplicate key error)  
CREATE INDEX idx_barcode ON products(barcode);

-- Index for product name (skip if you get duplicate key error)
CREATE INDEX idx_product_name ON products(product_name);

-- Composite index for supplier and product name (skip if you get duplicate key error)
CREATE INDEX idx_supplier_product_name ON products(supplier, product_name);

-- Index for created_at (skip if you get duplicate key error)
CREATE INDEX idx_created_at ON products(created_at);

-- Alternative approach: Check which indexes exist first
SELECT 
    index_name,
    CASE 
        WHEN index_name IN ('idx_supplier', 'idx_barcode', 'idx_product_name', 
                           'idx_supplier_product_name', 'idx_created_at') 
        THEN 'Performance index'
        ELSE 'Other index'
    END as index_type
FROM information_schema.STATISTICS 
WHERE table_schema = DATABASE() 
AND table_name = 'products'
ORDER BY index_name;