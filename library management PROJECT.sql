create database library_management;
use library_management;

create table tbl_publisher( publisher_PublisherName varchar(255) primary key,
							publisher_PublisherAddress varchar(255),
                            publisher_PublisherPhone varchar(255));

create table tbl_borrower(borrower_CardNo int primary key auto_increment ,
						  borrower_BorrowerName varchar(255),
                          borrower_BorrowerAddress varchar(255),
                          borrower_BorrowerPhone varchar(255)) auto_increment=100;
                          
create table tbl_library_branch(library_branch_BranchID int primary key auto_increment ,
							    library_branch_BranchName varchar(255),
                                library_branch_BranchAddress varchar(255));

create table tbl_book(book_BookID int primary key auto_increment,
					  book_Title varchar(255),
                      book_PublisherName varchar(255),
                      foreign key(book_PublisherName) references tbl_Publisher(publisher_PublisherName) on update cascade on delete cascade);
                      
create table tbl_book_authors(book_authors_AuthorID int primary key auto_increment,
                              book_authors_BookID int ,
                              book_authors_AuthorName varchar(255),
							 foreign key( book_authors_BookID) references tbl_book(book_BookID) on update cascade on delete cascade);
                             
create table tbl_book_copies( book_copies_CopiesID int primary key auto_increment,
                              book_copies_BookID int,
                              book_copies_BranchID int,
                              book_copies_No_Of_Copies int ,
                              foreign key(book_copies_BookID) references tbl_book(book_BookID) on update cascade on delete cascade,
                              foreign key(book_copies_BranchID) references tbl_library_branch(library_branch_BranchID) on update cascade on delete cascade);

create table tbl_book_loans(book_loans_LoansID int primary key auto_increment,
							book_loans_BookID int,
                            book_loans_BranchID int,
                            book_loans_CardNo int,
                            book_loans_DateOut varchar(255),
                            book_loans_DueDate varchar(255),
                            foreign key(book_loans_BookID) references tbl_book(book_BookID) on update cascade on delete cascade,
							foreign key( book_loans_BranchID) references tbl_library_branch(library_branch_BranchID) on update cascade on delete cascade,
                            foreign key( book_loans_CardNo) references tbl_borrower(borrower_CardNo) on update cascade on delete cascade);
	

-- 1. How many copies of the book titled "The Lost Tribe" are owned by the library branch whose name is "Sharpstown"?

select book_copies_No_Of_Copies from tbl_book
inner join tbl_book_copies
on tbl_book.book_BookID = tbl_book_copies.book_copies_BookID
inner join tbl_library_branch
on tbl_book_copies.book_copies_BranchID = tbl_library_branch.library_branch_BranchID
where library_branch_BranchName = 'Sharpstown'and  book_title = "The Lost Tribe";

-- 2. How many copies of the book titled "The Lost Tribe" are owned by each library branch?

select library_branch_BranchName, book_copies_No_Of_copies from tbl_book
inner join tbl_book_copies
on tbl_book.book_BookID = tbl_book_copies.book_copies_BookID
inner join tbl_library_branch
on tbl_book_copies.book_copies_BranchID = tbl_library_branch.library_branch_BranchID
where  book_title = "The Lost Tribe";

-- 3. Retrieve the names of all borrowers who do not have any books checked out.

select borrower_BorrowerName from tbl_borrower
left join tbl_book_loans
on tbl_borrower.borrower_CardNo=tbl_book_loans.book_loans_CardNo
where book_loans_CardNo is null;

/*4. For each book that is loaned out from the "Sharpstown" branch and whose DueDate is 2/3/18,
 retrieve the book title, the borrower's name, and the borrower's address.*/ 
set sql_safe_updates =0;
select*from tbl_book_loans;

alter table tbl_book_loans add column date_out date ;
update tbl_book_loans set date_out = str_to_date(book_loans_DateOut, '%m/%d/%Y');

alter table tbl_book_loans add column due_date date ;
update tbl_book_loans set due_date = str_to_date(book_loans_DueDate, '%m/%d/%Y');
						
select book_Title,borrower_BorrowerName,borrower_BorrowerAddress from tbl_library_branch
inner join tbl_book_loans
on tbl_book_loans.book_loans_BranchID=tbl_library_branch.library_branch_BranchID
inner join tbl_borrower
on tbl_book_loans.book_loans_CardNo=tbl_borrower.borrower_CardNo
inner join tbl_book
on tbl_book.book_BookID=tbl_book_loans.book_loans_BookID
where library_branch_BranchName = 'Sharpstown'  and due_date = '2018-02-03';

-- 5.For each library branch, retrieve the branch name and the total number of books loaned out from that branch.

select library_branch_BranchName , count(book_loans_LoansID) as total_books_loanedOut from tbl_library_branch
inner join tbl_book_loans
on tbl_library_branch.library_branch_BranchID=tbl_book_loans.book_loans_BranchID
group by library_branch_BranchName;

-- 6. Retrieve the names, addresses, and number of books checked out for all borrowers who have more than five books checked out.

select borrower_BorrowerName,borrower_BorrowerAddress, count(book_loans_LoansID) as no_of_books_checked_out  from tbl_borrower
inner join tbl_book_loans
on tbl_borrower.borrower_CardNo=tbl_book_loans.book_loans_CardNo
group by borrower_BorrowerName , borrower_BorrowerAddress
having count(book_loans_LoansID)>5;

/*7. For each book authored by "Stephen King", retrieve the title and the number of copies owned by the library branch 
whose name is "Central".*/

select book_Title, book_copies_No_Of_Copies from tbl_book_authors
inner join tbl_book
on tbl_book.book_BookID=tbl_book_authors.book_authors_BookID
inner join tbl_book_copies
on tbl_book_authors.book_authors_BookID=tbl_book_copies.book_copies_BookID
inner join tbl_library_branch
on tbl_library_branch.library_branch_BranchID= tbl_book_copies.book_copies_BranchID
where library_branch_BranchName='Central' and book_authors_AuthorName = 'Stephen King'


