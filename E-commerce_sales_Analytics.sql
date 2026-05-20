-- =========================================
-- E-COMMERCE SALES ANALYTICS SYSTEM
-- =========================================

-- Create Database
CREATE DATABASE IF NOT EXISTS EcommerceAnalyticsDB;

USE EcommerceAnalyticsDB;

-- =========================================
-- 1. CUSTOMERS TABLE
-- =========================================
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    FullName VARCHAR(120),
    Email VARCHAR(120),
    Phone VARCHAR(30),
    City VARCHAR(60),
    State VARCHAR(60),
    RegistrationDate DATE
);

INSERT INTO Customers VALUES
(1, 'Adebayo Ade', 'adebayo@gmail.com', '08031234567', 'Lagos', 'Lagos', '2024-01-10'),
(2, 'Fatima Musa', 'fatima@gmail.com', '08124567890', 'Kano', 'Kano', '2024-01-12'),
(3, 'Chidinma Okoro', 'chidinma@gmail.com', '07061234588', 'Enugu', 'Enugu', '2024-01-15'),
(4, 'Emeka Nwosu', 'emeka@gmail.com', '09027894561', 'Onitsha', 'Anambra', '2024-01-18'),
(5, 'Halima Abubakar', 'halima@gmail.com', '09134567210', 'Kaduna', 'Kaduna', '2024-01-20');

-- =========================================
-- 2. PRODUCTS TABLE
-- =========================================
CREATE TABLE Products (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(150),
    Category VARCHAR(80),
    Price DECIMAL(10,2),
    Stock INT,
    Supplier VARCHAR(120)
);

INSERT INTO Products VALUES
(1, 'Laptop HP ProBook', 'Electronics', 450000, 20, 'HP Nigeria'),
(2, 'iPhone 13', 'Electronics', 520000, 15, 'Apple Store NG'),
(3, 'Samsung TV 55"', 'Electronics', 380000, 10, 'Samsung NG'),
(4, 'Office Chair', 'Furniture', 45000, 50, 'HomeComfort'),
(5, 'Standing Desk', 'Furniture', 120000, 25, 'OfficePlus');

-- =========================================
-- 3. ORDERS TABLE
-- =========================================
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerID INT,
    OrderDate DATE,
    PaymentMethod VARCHAR(50),
    ShippingCity VARCHAR(60),
    ShippingState VARCHAR(60),
    OrderStatus VARCHAR(50),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

INSERT INTO Orders VALUES
(1, 1, '2024-02-01', 'Card', 'Lagos', 'Lagos', 'Completed'),
(2, 2, '2024-02-03', 'Transfer', 'Kano', 'Kano', 'Completed'),
(3, 3, '2024-02-05', 'Cash', 'Enugu', 'Enugu', 'Completed'),
(4, 4, '2024-02-07', 'Card', 'Onitsha', 'Anambra', 'Pending'),
(5, 5, '2024-02-10', 'Card', 'Kaduna', 'Kaduna', 'Completed');

-- =========================================
-- 4. ORDER ITEMS TABLE
-- =========================================
CREATE TABLE OrderItems (
    OrderItemID INT PRIMARY KEY,
    OrderID INT,
    ProductID INT,
    Quantity INT,
    UnitPrice DECIMAL(10,2),
    LineTotal DECIMAL(12,2),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

INSERT INTO OrderItems VALUES
(1, 1, 1, 1, 450000, 450000),
(2, 2, 2, 1, 520000, 520000),
(3, 3, 4, 2, 45000, 90000),
(4, 4, 3, 1, 380000, 380000),
(5, 5, 5, 1, 120000, 120000);

-- =========================================
-- 5. PAYMENTS TABLE (ADVANCED FEATURE)
-- =========================================
CREATE TABLE Payments (
    PaymentID INT PRIMARY KEY,
    OrderID INT,
    PaymentDate DATE,
    PaymentMethod VARCHAR(50),
    PaymentStatus VARCHAR(50),
    Amount DECIMAL(12,2),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);

INSERT INTO Payments VALUES
(1, 1, '2024-02-01', 'Card', 'Paid', 450000),
(2, 2, '2024-02-03', 'Transfer', 'Paid', 520000),
(3, 3, '2024-02-05', 'Cash', 'Paid', 90000),
(4, 4, '2024-02-07', 'Card', 'Pending', 380000),
(5, 5, '2024-02-10', 'Card', 'Paid', 120000);

-- =========================================
-- BASIC KPIs
-- =========================================

-- Total Customers
SELECT COUNT(*) AS TotalCustomers FROM Customers;

-- Total Orders
SELECT COUNT(*) AS TotalOrders FROM Orders;

-- Total Revenue
SELECT SUM(Amount) AS TotalRevenue FROM Payments WHERE PaymentStatus = 'Paid';

-- =========================================
-- ADVANCED ANALYTICS (RECRUITER LEVEL)
-- =========================================

-- 1. CUSTOMER LIFETIME VALUE (CLV)
SELECT
    c.CustomerID,
    c.FullName,
    SUM(p.Amount) AS LifetimeValue
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
JOIN Payments p ON o.OrderID = p.OrderID
WHERE p.PaymentStatus = 'Paid'
GROUP BY c.CustomerID, c.FullName
ORDER BY LifetimeValue DESC;

-- 2. TOP CUSTOMERS (RANKING)
SELECT
    c.FullName,
    SUM(p.Amount) AS TotalSpent,
    RANK() OVER (ORDER BY SUM(p.Amount) DESC) AS CustomerRank
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
JOIN Payments p ON o.OrderID = p.OrderID
GROUP BY c.FullName;

-- 3. MONTHLY REVENUE TREND (CTE)
WITH MonthlyRevenue AS (
    SELECT
        DATE_FORMAT(PaymentDate, '%Y-%m') AS Month,
        SUM(Amount) AS Revenue
    FROM Payments
    WHERE PaymentStatus = 'Paid'
    GROUP BY Month
)
SELECT * FROM MonthlyRevenue;

-- 4. PRODUCT PERFORMANCE
SELECT
    p.ProductName,
    SUM(oi.Quantity) AS UnitsSold,
    SUM(oi.LineTotal) AS RevenueGenerated
FROM OrderItems oi
JOIN Products p ON oi.ProductID = p.ProductID
GROUP BY p.ProductName
ORDER BY RevenueGenerated DESC;

-- 5. PAYMENT METHOD ANALYSIS
SELECT
    PaymentMethod,
    COUNT(*) AS Transactions,
    SUM(Amount) AS TotalValue
FROM Payments
GROUP BY PaymentMethod;

-- 6. RUNNING TOTAL SALES (WINDOW FUNCTION)
SELECT
    PaymentDate,
    Amount,
    SUM(Amount) OVER (ORDER BY PaymentDate) AS RunningTotal
FROM Payments
WHERE PaymentStatus = 'Paid';