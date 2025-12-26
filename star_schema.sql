
# Creating keywords_Dimension 

CREATE OR REPLACE TABLE dbproject-422905.archive.Keywords_Dimension AS
SELECT
    GENERATE_UUID() AS keyword_id,  -- Generating a surrogate key
    t._id AS _id,
    IFNULL(k.name, 'No Keyword') AS name,  -- Using 'No Keyword' if the array is empty
    IFNULL(k.value, 'No Value') AS value,
    IFNULL(k.rank, -1) AS rank,
    IFNULL(k.major, 'N/A') AS major
FROM
    dbproject-422905.archive.staging t
LEFT JOIN UNNEST(t.keywords) AS k ON TRUE; -- LEFT JOIN ensures inclusion of articles without keywords


# creating source_Dimension 

CREATE OR REPLACE TABLE dbproject-422905.archive.Source_Dimension AS
SELECT
    GENERATE_UUID() AS source_id,  -- Generating a unique identifier for each source entry
    _id AS _id,  -- Including article's unique identifier
    source,
    document_type,
    news_desk,
    section_name,
    subsection_name,
    COUNT(*) AS article_count  -- Counting how many times each source configuration appears
FROM
    dbproject-422905.archive.staging
GROUP BY
    _id, source, document_type, news_desk, section_name, subsection_name;

# Creating publication_Dimension 

CREATE OR REPLACE TABLE dbproject-422905.archive.Publication_Dimension AS
SELECT
    GENERATE_UUID() AS publication_id,  -- Generating a unique identifier for each source entry
    _id AS _id,  -- Including article's unique identifier
    pub_date,
    print_section,
    print_page,
    section_name,
    subsection_name,
    COUNT(*) AS article_count  -- Counting how many times each publication configuration appears
FROM
    dbproject-422905.archive.staging
GROUP BY
    _id, pub_date, print_section, print_page, section_name, subsection_name;


# creating headlines_dimension

CREATE OR REPLACE TABLE dbproject-422905.archive.Headlines_Dimension AS
SELECT
    GENERATE_UUID() AS headline_id,  -- Surrogate key for the dimension table
    _id AS _id,  -- Linking each headline back to its article
    headline.main AS main_headline,
    headline.kicker AS kicker,
    headline.content_kicker AS content_kicker,
    headline.print_headline AS print_headline,
    headline.name AS headline_name,
    headline.seo AS seo_headline,
    headline.sub AS sub_headline
FROM
    dbproject-422905.archive.staging;

# creating author_dimention 

CREATE OR REPLACE TABLE dbproject-422905.archive.Author_Dimension AS
SELECT
    GENERATE_UUID() AS author_id,  -- Surrogate key for the dimension table
    _id AS _id,  -- Linking each author back to their article
    byline.original AS byline_original,  -- Accessing the 'original' field in 'byline'
    p.firstname AS first_name,
    p.middlename AS middle_name,
    p.lastname AS last_name,
    p.qualifier AS qualifier,
    p.title AS title,
    p.role AS role,
    p.organization AS organization
FROM
    dbproject-422905.archive.staging,
    UNNEST(byline.person) AS p;  -- Extracting each person from the repeated 'person' field within 'byline'


# creating articles_fact

CREATE OR REPLACE TABLE dbproject-422905.archive.Articles_Fact AS
SELECT
    st._id AS _id,
    st.pub_date,
    st.abstract,  -- Including the abstract column
    ARRAY_AGG(DISTINCT k.keyword_id) AS keyword_ids,  -- Aggregating keyword IDs into an array
    ARRAY_AGG(DISTINCT h.headline_id) AS headline_ids,  -- Aggregating headline IDs into an array
    au.author_id,
    src.source_id,
    pub.publication_id,
    COUNT(st._id) AS article_count  -- Example metric
FROM
    dbproject-422905.archive.staging st
LEFT JOIN dbproject-422905.archive.Keywords_Dimension k ON st._id = k._id
LEFT JOIN dbproject-422905.archive.Headlines_Dimension h ON st._id = h._id
LEFT JOIN dbproject-422905.archive.Author_Dimension au ON st._id = au._id
LEFT JOIN dbproject-422905.archive.Source_Dimension src ON st._id = src._id
LEFT JOIN dbproject-422905.archive.Publication_Dimension pub ON st._id = pub._id
GROUP BY
    st._id, st.pub_date, st.abstract, au.author_id, src.source_id, pub.publication_id;







