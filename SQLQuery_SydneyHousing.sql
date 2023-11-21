-- Save this content in a file named "SydneyHousingCleaning.sql"

-- Date Conversion
ALTER TABLE SydneyHousing
ADD SaleDateConverted DATE;

UPDATE SydneyHousing
SET SaleDateConverted = CONVERT(DATE, SaleDate);

-- Populating Property Address Data
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM SydneyHousing a
JOIN SydneyHousing b
    ON a.ParcelID = b.ParcelID
       AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;

-- Breaking out Address into Individual Columns
ALTER TABLE SydneyHousing
ADD PropertySplitAddress VARCHAR(255);

ALTER TABLE SydneyHousing
ADD PropertySplitCity VARCHAR(255);

UPDATE SydneyHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1),
    PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress));

-- Splitting OwnerAddress into Three Parts
ALTER TABLE SydneyHousing
ADD OwnerSplitAddress VARCHAR(255);

ALTER TABLE SydneyHousing
ADD OwnerSplitCity VARCHAR(255);

ALTER TABLE SydneyHousing
ADD OwnerSplitState VARCHAR(255);

UPDATE SydneyHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
    OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
    OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);

-- Changing 'Y' and 'N' to 'Yes'
