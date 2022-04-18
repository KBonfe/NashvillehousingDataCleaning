SELECT * FROM [dbo].[Nashvillehouseing]

--Changing Sale Date from Date/Time format to only Date format--

SELECT SaleDate, CONVERT(Date,SaleDate)
FROM [dbo].[Nashvillehouseing]

ALTER TABLE [dbo].[Nashvillehouseing]--adding a new column to put the transformed data in keeping original data if needed
ADD SaleDateConverted Date;

UPDATE [dbo].[Nashvillehouseing]--converting the date into all the same date format so it is easier to use
SET SaleDateConverted = CONVERT(Date,SaleDate)

SELECT SaleDateConverted  FROM [dbo].[Nashvillehouseing]

--Populate Property Address Data

SELECT *
FROM [dbo].[Nashvillehouseing]
--where PropertyAddress is null
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, --Doing a self join in order to see if we can replace null property addresses with the correct address Utilizing the Parcel ID to find duplicates
	ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [dbo].[Nashvillehouseing] a
JOIN [dbo].[Nashvillehouseing] b
	ON a.ParcelID =b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress) --Doing a self join to replace null property addresses because the information was in another column --using ISNULL function to do the replacement
FROM [dbo].[Nashvillehouseing] a
JOIN [dbo].[Nashvillehouseing] b
	ON a.ParcelID =b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

--Breaking out Property Address into Individual Columns (Address, City).
	--substring and character

SELECT PropertyAddress
FROM [dbo].[Nashvillehouseing]

SELECT 
SUBSTRING(PropertyAddress,1, CHARINDEX (',', PropertyAddress)-1) AS StreetAddress, --Using SUBSTRING function to pull only street address from the property address --CHARINDEX TELLS US A POSITION IN A NUMBER
SUBSTRING(PropertyAddress, CHARINDEX (',', PropertyAddress)+1, LEN(PropertyAddress)) AS City
FROM [dbo].[Nashvillehouseing]

ALTER TABLE [dbo].[Nashvillehouseing]--creating a new column to put Street address data into
ADD PropertySplitAddress NVARCHAR(255);

UPDATE [dbo].[Nashvillehouseing]
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1, CHARINDEX (',', PropertyAddress)-1) --Putting the extracted data into its own column

ALTER TABLE [dbo].[Nashvillehouseing]--creating a new column to put City data into
ADD PropertySplitCity NVARCHAR(255);

UPDATE [dbo].[Nashvillehouseing]
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX (',', PropertyAddress)+1, LEN(PropertyAddress))--Now using SUBSTRING to extract the City

SELECT PropertySplitAddress, PropertySplitCity FROM [dbo].[Nashvillehouseing]

-- Breaking out Address for Owner address (Address, City, State) 
	--Using Parsename
SELECT * FROM [dbo].[Nashvillehouseing]

SELECT 
PARSENAME (REPLACE(OwnerAddress,',','.'), 3) AS StreetAdress,--using PARSENAME to pull the individual data from Owner Address
PARSENAME (REPLACE(OwnerAddress,',','.'), 2) AS City,
PARSENAME (REPLACE(OwnerAddress,',','.'), 1) AS State
FROM [dbo].[Nashvillehouseing]

ALTER TABLE [dbo].[Nashvillehouseing]--Creating a new column to put Address data into
ADD StreetAddressOwner NVARCHAR(255);

UPDATE [dbo].[Nashvillehouseing]
SET  StreetAddressOwner= PARSENAME (REPLACE(OwnerAddress,',','.'), 3) --putting the extracted address data into its own column

ALTER TABLE [dbo].[Nashvillehouseing]--Creating a new column to put City data into
ADD CityOwner NVARCHAR(255);

UPDATE [dbo].[Nashvillehouseing]
SET CityOwner = PARSENAME (REPLACE(OwnerAddress,',','.'), 2)--putting the extracted city data into its own column

ALTER TABLE [dbo].[Nashvillehouseing]--Creating a new column to put State data into
ADD StateOwner NVARCHAR(255);

UPDATE [dbo].[Nashvillehouseing]
SET StateOwner = PARSENAME (REPLACE(OwnerAddress,',','.'), 1)--putting the extracted state data into its own column

SELECT StreetAddressOwner, CityOwner, StateOwner FROM [dbo].[Nashvillehouseing]

--Change Y to Yes and N to NO in the SoldasVacant field to Standardize the field
	--Using Case Statement

SELECT DISTINCT (SoldAsVacant), COUNT(SoldAsVacant)
FROM [dbo].[Nashvillehouseing]
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM [dbo].[Nashvillehouseing]

UPDATE [dbo].[Nashvillehouseing]
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM [dbo].[Nashvillehouseing]

SELECT * FROM [dbo].[Nashvillehouseing]

SELECT DISTINCT (SoldAsVacant), COUNT(SoldAsVacant) --checking to see if worked
FROM [dbo].[Nashvillehouseing]
GROUP BY SoldAsVacant
ORDER BY 2

--Remove Duplicates
	--only do this with a working database not an original
	--Using a CTE

WITH RowNumCTE AS (			--EXPLORE
SELECT *,
	ROW_NUMBER () OVER (
	PARTITION BY	ParcelID,
					PropertyAddress,
					SalePrice,
					SaleDate, 
					LegalReference
	ORDER BY UniqueID) row_num
FROM [dbo].[Nashvillehouseing]
)
SELECT * FROM RowNumCTE
WHERE row_num >1 
ORDER BY PropertyAddress


WITH RowNumCTE AS (				--DELETE MULITPLES
SELECT *,
	ROW_NUMBER () OVER (
	PARTITION BY	ParcelID,
					PropertyAddress,
					SalePrice,
					SaleDate, 
					LegalReference
	ORDER BY UniqueID) row_num
FROM [dbo].[Nashvillehouseing]
)

DELETE
FROM RowNumCTE
WHERE row_num >1 


WITH RowNumCTE AS (				--CHECK WORK
SELECT *,
	ROW_NUMBER () OVER (
	PARTITION BY	ParcelID,
					PropertyAddress,
					SalePrice,
					SaleDate, 
					LegalReference
	ORDER BY UniqueID) row_num
FROM [dbo].[Nashvillehouseing]
)
SELECT * FROM RowNumCTE
WHERE row_num >1 
ORDER BY PropertyAddress

--Delete Unused Columns
--Again not done to raw data!  Working database!

SELECT * FROM [dbo].[Nashvillehouseing]

ALTER TABLE [dbo].[Nashvillehouseing]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate