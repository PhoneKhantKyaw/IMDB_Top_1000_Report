SELECT
    *
FROM
    Portfolio_Project_Esport.dbo.players;

-- change columns name for players table
EXEC sp_rename 'Portfolio_Project_Esport.dbo.players.PlayerId',
'player_id',
'COLUMN';

EXEC sp_rename 'Portfolio_Project_Esport.dbo.players.NameFirst',
'firstname',
'COLUMN';

EXEC sp_rename 'Portfolio_Project_Esport.dbo.players.NameLast',
'lastname',
'COLUMN';

EXEC sp_rename 'Portfolio_Project_Esport.dbo.players.CurrentHandle',
'nickname',
'COLUMN';

EXEC sp_rename 'Portfolio_Project_Esport.dbo.players.CountryCode',
'country_code',
'COLUMN';

EXEC sp_rename 'Portfolio_Project_Esport.dbo.players.TotalUSDPrize',
'earnings_usd',
'COLUMN';

EXEC sp_rename 'Portfolio_Project_Esport.dbo.players.Game',
'game',
'COLUMN';

EXEC sp_rename 'Portfolio_Project_Esport.dbo.players.Genre',
'genre',
'COLUMN';

-- update uppercase on country_code
UPDATE Portfolio_Project_Esport.dbo.players
SET
    country_code = UPPER(country_code);

-- total earnings by each game category
SELECT
    game,
    ROUND(SUM(earnings_usd), 2) earnings
FROM
    Portfolio_Project_Esport.dbo.players
GROUP BY
    game
ORDER BY
    earnings DESC;

-- average earnings per game category
SELECT
    game,
    ROUND(AVG(earnings_usd), 2) earnings
FROM
    Portfolio_Project_Esport.dbo.players
GROUP BY
    game
ORDER BY
    earnings DESC;

-- top 10 highest earnings players
SELECT
    Top 10
    nickname,
    game,
    earnings_usd
FROM
    Portfolio_Project_Esport.dbo.players
ORDER BY
    earnings_usd DESC;

-- highest earning players on each game
SELECT
    nickname,
    game,
    earnings_usd
FROM
    (
        SELECT
        nickname,
        game,
        earnings_usd,
        Rank() OVER (
                PARTITION BY
                    game
                ORDER BY
                    earnings_usd DESC
            ) ranked
    FROM
        Portfolio_Project_Esport.dbo.players
    ) subquery
WHERE
    ranked = 1
ORDER BY
    earnings_usd DESC;

SELECT
    *
FROM
    Portfolio_Project_Esport.dbo.country_and_continent;

-- drop column and change columns name for country_and_continent table
ALTER TABLE Portfolio_Project_Esport.dbo.country_and_continent
DROP COLUMN Three_Letter_Country_Code;

EXEC sp_rename 'Portfolio_Project_Esport.dbo.country_and_continent.Continent_Name',
'continent_name',
'COLUMN';

EXEC sp_rename 'Portfolio_Project_Esport.dbo.country_and_continent.Continent_Code',
'continent_code',
'COLUMN';

EXEC sp_rename 'Portfolio_Project_Esport.dbo.country_and_continent.Country_Name',
'country_name',
'COLUMN';

EXEC sp_rename 'Portfolio_Project_Esport.dbo.country_and_continent.Two_Letter_Country_Code',
'country_code',
'COLUMN';

EXEC sp_rename 'Portfolio_Project_Esport.dbo.country_and_continent.Country_Number',
'country_number',
'COLUMN';

-- create new column and update to fix country names
ALTER TABLE Portfolio_Project_Esport.dbo.country_and_continent ADD country_name_fixed NVARCHAR (255);

UPDATE Portfolio_Project_Esport.dbo.country_and_continent
SET
    country_name_fixed = CASE
        WHEN CHARINDEX (',', country_name) > 0 THEN LEFT (country_name, CHARINDEX (',', country_name) -1)
        ELSE country_name
    END;

-- total player per country
SELECT
    country_name_fixed AS country_name,
    COUNT(*) player_count
