/*
cleaning Data in sql Queries
*/

select * 
from PortfolioProject.dbo.NashvilleHousing

----------------------------------------------

/*
standrize Data Fomat
*/
select SaleDateConverted , convert(Date,SaleDate)
from PortfolioProject.dbo.NashvilleHousing

update NashvilleHousing
set SaleDate = convert(Date,SaleDate)

Alter Table NashvilleHousing
Add SaleDateConverted Date ;

update NashvilleHousing
SET SaleDateConverted = convert (Date,SaleDate)

------------------------------------------------------

--- populate property address date

select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing
--- where property address is null
order by ParcelID


select a.ParcelID , a.PropertyAddress , b.ParcelID , b.PropertyAddress , isnull( a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b 
     on a.ParcelID = b.ParcelID
	 And a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null 

update a 
SET PropertyAddress = isnull (a.PropertyAddress,b.PropertyAddress) 
from PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b 
     on a.ParcelID = b.ParcelID
	 And a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null 

---------------------------------------------------------------------------------
--- Breaking out Address into individual Columns (Address,city,state)

select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing

select 
substring (PropertyAddress,1,charindex(',',PropertyAddress)-1) as Address
,substring (PropertyAddress,charindex(',',PropertyAddress)+1,len(PropertyAddress)) as Address
from PortfolioProject.dbo.NashvilleHousing

Alter Table NashvilleHousing
Add PropertySplitAddres nvarchar(255) ;

update NashvilleHousing
SET PropertySplitAddres = substring (PropertyAddress,1,charindex(',',PropertyAddress)-1)


Alter Table NashvilleHousing
Add PropertySplitCity nvarchar(255) ;

update NashvilleHousing
SET PropertySplitCity = substring (PropertyAddress,charindex(',',PropertyAddress)+1,len(PropertyAddress))

select OwnerAddress
from PortfolioProject.dbo.NashvilleHousing

select 
PARSENAME (replace(OwnerAddress,',','.'),3)      ---- go backword 
,PARSENAME (replace(OwnerAddress,',','.'),2)
,PARSENAME (replace(OwnerAddress,',','.'),1)
from PortfolioProject.dbo.NashvilleHousing



Alter Table NashvilleHousing
Add OwnerSplitAddress nvarchar(255) ;

update NashvilleHousing
SET OwnerSplitAddress = PARSENAME (replace(OwnerAddress,',','.'),3)


Alter Table NashvilleHousing
Add OwnerSplitCity nvarchar(255) ;

update NashvilleHousing
SET OwnerSplitCity = PARSENAME (replace(OwnerAddress,',','.'),2)


Alter Table NashvilleHousing
Add OwnerSplitState nvarchar(255) ;

update NashvilleHousing
SET OwnerSplitState = PARSENAME (replace(OwnerAddress,',','.'),1)

select * 
from PortfolioProject.dbo.NashvilleHousing

----------------------------------------------------------------------------------
--- change y and n to yes and no in "sold as vacant" field 

select distinct (SoldAsVacant) , count(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant
order by 2



select SoldAsVacant
, case when SoldAsVacant = 'Y' THEN 'Yes'
     when SoldAsVacant = 'N' THEN 'No'
	 ElSE SoldAsVacant
	 END
from PortfolioProject.dbo.NashvilleHousing

update NashvilleHousing
SET SoldAsVacant = case when SoldAsVacant = 'Y' THEN 'Yes'
     when SoldAsVacant = 'N' THEN 'No'
	 ElSE SoldAsVacant
	 END
---------------------------------------------------------------------------
--- Remove Duplicates

with RowNumCTE AS (
select * ,
   Row_Number() over (
   partition by ParcelID,
                PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY 
				UniqueID
				) row_num 
from portfolioproject.dbo.NashvilleHousing 
)

select *  
from RowNumCTE
where row_num > 1  
order by PropertyAddress

----------------------------------------------------------------
--- Delete Unused Columns 

select *  
from PortfolioProject.dbo.NashvilleHousing

Alter Table PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict , PropertyAddress



Alter Table PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate