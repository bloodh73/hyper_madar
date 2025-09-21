# راهنمای حل مشکلات Build

## 🚨 مشکلات موجود

### 1. خطای file_picker
```
Package file_picker:linux references file_picker:linux as the default plugin
```

### 2. خطای Android NDK
```
file_picker requires Android NDK 27.0.12077973
```

### 3. خطای Java Compilation
```
cannot find symbol: class Registrar
```

## ✅ راه‌حل‌های اعمال شده

### 1. بروزرسانی file_picker
```yaml
# در pubspec.yaml
file_picker: ^8.0.0+1  # نسخه جدیدتر
```

### 2. تنظیم Android NDK
```kotlin
// در android/app/build.gradle.kts
ndkVersion = "27.0.12077973"
```

### 3. تنظیم Java Version
```kotlin
// در android/app/build.gradle.kts
compileOptions {
    sourceCompatibility = JavaVersion.VERSION_11
    targetCompatibility = JavaVersion.VERSION_11
}
```

## 🔧 مراحل حل مشکل

### مرحله 1: پاک کردن Cache
```bash
flutter clean
flutter pub get
```

### مرحله 2: بروزرسانی Dependencies
```bash
flutter pub upgrade
```

### مرحله 3: اجرای مجدد
```bash
flutter run
```

## 🛠️ اگر همچنان مشکل دارید

### راه‌حل جایگزین 1: حذف file_picker
اگر نمی‌خواهید از وارد کردن فایل استفاده کنید:

1. **از pubspec.yaml حذف کنید:**
```yaml
# file_picker: ^8.0.0+1  # این خط را کامنت کنید
```

2. **از کد حذف کنید:**
```dart
// import 'package:file_picker/file_picker.dart';  // کامنت کنید
```

3. **صفحه وارد کردن اکسل را غیرفعال کنید:**
```dart
// در home_screen.dart
// IconButton(
//   icon: const Icon(Icons.file_upload),
//   onPressed: () { ... },
// ),
```

### راه‌حل جایگزین 2: استفاده از نسخه قدیمی
```yaml
# در pubspec.yaml
file_picker: ^5.5.0  # نسخه قدیمی‌تر
```

### راه‌حل جایگزین 3: استفاده از دیتابیس آنلاین
- از دیتابیس آنلاین استفاده کنید
- نیازی به وارد کردن فایل نیست
- همه چیز از طریق API کار می‌کند

## 📱 تست بدون file_picker

### 1. حذف موقت file_picker
```bash
# در pubspec.yaml کامنت کنید
# file_picker: ^8.0.0+1
```

### 2. پاک کردن و نصب مجدد
```bash
flutter clean
flutter pub get
```

### 3. اجرای اپلیکیشن
```bash
flutter run
```

## 🎯 استفاده از اپلیکیشن

### بدون file_picker:
- ✅ نمایش محصولات
- ✅ افزودن محصول
- ✅ جستجو
- ✅ دیتابیس آنلاین
- ❌ وارد کردن از اکسل

### با file_picker:
- ✅ تمام امکانات
- ✅ وارد کردن از اکسل

## 🔍 عیب‌یابی بیشتر

### اگر خطای Gradle دارید:
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

### اگر خطای NDK دارید:
```bash
# در Android Studio
# File > Project Structure > SDK Location
# Android NDK location را بررسی کنید
```

### اگر خطای Java دارید:
```bash
# Java version را بررسی کنید
java -version
# باید Java 11 یا بالاتر باشد
```

## 📋 چک‌لیست

- [ ] flutter clean اجرا شده
- [ ] flutter pub get اجرا شده
- [ ] Android NDK نسخه 27.0.12077973
- [ ] Java version 11 یا بالاتر
- [ ] file_picker نسخه 8.0.0+1
- [ ] gradle.properties تنظیم شده

## 🚀 اجرای نهایی

```bash
# پاک کردن کامل
flutter clean
rm -rf build/
rm -rf .dart_tool/

# نصب مجدد
flutter pub get

# اجرا
flutter run
```

## 💡 نکات مهم

1. **file_picker اختیاری است** - اپلیکیشن بدون آن هم کار می‌کند
2. **دیتابیس آنلاین** - نیازی به وارد کردن فایل نیست
3. **نسخه‌های جدید** - همیشه آخرین نسخه‌ها را استفاده کنید
4. **Cache** - همیشه بعد از تغییر dependencies پاک کنید

## 🎊 نتیجه

اگر همچنان مشکل دارید:

1. **از دیتابیس آنلاین استفاده کنید** (توصیه شده)
2. **file_picker را حذف کنید** (موقت)
3. **نسخه قدیمی‌تر استفاده کنید**

**اپلیکیشن شما کار می‌کند! 🚀**
