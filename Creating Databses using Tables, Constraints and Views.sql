--*************************************************************************--
-- Title: Assignment02 
-- Desc: This script demonstrates the creation of a typical database with:
--       1) Tables
--       2) Constraints
--       3) Views
-- Dev: Nikita Daharia
-- Change Log: When,Who,What
-- TODO: 2022-01-25,NikitaDaharia,Completed File
--**************************************************************************--

--[ Create the Database ]--
USE MASTER;
GO
IF EXISTS (SELECT *
FROM sysdatabases
WHERE NAME='Assignment02DB_NikitaDaharia')
  BEGIN
    USE [master];
    ALTER DATABASE Assignment02DB_NikitaDaharia Set Single_User With Rollback Immediate;
    -- Kick everyone out of the DB
    DROP DATABASE Assignment02DB_NikitaDaharia;
END
GO

CREATE DATABASE Assignment02DB_NikitaDaharia;
GO
USE Assignment02DB_NikitaDaharia;
GO

INSERT INTO Categories
VALUES
  (1, 'CatA');
INSERT INTO Categories
VALUES
  (2, 'CatB');
  GO
  
-- Create table Categories  
CREATE TABLE dbo.Categories
(
    CategoryID int IDENTITY(1,1) NOT NULL,
    CategoryName nvarchar(100) NOT NULL
);
GO

-- Create table products
CREATE TABLE dbo.Products
(
    ProductID int IDENTITY(1,1) NOT NULL,
    ProductName nvarchar(100) NOT NULL,
    ProductCurrentPrice money NOT NULL,
    CategoryID int NULL
);
GO

-- Create table Inventories
CREATE TABLE dbo.Inventories
(
    InventoryID int IDENTITY(1,1) NOT NULL,
    InventoryDate date NOT NULL,
    InventoryCount int NOT NULL,
    ProductID int NOT NULL
);
GO

ALTER TABLE dbo.Categories
ADD CONSTRAINT PK_Categories PRIMARY KEY CLUSTERED(CategoryID);
GO

ALTER TABLE dbo.Categories
ADD CONSTRAINT U_CategoryName UNIQUE NonCLUSTERED (CategoryName);
GO

EXEC sp_helpconstraint Categories;
GO

ALTER TABLE dbo.Products
ADD CONSTRAINT PK_Products PRIMARY KEY CLUSTERED(ProductID);
GO

ALTER TABLE dbo.Products
ADD CONSTRAINT U_ProductName UNIQUE NonCLUSTERED (ProductName);
GO

ALTER TABLE dbo.Products
ADD CONSTRAINT FK_ProductsCategories
FOREIGN KEY (CategoryID)
REFERENCES dbo.Categories (CategoryID);
GO

ALTER TABLE dbo.Products
ADD CONSTRAINT CK_ProductsUnitPriceZeroOrMore CHECK (ProductCurrentPrice >= 0);
GO

EXEC sp_helpconstraint Products;
GO

ALTER TABLE dbo.Inventories
ADD CONSTRAINT PK_Inventories PRIMARY KEY CLUSTERED(InventoryID);
GO

ALTER TABLE dbo.Inventories
ADD CONSTRAINT FK_InventoriesProducts
FOREIGN KEY (ProductID)
REFERENCES dbo.Products (ProductID);
GO

ALTER TABLE dbo.Inventories
ADD CONSTRAINT DF_InventoriesCountIsZero DEFAULT (1)
FOR InventoryCount;
GO

EXEC sp_helpconstraint Inventories;
GO

INSERT INTO dbo.Categories
VALUES
    (1, 'CatA');
INSERT INTO dbo.Categories
VALUES
    (2, 'CatB');
  GO
  
INSERT INTO dbo.Products
VALUES
    (1, 'Prod1', 1, 9.99);
INSERT INTO dbo.Products
VALUES
    (2, 'Prod2', 1, 19.99);
INSERT INTO dbo.Products
VALUES
    (3, 'Prod3', 2, 14.99);
  GO
  
INSERT INTO dbo.Inventories
VALUES
    (11, 2020-01-01, 1, 100);
INSERT INTO dbo.Inventories
VALUES
    (22, 2020-01-01, 2, 50);
INSERT INTO dbo.Inventories
VALUES
    (33, 2020-01-01, 3, 34);
INSERT INTO dbo.Inventories
VALUES
    (44, 2020-02-01, 1, 100);
INSERT INTO dbo.Inventories
VALUES
    (55, 2020-02-01, 2, 50);
INSERT INTO dbo.Inventories
VALUES
    (66, 2020-02-01, 3, 34);  
GO

SELECT *
FROM dbo.Categories;
SELECT *
FROM dbo.Products;
SELECT *
FROM dbo.Inventories;
GO

CREATE View dbo.vCategories
AS
    SELECT
        CategoryID 
        CategoryName
    FROM dbo.Categories;
GO

Create View dbo.vProducts
As
    SELECT
        ProductID,
        ProductName,
        ProductCurrentPrice,
        CategoryID
    FROM dbo.Products;
GO

