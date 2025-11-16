CREATE DATABASE CART
GO

USE CART
GO

CREATE TABLE Product_SKU (
    BarCode VARCHAR(100) PRIMARY KEY,
    "Name" VARCHAR(100) NOT NULL,
    Price DECIMAL(10, 2) NOT NULL,
    Stock INT NOT NULL,
    "Size" VARCHAR(100),
    Color VARCHAR(100),
    Manufacture_Date DATE NOT NULL,
    Expired_Date DATE,
    sellerID VARCHAR(100) NOT NULL,
    --FOREIGN KEY(sellerID) REFERENCES Seller(userID)
);

INSERT INTO Product_SKU (BarCode, "Name", Price, Stock, "Size", Color, Manufacture_Date, Expired_Date, sellerID)
VALUES
('BC001', 'Organic Milk', 3.50, 20, '1 Litre', 'White', '2025-10-01', '2025-11-15', 'S001'),
('BC002', 'Men''s Cotton T-Shirt', 25.00, 300, 'Large', 'Navy Blue', '2025-05-20', NULL, 'S002'),
('BC003', 'Spicy Instant Noodles', 1.50, 1000, '75g', 'Red', '2025-11-01', '2026-05-01', 'S001'),
('BC004', 'USB-C Laptop Charger', 45.99, 50, 'N/A', 'Black', '2025-01-01', NULL, 'S003'),
('BC005', 'Thai Iced Tea Mix', 8.99, 200, '500g', 'Orange', '2025-07-10', '2026-07-10', 'S004');

%-------- PART 2 ---------

CREATE TABLE Cart (
    ID VARCHAR(100) NOT NULL PRIMARY KEY 
);
GO
INSERT INTO Cart (ID)
VALUES
('C101'), 
('C102'), 
('C103'), 
('C104'), 
('C105'); 
GO

CREATE TABLE CartItem (
    ID VARCHAR(100), 
    cartID VARCHAR(100), 
    Quantity INT NOT NULL DEFAULT 1,
    BarCode VARCHAR(100) NOT NULL,
    PRIMARY KEY(ID, cartID),
    FOREIGN KEY(cartID) REFERENCES Cart(ID),
    FOREIGN KEY(BarCode) REFERENCES Product_SKU(BarCode)
);
GO
INSERT INTO CartItem (ID, cartID, Quantity, BarCode)
VALUES
('CI001', 'C101', 2, 'BC001'),    
('CI002', 'C101', 1, 'BC002'),    
('CI003', 'C102', 5, 'BC003'),    
('CI004', 'C102', 1, 'BC004'),    
('CI005', 'C103', 10, 'BC005'); 
GO

% -------- LIST ITEMS ----------
CREATE PROCEDURE listCartItems(@cartID VARCHAR(100)) 
AS
BEGIN
    SET NOCOUNT ON;

    -- Condition: Check if the cart exists
    IF NOT EXISTS (SELECT 1 FROM Cart WHERE ID = @cartID)
    BEGIN
        PRINT 'Error: Cart ID ' + @cartID + ' does not exist.'; 
        RETURN;
    END

    -- Original query
    SELECT "Name", Price, Quantity, "Size", Color, Manufacture_Date, Expired_Date, CartItem.BarCode
    FROM CartItem LEFT JOIN Product_SKU
    ON CartItem.BarCode = Product_SKU.BarCode
    WHERE CartItem.cartID = @cartID;

    -- Condition: Check if the query returned any rows
    IF @@ROWCOUNT = 0
    BEGIN
        PRINT 'Info: Cart ' + @cartID + ' is empty.'; 
    END
END;

EXEC listCartItems 'C101';

% -------- SEARCH anD FILTER ITEMS ----------

