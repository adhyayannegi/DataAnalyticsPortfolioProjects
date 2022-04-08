/*
Cleaning Data in SQL Queries
*/


Select *
From PortfolioProject.dbo.NashvilleHousing


--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

update NashvilleHousing -- didnt work
set SaleDate=convert(date,SaleDate)
Select convert(date,SaleDate) as SaleDate
From PortfolioProject.dbo.NashvilleHousing

alter table NashvilleHousing -- add new column
add SaleDateconverted Date;

update NashvilleHousing
set SaleDateconverted=convert(date,SaleDate)


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data (Replacing Nulls)


Select *
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID



Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

select * from  PortfolioProject.dbo.NashvilleHousing a
Where a.PropertyAddress is null


--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

--Splitting Property Address using substring

select PropertyAddress,* from  PortfolioProject.dbo.NashvilleHousing 

select SUBSTRING(PropertyAddress,1,(CHARINDEX(',',propertyaddress)-1)) as Address,
SUBSTRING(PropertyAddress,(CHARINDEX(',',propertyaddress)+1),LEN(PropertyAddress)) as Address2
from  PortfolioProject.dbo.NashvilleHousing 


alter table NashvilleHousing -- add new column
add PropertySplitAddress nvarchar(255),
 PropertySplitCity nvarchar(255);

update NashvilleHousing
set PropertySplitAddress=SUBSTRING(PropertyAddress,1,(CHARINDEX(',',propertyaddress)-1))

update NashvilleHousing
set PropertySplitCity=SUBSTRING(PropertyAddress,(CHARINDEX(',',propertyaddress)+1),LEN(PropertyAddress))

--Splitting Owner Address using parsename and replace

select parsename(replace(OwnerAddress,',','.'),3),
parsename(replace(OwnerAddress,',','.'),2),
parsename(replace(OwnerAddress,',','.'),1),* from  PortfolioProject.dbo.NashvilleHousing 

alter table NashvilleHousing -- add new column
add OwnerSplitAddress nvarchar(255),
 OwnerSplitCity nvarchar(255),
 OwnerSplitState nvarchar(255);

 
update NashvilleHousing
set OwnerSplitAddress=parsename(replace(OwnerAddress,',','.'),3),
OwnerSplitCity=parsename(replace(OwnerAddress,',','.'),2),
OwnerSplitState=parsename(replace(OwnerAddress,',','.'),1)
from  PortfolioProject.dbo.NashvilleHousing 


select PropertySplitAddress,PropertySplitCity,OwnerSplitAddress,OwnerSplitCity,OwnerSplitState,* from  PortfolioProject.dbo.NashvilleHousing 


--------------------------------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" field
 
 select distinct SoldAsVacant from  PortfolioProject.dbo.NashvilleHousing 

 select soldasvacant ,
 CASE WHEN soldasvacant='Y' then 'Yes'
  WHEN soldasvacant='N' then 'No'
 Else SoldAsVacant
 end
 from  PortfolioProject.dbo.NashvilleHousing 


 update NashvilleHousing
 set soldasvacant=CASE WHEN soldasvacant='Y' then 'Yes'
  WHEN soldasvacant='N' then 'No'
 Else SoldAsVacant
 end
 from  PortfolioProject.dbo.NashvilleHousing 


 
-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH CTE_Rownum AS(
Select *,
	rank() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProject.dbo.NashvilleHousing)
--order by ParcelID

Select *
--delete
From CTE_Rownum
Where row_num > 1
Order by PropertyAddress;


---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns



Select *
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate

EXEC sp_rename 'PortfolioProject.dbo.NashvilleHousing.SalePrice', 'SaleDate'



Select *
From PortfolioProject.dbo.NashvilleHousing