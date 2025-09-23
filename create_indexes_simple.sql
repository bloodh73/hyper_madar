-- Simple and Safe Index Creation
-- Run these commands one by one in MySQL

-- Check existing indexes first
SHOW INDEX FROM products;

-- Create indexes manually only if they don't exist
-- You can run these commands one by one:

-- CREATE INDEX idx_supplier ON products(supplier);
-- CREATE INDEX idx_barcode ON products(barcode);
-- CREATE INDEX idx_product_name ON products(product_name);
-- CREATE INDEX idx_supplier_product_name ON products(supplier, product_name);
-- CREATE INDEX idx_created_at ON products(created_at);

-- Or use this alternative approach:
-- Drop existing indexes first (if they exist) and recreate them

-- DROP INDEX idx_supplier ON products;
-- DROP INDEX idx_barcode ON products;
-- DROP INDEX idx_product_name ON products;
-- DROP INDEX idx_supplier_product_name ON products;
-- DROP INDEX idx_created_at ON products;

-- Then create fresh indexes:
-- CREATE INDEX idx_supplier ON products(supplier);
-- CREATE INDEX idx_barcode ON products(barcode);
-- CREATE INDEX idx_product_name ON products(product_name);
-- CREATE INDEX idx_supplier_product_name ON products(supplier, product_name);
-- CREATE INDEX idx_created_at ON products(created_at);