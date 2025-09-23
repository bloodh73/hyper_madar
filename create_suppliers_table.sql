-- Create dedicated suppliers table
-- This script creates a separate suppliers table for better management

-- Create suppliers table
CREATE TABLE IF NOT EXISTS suppliers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    supplier_name VARCHAR(255) NOT NULL UNIQUE COMMENT 'نام تامین کننده',
    contact_person VARCHAR(255) COMMENT 'نام شخص تماس',
    phone VARCHAR(50) COMMENT 'تلفن تماس',
    email VARCHAR(255) COMMENT 'ایمیل',
    address TEXT COMMENT 'آدرس',
    description TEXT COMMENT 'توضیحات',
    is_active BOOLEAN DEFAULT TRUE COMMENT 'وضعیت فعال/غیرفعال',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'تاریخ ایجاد',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'تاریخ بروزرسانی',
    
    INDEX idx_supplier_name (supplier_name),
    INDEX idx_is_active (is_active),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='جدول تامین کنندگان';

-- Insert existing suppliers from products table
INSERT INTO suppliers (supplier_name, created_at, updated_at)
SELECT DISTINCT TRIM(supplier) as supplier_name, NOW(), NOW()
FROM products 
WHERE supplier IS NOT NULL AND TRIM(supplier) != ''
ORDER BY TRIM(supplier);

-- Add supplier_id column to products table
ALTER TABLE products ADD COLUMN supplier_id INT COMMENT 'شناسه تامین کننده';

-- Update products table to link with suppliers
UPDATE products p 
JOIN suppliers s ON TRIM(p.supplier) = TRIM(s.supplier_name)
SET p.supplier_id = s.id;

-- Add foreign key constraint (optional - uncomment if needed)
-- ALTER TABLE products 
-- ADD CONSTRAINT fk_products_suppliers 
-- FOREIGN KEY (supplier_id) REFERENCES suppliers(id) 
-- ON DELETE SET NULL ON UPDATE CASCADE;

-- Verify the data
SELECT 
    s.id,
    s.supplier_name,
    COUNT(p.id) as product_count,
    s.is_active,
    s.created_at
FROM suppliers s
LEFT JOIN products p ON s.id = p.supplier_id
GROUP BY s.id, s.supplier_name, s.is_active, s.created_at
ORDER BY s.supplier_name;

-- Show suppliers without products (if any)
SELECT s.* 
FROM suppliers s
LEFT JOIN products p ON s.id = p.supplier_id
WHERE p.id IS NULL
ORDER BY s.supplier_name;