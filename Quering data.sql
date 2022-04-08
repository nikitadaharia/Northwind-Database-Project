--*************************************************************************--
-- Title: Assignment03 
-- Desc: This script demonstrates querying data to get relevant information
-- Dev: NikitaDaharia
-- Change Log: When,Who,What
-- 2022-02-01,NikitaDahria,Created Assignment03_NikitaDaharia.sql
--**************************************************************************--

Use Master;
go
If exists (Select *
From sysdatabases
Where name='Assignment03DB_NikitaDaharia')
	Begin
	Use [master];
	Alter Database Assignment03DB_NikitaDaharia Set Single_User With Rollback Immediate;
	-- Kick everyone out of the DB
	Drop Database Assignment03DB_NikitaDaharia;
End
go
Create Database Assignment03DB_NikitaDaharia;
go
Use Assignment03DB_NikitaDaharia
go

Create Table Categories
(
	[CategoryID] [int] IDENTITY(1,1) NOT NULL
,
	[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
(
	[ProductID] [int] IDENTITY(1,1) NOT NULL
,
	[ProductName] [nvarchar](100) NOT NULL
,
	[ProductCurrentPrice] [money] NOT NULL
,
	[CategoryID] [int] NULL
);
go

Create Table Inventories
(
	[InventoryID] [int] IDENTITY(1,1) NOT NULL
,
	[InventoryDate] [Date] NOT NULL
,
	[InventoryCount] [int] NULL
,
	[ProductID] [int] NOT NULL
);
go


ALTER TABLE dbo.Categories
	ADD CONSTRAINT pkCategories PRIMARY KEY CLUSTERED (CategoryID);
go
ALTER TABLE dbo.Categories 
	ADD CONSTRAINT uCategoryName UNIQUE NonCLUSTERED (CategoryName);
go

ALTER TABLE dbo.Products
	ADD CONSTRAINT pkProducts PRIMARY KEY CLUSTERED (ProductID);
go
ALTER TABLE dbo.Products
	ADD CONSTRAINT uProductName UNIQUE NonCLUSTERED (ProductName);
go
ALTER TABLE dbo.Products  
	ADD CONSTRAINT fkProductsCategories  
		FOREIGN KEY (CategoryID)
		REFERENCES dbo.Categories (CategoryID);
go
ALTER TABLE dbo.Products  
	ADD CONSTRAINT pkProductsProductCurrentPriceZeroOrMore CHECK (ProductCurrentPrice > 0);
go

ALTER TABLE dbo.Inventories
	ADD CONSTRAINT pkInventories PRIMARY KEY CLUSTERED (InventoryID);
go
ALTER TABLE dbo.Inventories  
	ADD CONSTRAINT fkInventoriesProducts
		FOREIGN KEY (ProductID)
		REFERENCES dbo.Products (ProductID);
go
ALTER TABLE dbo.Inventories 
	ADD CONSTRAINT ckInventoriesInventoryCountMoreThanZero CHECK (InventoryCount >= 0);
go
ALTER TABLE dbo.Inventories  
	ADD	CONSTRAINT dfInventoriesCountIsZero DEFAULT (0)
	FOR [InventoryCount];
go

Create View vCategories
As
	Select[CategoryID], [CategoryName]
	From Categories;
;
go

Create View vProducts
As
	Select [ProductID], [ProductName], [CategoryID], [ProductCurrentPrice]
	From Products;
;
go

Create View vInventories
As
	Select [InventoryID], [InventoryDate], [ProductID], [InventoryCount]
	From Inventories
;
go

Insert Into Categories
	(CategoryName)
Select CategoryName
From Northwind.dbo.Categories
Order By CategoryID;
go

Insert Into Products
	(ProductName, CategoryID, ProductCurrentPrice)
Select ProductName, CategoryID, UnitPrice
From Northwind.dbo.Products
Order By ProductID;
go

Insert Into Inventories
	(InventoryDate, ProductID, [InventoryCount])
	Select '20200101' as InventoryDate, ProductID, UnitsInStock
	From Northwind.dbo.Products
UNION
	Select '20200201' as InventoryDate, ProductID, UnitsInStock + 10
	-- Using this is to create a made up value
	From Northwind.dbo.Products
UNION
	Select '20200302' as InventoryDate, ProductID, UnitsInStock + 20
	-- Using this is to create a made up value
	From Northwind.dbo.Products
Order By 1, 2
go

Select *
from vCategories;
go
Select *
from vProducts;
go
Select *
from vInventories;
go

-- Question 1 (5% pts): How can you show the Category ID and Category Name for 'Seafood'?
-- TODO: Add Your Code Here

SELECT CategoryID, CategoryName
FROM Categories
WHERE (CategoryName='Seafood');
GO

-- Question 2 (5% pts): How can you show the Product ID, Product Name, and Product Price 
-- of all Products with the Seafood's Category Id? With the results ordered By the Products Price
-- highest to the lowest!

SELECT ProductID, ProductName, ProductCurrentPrice
FROM Products
WHERE CategoryID = 8
ORDER BY ProductCurrentPrice DESC;
GO

-- Question 3 (5% pts):  How can you show the Product ID, Product Name, and Product Price 
-- Ordered By the Products Price highest to the lowest?
-- With only the products that have a price Greater than $100! 

SELECT ProductID, ProductName, ProductCurrentPrice
FROM Products
WHERE ProductCurrentPrice > 100
ORDER BY ProductCurrentPrice DESC;
GO

-- Question 4 (10% pts): How can you show the CATEGORY NAME, product name, and Product Price 
-- from both Categories and Products? Order the results by Category Name 
-- and then Product Name, in alphabetical order!

SELECT CategoryName, ProductName, ProductCurrentPrice
FROM Categories JOIN Products
	ON Categories.CategoryID = Products.CategoryID
ORDER BY CategoryName ASC, ProductName ASC;
GO

-- Question 5 (5% pts): How can you show the Product ID and Number of Products in Inventory
-- for the Month of JANUARY? Order the results by the ProductIDs! 

SELECT ProductID, InventoryCount
FROM Inventories
WHERE InventoryDate = '20200101'
ORDER BY ProductID;
GO

-- Question 6 (10% pts): How can you show the Category Name, Product Name, and Product Price 
-- from both Categories and Products. Order the results by price highest to lowest?
-- Show only the products that have a PRICE FROM $10 TO $20! 

SELECT CategoryName, ProductName, ProductCurrentPrice
FROM Categories JOIN Products
	ON Categories.CategoryId = Products.CategoryId
WHERE ProductCurrentPrice BETWEEN 10 AND 20
ORDER BY ProductCurrentPrice DESC;
GO

-- Question 7 (10% pts) How can you show the Product ID and Number of Products in Inventory
-- for the Month of JANUARY? Order the results by the ProductIDs
-- and where the Product IDs are only in the seafood category!

SELECT ProductID, InventoryCount
FROM Inventories
WHERE InventoryDate = '20200101' AND ProductID IN (SELECT ProductID
	FROM Products
	WHERE CategoryID = 8)

-- Question 8 (10% pts) How can you show the PRODUCT NAME and Number of Products in Inventory
-- for January? Order the results by the Product Names
-- and where the ProductID as only the ones in the seafood category!

SELECT ProductName, InventoryCount
FROM Inventories JOIN Products
	ON Inventories.ProductID = Products.ProductID
WHERE InventoryDate = '20200101' AND Products.ProductID IN (SELECT ProductID
	FROM Products
	WHERE CategoryID = 8)
ORDER BY ProductName;
GO

-- Question 9 (20% pts) How can you show the Product Name and Number of Products in Inventory
-- for both JANUARY and FEBRUARY? Show what the AVERAGE AMOUNT IN INVENTORY was 
-- and where the ProductID as only the ones in the seafood category
-- and Order the results by the Product Names! 

SELECT ProductName, Avg([InventoryCount]) AS AvgAmountInInventory
FROM Inventories JOIN Products
	ON Inventories.ProductID = Products.ProductID
WHERE InventoryDate IN ('20200101', '20200201')
	AND CategoryID = 8
GROUP BY ProductName
ORDER BY ProductName;
GO

-- Question 10 (20% pts) How can you show the Product Name and Number of Products in Inventory
-- for both JANUARY and FEBRUARY? Show what the AVERAGE AMOUNT IN INVENTORY was 
-- and where the ProductID as only the ones in the seafood category
-- and Order the results by the Product Names! 
-- Restrict the results to rows with a Average COUNT OF 100 OR HIGHER!

SELECT ProductName, Avg([InventoryCount]) AS AvgAmountInInventory
FROM Inventories
	JOIN Products
	ON Inventories.ProductID = Products.ProductID
	JOIN Categories
	ON Products.CategoryID = Categories.CategoryID
WHERE InventoryDate IN ('20200101', '20200201')
	AND Products.CategoryID = 8
GROUP BY ProductName
HAVING Avg([InventoryCount]) >= 100
ORDER BY ProductName;
GO

--**************************************************************************--


