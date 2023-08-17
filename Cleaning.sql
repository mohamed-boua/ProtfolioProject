/*

Cleaning Data in SQL Queries

*/


Select *
From Profolio_CoviD.dbo.Nashvillehousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format


Select saleDate, CONVERT(Date,SaleDate)
From Profolio_CoviD.dbo.NashvilleHousing


Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

-- If it doesn't Update properly

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

-- My update is modify the tableu and the column complet  

Alter Table Profolio_CoviD.dbo.NashvilleHousing
alter Column saleDate date 


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select *
From Profolio_CoviD.dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID


-- bach tna7i null adk lazm dir 2 tableu w dirlhom join bch thaz mn whd w t7ot f lokhr wala t7ot f ns tableu kima lt7t 
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From Profolio_CoviD.dbo.NashvilleHousing a
JOIN Profolio_CoviD.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From Profolio_CoviD.dbo.NashvilleHousing a
JOIN Profolio_CoviD.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null




--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)
-- ra7 t9asam data t3 adress 3la 2	column 
-- SubString(string, start,lenght)
-- charindex(sub string or kalma , 'string', start )


Select PropertyAddress
From Profolio_CoviD.dbo.NashvilleHousing
--Where PropertyAddress is null
--order by ParcelID



SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
From Profolio_CoviD.dbo.NashvilleHousing


ALTER TABLE Profolio_CoviD.dbo.NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update Profolio_CoviD.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE Profolio_CoviD.dbo.NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update Profolio_CoviD.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))




Select *
From Profolio_CoviD.dbo.NashvilleHousing



Select OwnerAddress
From Profolio_CoviD.dbo.NashvilleHousing


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From Profolio_CoviD.dbo.NashvilleHousing



ALTER TABLE Profolio_CoviD.dbo.NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update Profolio_CoviD.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE Profolio_CoviD.dbo.NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update Profolio_CoviD.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE Profolio_CoviD.dbo.NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update Profolio_CoviD.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



Select *
From Profolio_CoviD.dbo.NashvilleHousing




--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From Profolio_CoviD.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2




Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From Profolio_CoviD.dbo.NashvilleHousing


Update Profolio_CoviD.dbo.NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END






-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From Profolio_CoviD.dbo.NashvilleHousing
--order by ParcelID
)

--Select *
--From RowNumCTE
--Where row_num > 1
--Order by ParcelID


DELETE
From RowNumCTE
Where row_num > 1
--Order by ParcelID



Select *
From Profolio_CoviD.dbo.NashvilleHousing



---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns



Select *
From Profolio_CoviD.dbo.NashvilleHousing


ALTER TABLE Profolio_CoviD.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate



-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

--- Importing Data using OPENROWSET and BULK INSERT	

--  More advanced and looks cooler, but have to configure server appropriately to do correctly
--  Wanted to provide this in case you wanted to try it


--sp_configure 'show advanced options', 1;
--RECONFIGURE;
--GO
--sp_configure 'Ad Hoc Distributed Queries', 1;
--RECONFIGURE;
--GO


--USE PortfolioProject 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 

--GO 


---- Using BULK INSERT

--USE PortfolioProject;
--GO
--BULK INSERT nashvilleHousing FROM 'C:\Temp\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv'
--   WITH (
--      FIELDTERMINATOR = ',',
--      ROWTERMINATOR = '\n'
--);
--GO


---- Using OPENROWSET
--USE PortfolioProject;
--GO
--SELECT * INTO nashvilleHousing
--FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
--    'Excel 12.0; Database=C:\Users\alexf\OneDrive\Documents\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv', [Sheet1$]);
--GO

