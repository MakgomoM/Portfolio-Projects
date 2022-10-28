/*

Cleaning Data in SQL Queries for a Nashville Housing Data

*/

SELECT * 
FROM PortfolioProject.dbo.NashvilleHousing WITH (NOLOCK)
GO

---------------------------------------------------------------------------------------------------------------
----Standardize Date Format----
SELECT SaleDate --old saledate with the old format
FROM PortfolioProject.dbo.NashvilleHousing WITH (NOLOCK)
GO

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD SaleDateConverted Date;
GO

UPDATE PortfolioProject.dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)
GO

SELECT SaleDateConverted  ---new saledate with new format
FROM PortfolioProject.dbo.NashvilleHousing WITH (NOLOCK)
GO

--------------------------------------------------------------------------------------------------------------
-----Populate Property Address Data-----

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing WITH (NOLOCK)
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID
GO

SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing AS a WITH (NOLOCK)
JOIN PortfolioProject.dbo.NashvilleHousing AS b WITH (NOLOCK)
     ON a.ParcelID = b.ParcelID
	 AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing AS a WITH (NOLOCK)
JOIN PortfolioProject.dbo.NashvilleHousing AS b WITH (NOLOCK)
     ON a.ParcelID = b.ParcelID
	 AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

--------------------------------------------------------------------------------------------------------------

------Breaking out Address into Individual Columns(Address,City, State)------


--Breaking out Property Address---

SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL
--ORDER BY ParcelID
GO

SELECT
SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress) -1 ) AS Address
,SUBSTRING(PropertyAddress,CHARINDEX(',' , PropertyAddress) + 1, LEN(PropertyAddress)) AS Address
FROM PortfolioProject.dbo.NashvilleHousing
GO

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);
GO

UPDATE PortfolioProject.dbo.NashvilleHousing  --New split Address
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress) -1 ) 
GO

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD PropertySplitCity Nvarchar(255);
GO

UPDATE PortfolioProject.dbo.NashvilleHousing ---New split city
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',' , PropertyAddress) + 1, LEN(PropertyAddress)) 
GO

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing WITH (NOLOCK)
GO

--Breaking out Owner Address---

SELECT OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing
GO

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM PortfolioProject.dbo.NashvilleHousing
GO

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);
GO

UPDATE PortfolioProject.dbo.NashvilleHousing  --New split Address
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)
GO

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);
GO

UPDATE PortfolioProject.dbo.NashvilleHousing ---New split city
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)
GO

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitState Nvarchar(255);
GO

UPDATE PortfolioProject.dbo.NashvilleHousing ---New split city
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)
GO

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing WITH (NOLOCK)
GO


---------------------------------------------------------------------------------------------------------------------

---Change Y and N to Yes and No in"Sold as Vacant" Column--

SELECT DISTINCT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing
GO

--SELECT SoldAsVacant ,

--CASE WHEN SoldAsVacant = 'N' THEN 'No'
--     WHEN SoldAsVacant = 'Y' THEN 'Yes'
--	 ELSE SoldAsVacant
--	 END
--FROM PortfolioProject.dbo.NashvilleHousing
--GO

UPDATE PortfolioProject.dbo.NashvilleHousing
SET  SoldAsVacant = CASE WHEN SoldAsVacant = 'N' THEN 'No'
                         WHEN SoldAsVacant = 'Y' THEN 'Yes'
	                     ELSE SoldAsVacant
	                     END
GO


SELECT DISTINCT(SoldAsVacant),COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
GO

------------------------------------------------------------------------------------------------------------

---Removing Duplicates

WITH RowNumCTE AS(
SELECT *,
    ROW_NUMBER() OVER(
    PARTITION BY ParcelID,
	             PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
                 ORDER BY UniqueID) AS row_num 

FROM PortfolioProject.dbo.NashvilleHousing
)

SELECT * --DELETE FOR REMOVING DUPLICATES 
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress


---------------------------------------------------------------------------------------------------------------------

--Delete Unused Columns

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
GO

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress,SaleDate

