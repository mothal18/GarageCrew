-- Migration: Add Toy Number field and constraints
-- Description: Add toy_number column with unique index and format validation
-- Strategy: Soft migration (allows NULL for existing data)

-- Step 1: Add toy_number column if it doesn't exist
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'garage_cars' AND column_name = 'toy_number'
  ) THEN
    ALTER TABLE garage_cars ADD COLUMN toy_number TEXT;
  END IF;
END $$;

-- Step 2: Create unique index for (user_id, toy_number) - only for non-NULL values
-- This ensures each user can only have one car with a specific toy number
CREATE UNIQUE INDEX IF NOT EXISTS idx_garage_cars_user_toy_number
ON garage_cars(user_id, toy_number)
WHERE toy_number IS NOT NULL AND toy_number != '';

-- Step 3: Add format validation constraint
-- Format: 3 uppercase letters + 2 digits (e.g., JJJ02, DTX47, K5904)
-- Only validates non-NULL and non-empty values
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'chk_toy_number_format'
  ) THEN
    ALTER TABLE garage_cars
    ADD CONSTRAINT chk_toy_number_format
    CHECK (
      toy_number IS NULL
      OR toy_number = ''
      OR toy_number ~ '^[A-Z]{3}[0-9]{2}$'
    );
  END IF;
END $$;

-- Step 4: Add column comment for documentation
COMMENT ON COLUMN garage_cars.toy_number IS
'Hot Wheels Toy Number - unique identifier for each model (format: 3 uppercase letters + 2 digits, e.g., JJJ02)';
