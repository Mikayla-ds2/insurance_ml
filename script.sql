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

COPY insurance(age, sex, bmi, children, smoker, region, charges)
FROM '/Users/mikayla/insurance_ml/insurance.csv'
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

select distinct * from insurance

select * from insurance

-- proves no duplicates; actually will not work bc of the distinct patient_id -- 

select count(*) from insurance

-- data.head() --
select * from insurance
limit 10

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
where patient_id = 582

-- verifying --
select * from insurance
where (age, sex, bmi, children, smoker, region, charges) in (
    select age, sex, bmi, children, smoker, region, charges from insurance
    group by age, sex, bmi, children, smoker, region, charges
    having count(*) > 1);

select count(*) from insurance

select DISTINCT region, count(*) as region_count from insurance
group by region

select * from insurance

-- be careful of this; decent data imbalance -- 
select DISTINCT smoker, count(*) as smoker_count from insurance
GROUP BY smoker