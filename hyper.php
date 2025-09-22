<?php
/**
 * API برای اپلیکیشن مدیریت محصولات
 * آدرس: https://blizzardping.ir/hyper.php
 * 
 * این فایل به عنوان رابط بین اپلیکیشن Flutter و دیتابیس MySQL عمل می‌کند
 */

// تنظیمات CORS برای اپلیکیشن Flutter
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');
header('Content-Type: application/json; charset=utf-8');

// مدیریت OPTIONS request
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

// تنظیمات دیتابیس
$host = 'localhost';
$dbname = 'vghzoegc_hyper'; // نام دیتابیس واقعی شما
$username = 'vghzoegc_hamed'; // نام کاربری شما
$password = 'Hamed1373r'; // رمز عبور شما

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8mb4", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    $pdo->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);
} catch(PDOException $e) {
    sendError('خطا در اتصال به دیتابیس: ' . $e->getMessage());
}

// دریافت متد HTTP
$method = $_SERVER['REQUEST_METHOD'];
$action = $_GET['action'] ?? '';

// دریافت داده‌های JSON
$input = json_decode(file_get_contents('php://input'), true);

// اگر اکشن در QueryString نبود، از بدنه JSON بگیر
if ((empty($action) || $action === '') && is_array($input) && isset($input['action']) && !empty($input['action'])) {
    $action = $input['action'];
}

// مدیریت درخواست‌ها
switch ($method) {
    case 'GET':
        handleGet($action, $_GET);
        break;
    case 'POST':
        handlePost($action, $input);
        break;
    case 'PUT':
        handlePut($action, $input);
        break;
    case 'DELETE':
        handleDelete($action, $_GET);
        break;
    default:
        sendError('متد HTTP نامعتبر');
}

/**
 * مدیریت درخواست‌های GET
 */
function handleGet($action, $params) {
    global $pdo;
    
    switch ($action) {
        case 'products':
            getProducts($params);
            break;
        case 'search':
            searchProducts($params);
            break;
        case 'product':
            getProductById($params);
            break;
        case 'barcode':
            getProductByBarcode($params);
            break;
        case 'test':
            testConnection();
            break;
        case 'stats':
            getStats();
            break;
        default:
            sendError('اکشن نامعتبر');
    }
}

/**
 * مدیریت درخواست‌های POST
 */
function handlePost($action, $data) {
    global $pdo;
    
    switch ($action) {
        case 'product':
            createProduct($data);
            break;
        case 'products':
            createProducts($data);
            break;
        default:
            sendError('اکشن نامعتبر');
    }
}

/**
 * نرمال‌سازی و تبدیل مقادیر ورودی محصول (از اکسل/JSON)
 */
function normalizeProductInput($raw) {
    $out = [];
    // Trim همه رشته‌ها
    foreach ($raw as $k => $v) {
        if (is_string($v)) {
            $out[$k] = trim($v);
        } else {
            $out[$k] = $v;
        }
    }

    // تبدیل اعداد متنی با ویرگول به عدد اعشاری
    $num = function($val) {
        if ($val === null || $val === '') return 0.0;
        if (is_numeric($val)) return (float)$val;
        if (is_string($val)) {
            $clean = str_replace([',', '٬', ' '], '', $val);
            return is_numeric($clean) ? (float)$clean : 0.0;
        }
        return 0.0;
    };

    $out['purchase_price']   = $num($out['purchase_price']   ?? 0);
    $out['original_price']   = $num($out['original_price']   ?? 0);
    $out['discounted_price'] = $num($out['discounted_price'] ?? 0);

    // supplier_code را به رشته تبدیل کن (VARCHAR)
    if (!isset($out['supplier_code']) || $out['supplier_code'] === null) {
        $out['supplier_code'] = '';
    } else {
        $out['supplier_code'] = (string)$out['supplier_code'];
    }

    // barcode و product_name باید وجود داشته باشند
    $out['barcode'] = isset($out['barcode']) ? (string)$out['barcode'] : '';
    $out['product_name'] = isset($out['product_name']) ? (string)$out['product_name'] : '';
    $out['supplier'] = isset($out['supplier']) ? (string)$out['supplier'] : '';

    return $out;
}

/**
 * مدیریت درخواست‌های PUT
 */
function handlePut($action, $data) {
    global $pdo;
    
    switch ($action) {
        case 'product':
            updateProduct($data);
            break;
        default:
            sendError('اکشن نامعتبر');
    }
}

/**
 * مدیریت درخواست‌های DELETE
 */
function handleDelete($action, $params) {
    global $pdo;
    
    switch ($action) {
        case 'product':
            deleteProduct($params);
            break;
        default:
            sendError('اکشن نامعتبر');
    }
}

