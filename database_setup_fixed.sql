-- راهنمای حل مشکل دسترسی MySQL
-- اگر خطای "Access denied" دریافت می‌کنید، این مراحل را دنبال کنید:

-- مرحله 1: ابتدا دیتابیس را به صورت دستی در phpMyAdmin ایجاد کنید
-- یا از دستور زیر استفاده کنید (اگر دسترسی root دارید):

-- CREATE DATABASE IF NOT EXISTS product_manager CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- مرحله 2: اگر دیتابیس قبلاً ایجاد شده، فقط جدول را ایجاد کنید:
USE product_manager;

-- ایجاد جدول محصولات
CREATE TABLE IF NOT EXISTS products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    barcode VARCHAR(255) UNIQUE NOT NULL COMMENT 'بارکد محصول',
    product_name VARCHAR(255) NOT NULL COMMENT 'نام محصول',
    supplier VARCHAR(255) NOT NULL COMMENT 'تامین کننده',
    purchase_price DECIMAL(10,2) NOT NULL COMMENT 'قیمت خرید',
    original_price DECIMAL(10,2) NOT NULL COMMENT 'قیمت اصلی',
    discounted_price DECIMAL(10,2) NOT NULL COMMENT 'قیمت نهایی',
    supplier_code VARCHAR(255) NOT NULL COMMENT 'کد تامین کننده',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'تاریخ ایجاد',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'تاریخ بروزرسانی',
    
    -- ایندکس‌ها برای بهبود عملکرد
    INDEX idx_barcode (barcode),
    INDEX idx_product_name (product_name),
    INDEX idx_supplier (supplier),
    INDEX idx_supplier_code (supplier_code),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='جدول محصولات';

-- نمونه داده‌های اولیه (اختیاری)
INSERT INTO products (barcode, product_name, supplier, purchase_price, original_price, discounted_price, supplier_code) VALUES
('1234567890123', 'لپ‌تاپ ایسوس', 'شرکت فناوری پارس', 15000000, 18000000, 16000000, 'ASUS001'),
('2345678901234', 'موبایل سامسونگ', 'توزیع‌کننده موبایل', 8000000, 10000000, 9000000, 'SAMSUNG001'),
('3456789012345', 'هدفون بلوتوث', 'شرکت صوتی ایران', 500000, 800000, 600000, 'AUDIO001'),
('4567890123456', 'کیبورد مکانیکی', 'فروشگاه کامپیوتر', 1200000, 1500000, 1300000, 'KEYBOARD001'),
('5678901234567', 'ماوس بی‌سیم', 'تجهیزات کامپیوتر', 300000, 500000, 350000, 'MOUSE001');

-- نمایش اطلاعات جدول
DESCRIBE products;

-- نمایش تعداد محصولات
SELECT COUNT(*) as total_products FROM products;
