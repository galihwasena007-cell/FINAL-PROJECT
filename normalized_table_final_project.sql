USE company_enrich;

SELECT * FROM companies_raw;

CREATE TABLE locations (
    location_id  INT AUTO_INCREMENT PRIMARY KEY,
    country      VARCHAR(100),
    state        VARCHAR(100),
    city         VARCHAR(150),
    UNIQUE (country, state, city)
);
CREATE TABLE industries (
    industry_id    INT AUTO_INCREMENT PRIMARY KEY,
    industry_name  VARCHAR(150) UNIQUE
);
CREATE TABLE revenue_brackets (
    revenue_id  INT AUTO_INCREMENT PRIMARY KEY,
    label       VARCHAR(50) UNIQUE
);
CREATE TABLE employee_brackets (
    emp_bracket_id INT AUTO_INCREMENT PRIMARY KEY,
    label          VARCHAR(50) UNIQUE
);

INSERT INTO locations (country, state, city)
SELECT DISTINCT
    country,
    state,
    city
FROM companies_raw
WHERE country IS NOT NULL AND country <> '';

INSERT INTO industries (industry_name)
SELECT DISTINCT main_industry
FROM companies_raw
WHERE main_industry IS NOT NULL AND main_industry <> '';

INSERT INTO employee_brackets (label)
SELECT DISTINCT employees
FROM companies_raw
WHERE employees IS NOT NULL AND employees <> '';

INSERT INTO revenue_brackets (label)
SELECT DISTINCT revenue
FROM companies_raw
WHERE revenue IS NOT NULL AND revenue <> '';

SELECT * FROM locations LIMIT 5;
SELECT * FROM industries LIMIT 5;
SELECT * FROM employee_brackets;
SELECT * FROM revenue_brackets;

CREATE TABLE companies (
    company_id       INT AUTO_INCREMENT PRIMARY KEY,
    name             VARCHAR(255),
    domain           VARCHAR(255),
    
    location_id      INT,
    industry_id      INT,
    emp_bracket_id   INT,
    revenue_id       INT,
    
    founded_year     INT,
    founded_year_num INT,
    company_type     VARCHAR(50),

    employees_num    INT,
    revenue_num      BIGINT,

    categories_list  TEXT,
    category_primary VARCHAR(150),

    FOREIGN KEY (location_id)      REFERENCES locations(location_id),
    FOREIGN KEY (industry_id)      REFERENCES industries(industry_id),
    FOREIGN KEY (emp_bracket_id)   REFERENCES employee_brackets(emp_bracket_id),
    FOREIGN KEY (revenue_id)       REFERENCES revenue_brackets(revenue_id)
);

INSERT INTO companies (
    name,
    domain,
    location_id,
    industry_id,
    emp_bracket_id,
    revenue_id,
    founded_year,
    founded_year_num,
    company_type,
    employees_num,
    revenue_num,
    categories_list,
    category_primary
)
SELECT
    r.name,
    r.domain,
    loc.location_id,
    ind.industry_id,
    eb.emp_bracket_id,
    rb.revenue_id,

    -- founded_year (text) → NULL if invalid
    CASE 
        WHEN r.founded_year = 'Unknown' OR r.founded_year = '' THEN NULL
        ELSE r.founded_year
    END AS founded_year,

    -- founded_year_num (int) → NULL if 'None'
    CASE 
        WHEN r.founded_year_num = 'None' OR r.founded_year_num = '' THEN NULL
        ELSE r.founded_year_num
    END AS founded_year_num,

    r.type,
    r.employees_num,
    r.revenue_num,
    r.categories_list,
    r.category_primary
FROM companies_raw r
LEFT JOIN locations         AS loc ON r.country       = loc.country
                                   AND r.state         = loc.state
                                   AND r.city          = loc.city
LEFT JOIN industries        AS ind ON r.main_industry = ind.industry_name
LEFT JOIN employee_brackets AS eb  ON r.employees     = eb.label
LEFT JOIN revenue_brackets  AS rb  ON r.revenue       = rb.label;

SELECT COUNT(*) FROM companies;
SELECT * FROM companies LIMIT 10;




