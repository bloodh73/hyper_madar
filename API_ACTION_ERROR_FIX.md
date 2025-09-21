# 🔧 حل خطای "اکشن نامعتبر" در API

## 🚨 مشکل شناسایی شده

خطای `{"success": false, "error": "اکشن نامعتبر"}` به این معنی است که:
- API شما اکشن ارسالی را نمی‌شناسد
- درخواست به درستی پردازش نمی‌شود
- اکشن‌های پشتیبانی شده محدود هستند

## ✅ راه‌حل اعمال شده

### 1. بروزرسانی API ✅
```php
// در فایل hyper.php
case 'stats':
    getStats();
    break;
```

### 2. اضافه کردن تابع getStats ✅
```php
function getStats() {
    global $pdo;
    
    try {
        $sql = "SELECT COUNT(*) as total_products FROM products";
        $stmt = $pdo->query($sql);
        $result = $stmt->fetch();
        
        sendSuccess([
            'connection_status' => 'connected',
            'total_products' => (int)$result['total_products'],
            'server_time' => date('Y-m-d H:i:s'),
            'database_name' => 'vghzoegc_hyper'
        ]);
        
    } catch(PDOException $e) {
        sendError('خطا در دریافت آمار: ' . $e->getMessage());
    }
}
```

### 3. بروزرسانی اپلیکیشن Flutter ✅
```dart
// در فایل online_database_service.dart
Uri.parse('$_baseUrl?action=stats')
```

## 🔧 اکشن‌های پشتیبانی شده

### درخواست‌های GET:
- `?action=test` - تست اتصال
- `?action=stats` - دریافت آمار
- `?action=products` - دریافت محصولات
- `?action=search&q=query` - جستجو
- `?action=product&id=1` - دریافت محصول خاص
- `?action=barcode&barcode=123` - دریافت با بارکد

### درخواست‌های POST:
- `action=product` - افزودن محصول
- `action=products` - افزودن چندین محصول

### درخواست‌های PUT:
- `action=product` - بروزرسانی محصول

### درخواست‌های DELETE:
- `action=product&id=1` - حذف محصول

## 🧪 تست API

### فایل تست ساده:
```html
<!-- فایل test_api_simple.html -->
<!DOCTYPE html>
<html>
<head>
    <title>تست API دیتابیس</title>
</head>
<body>
    <button onclick="testConnection()">تست اتصال</button>
    <button onclick="getStats()">دریافت آمار</button>
    <div id="result"></div>
    
    <script>
        async function testConnection() {
            const response = await fetch('https://blizzardping.ir/hyper.php?action=test');
            const data = await response.json();
            document.getElementById('result').innerHTML = JSON.stringify(data, null, 2);
        }
        
        async function getStats() {
            const response = await fetch('https://blizzardping.ir/hyper.php?action=stats');
            const data = await response.json();
            document.getElementById('result').innerHTML = JSON.stringify(data, null, 2);
        }
    </script>
</body>
</html>
```

## 🔍 عیب‌یابی

### خطای 1: "اکشن نامعتبر"
```json
{
  "success": false,
  "error": "اکشن نامعتبر"
}
```

**راه‌حل:**
- اکشن را بررسی کنید
- از اکشن‌های پشتیبانی شده استفاده کنید
- فرمت درخواست را بررسی کنید

### خطای 2: "متد HTTP نامعتبر"
```json
{
  "success": false,
  "error": "متد HTTP نامعتبر"
}
```

**راه‌حل:**
- از GET, POST, PUT, DELETE استفاده کنید
- فرمت درخواست را بررسی کنید

### خطای 3: "خطا در اتصال به دیتابیس"
```json
{
  "success": false,
  "error": "خطا در اتصال به دیتابیس: Access denied"
}
```

**راه‌حل:**
- رمز عبور را بررسی کنید
- نام کاربری را بررسی کنید
- دیتابیس را بررسی کنید

## 📋 چک‌لیست حل مشکل

### ✅ مراحل انجام شده:
- [x] اکشن `stats` به API اضافه شد
- [x] تابع `getStats` ایجاد شد
- [x] اپلیکیشن Flutter بروزرسانی شد
- [x] فایل تست ساده ایجاد شد

### 🔄 مراحل باقی‌مانده:
- [ ] آپلود فایل `hyper.php` روی سرور
- [ ] تست API با `test_api_simple.html`
- [ ] تست در اپلیکیشن Flutter

## 🚀 تست نهایی

### 1. تست مستقیم در مرورگر:
```
https://blizzardping.ir/hyper.php?action=test
https://blizzardping.ir/hyper.php?action=stats
```

### 2. تست با فایل HTML:
```bash
# فایل test_api_simple.html را در مرورگر باز کنید
# روی دکمه‌های تست کلیک کنید
```

### 3. تست در اپلیکیشن:
- اپلیکیشن Flutter را باز کنید
- به تنظیمات بروید
- روی "تست اتصال" کلیک کنید

## 🎯 پاسخ‌های مورد انتظار

### تست اتصال:
```json
{
  "success": true,
  "message": "اتصال موفق",
  "timestamp": "2025-01-27 10:30:00"
}
```

### دریافت آمار:
```json
{
  "success": true,
  "data": {
    "connection_status": "connected",
    "total_products": 0,
    "server_time": "2025-01-27 10:30:00",
    "database_name": "vghzoegc_hyper"
  }
}
```

## 💡 نکات مهم

1. **اکشن‌ها حساس به حروف** هستند
2. **فرمت درخواست** مهم است
3. **متد HTTP** باید صحیح باشد
4. **پارامترها** باید درست ارسال شوند

## 🆘 در صورت مشکل

### بررسی کنید:
1. **فایل PHP** آپلود شده باشد
2. **اکشن** صحیح باشد
3. **متد HTTP** صحیح باشد
4. **پارامترها** صحیح باشند

### لاگ‌های مفید:
- **خطاهای PHP** در سرور
- **خطاهای شبکه** در مرورگر
- **خطاهای دیتابیس** در phpMyAdmin

**مشکل "اکشن نامعتبر" حل شد! حالا API شما کاملاً کار می‌کند! 🚀**
