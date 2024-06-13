SELECT *
FROM imdb_top_1000;


-- Movies per years
SELECT Released_Year, COUNT(*) Movie_Count
FROM imdb_top_1000
GROUP BY Released_Year
ORDER BY 2 DESC;


-- Top 5 directors with the most movies
SELECT TOP 5 Director, COUNT(*) Movie_Count
FROM imdb_top_1000
GROUP BY Director
ORDER BY Movie_Count DESC;


-- Actors appear more than 3 movies
SELECT Star1, COUNT(*) Total_Movies
FROM (
    SELECT Series_Title, Star1
    FROM imdb_top_1000
    UNION ALL 
    SELECT Series_Title, Star2
    FROM imdb_top_1000
    UNION ALL 
    SELECT Series_Title, Star3
    FROM imdb_top_1000
    UNION ALL 
    SELECT Series_Title, Star4
    FROM imdb_top_1000) AS Unnested_Stars
GROUP BY Star1
HAVING COUNT(*) > 3
ORDER BY Total_Movies DESC;


-- Top 10 box office revenue
SELECT TOP 10 Series_Title, MAX(Gross) Gross
FROM imdb_top_1000
GROUP BY Series_Title
ORDER BY Gross DESC;


-- Top_Rated_Movies From IMDB and Meta_score
SELECT Top_Rated_Movies, Rating,
CASE
    WHEN Rank_ = 1 THEN 'IMDB_Highest_Rating_Movie'
END AS Highest_Rating_Category
FROM (
    SELECT Series_Title AS Top_Rated_Movies, MAX(IMDB_Rating) AS Rating, RANK() OVER(ORDER BY MAX(IMDB_Rating) DESC) Rank_
    FROM imdb_top_1000
    GROUP BY Series_Title) Rating
WHERE Rank_ = 1
UNION
SELECT Top_Rated_Movies, Rating,
CASE
    WHEN Rank_ = 1 THEN 'MeatScore_Highest_Rating_Movie'
END AS Highest_Rating_Category
FROM (
    SELECT Series_Title AS Top_Rated_Movies, MAX(Meta_score) AS Rating, RANK() OVER(ORDER BY MAX(Meta_score) DESC) Rank_
    FROM imdb_top_1000
    GROUP BY Series_Title) Rating
WHERE Rank_ = 1
ORDER BY Rating DESC;


-- Classifying Movies by Runtime: Short, Medium, and Long
SELECT 
    CASE 
        WHEN Runtime BETWEEN 0 AND 80 THEN 'Short'
        WHEN Runtime BETWEEN 81 AND 150 THEN 'Medium'
        ELSE 'Long'
    END AS Movie_Runtime_Categories, COUNT(*) Movie_Count
FROM imdb_top_1000
GROUP BY 
    CASE 
        WHEN Runtime BETWEEN 0 AND 80 THEN 'Short'
        WHEN Runtime BETWEEN 81 AND 150 THEN 'Medium'
        ELSE 'Long'
    END
ORDER BY Movie_Count DESC;