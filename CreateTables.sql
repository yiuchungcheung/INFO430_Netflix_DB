-- CUSTOMER
CREATE TABLE tblCustomer
(CustomerID INT IDENTITY(1,1) PRIMARY KEY,
CustomerTypeID INT FOREIGN KEY REFERENCES tblCustomer_Type(CustomerTypeID) NOT NULL,
CustomerFName VARCHAR(500) NOT NULL,
CustomerLName VARCHAR(500) NOT NULL,
CustomerDOB DATE NOT NULL,
CustomerStreetAddress VARCHAR(500) NOT NULL,
CustomerCity VARCHAR(500) NOT NULL,
CustomerState VARCHAR(100) NOT NULL,
CustomerZipCode INT NOT NULL)
GO

-- REVIEW
CREATE TABLE tblREVIEW
(ReviewID INT IDENTITY(1,1) PRIMARY KEY,
RatingID INT FOREIGN KEY REFERENCES tblRATING(RatingID) NOT NULL,
StreamingID INT FOREIGN KEY REFERENCES tblSTREAMING(StreamingID) NOT NULL)
GO

-- CUSTOMER_TYPE
CREATE TABLE tblCustomer_Type
(CustomerTypeID INT IDENTITY(1,1) PRIMARY KEY,
CustomerTypeName VARCHAR(500) NOT NULL,
CustomerTypeDesc VARCHAR(1000) NOT NULL)
GO

-- GENRE
create table GENRE(
GenreID int primary key identity(1,1),
GenreName varchar(30) not null,
GenreDesc varchar(500)
)

-- AUDIENCE
create table tblAUDIENCE(
AudienceID int primary key identity(1,1),
AudienceType varchar(30) not null,
AudienceDesc varchar(500))
GO


-- PRODUCTION
create table PRODUCTION(
ProductionID int primary key identity(1,1),
ProductionName varchar(100) not null,
ProductionDesc varchar(500)
)

-- PERSONNEL
create table PERSONNEL(
PersonnelID int primary key identity(1,1),
PersonnelFname varchar(30) not null,
PersonnelLname varchar(30) not null,
PersonnelDOB date
)

-- ROLE
create table ROLE(
RoleID int primary key identity(1,1),
RoleName varchar(30),
RoleDesc varchar(500)
)

-- Credit
CREATE TABLE tblCredit
(CreditID INT IDENTITY(1,1) PRIMARY KEY,
ContentID INT FOREIGN KEY REFERENCES tblContent(ContentID) NOT NULL,
ProductionID INT FOREIGN KEY REFERENCES tblProduction(ProductionID) NOT NULL,
PersonnelID INT FOREIGN KEY REFERENCES tblPersonnel(PersonnelID) NOT NULL,
RoleID INT FOREIGN KEY REFERENCES tblRole(RoleID) NOT NULL,
CreditDesc varchar(100) NOT NULL)

-- Genre_Content
CREATE TABLE tblGenre_Content
(Genre_ContentID INT IDENTITY(1,1) PRIMARY KEY,
ContentID INT FOREIGN KEY REFERENCES tblContent(ContentID) NOT NULL,
GenreID INT FOREIGN KEY REFERENCES tblGenre(GenreID) NOT NULL,
GenreContentPerc FLOAT NOT NULL)

-- Language
CREATE TABLE tblLanguage
(LanguageID INT IDENTITY(1,1) PRIMARY KEY,
LanguageShortName varchar(30) NOT NULL,
LanguageDesc varchar(200) NOT NULL)

-- Language_Content
CREATE TABLE tblLanguage_Content
(Language_ContentID INT IDENTITY(1,1) PRIMARY KEY,
LanguageID INT FOREIGN KEY REFERENCES tblLanguage(LanguageID) NOT NULL,
ContentID INT FOREIGN KEY REFERENCES tblContent(ContentID) NOT NULL)

-- HISTORY
CREATE TABLE tblHISTORY
(HistoryID INT IDENTITY(1,1) PRIMARY KEY,
StatusID INT FOREIGN KEY REFERENCES tblSTATUS(StatusID) NOT NULL,
ContentID INT FOREIGN KEY REFERENCES tblCONTENT(ContentID) NOT NULL,
HistoryDate DATE NOT NULL,
HistoryDesc VARCHAR(500) NULL)

-- STATUS (lookup table)
CREATE TABLE tblSTATUS
(StatusID INT IDENTITY(1,1), PRIMARY KEY,
StatusName VARCHAR(30) NOT NULL,
StatusDesc VARCHAR(500) NULL)
GO

-- STREAMING
CREATE TABLE tblSTREAMING
(StreamingID INT IDENTITY(1,1), PRIMARY KEY,
CustomerID INT FOREIGN KEY REFERENCES tblCUSTOMER(CustomerID) NOT NULL,
ContentID INT FOREIGN KEY REFERENCES tblCONTENT(ContentID) NOT NULL,
StreamingDate DATE NOT NULL)
GO

-- RATING (lookup table)
CREATE TABLE tblRATING
(RatingID INT IDENTITY(1,1), PRIMARY KEY,
RatingName VARCHAR(50) NOT NULL,
RatingShortName VARCHAR(30),
RatingDesc VARCHAR(500) NULL)
GO

-- Content
CREATE TABLE tblContent
(ContentID INT IDENTITY(1,1) PRIMARY KEY,
AudienceID INT FOREIGN KEY REFERENCES tblAudience(AudienceID) NOT NULL,
Content_TypeID INT FOREIGN KEY REFERENCES tblCONTENT_Type(Content_TypeID) NOT NULL,
ContentName VARCHAR(500) NOT NULL,
ContentReleaseDate DATE NOT NULL,
ContentViews INT NOT NULL)
GO

-- Content_Type (lookup table)
CREATE TABLE tblContent_Type
(ContentTypeID INT IDENTITY(1,1) PRIMARY KEY,
ContentTypeName VARCHAR(500) NOT NULL,
ContentTypeDesc VARCHAR(1000) NOT NULL)
GO