CREATE PROCEDURE searchAndFilterCartItems(
    @cartID VARCHAR(100), 
    @itemName VARCHAR(100) = NULL,
    @itemColor VARCHAR(100) = NULL,
    @itemSize VARCHAR(100) = NULL,
    @minPrice DECIMAL(10, 2) = NULL,
    @maxPrice DECIMAL(10, 2) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    -- Condition: Check if the cart exists
    IF NOT EXISTS (SELECT 1 FROM Cart WHERE ID = @cartID)
    BEGIN
        PRINT 'Error: Cart ID ' + @cartID + ' does not exist.'; 
        RETURN;
    END

    -- Original query
    SELECT
        ps."Name", ps.Price, ci.Quantity, ps."Size", ps.Color,
        ps.Manufacture_Date, ps.Expired_Date
    FROM
        CartItem AS ci
    LEFT JOIN
        Product_SKU AS ps ON ci.BarCode = ps.BarCode
    WHERE
        ci.cartID = @cartID
    AND
        (@itemName IS NULL OR ps."Name" LIKE '%' + @itemName + '%')
    AND
        (@itemColor IS NULL OR ps.Color LIKE '%' + @itemColor + '%')
    AND
        (@itemSize IS NULL OR ps."Size" LIKE '%' + @itemSize + '%')
    AND
        (@minPrice IS NULL OR ps.Price >= @minPrice)
    AND
        (@maxPrice IS NULL OR ps.Price <= @maxPrice);

    -- Condition: Check if any items matched the search
    IF @@ROWCOUNT = 0
    BEGIN
        PRINT 'Info: No items in cart ' + @cartID + ' matched your search criteria.'; 
    END
END;

EXEC searchAndFilterCartItems
    @cartID = 'C102', 
    @minPrice = 30.00;

% -------------- REMOVE ITEM --------------
CREATE PROCEDURE removeCartItem(
    @cartID VARCHAR(100), 
    @BarCode VARCHAR(100)
)
AS
BEGIN
    SET NOCOUNT ON;

    -- Condition: Check if the cart exists
    IF NOT EXISTS (SELECT 1 FROM Cart WHERE ID = @cartID)
    BEGIN
        PRINT 'Error: Cart ID ' + @cartID + ' does not exist.'; 
        RETURN;
    END

    -- Condition: Check if the item is in the cart
    IF NOT EXISTS (SELECT 1 FROM CartItem WHERE cartID = @cartID AND BarCode = @BarCode)
    BEGIN
        PRINT 'Info: Item ' + @BarCode + ' was not in cart ' + @cartID + '. No action taken.'; 
        RETURN;
    END

    -- All checks passed, perform the deletion
    DELETE FROM CartItem
    WHERE cartID = @cartID AND BarCode = @BarCode;
    
    PRINT 'Item ' + @BarCode + ' successfully removed from cart ' + @cartID + '.'; 
END;

EXEC removeCartItem @cartID = 'C101', @BarCode = 'BC002'; 

% -------------- UPDATE ITEM --------------
CREATE PROCEDURE updateCartItemQuantity(
    @cartID VARCHAR(100), 
    @BarCode VARCHAR(100),
    @NewQuantity INT
)
AS
BEGIN
    SET NOCOUNT ON;

    -- Condition: Check if the cart exists
    IF NOT EXISTS (SELECT 1 FROM Cart WHERE ID = @cartID)
    BEGIN
        PRINT 'Error: Cart ID ' + @cartID + ' does not exist.'; 
        RETURN;
    END

    -- Condition: Check if the item is already in this cart
    IF NOT EXISTS (SELECT 1 FROM CartItem WHERE cartID = @cartID AND BarCode = @BarCode)
    BEGIN
        IF @NewQuantity > 0
        BEGIN
            PRINT 'Error: Item ' + @BarCode + ' is not in cart ' + @cartID + '. Cannot update.'; 
            PRINT '(Note: This procedure only updates existing items, it does not add new ones.)';
        END
        ELSE
        BEGIN
            -- User tried to "delete" (quantity 0) an item that wasn't in the cart anyway.
            PRINT 'Info: Item ' + @BarCode + ' was not in cart ' + @cartID + '. No action taken.'; 
        END
        RETURN; -- Stop execution
    END

    -- Handle Deletion (NewQuantity is 0 or less)
    IF @NewQuantity <= 0
    BEGIN
        DELETE FROM CartItem
        WHERE cartID = @cartID AND BarCode = @BarCode;
        PRINT 'Item ' + @BarCode + ' removed from cart ' + @cartID + '.'; 
    END
    -- Handle Update (NewQuantity is 1 or more)
    ELSE
    BEGIN
        -- Condition: Check for available stock
        DECLARE @Stock INT;
        SELECT @Stock = Stock
        FROM Product_SKU
        WHERE BarCode = @BarCode;

        IF @NewQuantity > @Stock
        BEGIN
            PRINT 'Error: Insufficient stock for item ' + @BarCode + '.';
            PRINT ' Requested: ' + CAST(@NewQuantity AS VARCHAR) + ', Available: ' + CAST(@Stock AS VARCHAR) + '. No update was made.';
            RETURN;
        END

        -- All checks passed, perform the update
        UPDATE CartItem
        SET Quantity = @NewQuantity
        WHERE cartID = @cartID AND BarCode = @BarCode;
        PRINT 'Item ' + @BarCode + ' quantity updated to ' + CAST(@NewQuantity AS VARCHAR) + ' in cart ' + @cartID + '.'; 
    END
END;

EXEC updateCartItemQuantity
    @cartID = 'C101', 
    @BarCode = 'BC001',
    @NewQuantity = 10;

PRINT '--- 5. Cart C101 after update ---';
EXEC listCartItems 'C101'; 
GO

PRINT '--- 6. Removing T-Shirt (BC002) from Cart C101 ---';
EXEC removeCartItem @cartID = 'C101', @BarCode = 'BC002'; 
GO

PRINT '--- 7. Cart C101 after removal ---';
EXEC listCartItems 'C102'; 
GO

PRINT '--- 8. Removing Milk (BC001) from Cart C101 by setting quantity to 0 ---';
EXEC updateCartItemQuantity
    @cartID = 'C102', 
    @BarCode = 'BC004',
    @NewQuantity = 6;
GO

PRINT '--- 9. Cart C101 after final removal ---';
EXEC listCartItems 'C101'; 
GO

PRINT '--- 10. Trying to remove an item that is not in the cart ---';
EXEC removeCartItem @cartID = 'C102', @BarCode = 'BC003'; 
GO

PRINT '--- 11. Trying to list a cart that does not exist ---';
EXEC listCartItems 'C999'; 
GO
USE CART
SELECT * FROM Cart
SELECT * FROM CartItem
SELECT * FROM Product_SKU
