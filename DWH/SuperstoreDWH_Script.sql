-- Create Data Warehouse Schema for Superstore

-- Dimension: DimCustomer
CREATE TABLE DimCustomer (
    CustomerKey INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID NVARCHAR(50) NOT NULL,
    CustomerName NVARCHAR(255),
    Segment NVARCHAR(50)
);
GO

-- Dimension: DimProduct
CREATE TABLE DimProduct (
    ProductKey INT IDENTITY(1,1) PRIMARY KEY,
    ProductID NVARCHAR(50) NOT NULL,
    ProductName NVARCHAR(500),
    Category NVARCHAR(50),
    SubCategory NVARCHAR(50)
);
GO

-- Dimension: DimLocation
CREATE TABLE DimLocation (
    LocationKey INT IDENTITY(1,1) PRIMARY KEY,
    Country NVARCHAR(100),
    City NVARCHAR(100),
    State NVARCHAR(100),
    PostalCode NVARCHAR(50),
    Region NVARCHAR(50)
);
GO

-- Dimension: DimDate
CREATE TABLE DimDate (
    DateKey INT PRIMARY KEY, -- Format YYYYMMDD
    FullDateAlternateKey DATE,
    DayNumberOfWeek TINYINT,
    EnglishDayNameOfWeek NVARCHAR(10),
    DayNumberOfMonth TINYINT,
    DayNumberOfYear SMALLINT,
    WeekNumberOfYear TINYINT,
    EnglishMonthName NVARCHAR(10),
    MonthNumberOfYear TINYINT,
    CalendarQuarter TINYINT,
    CalendarYear SMALLINT
);
GO

-- Populate DimDate
DECLARE @StartDate DATE = '2010-01-01';
DECLARE @EndDate DATE = '2030-12-31';

WHILE @StartDate <= @EndDate
BEGIN
    INSERT INTO DimDate (
        DateKey,
        FullDateAlternateKey,
        DayNumberOfWeek,
        EnglishDayNameOfWeek,
        DayNumberOfMonth,
        DayNumberOfYear,
        WeekNumberOfYear,
        EnglishMonthName,
        MonthNumberOfYear,
        CalendarQuarter,
        CalendarYear
    )
    SELECT
        CAST(CONVERT(VARCHAR(8), @StartDate, 112) AS INT),
        @StartDate,
        DATEPART(dw, @StartDate),
        DATENAME(dw, @StartDate),
        DAY(@StartDate),
        DATEPART(dy, @StartDate),
        DATEPART(wk, @StartDate),
        DATENAME(mm, @StartDate),
        MONTH(@StartDate),
        DATEPART(qq, @StartDate),
        YEAR(@StartDate);

    SET @StartDate = DATEADD(dd, 1, @StartDate);
END;
GO

-- Fact Table: FactSales
CREATE TABLE FactSales (
    SalesKey INT IDENTITY(1,1) PRIMARY KEY,
    OrderDateKey INT NOT NULL,
    ShipDateKey INT NOT NULL,
    CustomerKey INT NOT NULL,
    ProductKey INT NOT NULL,
    LocationKey INT NOT NULL,
    OrderID NVARCHAR(50) NOT NULL,
    ShipMode NVARCHAR(50),
    Sales DECIMAL(18, 4),
    Quantity INT,
    Discount DECIMAL(18, 4),
    Profit DECIMAL(18, 4),
    RowID INT, -- Source System ID for lineage/audit
    
    -- Foreign Keys
    CONSTRAINT FK_FactSales_DimDate_Order FOREIGN KEY (OrderDateKey) REFERENCES DimDate(DateKey),
    CONSTRAINT FK_FactSales_DimDate_Ship FOREIGN KEY (ShipDateKey) REFERENCES DimDate(DateKey),
    CONSTRAINT FK_FactSales_DimCustomer FOREIGN KEY (CustomerKey) REFERENCES DimCustomer(CustomerKey),
    CONSTRAINT FK_FactSales_DimProduct FOREIGN KEY (ProductKey) REFERENCES DimProduct(ProductKey),
    CONSTRAINT FK_FactSales_DimLocation FOREIGN KEY (LocationKey) REFERENCES DimLocation(LocationKey)
);
GO
