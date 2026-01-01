-- 1. Create Database and Table
CREATE DATABASE StressTestDB;
GO
USE StressTestDB;
GO

CREATE TABLE Products (
    ProductID INT IDENTITY(1,1) PRIMARY KEY,
    ProductName NVARCHAR(100),
    Category NVARCHAR(50),
    Price DECIMAL(18,2),
    CreatedDate DATETIME DEFAULT GETDATE()
);

-- 2. Seed Data (Insert 50,000 rows)
DECLARE @i INT = 0;
WHILE @i < 50000
BEGIN
    INSERT INTO Products (ProductName, Category, Price)
    VALUES (
        'Product-' + CAST(@i AS NVARCHAR), 
        CASE WHEN @i % 5 = 0 THEN 'Electronics' ELSE 'Home' END, 
        RAND() * 100
    );
    SET @i = @i + 1;
END;
GO

-- 3. Create a "Slow" Stored Procedure (Intentionally bad performance for testing)
-- It uses LIKE with a wildcard at the start (SARGable violation) to force a Full Table Scan.
CREATE PROCEDURE GetProductsSlow
    @SearchTerm NVARCHAR(50)
AS
BEGIN
    SELECT * FROM Products 
    WHERE ProductName LIKE '%' + @SearchTerm + '%'
END;
GO