Create View dbo.vInventories
As
    SELECT
        InventoryID,
        InventoryDate,
        InventoryCount,
        ProductID
    FROM dbo.Inventories;
GO

SELECT *
FROM dbo.vCategories;
GO

SELECT *
FROM dbo.vProducts;
GO

SELECT *
FROM dbo.vInventories;
GO

INSERT INTO Categories
VALUES
  (1, 'CatA');
INSERT INTO Categories
VALUES
  (2, 'CatB');
  GO
  
  
-- TODO: Add data to Products
/*
ProductID	ProductName	CategoryID	UnitPrice
1	Prod1	1	9.99
2	Prod2	1	19.99
3	Prod3	2	14.99
*/
go

INSERT INTO Products
VALUES
  (1, 'Prod1',1,9.99);
INSERT INTO Products
VALUES
  (2, 'Prod2',1,19.99);
INSERT INTO Products
VALUES
  (3, 'Prod3',2,14.99);
  GO
  
-- TODO: Add data to Inventories
/*
InventoryID	InventoryDate	ProductID	InventoryCount
1	1	2020-01-01	1	100
2	2	2020-01-01	2	50
3	3	2020-01-01	3	34
4	4	2020-02-01	1	100
5	5	2020-02-01	2	50
6	6	2020-02-01	3	34
*/
  
INSERT INTO Inventories
VALUES
  (11, 2020-01-01,1,100);
INSERT INTO Inventories
VALUES
 (22, 2020-01-01,2,50);
INSERT INTO Inventories
VALUES
  (33, 2020-01-01,3,34);  
INSERT INTO Inventories
VALUES
  (44, 2020-02-01,1,100);
INSERT INTO Inventories
VALUES
 (55, 2020-02-01,2,50);
INSERT INTO Inventories
VALUES
  (66, 2020-02-01,3,34);  
GO
  

GO
--[ Review the design ]--
-- Meta Data Query:
With 
TablesAndColumns As (
Select  
  [SourceObjectName] = TABLE_CATALOG + '.' + TABLE_SCHEMA + '.' + TABLE_NAME + '.' + COLUMN_NAME
, [IS_NULLABLE]=[IS_NULLABLE]
, [DATA_TYPE] = Case [DATA_TYPE]
                When 'varchar' Then  [DATA_TYPE] + '(' + IIf(DATA_TYPE = 'int','', IsNull(Cast(CHARACTER_MAXIMUM_LENGTH as varchar(10)), '')) + ')'
                When 'nvarchar' Then [DATA_TYPE] + '(' + IIf(DATA_TYPE = 'int','', IsNull(Cast(CHARACTER_MAXIMUM_LENGTH as varchar(10)), '')) + ')'
                When 'money' Then [DATA_TYPE] + '(' + Cast(NUMERIC_PRECISION as varchar(10)) + ',' + Cast(NUMERIC_SCALE as varchar(10)) + ')'
                When 'decimal' Then [DATA_TYPE] + '(' + Cast(NUMERIC_PRECISION as varchar(10)) + ',' + Cast(NUMERIC_SCALE as varchar(10)) + ')'
                When 'float' Then [DATA_TYPE] + '(' + Cast(NUMERIC_PRECISION as varchar(10)) + ',' + Cast(NUMERIC_SCALE as varchar(10)) + ')'
                Else [DATA_TYPE]
                End                          
, [TABLE_NAME]
, [COLUMN_NAME]
, [ORDINAL_POSITION]
, [COLUMN_DEFAULT]
From Information_Schema.columns 
),
Constraints As (
Select 
 [SourceObjectName] = TABLE_CATALOG + '.' + TABLE_SCHEMA + '.' + TABLE_NAME + '.' + COLUMN_NAME
,[CONSTRAINT_NAME]
From [INFORMATION_SCHEMA].[CONSTRAINT_COLUMN_USAGE]
), 
IdentityColumns As (
Select 
 [ObjectName] = object_name(c.[object_id]) 
,[ColumnName] = c.[name]
,[IsIdentity] = IIF(is_identity = 1, 'Identity', Null)
From sys.columns as c Join Sys.tables as t on c.object_id = t.object_id
) 
Select 
  TablesAndColumns.[SourceObjectName]
, [IsNullable] = [Is_Nullable]
, [DataType] = [Data_Type] 
, [ConstraintName] = IsNull([CONSTRAINT_NAME], 'NA')
, [COLUMN_DEFAULT] = IsNull(IIF([IsIdentity] Is Not Null, 'Identity', [COLUMN_DEFAULT]), 'NA')
--, [ORDINAL_POSITION]
From TablesAndColumns 
Full Join Constraints On TablesAndColumns.[SourceObjectName]= Constraints.[SourceObjectName]
Full Join IdentityColumns On TablesAndColumns.COLUMN_NAME = IdentityColumns.[ColumnName]
                          And TablesAndColumns.Table_NAME = IdentityColumns.[ObjectName]
Where [TABLE_NAME] Not In (Select [TABLE_NAME] From [INFORMATION_SCHEMA].[VIEWS])
Order By [TABLE_NAME],[ORDINAL_POSITION]

--**************************************************************************--
  