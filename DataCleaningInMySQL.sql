### Data Cleaning
-- (1) Remove Duplicates
-- (2) Standardize the Data
-- (3) Null Values or Blank Values
-- (4) Remove Any Columns or Rows


##Create a New Table Seperate from the Raw Data

Create Table layoffs_staging 
LIKE layoffs

--Insert Data into New Table

Select *
From layoffs_staging;

INSERT layoffs_staging
Select *
From layoffs;


##Identify Any Duplicates

Select *,
Row_Number() Over(
	Partition by company, location, industry, total_laid_off, percentage_laid_off, 'date', stage, country, funds_raised_millions) AS row_num
From layoffs_staging;

With duplicate_cte AS 
(
Select *,
Row_Number() Over(
	Partition by company, location, industry, total_laid_off, percentage_laid_off, 'date', stage, country, funds_raised_millions) AS row_num
From layoffs_staging
)
Select *
From duplicate_cte
WHERE row_num > 1;

--Double Check if rows returned are Duplicates

Select *
From layoffs_staging
Where company = '';

--Remove Duplicates

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT 
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO layoffs_staging2
Select *,
Row_Number() Over(
	Partition by company, location, industry, total_laid_off, percentage_laid_off, 'date', stage, country, funds_raised_millions) AS row_num
From layoffs_staging;

Select * 
From layoffs_staging2
Where row_num > 1;

Delete 
From layoffs_staging2
Where row_num > 1;

--Check if Duplicates were Deleted

Select * 
From layoffs_staging2
Where row_num > 1;


##Standardizing Data

Select Distinct company
From layoffs_staging2

Select company, (Trim(company))
From layoffs_staging2;

Update layoffs_staging2
Set company = (Trim(company));
--
Select Distinct industry
From layoffs_staging2
Order by 1;
--
Select Distinct location
From layoffs_staging2
Order by 1;
--
Select Distinct country
From layoffs_staging2
Order by 1;

Select * 
From layoffs_staging2
Where country Like 'United States%';

Select Distinct country, Trim(Trailing '.' From country)
From layoffs_staging2
Order by 1;

Update layoffs_staging2
Set country = Trim(Trailing '.' From country)
Where country Like 'United States%';
--
Select date,
From layoffs_staging2;

Select date,
Str_to_date(date,'%m/%d/%Y')
From layoffs_staging2;

Update layoffs_staging2
Set date = Str_to_date(date,'%m/%d/%Y')

Alter Table layoffs_staging2
Modify Column date DATE;


##Working with Nulls/Blank Values

Select *
From layoffs_staging2
Where total_laid_off is NULL;

Select *
From layoffs_staging2
Where total_laid_off is NULL And percentage_laid_off is NULL;

Select * 
From layoffs_staging2
Where industry is NULL Or industry = '';

Select * 
From layoffs_staging2
Where company = 'Airbnb';

--Set Blank Industry Values as Null
Update layoffs_staging2
Set industry = NULL
Where industry = '';

--Populate Null Industry Values
Select *
From layoffs_staging2 t1 
Join layoffs_staging2 t2
	on t1.company = t2.company 
Where (t1.industry is NULL And t2.industry is NOT NULL);

Select t1.industry, t2.industry
From layoffs_staging2 t1 
Join layoffs_staging2 t2
	on t1.company = t2.company 
Where (t1.industry is NULL And t2.industry is NOT NULL);

Update layoffs_staging2 t1
Join  layoffs_staging2 t2
	on t1.company = t2.company
Set t1.industry = t2.industry
Where (t1.industry is NULL And t2.industry is NOT NULL);

Select *
From layoffs_staging2
Where company Like 'Bally%';


##Remove Any Column/Row

Select *
From layoffs_staging2
Where total_laid_off is NULL And percentage_laid_off is NULL;

Delete
From layoffs_staging2
Where total_laid_off is NULL And percentage_laid_off is NULL;

Select *
From layoffs_staging2;

Alter Table layoffs_staging2
Drop Column row_num;
--





















































