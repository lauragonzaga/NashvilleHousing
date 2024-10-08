/* CLEANING DATA WITH SQL */

/* This project was created following Alex The Analyst's tutorial, but most of these queries I wrote on my own. */

SELECT *
FROM PortfolioProject..nashvilleHousing;

-----------------------------------------------------------------------------------------------

-- Standardizing Date Format

ALTER TABLE PortfolioProject..nashvilleHousing
ALTER COLUMN  SaleDate DATE;


-----------------------------------------------------------------------------------------------

-- Populating Property Address Data

SELECT *
FROM PortfolioProject..nashvilleHousing
WHERE PropertyAddress IS NULL;



SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, 
		ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..nashvilleHousing a
JOIN PortfolioProject..nashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..nashvilleHousing a
JOIN PortfolioProject..nashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID


-----------------------------------------------------------------------------------------------

-- Breaking out Property Address Into Individual Columns (Address, City)

SELECT PropertyAddress, 
	TRIM(SUBSTRING(PropertyAddress, 0, CHARINDEX(',', PropertyAddress))) AS Address,
	TRIM(SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+2, LEN(PropertyAddress))) AS City
FROM PortfolioProject..nashvilleHousing



ALTER TABLE PortfolioProject..nashvilleHousing
ADD  PropertySplitAddress nvarchar(255)

UPDATE PortfolioProject..nashvilleHousing
SET  PropertySplitAddress = TRIM(SUBSTRING(PropertyAddress, 0, CHARINDEX(',', PropertyAddress)))


ALTER TABLE PortfolioProject..nashvilleHousing
ADD  PropertySplitCity nvarchar(255)

UPDATE PortfolioProject..nashvilleHousing
SET  PropertySplitCity = TRIM(SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+2, LEN(PropertyAddress)))




-- Breaking out Owner Address Into Individual Columns (Address, City, State)


SELECT 
	TRIM(PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)) AS Address,
	TRIM(PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)) AS City,
	TRIM(PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)) AS State
FROM PortfolioProject..NashvilleHousing


ALTER TABLE PortfolioProject..nashvilleHousing
ADD OwnerSplitAddress nvarchar(255)


UPDATE PortfolioProject..nashvilleHousing
SET OwnerSplitAddress = TRIM(PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3))



ALTER TABLE PortfolioProject..nashvilleHousing
ADD OwnerSplitCity nvarchar(255)

UPDATE PortfolioProject..nashvilleHousing
SET OwnerSplitCity = TRIM(PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2))



ALTER TABLE PortfolioProject..nashvilleHousing
ADD OwnerSplitState  nvarchar(255)


UPDATE PortfolioProject..nashvilleHousing
SET OwnerSplitState = TRIM(PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1))


-----------------------------------------------------------------------------------------------


-- Changing 'Yes' and 'No' to 'Y' or 'N' in SoldAsVacant


SELECT DISTINCT SoldAsVacant
FROM PortfolioProject..NashvilleHousing


SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Yes' THEN 'Y'
			WHEN SoldAsVacant = 'No' THEN 'N'
			ELSE SoldAsVacant 
			END AS NewSoldAsVacant
FROM PortfolioProject..NashvilleHousing


UPDATE PortfolioProject..NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Yes' THEN 'Y'
					WHEN SoldAsVacant = 'No' THEN 'N'
					ELSE SoldAsVacant 
					END



-----------------------------------------------------------------------------------------------

-- Removing Duplicates

with cte as
(
SELECT ROW_NUMBER() over(PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
						ORDER BY UniqueID) Row_num,
		*
FROM PortfolioProject..nashvilleHousing
)

DELETE
FROM cte
WHERE row_num >1




-----------------------------------------------------------------------------------------------


-- Deleting Unused Columns

SELECT * FROM PortfolioProject..nashvilleHousing


ALTER TABLE PortfolioProject..nashvilleHousing
DROP COLUMN TaxDistrict, OwnerAddress, PropertyAddress