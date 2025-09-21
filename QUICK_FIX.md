# راه‌حل سریع مشکل MySQL

## 🚨 مشکل: Access denied for user 'vghzoegc'@'localhost' to database 'product_manager'

## ⚡ راه‌حل فوری (توصیه شده):

### 1. استفاده از SQLite (ساده‌ترین راه)
```
✅ در اپلیکیشن، به تنظیمات بروید
✅ گزینه "SQLite (محلی)" را انتخاب کنید
✅ هیچ تنظیماتی نیاز نیست!
✅ اپلیکیشن خودکار دیتابیس محلی ایجاد می‌کند
```

### 2. ایجاد دیتابیس در phpMyAdmin
```
1. وارد phpMyAdmin شوید
2. روی تب "Databases" کلیک کنید
3. نام دیتابیس: product_manager
4. Collation: utf8mb4_unicode_ci
5. روی "Create" کلیک کنید
6. سپس کد SQL زیر را اجرا کنید:
```

```sql
USE product_manager;

CREATE TABLE IF NOT EXISTS products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    barcode VARCHAR(255) UNIQUE NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    supplier VARCHAR(255) NOT NULL,
    purchase_price DECIMAL(10,2) NOT NULL,
    original_price DECIMAL(10,2) NOT NULL,
    discounted_price DECIMAL(10,2) NOT NULL,
    supplier_code VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

## 🔧 تنظیمات اپلیکیشن:

### برای MySQL:
- **Host:** localhost
- **Port:** 3306  
- **Username:** vghzoegc
- **Password:** [رمز عبور شما]
- **Database:** product_manager

### برای SQLite:
- هیچ تنظیماتی نیاز نیست!

## 📱 مراحل تست:

1. **اپلیکیشن را اجرا کنید:**
   ```bash
   flutter run
   ```

2. **به تنظیمات بروید**

3. **نوع دیتابیس را انتخاب کنید:**
   - SQLite (توصیه شده)
   - یا MySQL (اگر دیتابیس ایجاد کردید)

4. **تست کنید:**
   - دکمه + را بزنید
   - محصول جدیدی اضافه کنید
   - اگر موفق بود، همه چیز درست کار می‌کند!

## 🆘 اگر همچنان مشکل دارید:

### راه‌حل‌های جایگزین:

1. **از فایل نمونه استفاده کنید:**
   - فایل `sample_data.csv` را باز کنید
   - داده‌ها را کپی کنید
   - در اپلیکیشن، محصولات را دستی اضافه کنید

2. **با پشتیبانی هاستینگ تماس بگیرید:**
   - درخواست دسترسی CREATE DATABASE کنید
   - یا از آنها بخواهید دیتابیس را ایجاد کنند

3. **از دیتابیس موجود استفاده کنید:**
   - اگر دیتابیس دیگری دارید که دسترسی دارید
   - نام آن را در تنظیمات وارد کنید

## ✅ مزایای SQLite:

- ✅ نیازی به تنظیم ندارد
- ✅ سریع و سبک است
- ✅ فایل دیتابیس در گوشی ذخیره می‌شود
- ✅ نیازی به سرور ندارد
- ✅ برای استفاده شخصی عالی است

## 🎯 نتیجه:

**توصیه:** از SQLite استفاده کنید! ساده‌تر، سریع‌تر و بدون دردسر است.

اگر حتماً باید از MySQL استفاده کنید، دیتابیس را در phpMyAdmin ایجاد کنید و سپس کد SQL بالا را اجرا کنید.