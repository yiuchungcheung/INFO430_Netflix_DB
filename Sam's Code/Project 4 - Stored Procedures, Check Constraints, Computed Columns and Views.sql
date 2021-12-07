--												STORED PROCEDURES
use INFO_430_Proj_02a

go
create proc samw1_InsertContent
@Name varchar(100),
@Date date,
@Aud varchar(100),
@Content varchar(100)
as
begin
declare @A_ID int, @C_ID int
set @A_ID = (select AudienceID from tblAudience where AudienceType = @Aud)
if @A_ID is null
	begin;
		throw 53001, '@A_ID cannot be null', 1;
	end

begin tran t1
	insert into tblContent(ContentName, ContentReleaseDate, AudienceID)
	values(@Name, @Date, @A_ID, @C_ID)

	if @@error <> 0 
		rollback tran t1
	else
		commit tran t1
end

go 
create proc getCustTypeID
@CT varchar(100),
@CT_ID int output
as
begin 
	set @CT_ID = (select CustomerTypeID from tblCustomer_Type where CustomerTypeName = @CT)
end

-- GetIDs
go
create proc samw1_GetContentID
@Cont varchar(100),
@CID int output
as
begin
if @Cont is null
	begin;
		throw 53001, 'Given @Cont cannot be null', 1;
	end

set @CID = (select ContentID from tblContent where ContentName = @Cont)
if @CID is null
	begin;
		throw 53001, '@CID cannot be null', 1;
	end
end

go
create proc samw1_GetCustomerID
@F varchar(100),
@L varchar(100),
@B date,
@CstID int output
as
begin
if @F is null or @L is null or @B is null
	begin;
		throw 53001, 'Input parameters cannot be null', 1;
	end

set @CstID = (select CustomerID from tblCustomer where CustomerFname = @F and CustomerLname = @L and CustomerDOB = @B)
if @CstID is null
	begin;
		throw 53001, '@CstID cannot be null', 1;
	end
end


-- insert sproc
go
create proc samw1_NewStream
@Date date,
@Quality varchar(100),
@Content varchar(100),
@First varchar(100),
@Last varchar(100),
@Birth date
as
begin

declare @C_ID int, @Cst_ID int
exec samw1_GetContentID
@Cont = @Content,
@CID = @C_ID output

exec samw1_GetCustomerID
@F = @First,
@L = @Last,
@B = @Birth,
@CstID = @Cst_ID output

begin tran t1
	insert into tblStreaming(ContentID, CustomerID, StreamingDate, StreamingQuality)
	values(@C_ID, @Cst_ID, @Date, @Quality)

	if @@error <> 0
		rollback tran t1
	else
		commit tran t1
end


-- wrapper
go
create proc samw1_WRAPPER_NewStream
@run int
as
begin
declare @CustPK int,
		@ContPK int,
		@CustCount int = (select count(*) from tblCustomer),
		@ContCount int = (select count(*) from tblContent),
		@Fn varchar(100),
		@Ln varchar(100),
		@Bd varchar(100),
		@ContName varchar(100),
		@D date,
		@RandQuality int,
		@Q varchar(100)
while @run > 0
begin
	set @CustPK = (select rand() * @CustCount + 1)
	set @ContPK = (select rand() * @ContCount + 1)
	set @Fn = (select CustomerFname from tblCustomer where CustomerID = @CustPK)
	set @Ln = (select CustomerLname from tblCustomer where CustomerID = @CustPK)
	set @BD = (select CustomerDOB from tblCustomer where CustomerID = @CustPK)

	set @ContName = (select ContentName from tblContent where ContentID = @ContPK)
	set @D = (select getdate() - (rand() * 1000))
	set @RandQuality = (select round(rand() * 3, 0))
	if @RandQuality = 0
		set @Q = 'Basic'
	else if @RandQuality = 1
		set @Q = 'HD'
	else
		set @Q = 'Ultra HD'
	exec samw1_NewStream
	@Date = @D,
	@Quality = @Q,
	@Content = @ContName,
	@First = @Fn,
	@Last = @Ln,
	@Birth = @Bd

	set @run = @run - 1
end

exec samw1_WRAPPER_NewStream 10;

--																						CHECK CONSTRAINTS

-- No customer under 18 years old can stream an R rated movie
go
create function fn_NoMinorsRatedR()
returns int
as 
begin 
declare @ret int = 0
if exists (select * 
            from tblCustomer C
                join tblStreaming S on C.CustomerID = S.StreamingID
                join tblContent Co on S.ContentID = Co.ContentID
                join tblAudience A on Co.AudienceID = A.AudienceID
            where dateadd(Year, 18, C.CustomerDOB) > getdate()
                and A.AudienceType = 'R')
begin 
    set @ret = 1
end 

return @ret 
end 

