-- Database Indexes for Performance Optimization
-- Run this script after creating your tables

-- Index for supplier field (used in supplier filtering)
-- برای MySQL: (بدون IF NOT EXISTS)
CREATE INDEX idx_supplier ON products(supplier);

-- Index for barcode field (used in product search)
CREATE INDEX idx_barcode ON products(barcode);

-- Index for product name (used in search)
CREATE INDEX idx_product_name ON products(product_name);

-- Composite index for supplier and product name (used in supplier product filtering)
CREATE INDEX idx_supplier_product_name ON products(supplier, product_name);

-- Index for created_at (used in sorting)
CREATE INDEX idx_created_at ON products(created_at);