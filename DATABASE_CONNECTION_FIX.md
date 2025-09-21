# 🔧 حل مشکل اتصال دیتابیس

## 🚨 مشکل شناسایی شده

مشکل اصلی این است که:
- **فایل `database_setup.sql`** شما برای دیتابیس `vghzoegc_hyper` است
- **فایل `hyper.php`** به دنبال دیتابیس `product_manager` می‌گردد
- **نام‌ها مطابقت ندارند** ❌

## ✅ راه‌حل اعمال شده

### 1. بروزرسانی فایل PHP ✅
```php
// در فایل hyper.php
$dbname = 'vghzoegc_hyper'; // نام دیتابیس واقعی شما
```

### 2. بررسی ساختار دیتابیس ✅
فایل `database_setup.sql` شما شامل:
- دیتابیس: `vghzoegc_hyper`
- جدول: `products`
- ساختار کامل جدول

## 🔧 مراحل حل مشکل

### مرحله 1: آپلود فایل PHP
```bash
# فایل hyper.php را روی سرور آپلود کنید
# آدرس: https://blizzardping.ir/hyper.php
```

### مرحله 2: اجرای SQL در phpMyAdmin
```sql
-- این کد را در phpMyAdmin اجرا کنید
-- (فایل database_setup.sql شما)

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

-- Database: `vghzoegc_hyper`

CREATE TABLE `products` (
  `id` int NOT NULL,
  `barcode` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `product_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `supplier` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `purchase_price` decimal(10,2) NOT NULL,
  `original_price` decimal(10,2) NOT NULL,
  `discounted_price` decimal(10,2) NOT NULL,
  `supplier_code` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

ALTER TABLE `products`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `barcode` (`barcode`);

ALTER TABLE `products`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;
COMMIT;
```

### مرحله 3: تنظیم رمز عبور
```php
// در فایل hyper.php
$password = 'YOUR_ACTUAL_PASSWORD'; // رمز عبور واقعی خود را وارد کنید
```

### مرحله 4: تست اتصال
```bash
# فایل test_api.html را در مرورگر باز کنید
# روی "تست اتصال" کلیک کنید
```

## 🧪 تست اتصال

### روش 1: استفاده از فایل تست
```html
<!-- فایل test_api.html -->
<!DOCTYPE html>
<html>
<head>
    <title>تست API دیتابیس</title>
</head>
<body>
    <button onclick="testConnection()">تست اتصال</button>
    <div id="result"></div>
    
    <script>
    function testConnection() {
        fetch('https://blizzardping.ir/hyper.php?action=stats')
            .then(response => response.json())
            .then(data => {
                document.getElementById('result').innerHTML = 
                    '<pre>' + JSON.stringify(data, null, 2) + '</pre>';
            })
            .catch(error => {
                document.getElementById('result').innerHTML = 
                    'خطا: ' + error.message;
            });
    }
    </script>
</body>
</html>
```

### روش 2: تست مستقیم در مرورگر
```
https://blizzardping.ir/hyper.php?action=stats
```

### پاسخ مورد انتظار:
```json
{
  "connection_status": "connected",
  "total_products": 0,
  "server_time": "2025-01-27 10:30:00"
}
```

## 🔍 عیب‌یابی

### خطای 1: "Connection failed"
```json
{
  "status": "error",
  "message": "Connection failed: Access denied for user 'vghzoegc'@'localhost'"
}
```

**راه‌حل:**
- رمز عبور را بررسی کنید
- نام کاربری را بررسی کنید
- دسترسی‌های دیتابیس را بررسی کنید

### خطای 2: "Unknown database"
```json
{
  "status": "error",
  "message": "Unknown database 'vghzoegc_hyper'"
}
```

**راه‌حل:**
- دیتابیس را در phpMyAdmin ایجاد کنید
- فایل `database_setup.sql` را اجرا کنید

### خطای 3: "Table doesn't exist"
```json
{
  "status": "error",
  "message": "Table 'products' doesn't exist"
}
```

**راه‌حل:**
- جدول `products` را ایجاد کنید
- فایل `database_setup.sql` را اجرا کنید

## 📋 چک‌لیست حل مشکل

### ✅ مراحل انجام شده:
- [x] نام دیتابیس در `hyper.php` بروزرسانی شد
- [x] فایل `database_setup.sql` بررسی شد
- [x] ساختار جدول `products` تایید شد

### 🔄 مراحل باقی‌مانده:
- [ ] آپلود فایل `hyper.php` روی سرور
- [ ] اجرای `database_setup.sql` در phpMyAdmin
- [ ] تنظیم رمز عبور در `hyper.php`
- [ ] تست اتصال با `test_api.html`

## 🚀 تست نهایی

### 1. تست API
```bash
# در مرورگر باز کنید
https://blizzardping.ir/hyper.php?action=stats
```

### 2. تست در اپلیکیشن
- اپلیکیشن Flutter را باز کنید
- به تنظیمات بروید
- روی "تست اتصال" کلیک کنید
- باید پیام سبز "اتصال موفق" ببینید

### 3. افزودن محصول تست
- دکمه + را بزنید
- اطلاعات محصول را وارد کنید
- روی ذخیره کلیک کنید
- محصول باید اضافه شود

## 🎯 نتیجه نهایی

### ✅ پس از حل مشکل:
- **اتصال دیتابیس** کار می‌کند
- **API** پاسخ می‌دهد
- **افزودن محصول** کار می‌کند
- **جستجو** کار می‌کند
- **تمام عملیات** کار می‌کند

### 🌐 آدرس‌های مهم:
- **API:** `https://blizzardping.ir/hyper.php`
- **تست:** `https://blizzardping.ir/hyper.php?action=stats`
- **دیتابیس:** `vghzoegc_hyper`

## 💡 نکات مهم

1. **نام دیتابیس** باید دقیقاً `vghzoegc_hyper` باشد
2. **رمز عبور** را در `hyper.php` تنظیم کنید
3. **جدول products** باید وجود داشته باشد
4. **فایل PHP** باید روی سرور آپلود شود

## 🆘 در صورت مشکل

### بررسی کنید:
1. **فایل PHP** آپلود شده باشد
2. **دیتابیس** ایجاد شده باشد
3. **جدول products** وجود داشته باشد
4. **رمز عبور** صحیح باشد
5. **نام کاربری** صحیح باشد

### لاگ‌های مفید:
- **خطاهای PHP** در سرور
- **خطاهای دیتابیس** در phpMyAdmin
- **خطاهای شبکه** در مرورگر

**موفق باشید! مشکل اتصال دیتابیس حل خواهد شد! 🚀**
