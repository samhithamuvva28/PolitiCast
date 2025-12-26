#1 Analysis of Keyword Usage in Political Articles
SELECT
    k.name AS keyword,
    COUNT(*) AS count
FROM
    dbproject-422905.archive.Articles_Fact f
JOIN
    dbproject-422905.archive.Keywords_Dimension k ON f._id = k._id
GROUP BY
    keyword
ORDER BY
    count DESC;


#2 Publication Trend Over Time

SELECT
    EXTRACT(YEAR FROM pub_date) AS year,
    COUNT(*) AS number_of_articles
FROM
    dbproject-422905.archive.Articles_Fact
GROUP BY
    year
ORDER BY
    year;


#3 Analyze Author Contributions of different authors have evolved over the years

SELECT
    EXTRACT(YEAR FROM f.pub_date) AS year,
    a.first_name,
    a.last_name,
    COUNT(*) AS articles_written
FROM
    dbproject-422905.archive.Articles_Fact f
JOIN
    dbproject-422905.archive.Author_Dimension a ON f._id = a._id
GROUP BY
    year, a.first_name, a.last_name
ORDER BY
    year, articles_written DESC;

# 4 keyword analysis to see what topics or themes were most prevalent in different years.

SELECT
    EXTRACT(YEAR FROM f.pub_date) AS year,
    k.name AS keyword,
    COUNT(*) AS keyword_count
FROM
    dbproject-422905.archive.Articles_Fact f
JOIN
    dbproject-422905.archive.Keywords_Dimension k ON f._id = k._id
GROUP BY
    year, keyword
ORDER BY
    year, keyword_count DESC;



# 5 Election-Related Media Analysis by Year and Month

WITH KeywordRanks AS (
  SELECT
    EXTRACT(YEAR FROM pub_date) AS year,
    EXTRACT(MONTH FROM pub_date) AS month,
    k.value AS keyword,
    COUNT(*) AS keyword_count
  FROM
    dbproject-422905.archive.Articles_Fact f
  JOIN
    dbproject-422905.archive.Keywords_Dimension k ON f._id = k._id
  WHERE
    k.value LIKE '%election%'
  GROUP BY
    year, month, keyword
)

SELECT
  year,
  month,
  SUM(keyword_count) AS total_election_articles,
  ARRAY_AGG(keyword ORDER BY keyword_count DESC LIMIT 5) AS top_keywords
FROM
  KeywordRanks
GROUP BY
  year, month
ORDER BY
  year, month;

#6 Region-Based Query - the distribution of articles by geographical locations, derived from keywords marked as 'glocations' in your dataset

SELECT
    k.value AS location,
    COUNT(*) AS number_of_articles
FROM
    dbproject-422905.archive.Articles_Fact f
JOIN
    dbproject-422905.archive.Keywords_Dimension k ON f._id = k._id
WHERE
    k.name = 'glocations'
GROUP BY
    k.value
ORDER BY
    number_of_articles DESC;

#7 cumulative count of articles over time, giving insights into how article production has evolved 

SELECT
    year,
    month,
    SUM(number_of_articles) OVER (ORDER BY year, month) AS cumulative_articles
FROM (
    SELECT
        EXTRACT(YEAR FROM pub_date) AS year,
        EXTRACT(MONTH FROM pub_date) AS month,
        COUNT(*) AS number_of_articles
    FROM
        dbproject-422905.archive.Articles_Fact
    GROUP BY
        year, month
)
ORDER BY
    year, month;


#8  the top 5 topics of the most frequent subjects or themes covered in the article

SELECT
    k.value AS subject,
    COUNT(*) AS number_of_mentions
FROM
    dbproject-422905.archive.Articles_Fact f
JOIN
    dbproject-422905.archive.Keywords_Dimension k ON f._id = k._id
WHERE
    k.name = 'subject'
GROUP BY
    k.value
ORDER BY
    number_of_mentions DESC
LIMIT 5;

#9 Analysis of Voter Issues Highlighted in Articles

SELECT
    k.value AS issue,
    COUNT(*) AS number_of_mentions
FROM
    dbproject-422905.archive.Articles_Fact f
JOIN
    dbproject-422905.archive.Keywords_Dimension k ON f._id = k._id
WHERE
    k.name = 'subject' AND
    (LOWER(k.value) LIKE '%healthcare%' OR
    LOWER(k.value) LIKE '%immigration%' OR
    LOWER(k.value) LIKE '%economy%')
GROUP BY
    k.value
ORDER BY
    number_of_mentions DESC;

#10 Political Article Trends by Geographic Location

SELECT
    k.value AS location,
    EXTRACT(YEAR FROM pub_date) AS year,
    COUNT(*) AS number_of_articles
FROM
    dbproject-422905.archive.Articles_Fact f
JOIN
    dbproject-422905.archive.Keywords_Dimension k ON f._id = k._id
WHERE
    k.name = 'glocations'
GROUP BY
    location, year
ORDER BY
    year, number_of_articles DESC;

# 11 Count of Articles per Year
SELECT
    EXTRACT(YEAR FROM pub_date) AS year,
    COUNT(*) AS number_of_articles
FROM
    dbproject-422905.archive.Articles_Fact
GROUP BY
    year
ORDER BY
    year;






