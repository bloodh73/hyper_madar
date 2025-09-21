# راهنمای حل مشکل دسترسی MySQL

## مشکل: Access denied for user 'vghzoegc'@'localhost' to database 'product_manager'

این خطا نشان می‌دهد که کاربر MySQL شما دسترسی لازم برای ایجاد دیتابیس را ندارد.

## راه‌حل‌های مختلف:

### راه‌حل 1: ایجاد دیتابیس در phpMyAdmin (توصیه شده)

1. **وارد phpMyAdmin شوید**
2. **روی تب "Databases" کلیک کنید**
3. **نام دیتابیس را وارد کنید:** `product_manager`
4. **Collation را انتخاب کنید:** `utf8mb4_unicode_ci`
5. **روی "Create" کلیک کنید**

### راه‌حل 2: استفاده از SQLite (ساده‌تر)

اگر نمی‌توانید دیتابیس MySQL ایجاد کنید، از SQLite استفاده کنید:

1. **در اپلیکیشن، به تنظیمات بروید**
2. **گزینه "SQLite (محلی)" را انتخاب کنید**
3. **اپلیکیشن خودکار دیتابیس محلی ایجاد می‌کند**

### راه‌حل 3: درخواست دسترسی از مدیر سرور

اگر از هاستینگ استفاده می‌کنید:

1. **با پشتیبانی هاستینگ تماس بگیرید**
2. **درخواست دسترسی CREATE DATABASE کنید**
3. **یا از آنها بخواهید دیتابیس `product_manager` را ایجاد کنند**

### راه‌حل 4: استفاده از دیتابیس موجود

اگر دیتابیس دیگری دارید که دسترسی دارید:

1. **نام دیتابیس موجود را در تنظیمات اپلیکیشن وارد کنید**
2. **فقط جدول `products` ایجاد خواهد شد**

## مراحل بعد از ایجاد دیتابیس:

### 1. ایجاد جدول products

```sql
USE product_manager;

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
    
    INDEX idx_barcode (barcode),
    INDEX idx_product_name (product_name),
    INDEX idx_supplier (supplier),
    INDEX idx_supplier_code (supplier_code),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='جدول محصولات';
```

### 2. اضافه کردن داده‌های نمونه (اختیاری)

```sql
INSERT INTO products (barcode, product_name, supplier, purchase_price, original_price, discounted_price, supplier_code) VALUES
('1234567890123', 'لپ‌تاپ ایسوس', 'شرکت فناوری پارس', 15000000, 18000000, 16000000, 'ASUS001'),
('2345678901234', 'موبایل سامسونگ', 'توزیع‌کننده موبایل', 8000000, 10000000, 9000000, 'SAMSUNG001'),
('3456789012345', 'هدفون بلوتوث', 'شرکت صوتی ایران', 500000, 800000, 600000, 'AUDIO001');
```

## تنظیم اپلیکیشن:

### برای MySQL:
1. **Host:** localhost (یا آدرس سرور شما)
2. **Port:** 3306
3. **Username:** vghzoegc
4. **Password:** [رمز عبور شما]
5. **Database:** product_manager

### برای SQLite:
- هیچ تنظیماتی نیاز نیست
- اپلیکیشن خودکار دیتابیس محلی ایجاد می‌کند

## تست اتصال:

1. **در اپلیکیشن، به تنظیمات بروید**
2. **روی "اتصال به MySQL" کلیک کنید**
3. **اگر موفق بود، پیام سبز نمایش داده می‌شود**
4. **اگر خطا بود، اطلاعات اتصال را بررسی کنید**

## نکات مهم:

- ✅ SQLite نیازی به تنظیم ندارد
- ✅ MySQL نیاز به ایجاد دیتابیس دارد
- ✅ حتماً Collation را `utf8mb4_unicode_ci` انتخاب کنید
- ✅ اگر از هاستینگ استفاده می‌کنید، با پشتیبانی تماس بگیرید

## در صورت مشکل:

اگر همچنان مشکل دارید، از SQLite استفاده کنید که ساده‌تر است و نیازی به تنظیم ندارد.
