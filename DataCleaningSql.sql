--Cleaning Data in SQL queries

SELECT *
FROM PortfolioProject..NashvilleHousing

--Standardize Date Format

SELECT SaleDateConverted,CONVERT(Date,SaleDate)
FROM PortfolioProject..NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

--------------------------------------------------------------------------------

--Populate Property Address data

SELECT *
FROM PortfolioProject..NashvilleHousing
--Where PropertyAddress is null
order by ParcelID

SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

---------------------------------------------------------------

--Breaking out Address into Individual Columns (Address,City,State)
SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing
--Where PropertyAddress is null
--order by ParcelID

SELECT 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1) as Address
,SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1 ,LEN(PropertyAddress)) as Address
	
FROM PortfolioProject..NashvilleHousing


ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1)


ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1 ,LEN(PropertyAddress))


SELECT *
FROM PortfolioProject..NashvilleHousing



SELECT OwnerAddress
FROM PortfolioProject..NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM PortfolioProject..NashvilleHousing




ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)


SELECT *
FROM PortfolioProject..NashvilleHousing

--------------------------------------------------------------------------------

--Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant),COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP by SoldAsVacant
order by 2

SELECT SoldAsVacant
,CASE When SoldAsVacant = 'Y' THEN 'Yes'
		When SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
FROM PortfolioProject..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
		When SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END

------------------------------------------------------------------

--Remove Duplicates
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY 
					UniqueID
					) row_num

FROM PortfolioProject..NashvilleHousing
--ORDER by ParcelID
)

SELECT *
FROM RowNumCTE
WHERE row_num > 1
--Order By PropertyAddress
-------------------------------------------------------

--Delete Unused Columns

SELECT *
FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress


ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN SaleDate