go
alter table tblStreaming with nocheck 
add constraint CK_NoMinorsR
check (dbo.fn_NoMinorsRatedR() = 0)

-- no piece of Content can have a genre percentage of less than 10%.
go 
create function samw1_noGenreContentPercUnder10()
returns int 
as
begin 
    declare @ret int = 0
    if exists(
        select *
        from tblGENRE_CONTENT
        where GenreContentPerc < 10.0)
    begin
        set @ret = 1;
    end
    return @ret
end

go
alter table tblGenre_Content with nocheck
add constraint ck_NoGenreContentPercUnder10
check (dbo.noGenreContentPercUnder10() = 0)

--												COMPUTED COLUMNS

-- Find the average rating for each language 
go
create function samw1_avgLangRating(@pk int)
returns float 
as 
begin
    declare @ret float = (
    select avg(r.NumRating)
    from tblLANGUAGE l 
        join tblLANGUAGE_CONTENT lc on l.LanguageID = lc.LanguageID 
        join tblCONTENT c on lc.ContentID = c.ContentID
        join tblSTREAMING s on c.ContentID = s.ContentID
        join tblRATING r on s.RatingID = r.RatingID
    where l.LanguageID = @pk
    )
    return @ret
end

go
alter table tblLANGUAGE
add AvgLangRating as (dbo.avgLangRating(LanguageID))

select * from tblLanguage

-- find the average rating for each Production Company
go 
create function samw1_avgProdRating(@pk int)
returns float 
as 
begin 
    declare @ret float = (
        select avg(r.NumRating)
        from tblPRODUCTION p 
            join tblCredit c on p.ProductionID = c.ProductionID
            join tblContent co on c.ContentID = co.ContentID
            join tblSTREAMING s on co.ContentID = s.StreamingID 
            join tblRATING r on s.RatingID = r.RatingID
        where p.ProductionID = @pk
    )
    return @ret 
end

go
alter table tblProduction
add AvgProdRating as (dbo.avgProdRating(ProductionID))

select * from tblPRODUCTION
order by AvgProdRating desc

--													VIEWS

/*
- Total number of customers that has watched each genre since 2000
*/
go
create view samw1_view_GenreCustomerCt
as 
select g.GenreName, count(*) as TotalCustomers
from tblCUSTOMER c
    join tblSTREAMING s on c.CustomerID = s.CustomerID
    join tblCONTENT co on s.ContentID = co.ContentID
    join tblGENRE_CONTENT gc on co.ContentID = gc.ContentID
    join tblGENRE g on gc.GenreID = g.GenreID
where Year(s.StreamingDate) >= 2000
group by g.GenreName

go 
select * from view_GenreCustomerCt
order by TotalCustomers desc

-- Top genre by rating, partitioned by state
go
create view samw1_view_RankGenreByState
as 
select g.GenreName, c.CustomerState, rank() over (partition by c.CustomerState order by sum(r.NumRating) desc) as Ranking, sum(r.NumRating) as ratingSum
from tblCustomer c
    join tblSTREAMING s on c.CustomerID = s.StreamingID
    join tblContent co on s.ContentID = co.ContentID
    join tblGenre_Content gc on gc.ContentID = gc.ContentID
    join tblGenre g on gc.GenreID = g.GenreID
    join tblRATING r on s.RatingID = r.RatingID
group by g.GenreName, c.CustomerState

-- get the top 5 ranked genres by state
go
select * from view_RankGenreByState
where Ranking <= 5

--																COMPLEX QUERIES

/*
 Get the list of production companies that have had the highest average rating in a particular genre where the genrePercentage is at least 30%
*/

select p.ProductionName, avg(rt.NumRating) as AvgRating
from tblProduction p
    join tblCredit c on c.ProductionID = p.ProductionID
    join tblContent co on c.ContentID = co.ContentID
    join tblGenre_Content gc on c.ContentID = gc.ContentID
    join tblGenre g on gc.GenreID = g.GenreID
    join tblStreaming s on c.ContentID = s.ContentID
    join tblRating rt on rt.RatingID = s.RatingID
where g.GenreName = 'Horror'
    and gc.GenreContentPerc >= 30
group by p.ProductionName
order by AvgRating desc

/*
- Get the names of the personnel who have been associated with films that have an average rating of at least 4
*/
select p.PersonnelFname, p.PersonnelLname, avg(rt.NumRating) as AvgRating 
from tblPERSONNEL p
    join tblCredit c on p.PersonnelID = c.PersonnelID
    join tblCONTENT co on c.ContentID = co.ContentID
    join tblSTREAMING s on co.ContentID = s.ContentID
    join tblRATING rt on rt.RatingID = s.RatingID
group by p.PersonnelFname, p.PersonnelLname
having avg(rt.NumRating) >= 4
order by AvgRating desc