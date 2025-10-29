USE startersql;
SELECT * FROM books;
SELECT * FROM customers;
SELECT * FROM orders;

-- Retrieve all the books in the 'fiction' genre
SELECT * FROM books WHERE Genre = 'Fiction';

-- Find the books published after the 1950
SELECT * FROM books WHERE Published_Year > 1950;

-- List all customers from the canada
SELECT * FROM customers WHERE Country = 'Canada';

-- Show all order placed in november 2023
SELECT * FROM orders WHERE Order_Date BETWEEN '2023-11-01' AND '2023-11-30';

-- Retrieve the total stocks of book availabel
SELECT SUM(Stock) AS Total_stock 
FROM books;

-- Find the details of the most expensive books    >>>
 SELECT * 
 FROM books
 ORDER BY Price DESC;
 
 -- Show all customers who ordered more than 1 quantity of books
SELECT c.Customer_ID, o.Order_ID, Quantity
FROM orders o
JOIN customers c ON o.Order_ID = c.Customer_ID
WHERE Quantity > 1;

-- Retrieve all orders where the total amount exceed $20
SELECT * FROM orders WHERE Total_Amount > 20;

-- List all genre availabel in the book table
SELECT DISTINCT Genre FROM books;

-- Find the books with the lowest stock
SELECT * FROM books;
SELECT * FROM books 
ORDER BY Stock ASC LIMIT 1;

-- Calculate the total revenue gnerated from all orders
SELECT SUM(Total_Amount) AS total_revenue
FROM orders;

-- ADVANCE QUERY
-- Retrieve the total number of book sold for each genre    >>>
SELECT b.Genre, SUM(Quantity)
FROM orders o 
JOIN books b ON b.Book_ID = o.Book_ID
GROUP BY b.Genre;


-- Find the average price of book in the 'fantasy' genre
SELECT Genre, AVG(Price) AS Average_book
FROM books
WHERE Genre = 'Fantasy';

-- List the customers who have placed at least two orders
SELECT c.Customer_ID, COUNT(O.Order_ID) AS order_count
FROM orders o
JOIN customers c ON c.Customer_ID = o.Customer_ID
GROUP BY O.Customer_ID
HAVING COUNT(Order_ID) >= 2;

-- Find the most frequently order book   >>>>
SELECT Book_ID, COUNT(Order_ID)
FROM orders
GROUP BY Book_ID
ORDER BY COUNT(Order_ID) DESC
LIMIT 1;

SELECT * FROM orders
WHERE Book_ID = 73;

-- Show the top most 3 most expensive books of 'fantasy' genre
SELECT * FROM books
WHERE Genre = 'Fantasy'
ORDER BY Price DESC LIMIT 3;

-- Retrieve the total quantity of books sold by each other
SELECT b.Author, SUM(o.Quantity) AS Total_book_sold
FROM orders o
JOIN books b ON o.Book_ID = b.Book_ID
GROUP BY b.Author;

-- List the city where customer who spent $30 over located     >>>
SELECT DISTINCT c.City, o.Total_Amount
FROM orders o
JOIN customers c ON c.Customer_ID = o.Customer_ID
WHERE o.Total_Amount > 30;

-- Find the customer who spent the most on order
SELECT c.Customer_ID, c.Name, t.Total_Amount
FROM customers c
JOIN 
   (SELECT o.Customer_ID, SUM(o.Total_Amount) AS Total_Amount
   FROM orders o
   GROUP BY o.Customer_ID, o.Total_Amount
   ORDER BY o.Total_Amount DESC LIMIT 1) t
ON c.Customer_ID = t.Customer_ID;
   
   
-- Calculate the stock remaning after fulfiling all orders
SELECT 
    b.Book_ID, 
    b.Title, 
    b.Stock, 
    COALESCE(SUM(o.Quantity),0) AS order_quantity,
    b.Stock - COALESCE(SUM(o.Quantity),0) AS remaining_quantity
FROM books b
LEFT JOIN orders o ON b.Book_ID = o.Book_ID
GROUP BY b.Book_ID, b.Title, b.Stock;
