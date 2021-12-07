USE INFO_430_Proj_02A;
select * from 
--- Find the total number of “horror” movies that had a rating over 4/5 and the language is not in English

SELECT COUNT(*) AS TotalHorror
FROM tblCONTENT C 
 JOIN tblGENRE_CONTENT GC ON GC.ContentID = C.ContentID
 JOIN tblGENRE G ON G.GenreID = GC.GenreID
 JOIN tblLANGUAGE_CONTENT LC ON LC.ContentID = C.ContentID
 JOIN tblLANGUAGE L ON L.LanguageID = LC.LanguageID
 JOIN tblSTREAMING S ON S.ContentID = C.ContentID
 JOIN tblRATING R ON R.RatingID = S.RatingID
 WHERE G.GenreName = 'Horror'
	AND L.LanguageShortName != 'en'
	AND R.NumRating >= 4

-- Get the top 2 highest rated movies in each year from 2010 - 2020

WITH CTE_TOP_RATED (Movie, StreamingYear,Rating, DenseRanky)
AS(
SELECT C.ContentName, YEAR(S.StreamingDate) AS [YEAR], AVG(RT.NumRating), DENSE_RANK() OVER (PARTITION BY YEAR(S.StreamingDate) ORDER BY AVG(RT.NumRating) DESC)
FROM tblCONTENT C
 JOIN tblSTREAMING S ON S.ContentID = C.ContentID
 JOIN tblRATING RT ON RT.RatingID = S.RatingID
 WHERE YEAR(S.StreamingDate) BETWEEN 2010 AND 2020
 GROUP BY C.ContentName, S.StreamingDate)
SELECT * FROM CTE_TOP_RATED
WHERE DenseRanky <= 2


