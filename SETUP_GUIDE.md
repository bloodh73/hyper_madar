# راهنمای نصب و اجرای اپلیکیشن مدیریت محصولات

## پیش‌نیازها

### 1. نصب Flutter
1. از [flutter.dev](https://flutter.dev/docs/get-started/install) Flutter SDK را دانلود کنید
2. Flutter را به PATH سیستم اضافه کنید
3. در Command Prompt یا PowerShell دستور زیر را اجرا کنید:
```bash
flutter doctor
```

### 2. نصب Android Studio (برای Android)
1. از [developer.android.com](https://developer.android.com/studio) Android Studio را دانلود کنید
2. Android SDK را نصب کنید
3. یک Virtual Device ایجاد کنید

### 3. نصب MySQL (اختیاری)
1. از [mysql.com](https://dev.mysql.com/downloads/mysql/) MySQL Server را دانلود کنید
2. MySQL را نصب و اجرا کنید
3. دیتابیس `product_manager` را ایجاد کنید

## مراحل نصب

### مرحله 1: کلون کردن پروژه
```bash
git clone <repository-url>
cd product_manager
```

### مرحله 2: نصب Dependencies
```bash
flutter pub get
```

### مرحله 3: اجرای اپلیکیشن

#### روش 1: استفاده از فایل Batch (ویندوز)
فایل `run_app.bat` را دوبار کلیک کنید

#### روش 2: استفاده از Command Line
```bash
flutter run
```

## تنظیم دیتابیس

### SQLite (پیش‌فرض)
- نیازی به تنظیم ندارد
- اپلیکیشن به صورت خودکار دیتابیس محلی ایجاد می‌کند

### MySQL
1. MySQL Server را اجرا کنید
2. فایل `database_setup.sql` را در MySQL اجرا کنید:
```sql
source database_setup.sql;
```
3. در اپلیکیشن، به بخش تنظیمات بروید
4. اطلاعات اتصال MySQL را وارد کنید

## تست اپلیکیشن

### 1. افزودن محصول دستی
- روی دکمه + کلیک کنید
- اطلاعات محصول را وارد کنید
- روی ذخیره کلیک کنید

### 2. وارد کردن از اکسل
- فایل `example_products.xlsx` را به عنوان نمونه استفاده کنید
- در اپلیکیشن، گزینه وارد کردن از اکسل را انتخاب کنید
- فایل نمونه را انتخاب کنید

### 3. جستجو
- در نوار جستجو، نام محصول یا بارکد را تایپ کنید

## عیب‌یابی

### خطای Flutter Doctor
```bash
flutter doctor --android-licenses
```

### خطای Dependencies
```bash
flutter clean
flutter pub get
```

### خطای MySQL
- مطمئن شوید MySQL Server اجرا است
- پورت 3306 باز است
- اطلاعات اتصال صحیح است

### خطای Android
- Virtual Device ایجاد کنید
- USB Debugging را فعال کنید

## ویژگی‌های اپلیکیشن

✅ **نمایش بارکد**: هر محصول با بارکد Code128 نمایش داده می‌شود
✅ **جستجو**: امکان جستجو در نام، بارکد، تامین کننده
✅ **وارد کردن اکسل**: پشتیبانی از فایل‌های .xlsx و .xls
✅ **دیتابیس دوگانه**: SQLite محلی و MySQL سرور
✅ **رابط فارسی**: تمام متن‌ها به فارسی
✅ **طراحی مدرن**: Material Design 3

## ساختار فایل‌ها

```
product_manager/
├── lib/
│   ├── main.dart              # نقطه ورود
│   ├── models/               # مدل‌های داده
│   ├── providers/            # مدیریت state
│   ├── screens/              # صفحات اپلیکیشن
│   ├── services/             # سرویس‌های دیتابیس
│   └── widgets/              # کامپوننت‌های UI
├── assets/                   # فایل‌های استاتیک
├── pubspec.yaml             # Dependencies
├── database_setup.sql       # اسکریپت MySQL
├── example_products.xlsx    # نمونه فایل اکسل
└── README.md               # مستندات
```

## پشتیبانی

برای گزارش مشکل یا درخواست ویژگی جدید، Issue ایجاد کنید.

## لایسنس

این پروژه تحت لایسنس MIT منتشر شده است.
