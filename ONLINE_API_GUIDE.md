# راهنمای استفاده از دیتابیس آنلاین

## 🌐 آدرس API
```
https://blizzardping.ir/hyper.php
```

## 📋 امکانات API

### 1. تست اتصال
```http
GET https://blizzardping.ir/hyper.php?action=test
```

**پاسخ موفق:**
```json
{
  "success": true,
  "data": {
    "message": "اتصال به دیتابیس موفق است",
    "total_products": 5,
    "server_time": "2024-01-15 14:30:25"
  }
}
```

### 2. دریافت تمام محصولات
```http
GET https://blizzardping.ir/hyper.php?action=products&page=1&limit=50
```

**پاسخ:**
```json
{
  "success": true,
  "data": {
    "products": [
      {
        "id": 1,
        "barcode": "1234567890123",
        "product_name": "لپ‌تاپ ایسوس",
        "supplier": "شرکت فناوری پارس",
        "purchase_price": 15000000,
        "original_price": 18000000,
        "discounted_price": 16000000,
        "supplier_code": "ASUS001",
        "created_at": "2024-01-15 14:30:25",
        "updated_at": "2024-01-15 14:30:25"
      }
    ],
    "total": 5,
    "page": 1,
    "limit": 50
  }
}
```

### 3. جستجو در محصولات
```http
GET https://blizzardping.ir/hyper.php?action=search&q=ایسوس&page=1&limit=50
```

### 4. دریافت محصول بر اساس ID
```http
GET https://blizzardping.ir/hyper.php?action=product&id=1
```

### 5. دریافت محصول بر اساس بارکد
```http
GET https://blizzardping.ir/hyper.php?action=barcode&barcode=1234567890123
```

### 6. ایجاد محصول جدید
```http
POST https://blizzardping.ir/hyper.php?action=product
Content-Type: application/json

{
  "barcode": "1234567890123",
  "product_name": "لپ‌تاپ ایسوس",
  "supplier": "شرکت فناوری پارس",
  "purchase_price": 15000000,
  "original_price": 18000000,
  "discounted_price": 16000000,
  "supplier_code": "ASUS001"
}
```

**پاسخ موفق:**
```json
{
  "success": true,
  "data": {
    "message": "محصول با موفقیت ایجاد شد",
    "product_id": 6
  }
}
```

### 7. بروزرسانی محصول
```http
PUT https://blizzardping.ir/hyper.php?action=product
Content-Type: application/json

{
  "id": 1,
  "barcode": "1234567890123",
  "product_name": "لپ‌تاپ ایسوس بروزرسانی شده",
  "supplier": "شرکت فناوری پارس",
  "purchase_price": 15000000,
  "original_price": 18000000,
  "discounted_price": 16000000,
  "supplier_code": "ASUS001"
}
```

### 8. حذف محصول
```http
DELETE https://blizzardping.ir/hyper.php?action=product&id=1
```

### 9. وارد کردن چندین محصول (از اکسل)
```http
POST https://blizzardping.ir/hyper.php?action=products
Content-Type: application/json

{
  "products": [
    {
      "barcode": "1234567890123",
      "product_name": "لپ‌تاپ ایسوس",
      "supplier": "شرکت فناوری پارس",
      "purchase_price": 15000000,
      "original_price": 18000000,
      "discounted_price": 16000000,
      "supplier_code": "ASUS001"
    },
    {
      "barcode": "2345678901234",
      "product_name": "موبایل سامسونگ",
      "supplier": "توزیع‌کننده موبایل",
      "purchase_price": 8000000,
      "original_price": 10000000,
      "discounted_price": 9000000,
      "supplier_code": "SAMSUNG001"
    }
  ]
}
```

**پاسخ:**
```json
{
  "success": true,
  "data": {
    "message": "وارد کردن محصولات تکمیل شد",
    "inserted_count": 2,
    "total_count": 2,
    "inserted_ids": [6, 7],
    "errors": []
  }
}
```

## 🔧 تنظیمات در اپلیکیشن Flutter

### 1. فعال کردن دیتابیس آنلاین
- به تنظیمات اپلیکیشن بروید
- بخش "دیتابیس آنلاین" را پیدا کنید
- روی "تست اتصال" کلیک کنید
- اگر موفق بود، می‌توانید از دیتابیس آنلاین استفاده کنید

### 2. استفاده از API در کد
```dart
import 'package:your_app/services/online_database_service.dart';

// ایجاد سرویس
final onlineService = OnlineDatabaseService();

// تست اتصال
final stats = await onlineService.getStats();

// دریافت محصولات
final products = await onlineService.getAllProducts();

// جستجو
final searchResults = await onlineService.searchProducts('ایسوس');

// افزودن محصول
final productId = await onlineService.insertProduct(product);

// بروزرسانی محصول
await onlineService.updateProduct(product);

// حذف محصول
await onlineService.deleteProduct(productId);
```

## 🛡️ امنیت

### 1. CORS
- API از CORS پشتیبانی می‌کند
- تمام درخواست‌ها از اپلیکیشن Flutter مجاز است

### 2. اعتبارسنجی
- تمام فیلدهای الزامی بررسی می‌شوند
- بارکد تکراری مجاز نیست
- قیمت‌ها باید عدد معتبر باشند

### 3. مدیریت خطا
- خطاها به صورت JSON برگردانده می‌شوند
- کدهای HTTP مناسب استفاده می‌شود
- پیام‌های خطا به فارسی هستند

## 📊 آمار و مانیتورینگ

### دریافت آمار کلی
```http
GET https://blizzardping.ir/hyper.php?action=test
```

**اطلاعات برگشتی:**
- تعداد کل محصولات
- زمان سرور
- وضعیت اتصال

## 🚀 مزایای دیتابیس آنلاین

### ✅ مزایا:
- دسترسی از هر جا
- پشتیبان‌گیری خودکار
- چندین کاربر همزمان
- امنیت بالا
- سرعت بالا

### ⚠️ نکات:
- نیاز به اتصال اینترنت
- وابسته به سرور
- ممکن است قطع شود

## 🔧 عیب‌یابی

### خطاهای رایج:

#### 1. خطای اتصال
```
خطا در اتصال: SocketException
```
**راه‌حل:** اتصال اینترنت را بررسی کنید

#### 2. خطای سرور
```
خطا در اتصال به دیتابیس
```
**راه‌حل:** سرور را بررسی کنید

#### 3. خطای اعتبارسنجی
```
فیلد barcode الزامی است
```
**راه‌حل:** تمام فیلدهای الزامی را پر کنید

## 📱 استفاده در اپلیکیشن

### 1. تست اتصال
- در تنظیمات، روی "تست اتصال" کلیک کنید
- اگر سبز شد، اتصال موفق است

### 2. مشاهده آمار
- روی "آمار" کلیک کنید
- تعداد محصولات و وضعیت را ببینید

### 3. استفاده عادی
- تمام عملیات مثل دیتابیس محلی است
- فقط داده‌ها از سرور می‌آیند

## 🎯 نتیجه

دیتابیس آنلاین شما آماده استفاده است! می‌توانید:

1. فایل `hyper.php` را روی سرور آپلود کنید
2. دیتابیس MySQL را ایجاد کنید
3. در اپلیکیشن Flutter تست کنید
4. شروع به استفاده کنید

**موفق باشید! 🚀**
