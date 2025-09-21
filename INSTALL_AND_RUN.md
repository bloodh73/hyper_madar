# راهنمای نصب و اجرای سریع

## 🚀 نصب و اجرا در 3 مرحله

### مرحله 1: نصب Flutter (اگر نصب نیست)
```bash
# دانلود Flutter از flutter.dev
# اضافه کردن به PATH
flutter doctor
```

### مرحله 2: نصب Dependencies
```bash
flutter pub get
```

### مرحله 3: اجرای اپلیکیشن
```bash
flutter run
```

## ⚡ اجرای سریع با فایل Batch

### در ویندوز:
```bash
# فایل run_app.bat را دوبار کلیک کنید
run_app.bat
```

### در لینوکس/Mac:
```bash
# فایل run_app.sh را اجرا کنید
./run_app.sh
```

## 📱 اولین استفاده

### 1. اپلیکیشن را باز کنید
- صفحه اصلی نمایش داده می‌شود
- لیست محصولات خالی است

### 2. تنظیم دیتابیس (اختیاری)
- به تنظیمات بروید
- **توصیه:** SQLite را انتخاب کنید (ساده‌تر)
- یا MySQL را انتخاب کنید (اگر دیتابیس دارید)

### 3. افزودن محصول اول
- دکمه + را بزنید
- اطلاعات محصول را وارد کنید:
  - بارکد: 1234567890123
  - نام: لپ‌تاپ ایسوس
  - تامین کننده: شرکت فناوری پارس
  - قیمت خرید: 15000000
  - قیمت اصلی: 18000000
  - قیمت نهایی: 16000000
  - کد تامین کننده: ASUS001

### 4. تست جستجو
- در نوار جستجو "ایسوس" تایپ کنید
- محصول نمایش داده می‌شود

### 5. تست وارد کردن از اکسل
- دکمه آپلود فایل را بزنید
- فایل `sample_data.csv` را انتخاب کنید
- محصولات وارد می‌شوند

## 🔧 تنظیمات MySQL (اختیاری)

### اگر می‌خواهید از MySQL استفاده کنید:

1. **MySQL Server را اجرا کنید**

2. **دیتابیس ایجاد کنید:**
   ```sql
   CREATE DATABASE product_manager CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
   ```

3. **جدول ایجاد کنید:**
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

4. **در اپلیکیشن تنظیمات را وارد کنید:**
   - Host: localhost
   - Port: 3306
   - Username: root (یا نام کاربری شما)
   - Password: [رمز عبور شما]
   - Database: product_manager

## 📊 فایل‌های نمونه

- `sample_data.csv` - نمونه داده‌های محصولات
- `database_setup.sql` - اسکریپت کامل MySQL
- `database_setup_fixed.sql` - نسخه بهبود یافته

## 🆘 عیب‌یابی

### خطای رایج:
```
#1044 - Access denied for user to database
```

### راه‌حل:
1. **از SQLite استفاده کنید** (توصیه شده)
2. یا دیتابیس را در phpMyAdmin ایجاد کنید
3. یا با پشتیبانی هاستینگ تماس بگیرید

### سایر خطاها:
- فایل `MYSQL_SETUP_GUIDE.md` را مطالعه کنید
- در اپلیکیشن، به راهنمای عیب‌یابی بروید

## ✅ تست عملکرد

### چک‌لیست:
- [ ] اپلیکیشن اجرا می‌شود
- [ ] صفحه اصلی نمایش داده می‌شود
- [ ] می‌توانید محصول اضافه کنید
- [ ] بارکد نمایش داده می‌شود
- [ ] جستجو کار می‌کند
- [ ] وارد کردن از اکسل کار می‌کند

## 🎯 نکات مهم

1. **SQLite ساده‌تر است** - نیازی به تنظیم ندارد
2. **MySQL برای سرور** - اگر چندین کاربر دارید
3. **فایل نمونه** - برای تست استفاده کنید
4. **راهنمای عیب‌یابی** - در اپلیکیشن موجود است

## 🚀 آماده استفاده!

اگر همه چیز درست کار کرد، اپلیکیشن شما آماده استفاده است!

### ویژگی‌های موجود:
- ✅ نمایش بارکد
- ✅ مدیریت محصولات
- ✅ جستجو
- ✅ وارد کردن از اکسل
- ✅ دیتابیس دوگانه (SQLite + MySQL)
- ✅ رابط فارسی
