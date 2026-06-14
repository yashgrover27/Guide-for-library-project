select * from books;
select * from branch;
select * from employees;
select * from issued_status;
select * from members;
select * from return_status;

desc members;





-- Task 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 
-- 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

insert into books values
('978-1-60129-456-2','To Kill a Mockingbird','Classic' ,6.00,'yes','Harper Lee', 'J.B. Lippincott & Co.' );




-- Task 2: Update an Existing Member's Address

update members
set member_address= '666 Jawahar'
where member_id='C102';

-- Task 3: Delete a Record from the Issued Status Table -- Objective: Delete the record with issued_id = 'IS121' 
-- from the issued_status table.


delete from issued_status
where issued_id= 'IS121';


-- Task 4: Retrieve All Books Issued by a Specific Employee -- 
-- Objective: Select all books issued by the employee with emp_id = 'E101'.

select *
from issued_status
where issuedemp_id='E101'
;



-- Task 5: List Members Who Have Issued More Than One Book -- 
-- Objective: Use GROUP BY to find members who have issued more than one book.


select count(issued_emp_id),issued_emp_id
from issued_status
group by issued_emp_id
having count(issued_emp_id)>1;



-- Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results -
--  each book and total book_issued_cnt**
create table books_counts
as
select b.isbn, ist.issued_member_id,count(*)
 from books as b
join issued_status as ist
on b.isbn=issued_book_isbn
group by b.isbn,ist.issued_member_id;


select * from books_counts;




-- Task 7. Retrieve All Books in a Specific Category:

select * from books
where category="fiction";




-- Task 8: Find Total Rental Income by Category:

select category ,count(category),
sum(rental_price) from books
group by category;


-- Task 9: List Members Who Registered in the Last 1180 Days:


select *
from members
where reg_date>= current_date-interval 1180 day;



-- task. 10 List Employees with Their Branch Manager's Name and their branch details:

select * 
from branch as b
join
employees as e 
on b.branch_id= e.branch_id
join
employees as e2
on b.manager_id= e2.emp_id;




-- Task 11. Create a Table of Books with Rental Price Above a Certain Threshold 7 dollar:-- 

create table expensive_book
as
select * from books
where rental_price>=7;


select * from expensive_book;




-- Task 12: Retrieve the List of Books Not Yet Returned

select  row_number() over(order by issued_date ),
ist.* 
from issued_status as ist
left join
return_status as rs
on ist.issued_id =rs.issued_id
where rs.return_id is null;




-- Task 13:
--  Identify Members with Overdue Books
-- Write a query to identify members who have overdue books (assume a 20250-day return period). 
-- Display the member's_id, member's name, book title, issue date, and days overdue.


-- issued_memebr_id=member_id=books_isbn=return_Date

select 

 row_number() over(order by issued_date ),
m.member_id,
m.member_name,
b.book_title,
ist.issued_date,
current_date()-ist.issued_date as gap_days



 from issued_status

as ist 
join 
members as m
on ist.issued_member_id = m.member_id
join books as b
on ist.issued_book_isbn= b.isbn
left join return_status as rs
on ist.issued_id=rs.issued_id
where rs.return_date is null
and current_date-ist.issued_date>200;





-- Task 14: Branch Performance Report
-- Create a query that generates a performance report for each branch,
--  showing the number of books issued,
 -- the number of books returned,
--  and the total revenue generated from book rentals.





create table branch_reports
as
select
row_number() over(order by b.branch_id) as row_num,
b.branch_id,
b.manager_id,
sum(bk.rental_price) as total_revenue,
count(ist.issued_id) as countt,
count(rs.return_id) as returned_book
from issued_status as ist
join employees as e
on ist.issued_emp_id = e.emp_id
join branch as b
on b.branch_id = e.branch_id
left join return_status as rs
on rs.issued_id = ist.issued_id
join books as bk
on ist.issued_book_isbn = bk.isbn
group by
b.branch_id,
b.manager_id;




select * from branch_reports;








-- TASK 15 Use the CREATE TABLE AS (CTAS) statement 
-- to create a new table active_members 
-- containing members who have issued at least one book in the last 3 months.-- 


create table bookin_lastyear
as
select 
issued_date,issued_id
from issued_status
 
where issued_date> CURRENT_DATE - INTERVAL 3 YEAR;



select * from bookin_lastyear;




-- Task 16: Find Employees with the Most Book Issues Processed
-- Write a query to find the top 3 employees who have processed the most book issues.
--  Display the employee name, number of books processed, and their branch.



select * from issued_status;
select * from employees;
select * from branch;


select 
e.emp_id,
e.emp_name,


count(ist.issued_id),
b.branch_address
from issued_status as ist
 join employees as e
on ist.issued_emp_id= e.emp_id
join branch as b
on e.branch_id=b.branch_id
group by 1;