FROM
    Portfolio_Project_Esport.dbo.players players
    JOIN Portfolio_Project_Esport.dbo.country_and_continent country ON players.country_code = country.country_code
GROUP BY
    country_name_fixed
ORDER BY
    player_count DESC;

-- total player per country per game
SELECT
    country_name_fixed AS country_name,
    game,
    COUNT(*) player_count
FROM
    Portfolio_Project_Esport.dbo.players players
    JOIN Portfolio_Project_Esport.dbo.country_and_continent country ON players.country_code = country.country_code
GROUP BY
    country_name_fixed,
    game
ORDER BY
    game,
    country_name,
    player_count DESC;

-- avg earnings per country
SELECT
    country_name_fixed AS country_name,
    ROUND(AVG(earnings_usd), 2) earnings
FROM
    Portfolio_Project_Esport.dbo.players players
    JOIN Portfolio_Project_Esport.dbo.country_and_continent country ON players.country_code = country.country_code
GROUP BY
    country_name_fixed
ORDER BY
    earnings DESC;

-- top 3 countries in terms of total prize money earned by players
SELECT
    Top 3
    country_name_fixed AS country_name,
    COUNT(nickname) players,
    ROUND(SUM(earnings_usd), 2) earnings
FROM
    Portfolio_Project_Esport.dbo.players players
    JOIN Portfolio_Project_Esport.dbo.country_and_continent country ON players.country_code = country.country_code
GROUP BY
    country_name_fixed
ORDER BY
    earnings DESC;

-- the highest earning player from each continent.
WITH
    ContinentEarnings
    AS
    (
        SELECT
            nickname,
            continent_name,
            game,
            earnings_usd,
            RANK() OVER (
                PARTITION BY
                    continent_name
                ORDER BY
                    earnings_usd DESC
            ) Rank
        FROM
            Portfolio_Project_Esport.dbo.players players
            JOIN Portfolio_Project_Esport.dbo.country_and_continent country ON players.country_code = country.country_code
    )
SELECT
    nickname,
    continent_name,
    game,
    earnings_usd
FROM
    ContinentEarnings
WHERE
    Rank = 1;

-- the average prize money earned by players for each game genre.
SELECT
    genre,
    ROUND(AVG(earnings_usd), 2) average_prize_money
FROM
    Portfolio_Project_Esport.dbo.players players
    JOIN Portfolio_Project_Esport.dbo.country_and_continent country ON players.country_code = country.country_code
GROUP BY
    genre
ORDER BY
    average_prize_money DESC;

-- the most playing game from each continent.
WITH
    MostPlayingGame
    AS
    (
        SELECT
            continent_name,
            game,
            COUNT(*) player_count,
            RANK() OVER (
                PARTITION BY
                    continent_name
                ORDER BY
                    COUNT(*) DESC
            ) rank
        FROM
            Portfolio_Project_Esport.dbo.players players
            JOIN Portfolio_Project_Esport.dbo.country_and_continent country ON players.country_code = country.country_code
        GROUP BY
            continent_name,
            game
    )
SELECT
    continent_name,
    game,
    player_count
FROM
    MostPlayingGame
WHERE
    rank = 1;

-- the top 5 players with the highest average prize money per game genre.
WITH
    PlayerGenreEarnings
    AS
    (
        SELECT
            nickname,
            genre,
            AVG(earnings_usd) OVER (
                PARTITION BY
                    players.nickname,
                    players.genre
            ) avg_prize_money_per_genre
        FROM
            Portfolio_Project_Esport.dbo.players players
            JOIN Portfolio_Project_Esport.dbo.country_and_continent country ON players.country_code = country.country_code
    ),
    RankedPlayerGenreEarnings
    AS
    (
        SELECT
            nickname,
            genre,
            avg_prize_money_per_genre,
            ROW_NUMBER() OVER (
                PARTITION BY
                    genre
                ORDER BY
                    avg_prize_money_per_genre DESC
            ) rank
        FROM
            PlayerGenreEarnings
    )
SELECT
    nickname,
    genre,
    avg_prize_money_per_genre
FROM
    RankedPlayerGenreEarnings
WHERE
    rank <= 5;