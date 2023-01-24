-- Data cleaning and data Parsing 

--data taken from https://github.com/AlexTheAnalyst/PortfolioProjects/blob/main/Nashville%20Housing%20Data%20for%20Data%20Cleaning.xlsx
-- Nashville housing data 
-- 
SELECT *
FROM nashvillehousing

-- know the data in SQL 
exec sp_help nashvillehousing
-- have sale data standardise 
select convert(Date ,SaleDate,1)
from nashvillehousing

UPDATE nashvillehousing
SET SaleDate = convert(Date ,SaleDate,1)

-- OR 

 ALTER TABLE nashvillehousing
ALTER column  SaleDate Date; 


-- Populate Propert address data 

SELECT [UniqueID ] , count(*)
FROM nashvillehousing
group by [UniqueID ]
having count(*)>1

SELECT PropertyAddress , count(*)
FROM nashvillehousing
group by PropertyAddress
having count(*)>1

-- to know multiple parcel ids 
SELECT ParcelID , count(*)
FROM nashvillehousing
group by ParcelID
having count(*)>1

-- Populate Address with same parcelId 

--SELECT  ISNULL(nh.PropertyAddress , nh2.PropertyAddress) as PropertyAddress
--FROM NashvilleHousing nh
--JOIN NashvilleHousing nh2
--ON nh.ParcelID = nh2.ParcelID
--where nh2.PropertyAddress is null and nh.PropertyAddress is not null
--and nh.[UniqueID ]<> nh2.[UniqueID ]

Update  nh
set PropertyAddress = ISNULL(nh.PropertyAddress , nh2.PropertyAddress) 
FROM NashvilleHousing nh
JOIN NashvilleHousing nh2
ON nh.ParcelID = nh2.ParcelID
where nh2.PropertyAddress is null and nh.PropertyAddress is not null
and nh.[UniqueID ]<> nh2.[UniqueID ] 

select * from NashvilleHousing
where PropertyAddress is null


-- Now we will try to break out the address into address city and state

SELECT propertyAddress, 
SUBSTRING(propertyAddress , 1 , CHARINDEX(',',propertyaddress)-1) as Address ,
SUBSTRING(propertyAddress ,CHARINDEX(',', propertyaddress)+1 , len(PropertyAddress)) as City 

from NashvilleHousing

alter table NashvilleHousing
add split_City nvarchar(255);


update NashvilleHousing
SET split_City = SUBSTRING(propertyAddress ,CHARINDEX(',', propertyaddress)+1 , len(PropertyAddress))

alter table NashvilleHousing
add  split_Address nvarchar(255);

update NashvilleHousing
SET split_Address = SUBSTRING(propertyAddress , 1 , CHARINDEX(',',propertyaddress)-1)

SELECT * FROM NashvilleHousing


--- we can do this on owner address 

SELECT 
PARSENAME(replace(OwnerAddress,',','.') , 1 ) as own_state , 
PARSENAME(replace(OwnerAddress,',','.') , 2 ) own_city, 
PARSENAME(replace(OwnerAddress,',','.') , 3 ) own_add

ALTER TABLE NashvilleHousing
add own_state nvarchar(255) ,  own_add nvarchar(255), own_city nvarchar(255)

UPDATE  NashvilleHousing
SET own_state = PARSENAME(replace(OwnerAddress,',','.') , 1 )
, own_city=PARSENAME(replace(OwnerAddress,',','.') , 2 )
, own_add=PARSENAME(replace(OwnerAddress,',','.') , 3 )



--  changing yes and no to Y and N  

select SoldAsVacant, count(*)
from NashvilleHousing

UPDATE NashvilleHousing
SET soldasvacant = 
CASE 
		WHEN soldasvacant='Yes' then 'Y' 
		when soldasvacant='No' then 'N'
end 



-- Remove Duplicates 
SELECT * from NashvilleHousing

WITH CTE AS (	SELECT * ,
	ROW_NUMBER() over( partition by
	parcelID , propertyAddress , saleprice , saledate 
	
	order by uniqueID ) as  rn
	FROM NashvilleHousing
	)

	SELECT *   
	FROM CTE 
	where rn>1


-- Remove unused Columns 

ALTER TABLE NashvilleHousing
DROP column propertyAddress , TaxDistrict , PropertyAddress

--
