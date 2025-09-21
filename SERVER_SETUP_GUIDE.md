# راهنمای نصب و راه‌اندازی سرور

## 🌐 آدرس سرور شما
```
https://blizzardping.ir/hyper.php
```

## 📋 مراحل نصب

### 1. آپلود فایل PHP
1. فایل `hyper.php` را روی سرور آپلود کنید
2. مطمئن شوید که در مسیر صحیح قرار دارد
3. مجوزهای فایل را بررسی کنید (644)

### 2. ایجاد دیتابیس MySQL
1. وارد کنترل پنل هاستینگ شوید
2. به بخش MySQL/phpMyAdmin بروید
3. دیتابیس جدید ایجاد کنید:
   - نام: `product_manager`
   - Collation: `utf8mb4_unicode_ci`

### 3. ایجاد جدول products
در phpMyAdmin، کد SQL زیر را اجرا کنید:

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

### 4. تنظیم اطلاعات دیتابیس در فایل PHP
فایل `hyper.php` را ویرایش کنید و اطلاعات دیتابیس را وارد کنید:

```php
// تنظیمات دیتابیس
$host = 'localhost';
$dbname = 'product_manager';
$username = 'vghzoegc'; // نام کاربری شما
$password = 'YOUR_PASSWORD'; // رمز عبور شما
```

### 5. تست API
1. فایل `test_api.html` را در مرورگر باز کنید
2. روی "تست اتصال" کلیک کنید
3. اگر سبز شد، API کار می‌کند

## 🔧 تنظیمات پیشرفته

### 1. امنیت
- رمز عبور قوی برای دیتابیس انتخاب کنید
- دسترسی‌های کاربر دیتابیس را محدود کنید
- فایل PHP را در مسیر امن قرار دهید

### 2. بهینه‌سازی
- ایندکس‌های مناسب اضافه کنید
- محدودیت تعداد درخواست تنظیم کنید
- Cache مناسب پیاده کنید

### 3. پشتیبان‌گیری
- پشتیبان‌گیری خودکار دیتابیس تنظیم کنید
- فایل‌های مهم را بک‌آپ کنید

## 📊 مانیتورینگ

### 1. لاگ‌ها
- خطاهای PHP را بررسی کنید
- لاگ‌های سرور را مانیتور کنید
- ترافیک API را بررسی کنید

### 2. عملکرد
- زمان پاسخ API را اندازه‌گیری کنید
- استفاده از CPU و RAM را بررسی کنید
- تعداد اتصالات دیتابیس را مانیتور کنید

## 🚀 تست کامل

### 1. تست اتصال
```bash
curl "https://blizzardping.ir/hyper.php?action=test"
```

### 2. تست افزودن محصول
```bash
curl -X POST "https://blizzardping.ir/hyper.php?action=product" \
  -H "Content-Type: application/json" \
  -d '{
    "barcode": "1234567890123",
    "product_name": "لپ‌تاپ ایسوس",
    "supplier": "شرکت فناوری پارس",
    "purchase_price": 15000000,
    "original_price": 18000000,
    "discounted_price": 16000000,
    "supplier_code": "ASUS001"
  }'
```

### 3. تست دریافت محصولات
```bash
curl "https://blizzardping.ir/hyper.php?action=products&page=1&limit=10"
```

## 🔍 عیب‌یابی

### خطاهای رایج:

#### 1. خطای اتصال دیتابیس
```
خطا در اتصال به دیتابیس: Access denied
```
**راه‌حل:**
- اطلاعات دیتابیس را بررسی کنید
- دسترسی کاربر را بررسی کنید
- رمز عبور را بررسی کنید

#### 2. خطای جدول وجود ندارد
```
Table 'product_manager.products' doesn't exist
```
**راه‌حل:**
- جدول products را ایجاد کنید
- کد SQL را دوباره اجرا کنید

#### 3. خطای CORS
```
Access to fetch at '...' from origin '...' has been blocked by CORS policy
```
**راه‌حل:**
- Headers CORS در فایل PHP بررسی کنید
- سرور CORS را پشتیبانی می‌کند

#### 4. خطای 500
```
Internal Server Error
```
**راه‌حل:**
- لاگ‌های PHP را بررسی کنید
- مجوزهای فایل را بررسی کنید
- سینتکس PHP را بررسی کنید

## 📱 استفاده در اپلیکیشن Flutter

### 1. فعال کردن دیتابیس آنلاین
- اپلیکیشن Flutter را باز کنید
- به تنظیمات بروید
- بخش "دیتابیس آنلاین" را پیدا کنید
- روی "تست اتصال" کلیک کنید

### 2. استفاده عادی
- تمام عملیات مثل دیتابیس محلی است
- داده‌ها از سرور می‌آیند
- تغییرات روی سرور ذخیره می‌شوند

## 🎯 مزایای دیتابیس آنلاین

### ✅ مزایا:
- دسترسی از هر جا
- پشتیبان‌گیری خودکار
- چندین کاربر همزمان
- امنیت بالا
- سرعت بالا
- مقیاس‌پذیری

### ⚠️ نکات:
- نیاز به اتصال اینترنت
- وابسته به سرور
- ممکن است قطع شود
- هزینه هاستینگ

## 📞 پشتیبانی

### در صورت مشکل:
1. لاگ‌های سرور را بررسی کنید
2. اطلاعات دیتابیس را بررسی کنید
3. فایل PHP را دوباره آپلود کنید
4. با پشتیبانی هاستینگ تماس بگیرید

## 🎊 نتیجه

سرور شما آماده است! می‌توانید:

1. ✅ فایل PHP را آپلود کنید
2. ✅ دیتابیس را ایجاد کنید
3. ✅ API را تست کنید
4. ✅ در اپلیکیشن Flutter استفاده کنید

**موفق باشید! 🚀**
