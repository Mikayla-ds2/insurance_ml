-- Active: 1758170477555@@127.0.0.1@5432
DROP TABLE IF EXISTS insurance;

CREATE TABLE IF NOT EXISTS insurance (
    patient_id SERIAL PRIMARY KEY,
    age INT,
    sex VARCHAR(10),
    bmi FLOAT,
    children INT,
    smoker VARCHAR(5),
    region VARCHAR(20),
    charges FLOAT
);

SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'insurance';

/COPY insurance(age, sex, bmi, children, smoker, region, charges)
FROM '/tmp/insurance.csv'
DELIMITER ','
CSV HEADER;

select * from insurance;

-- database & table is workingg; now begin cleaning -- 
select * from insurance
where patient_id is null 
or age is NULL 
or region is null 
or sex is null 
or bmi is null 
or children is null 
or smoker is null 
or charges is null;

select distinct * from insurance;

select * from insurance;

-- proves no duplicates; actually will not work bc of the distinct patient_id -- 

select count(*) from insurance;

-- data.head() --
select * from insurance
limit 10;

-- checking a duplicated value; seems pandas picked up on something sql didn't --
select * from insurance
where region = 'northwest'
and age = 19 and bmi  = 30.59;

-- checking a chat query for duplicates; sure does, patient_id won't ever have a "duplicate" 
-- bc it's a primary key so not present, count shows how many duplicates
select age, sex, bmi, children, smoker, region, charges, count(*) as count from insurance
group by age, sex, bmi, children, smoker, region, charges
having count(*) > 1;

-- showing patient_id; won't necessarily show number of duplicates but yk look with your eyes lol --
select * from insurance
where (age, sex, bmi, children, smoker, region, charges) in (
    select age, sex, bmi, children, smoker, region, charges from insurance
    group by age, sex, bmi, children, smoker, region, charges
    having count(*) > 1);

-- deleting duplicates; ha made a mistake here; needed to only delete one of the rows, not both -- 
DELETE from insurance
where patient_id = 582;

-- verifying --
select * from insurance
where (age, sex, bmi, children, smoker, region, charges) in (
    select age, sex, bmi, children, smoker, region, charges from insurance
    group by age, sex, bmi, children, smoker, region, charges
    having count(*) > 1);

select count(*) from insurance;

-- verifying imbalances -- 
select DISTINCT region, count(*) as region_count from insurance
group by region;
-- quite balanced (324, 324, 364, 325)  mean is 334 --

select DISTINCT smoker, count(*) as smoker_count from insurance
GROUP BY smoker;
-- heavily imbalanced (1063, 274) mean is 668

select DISTINCT sex, count(*) as sex_count from insurance
group by sex
-- balanced (662, 675 ) mean is 668

select DISTINCT children, count(*) as children_count from insurance
group by children
ORDER BY children asc;
-- quite imbalanced (573, 324, 240, 157, 25, 18)  mean = 222 --

-- creating this table to utilize numerical => categorical features to check for "imbalance"
CREATE TABLE IF NOT EXISTS insurance_categorical (
    patient_id SERIAL PRIMARY KEY,
    age INT,
    sex VARCHAR(10),
    bmi FLOAT,
    children INT,
    smoker VARCHAR(5),
    region VARCHAR(20),
    charges FLOAT,
    age_category VARCHAR(20),
    bmi_category VARCHAR(20)
);

-- adding the data --
COPY insurance_categorical(age, sex, bmi, children, smoker, region, charges, age_category, bmi_category)
FROM '/Users/mikayla/insurance_ml/cleaned_data.csv'
DELIMITER ','
CSV HEADER;

select * from insurance_categorical;

-- allows me to run the queries to check for "imbalance"
select insurance_categorical.age_category, count(*) as age_category_count from insurance
join insurance_categorical on insurance.patient_id = insurance_categorical.patient_id
group by insurance_categorical.age_category
order by insurance_categorical.age_category asc;
-- balanced (305, 268, 263, 284, 216) mean = 267

-- now looking @ bmi --
select insurance_categorical.bmi_category, count(*) as bmi_category_count from insurance
join insurance_categorical on insurance.patient_id = insurance_categorical.patient_id
group by insurance_categorical.bmi_category;
-- quite imbalanced (Underweight: 21, Normal: 226, Overweight: 386, Obese: 703) mean = 334


-- men vs. women bmi --
select insurance.sex, insurance_categorical.bmi_category, count(*) as count from insurance
join insurance_categorical on insurance.patient_id = insurance_categorical.patient_id
group by insurance.sex, insurance_categorical.bmi_category
order by insurance.sex;
-- much more even than imagined, man this would hit different if i could see the race of these individuals as well --

-- might be dealing with a duplicate issue; there's a one row difference that i don't care enough to find icl --
select insurance.age, insurance.sex, insurance.bmi, insurance.children, insurance.smoker, insurance.region, insurance.charges, insurance_categorical.age_category, insurance_categorical.bmi_category, count(*) as count 
from insurance
join insurance_categorical on insurance.patient_id = insurance_categorical.patient_id
group by insurance.age, insurance.sex, insurance.bmi, insurance.children, insurance.smoker, insurance.region, insurance.charges, insurance_categorical.age_category, insurance_categorical.bmi_category
having count(*) > 1;

CREATE TABLE IF NOT EXISTS insurance_errors (
    patient_id SERIAL PRIMARY KEY,
    age INT,
    sex VARCHAR(10),
    bmi FLOAT,
    children INT,
    smoker VARCHAR(5),
    region VARCHAR(20),
    charges FLOAT,
    age_category VARCHAR(20),
    bmi_category VARCHAR(20)
);

-- adding the data --
COPY insurance_categorical(age, sex, bmi, children, smoker, region, charges, age_category, bmi_category)
FROM '/Users/mikayla/insurance_ml/cleaned_data.csv'
DELIMITER ','
CSV HEADER;