/**
 * دریافت تمام محصولات
 */
function getProducts($params) {
    global $pdo;
    
    try {
        $page = $params['page'] ?? 1;
        $limit = $params['limit'] ?? 50;
        $offset = ($page - 1) * $limit;
        
        $stmt = $pdo->prepare("
            SELECT * FROM products 
            ORDER BY created_at DESC 
            LIMIT :limit OFFSET :offset
        ");
        $stmt->bindParam(':limit', $limit, PDO::PARAM_INT);
        $stmt->bindParam(':offset', $offset, PDO::PARAM_INT);
        $stmt->execute();
        
        $products = $stmt->fetchAll();
        
        // شمارش کل محصولات
        $countStmt = $pdo->query("SELECT COUNT(*) as total FROM products");
        $total = $countStmt->fetch()['total'];
        
        sendSuccess([
            'products' => $products,
            'total' => $total,
            'page' => $page,
            'limit' => $limit
        ]);
        
    } catch(PDOException $e) {
        sendError('خطا در دریافت محصولات: ' . $e->getMessage());
    }
}

/**
 * جستجو در محصولات
 */
function searchProducts($params) {
    global $pdo;
    
    try {
        $query = $params['q'] ?? '';
        $page = $params['page'] ?? 1;
        $limit = $params['limit'] ?? 50;
        $offset = ($page - 1) * $limit;
        
        if (empty($query)) {
            getProducts($params);
            return;
        }
        
        $searchTerm = "%$query%";
        
        $stmt = $pdo->prepare("
            SELECT * FROM products 
            WHERE barcode LIKE :query 
               OR product_name LIKE :query 
               OR supplier LIKE :query 
               OR supplier_code LIKE :query
            ORDER BY created_at DESC 
            LIMIT :limit OFFSET :offset
        ");
        $stmt->bindParam(':query', $searchTerm);
        $stmt->bindParam(':limit', $limit, PDO::PARAM_INT);
        $stmt->bindParam(':offset', $offset, PDO::PARAM_INT);
        $stmt->execute();
        
        $products = $stmt->fetchAll();
        
        // شمارش نتایج جستجو
        $countStmt = $pdo->prepare("
            SELECT COUNT(*) as total FROM products 
            WHERE barcode LIKE :query 
               OR product_name LIKE :query 
               OR supplier LIKE :query 
               OR supplier_code LIKE :query
        ");
        $countStmt->bindParam(':query', $searchTerm);
        $countStmt->execute();
        $total = $countStmt->fetch()['total'];
        
        sendSuccess([
            'products' => $products,
            'total' => $total,
            'query' => $query,
            'page' => $page,
            'limit' => $limit
        ]);
        
    } catch(PDOException $e) {
        sendError('خطا در جستجو: ' . $e->getMessage());
    }
}

/**
 * دریافت محصول بر اساس ID
 */
function getProductById($params) {
    global $pdo;
    
    try {
        $id = $params['id'] ?? '';
        
        if (empty($id)) {
            sendError('ID محصول الزامی است');
            return;
        }
        
        $stmt = $pdo->prepare("SELECT * FROM products WHERE id = :id");
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();
        
        $product = $stmt->fetch();
        
        if ($product) {
            sendSuccess(['product' => $product]);
        } else {
            sendError('محصول یافت نشد');
        }
        
    } catch(PDOException $e) {
        sendError('خطا در دریافت محصول: ' . $e->getMessage());
    }
}

/**
 * دریافت محصول بر اساس بارکد
 */
function getProductByBarcode($params) {
    global $pdo;
    
    try {
        $barcode = $params['barcode'] ?? '';
        
        if (empty($barcode)) {
            sendError('بارکد الزامی است');
            return;
        }
        
        $stmt = $pdo->prepare("SELECT * FROM products WHERE barcode = :barcode");
        $stmt->bindParam(':barcode', $barcode);
        $stmt->execute();
        
        $product = $stmt->fetch();
        
        if ($product) {
            sendSuccess(['product' => $product]);
        } else {
            sendError('محصول با این بارکد یافت نشد');
        }
        
    } catch(PDOException $e) {
        sendError('خطا در دریافت محصول: ' . $e->getMessage());
    }
}

/**
 * ایجاد محصول جدید
 */
function createProduct($data) {
    global $pdo;
    
    try {
        // نرمال‌سازی
        $data = normalizeProductInput($data);

        // اعتبارسنجی حداقلی
        if ($data['barcode'] === '' || $data['product_name'] === '') {
            sendError('بارکد و نام محصول الزامی است');
            return;
        }
        
        // بررسی تکراری نبودن بارکد
        $checkStmt = $pdo->prepare("SELECT id FROM products WHERE barcode = :barcode");
        $checkStmt->bindParam(':barcode', $data['barcode']);
        $checkStmt->execute();
        
        if ($checkStmt->fetch()) {
            sendError('محصولی با این بارکد قبلاً وجود دارد');
            return;
        }
        
        $stmt = $pdo->prepare("
            INSERT INTO products (barcode, product_name, supplier, purchase_price, original_price, discounted_price, supplier_code) 
            VALUES (:barcode, :product_name, :supplier, :purchase_price, :original_price, :discounted_price, :supplier_code)
        ");
        
        $stmt->bindParam(':barcode', $data['barcode']);
        $stmt->bindParam(':product_name', $data['product_name']);
        $stmt->bindParam(':supplier', $data['supplier']);
        $stmt->bindParam(':purchase_price', $data['purchase_price']);
        $stmt->bindParam(':original_price', $data['original_price']);
        $stmt->bindParam(':discounted_price', $data['discounted_price']);
        $stmt->bindParam(':supplier_code', $data['supplier_code']);
        
        $stmt->execute();
        
        $productId = $pdo->lastInsertId();
        
        sendSuccess([
            'message' => 'محصول با موفقیت ایجاد شد',
            'product_id' => $productId
        ]);
        
    } catch(PDOException $e) {
        sendError('خطا در ایجاد محصول: ' . $e->getMessage());
    }
}

/**
 * ایجاد چندین محصول (برای وارد کردن از اکسل)
 */
function createProducts($data) {
    global $pdo;
    
    try {
        if (!isset($data['products']) || !is_array($data['products'])) {
            sendError('لیست محصولات الزامی است');
            return;
        }
        
        $products = $data['products'];
        $insertedIds = [];
        $errors = [];
        
        $pdo->beginTransaction();
        
        foreach ($products as $index => $product) {
            try {
                // نرمال‌سازی
                $product = normalizeProductInput($product);

                // اعتبارسنجی حداقلی هر ردیف
                if ($product['barcode'] === '' || $product['product_name'] === '') {
                    $errors[] = "ردیف " . ($index + 1) . ": بارکد و نام محصول الزامی است";
                    continue;
                }
                
                // بررسی تکراری نبودن بارکد
                $checkStmt = $pdo->prepare("SELECT id FROM products WHERE barcode = :barcode");
                $checkStmt->bindParam(':barcode', $product['barcode']);
                $checkStmt->execute();
                
                if ($checkStmt->fetch()) {
                    $errors[] = "ردیف " . ($index + 1) . ": محصولی با این بارکد قبلاً وجود دارد";
                    continue;
                }
                
                $stmt = $pdo->prepare("
                    INSERT INTO products (barcode, product_name, supplier, purchase_price, original_price, discounted_price, supplier_code) 
                    VALUES (:barcode, :product_name, :supplier, :purchase_price, :original_price, :discounted_price, :supplier_code)
                ");
                
                $stmt->bindParam(':barcode', $product['barcode']);
                $stmt->bindParam(':product_name', $product['product_name']);
                $stmt->bindParam(':supplier', $product['supplier']);
                $stmt->bindParam(':purchase_price', $product['purchase_price']);
                $stmt->bindParam(':original_price', $product['original_price']);
                $stmt->bindParam(':discounted_price', $product['discounted_price']);
                $stmt->bindParam(':supplier_code', $product['supplier_code']);
                
                $stmt->execute();
                $insertedIds[] = $pdo->lastInsertId();
                
            } catch(PDOException $e) {
                $errors[] = "ردیف " . ($index + 1) . ": " . $e->getMessage();
            }
        }
        
        $pdo->commit();

        sendSuccess([
            'message' => 'وارد کردن محصولات تکمیل شد',
            'inserted_count' => count($insertedIds),
            'total_count' => count($products),
            'inserted_ids' => $insertedIds,
            'errors' => $errors
        ]);
        
    } catch(PDOException $e) {
        $pdo->rollBack();
        sendError('خطا در وارد کردن محصولات: ' . $e->getMessage());
    }
}

/**
 * بروزرسانی محصول
 */
function updateProduct($data) {
    global $pdo;
    
    try {
        if (!isset($data['id']) || empty($data['id'])) {
            sendError('ID محصول الزامی است');
            return;
        }
        
        $id = $data['id'];
        
        // بررسی وجود محصول
        $checkStmt = $pdo->prepare("SELECT id FROM products WHERE id = :id");
        $checkStmt->bindParam(':id', $id, PDO::PARAM_INT);
        $checkStmt->execute();
        
        if (!$checkStmt->fetch()) {
            sendError('محصول یافت نشد');
            return;
        }
        
        // اعتبارسنجی داده‌ها
        $requiredFields = ['barcode', 'product_name', 'supplier', 'purchase_price', 'original_price', 'discounted_price', 'supplier_code'];
        
        foreach ($requiredFields as $field) {
            if (!isset($data[$field]) || empty($data[$field])) {
                sendError("فیلد $field الزامی است");
                return;
            }
        }
        
        // بررسی تکراری نبودن بارکد (به جز خود محصول)
        $checkBarcodeStmt = $pdo->prepare("SELECT id FROM products WHERE barcode = :barcode AND id != :id");
        $checkBarcodeStmt->bindParam(':barcode', $data['barcode']);
        $checkBarcodeStmt->bindParam(':id', $id, PDO::PARAM_INT);
        $checkBarcodeStmt->execute();
        
        if ($checkBarcodeStmt->fetch()) {
            sendError('محصولی با این بارکد قبلاً وجود دارد');
            return;
        }
        
        $stmt = $pdo->prepare("
            UPDATE products 
            SET barcode = :barcode, 
                product_name = :product_name, 
                supplier = :supplier, 
                purchase_price = :purchase_price, 
                original_price = :original_price, 
                discounted_price = :discounted_price, 
                supplier_code = :supplier_code,
                updated_at = CURRENT_TIMESTAMP
            WHERE id = :id
        ");
        
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->bindParam(':barcode', $data['barcode']);
        $stmt->bindParam(':product_name', $data['product_name']);
        $stmt->bindParam(':supplier', $data['supplier']);
        $stmt->bindParam(':purchase_price', $data['purchase_price']);
        $stmt->bindParam(':original_price', $data['original_price']);
        $stmt->bindParam(':discounted_price', $data['discounted_price']);
        $stmt->bindParam(':supplier_code', $data['supplier_code']);
        
        $stmt->execute();
        
        sendSuccess([
            'message' => 'محصول با موفقیت بروزرسانی شد',
            'product_id' => $id
        ]);
        
    } catch(PDOException $e) {
        sendError('خطا در بروزرسانی محصول: ' . $e->getMessage());
    }
}

/**
 * حذف محصول
 */
function deleteProduct($params) {
    global $pdo;
    
    try {
        $id = $params['id'] ?? '';
        
        if (empty($id)) {
            sendError('ID محصول الزامی است');
            return;
        }
        
        // بررسی وجود محصول
        $checkStmt = $pdo->prepare("SELECT id FROM products WHERE id = :id");
        $checkStmt->bindParam(':id', $id, PDO::PARAM_INT);
        $checkStmt->execute();
        
        if (!$checkStmt->fetch()) {
            sendError('محصول یافت نشد');
            return;
        }
        
        $stmt = $pdo->prepare("DELETE FROM products WHERE id = :id");
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();
        
        sendSuccess([
            'message' => 'محصول با موفقیت حذف شد',
            'product_id' => $id
        ]);
        
    } catch(PDOException $e) {
        sendError('خطا در حذف محصول: ' . $e->getMessage());
    }
}

/**
 * تست اتصال
 */
function testConnection() {
    global $pdo;
    
    try {
        $stmt = $pdo->query("SELECT COUNT(*) as total FROM products");
        $result = $stmt->fetch();
        
        sendSuccess([
            'message' => 'اتصال به دیتابیس موفق است',
            'total_products' => $result['total'],
            'server_time' => date('Y-m-d H:i:s')
        ]);
        
    } catch(PDOException $e) {
        sendError('خطا در اتصال به دیتابیس: ' . $e->getMessage());
    }
}

/**
 * ارسال پاسخ موفق
 */
function sendSuccess($data) {
    http_response_code(200);
    echo json_encode([
        'success' => true,
        'data' => $data
    ], JSON_UNESCAPED_UNICODE);
    exit();
}

/**
 * ارسال پاسخ خطا
 */
function sendError($message) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'error' => $message
    ], JSON_UNESCAPED_UNICODE);
    exit();
}

/**
 * ایجاد جدول products (اگر وجود ندارد)
 */
function createTableIfNotExists() {
    global $pdo;
    
    try {
        $sql = "
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
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
        ";
        
        $pdo->exec($sql);
        
    } catch(PDOException $e) {
        // جدول احتمالاً قبلاً ایجاد شده
    }
}

/**
 * دریافت آمار دیتابیس
 */
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

// ایجاد جدول در صورت عدم وجود
createTableIfNotExists();

?>
