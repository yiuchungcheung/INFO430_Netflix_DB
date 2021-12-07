use info_430_proj_02a

-- Language
CREATE TABLE tblLanguage
(LanguageID INT IDENTITY(1,1) PRIMARY KEY,
LanguageName varchar(100) NOT NULL,
LanguageDesc varchar(200) NOT NULL)

-- GENRE
create table tblGENRE(
GenreID int primary key identity(1,1),
GenreName varchar(30) not null,
GenreDesc varchar(500)
)

-- PRODUCTION
create table tblPRODUCTION(
ProductionID int primary key identity(1,1),
ProductionName varchar(100) not null,
ProductionDesc varchar(500)
)

-- PERSONNEL
create table tblPERSONNEL(
PersonnelID int primary key identity(1,1),
PersonnelFname varchar(30) not null,
PersonnelLname varchar(30) not null,
PersonnelDOB date
)

-- ROLE
create table tblROLE(
RoleID int primary key identity(1,1),
RoleName varchar(30),
RoleDesc varchar(500)
)

CREATE TABLE tblRATING
(RatingID INT IDENTITY(1,1) PRIMARY KEY,
RatingName VARCHAR(50) NOT NULL,
RatingShortName VARCHAR(30),
RatingDesc VARCHAR(500) NULL)
GO

CREATE TABLE tblCustomer_Type
(CustomerTypeID INT IDENTITY(1,1) PRIMARY KEY,
CustomerTypeName VARCHAR(500) NOT NULL,
CustomerTypeDesc VARCHAR(1000) NOT NULL)
GO

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

-- AUDIENCE
create table tblAUDIENCE(
AudienceID int primary key identity(1,1),
AudienceType varchar(30) not null,
AudienceDesc varchar(500))
GO

CREATE TABLE tblContent
(ContentID INT IDENTITY(1,1) PRIMARY KEY,
AudienceID INT FOREIGN KEY REFERENCES tblAudience(AudienceID) NOT NULL,
ContentName VARCHAR(500) NOT NULL,
ContentReleaseDate DATE NOT NULL,
ContentViews INT NOT NULL)
GO

CREATE TABLE tblSTREAMING
(StreamingID INT IDENTITY(1,1) PRIMARY KEY,
CustomerID INT FOREIGN KEY REFERENCES tblCUSTOMER(CustomerID) NOT NULL,
ContentID INT FOREIGN KEY REFERENCES tblCONTENT(ContentID) NOT NULL,
StreamingDate DATE NOT NULL,
RatingID INT FOREIGN KEY REFERENCES tblRating(RatingID) NOT NULL)
GO

CREATE TABLE tblSTATUS
(StatusID INT IDENTITY(1,1) PRIMARY KEY,
StatusName VARCHAR(30) NOT NULL,
StatusDesc VARCHAR(500) NULL)
GO

CREATE TABLE tblHISTORY
(HistoryID INT IDENTITY(1,1) PRIMARY KEY,
StatusID INT FOREIGN KEY REFERENCES tblSTATUS(StatusID) NOT NULL,
ContentID INT FOREIGN KEY REFERENCES tblCONTENT(ContentID) NOT NULL,
HistoryDate DATE NOT NULL,
HistoryDesc VARCHAR(500) NULL)

-- Credit
CREATE TABLE tblCredit
(CreditID INT IDENTITY(1,1) PRIMARY KEY,
ContentID INT FOREIGN KEY REFERENCES tblContent(ContentID) NOT NULL,
ProductionID INT FOREIGN KEY REFERENCES tblProduction(ProductionID) NOT NULL,
PersonnelID INT FOREIGN KEY REFERENCES tblPersonnel(PersonnelID) NOT NULL,
RoleID INT FOREIGN KEY REFERENCES tblRole(RoleID) NOT NULL,
CreditDesc varchar(500) NULL)

-- Genre_Content
CREATE TABLE tblGenre_Content
(Genre_ContentID INT IDENTITY(1,1) PRIMARY KEY,
ContentID INT FOREIGN KEY REFERENCES tblContent(ContentID) NOT NULL,
GenreID INT FOREIGN KEY REFERENCES tblGenre(GenreID) NOT NULL,
GenreContentPerc decimal(5,4) NOT NULL)

-- Language_Content
CREATE TABLE tblLanguage_Content
(Language_ContentID INT IDENTITY(1,1) PRIMARY KEY,
LanguageID INT FOREIGN KEY REFERENCES tblLanguage(LanguageID) NOT NULL,
ContentID INT FOREIGN KEY REFERENCES tblContent(ContentID) NOT NULL)
