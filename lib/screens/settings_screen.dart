import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../services/online_database_service.dart';
import 'troubleshoot_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _hostController = TextEditingController(text: 'localhost');
  final _portController = TextEditingController(text: '3306');
  final _userController = TextEditingController(text: 'root');
  final _passwordController = TextEditingController();
  final _dbNameController = TextEditingController(text: 'product_manager');

  bool _isConnecting = false;
  bool _isTestingOnline = false;
  Map<String, dynamic>? _onlineStats;

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    _userController.dispose();
    _passwordController.dispose();
    _dbNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تنظیمات دیتابیس'),
        backgroundColor: Colors.purple[600],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Database Type Selection
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'نوع دیتابیس',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: RadioListTile<bool>(
                                title: const Text('دیتابیس آنلاین'),
                                subtitle: const Text('توصیه شده'),
                                value: true,
                                groupValue: productProvider.useOnline,
                                onChanged: (value) async {
                                  if (value != null && value != productProvider.useOnline) {
                                    await productProvider.toggleOnlineDatabase();
                                  }
                                },
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<bool>(
                                title: const Text('SQLite (محلی)'),
                                subtitle: const Text('دیتابیس محلی'),
                                value: false,
                                groupValue: productProvider.useOnline,
                                onChanged: (value) async {
                                  if (value != null && value != productProvider.useOnline) {
                                    await productProvider.toggleOnlineDatabase();
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // دیتابیس آنلاین
                        Card(
                          color: Colors.purple[50],
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.cloud, color: Colors.purple[600]),
                                    const SizedBox(width: 8),
                                    Text(
                                      'دیتابیس آنلاین',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.purple[800],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'آدرس: https://blizzardping.ir/hyper.php',
                                  style: TextStyle(fontSize: 12),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: _isTestingOnline ? null : _testOnlineConnection,
                                        icon: _isTestingOnline
                                            ? const SizedBox(
                                                width: 16,
                                                height: 16,
                                                child: CircularProgressIndicator(strokeWidth: 2),
                                              )
                                            : const Icon(Icons.cloud_done),
                                        label: Text(_isTestingOnline ? 'در حال تست...' : 'تست اتصال'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.purple[600],
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () => _showOnlineStats(),
                                        icon: const Icon(Icons.info_outline),
                                        label: const Text('آمار'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue[600],
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (_onlineStats != null) ...[
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.green[50],
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.green[200]!),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'وضعیت: ${_onlineStats!['connection_status'] == 'connected' ? 'متصل' : 'قطع'}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: _onlineStats!['connection_status'] == 'connected' 
                                                ? Colors.green[800] 
                                                : Colors.red[800],
                                          ),
                                        ),
                                        if (_onlineStats!['total_products'] != null)
                                          Text('تعداد محصولات: ${_onlineStats!['total_products']}'),
                                        if (_onlineStats!['server_time'] != null)
                                          Text('زمان سرور: ${_onlineStats!['server_time']}'),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Current Status
                Card(
                  color: productProvider.useMySQL ? Colors.green[50] : Colors.blue[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          productProvider.useMySQL ? Icons.cloud_done : Icons.storage,
                          color: productProvider.useMySQL ? Colors.green[600] : Colors.blue[600],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                productProvider.useMySQL ? 'متصل به MySQL' : 'استفاده از SQLite',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: productProvider.useMySQL ? Colors.green[800] : Colors.blue[800],
                                ),
                              ),
                              Text(
                                productProvider.useMySQL 
                                    ? 'دیتابیس سرور فعال است' 
                                    : 'دیتابیس محلی فعال است',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: productProvider.useMySQL ? Colors.green[600] : Colors.blue[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (productProvider.useMySQL)
                          IconButton(
                            icon: const Icon(Icons.link_off),
                            onPressed: () async {
                              await productProvider.disconnectFromMySQL();
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('اتصال به MySQL قطع شد'),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                              }
                            },
                            tooltip: 'قطع اتصال',
                          ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // MySQL Connection Button
                if (!productProvider.useMySQL)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _isConnecting ? null : () => _showMySQLConnectionDialog(),
                      icon: const Icon(Icons.cloud),
                      label: const Text('اتصال به MySQL'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[600],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                
                if (productProvider.error.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Card(
                    color: Colors.red[50],
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red[600]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              productProvider.error,
                              style: TextStyle(color: Colors.red[800]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                
                const SizedBox(height: 24),
                
                // Instructions
                Card(
                  color: Colors.amber[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.amber[800]),
                            const SizedBox(width: 8),
                            Text(
                              'راهنمای اتصال به MySQL',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber[800],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          '1. مطمئن شوید که MySQL Server نصب و اجرا است\n'
                          '2. دیتابیس product_manager را ایجاد کنید\n'
                          '3. اطلاعات اتصال را وارد کنید\n'
                          '4. روی دکمه اتصال کلیک کنید',
                          style: TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const TroubleshootScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.bug_report),
                            label: const Text('راهنمای عیب‌یابی'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange[600],
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showMySQLConnectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تنظیمات اتصال MySQL'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _hostController,
                decoration: const InputDecoration(
                  labelText: 'Host',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _portController,
                decoration: const InputDecoration(
                  labelText: 'Port',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _userController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _dbNameController,
                decoration: const InputDecoration(
                  labelText: 'Database Name',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('انصراف'),
          ),
          ElevatedButton(
            onPressed: _isConnecting ? null : _connectToMySQL,
            child: _isConnecting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('اتصال'),
          ),
        ],
      ),
    );
  }

  Future<void> _connectToMySQL() async {
    setState(() {
      _isConnecting = true;
    });

    try {
      final productProvider = context.read<ProductProvider>();
      bool success = await productProvider.connectToMySQL();
      
      if (mounted) {
        Navigator.pop(context);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('اتصال به MySQL موفقیت‌آمیز بود'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(productProvider.error.isNotEmpty 
                  ? productProvider.error 
                  : 'خطا در اتصال به MySQL'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطا: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isConnecting = false;
        });
      }
    }
  }

  Future<void> _testOnlineConnection() async {
    if (!mounted) return;
    
    setState(() {
      _isTestingOnline = true;
    });

    try {
      final onlineService = OnlineDatabaseService();
      final stats = await onlineService.getStats();
      
      if (mounted) {
        setState(() {
          _onlineStats = stats;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              stats['connection_status'] == 'connected' 
                  ? 'اتصال به دیتابیس آنلاین موفق است' 
                  : 'خطا در اتصال به دیتابیس آنلاین'
            ),
            backgroundColor: stats['connection_status'] == 'connected' 
                ? Colors.green 
                : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _onlineStats = {
            'connection_status': 'disconnected',
            'error': e.toString(),
          };
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطا در اتصال: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isTestingOnline = false;
        });
      }
    }
  }

  void _showOnlineStats() {
    if (_onlineStats == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ابتدا اتصال را تست کنید'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('آمار دیتابیس آنلاین'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('وضعیت: ${_onlineStats!['connection_status'] == 'connected' ? 'متصل' : 'قطع'}'),
            if (_onlineStats!['total_products'] != null)
              Text('تعداد محصولات: ${_onlineStats!['total_products']}'),
            if (_onlineStats!['server_time'] != null)
              Text('زمان سرور: ${_onlineStats!['server_time']}'),
            if (_onlineStats!['error'] != null)
              Text('خطا: ${_onlineStats!['error']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('بستن'),
          ),
        ],
      ),
    );
  }
}
