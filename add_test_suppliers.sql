-- Add test suppliers and products to verify the fix
INSERT INTO products (barcode, product_name, supplier, purchase_price, original_price, discounted_price, supplier_code) VALUES
('123456789', 'Test Product 1', 'Supplier A', 10.00, 15.00, 12.00, 'SUP001'),
('234567890', 'Test Product 2', 'Supplier A', 20.00, 25.00, 22.00, 'SUP002'),
('345678901', 'Test Product 3', 'Supplier B', 30.00, 35.00, 32.00, 'SUP003'),
('456789012', 'Test Product 4', 'Supplier B', 40.00, 45.00, 42.00, 'SUP004'),
('567890123', 'Test Product 5', 'Supplier C', 50.00, 55.00, 52.00, 'SUP005');

-- Verify the suppliers are found
SELECT DISTINCT TRIM(supplier) as supplier FROM products WHERE supplier IS NOT NULL AND TRIM(supplier) != "" ORDER BY TRIM(supplier);

-- Verify product counts per supplier
SELECT TRIM(supplier) as supplier, COUNT(*) as product_count 
FROM products 
WHERE supplier IS NOT NULL AND TRIM(supplier) != "" 
GROUP BY TRIM(supplier) 
ORDER BY TRIM(supplier);