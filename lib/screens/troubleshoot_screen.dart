import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TroubleshootScreen extends StatelessWidget {
  const TroubleshootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('راهنمای عیب‌یابی'),
        backgroundColor: Colors.orange[600],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // MySQL Access Denied Error
            _buildErrorCard(
              title: 'خطای Access Denied در MySQL',
              error: '#1044 - Access denied for user to database',
              solutions: [
                '1. دیتابیس را در phpMyAdmin ایجاد کنید',
                '2. از SQLite استفاده کنید (توصیه شده)',
                '3. با پشتیبانی هاستینگ تماس بگیرید',
                '4. از دیتابیس موجود استفاده کنید',
              ],
              onCopy: () => _copyToClipboard(context, '''
CREATE DATABASE IF NOT EXISTS product_manager 
CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

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
              '''),
            ),
            
            const SizedBox(height: 16),
            
            // Excel Import Error
            _buildErrorCard(
              title: 'خطای وارد کردن فایل اکسل',
              error: 'فایل اکسل خوانده نمی‌شود',
              solutions: [
                '1. فرمت فایل را بررسی کنید (.xlsx یا .xls)',
                '2. ستون‌ها را به ترتیب صحیح قرار دهید',
                '3. داده‌های خالی را پر کنید',
                '4. از فایل نمونه استفاده کنید',
              ],
              onCopy: () => _copyToClipboard(context, '''
فرمت صحیح فایل اکسل:
ستون 1: بارکد
ستون 2: نام محصول
ستون 3: تامین کننده
ستون 4: قیمت خرید
ستون 5: قیمت اصلی
ستون 6: قیمت نهایی
ستون 7: کد تامین کننده
              '''),
            ),
            
            const SizedBox(height: 16),
            
            // Connection Error
            _buildErrorCard(
              title: 'خطای اتصال به دیتابیس',
              error: 'Cannot connect to MySQL server',
              solutions: [
                '1. MySQL Server را اجرا کنید',
                '2. اطلاعات اتصال را بررسی کنید',
                '3. پورت 3306 را بررسی کنید',
                '4. از SQLite استفاده کنید',
              ],
              onCopy: () => _copyToClipboard(context, '''
تنظیمات پیش‌فرض MySQL:
Host: localhost
Port: 3306
Username: root
Password: [رمز عبور شما]
Database: product_manager
              '''),
            ),
            
            const SizedBox(height: 16),
            
            // Barcode Display Error
            _buildErrorCard(
              title: 'خطای نمایش بارکد',
              error: 'بارکد نمایش داده نمی‌شود',
              solutions: [
                '1. بارکد را بررسی کنید (نباید خالی باشد)',
                '2. طول بارکد را بررسی کنید',
                '3. کاراکترهای غیرمجاز را حذف کنید',
                '4. اپلیکیشن را restart کنید',
              ],
              onCopy: () => _copyToClipboard(context, '''
نمونه بارکد معتبر:
1234567890123
2345678901234
3456789012345
              '''),
            ),
            
            const SizedBox(height: 24),
            
            // Quick Solutions
            Card(
              color: Colors.green[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb_outline, color: Colors.green[600]),
                        const SizedBox(width: 8),
                        Text(
                          'راه‌حل‌های سریع',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[800],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '✅ از SQLite استفاده کنید (ساده‌ترین راه)\n'
                      '✅ فایل نمونه اکسل را استفاده کنید\n'
                      '✅ اپلیکیشن را restart کنید\n'
                      '✅ اطلاعات اتصال را دوباره بررسی کنید',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Contact Support
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.support_agent, color: Colors.blue[600]),
                        const SizedBox(width: 8),
                        Text(
                          'پشتیبانی',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'اگر مشکل شما حل نشد:\n'
                      '• فایل‌های log را بررسی کنید\n'
                      '• تصاویر خطا را ذخیره کنید\n'
                      '• مراحل انجام شده را یادداشت کنید\n'
                      '• با تیم پشتیبانی تماس بگیرید',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard({
    required String title,
    required String error,
    required List<String> solutions,
    required VoidCallback onCopy,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Text(
                error,
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'monospace',
                  color: Colors.red[800],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'راه‌حل‌ها:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            ...solutions.map((solution) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                solution,
                style: const TextStyle(fontSize: 13),
              ),
            )),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onCopy,
                icon: const Icon(Icons.copy, size: 16),
                label: const Text('کپی کد SQL'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('کد SQL کپی شد'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }
}
