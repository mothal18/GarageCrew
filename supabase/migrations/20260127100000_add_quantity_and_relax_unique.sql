-- Migration: Add quantity and variant, relax unique constraint on toy_number
-- Description: Allow users to track multiple copies/variants of the same model
-- Strategy: Backward compatible (existing entries get quantity=1, variant=NULL)
--
-- Context: Collectors need to track variants (Mint, Opened, Treasure Hunt, etc.)
-- Each variant can have its own photos and notes, but share the same toy_number

-- Step 1: Drop the unique index on (user_id, toy_number)
-- This allows users to add multiple entries with the same toy_number
DROP INDEX IF EXISTS idx_garage_cars_user_toy_number;

-- Step 2: Add quantity column (default 1 for existing entries)
-- Represents how many copies of this specific variant the user owns
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'garage_cars' AND column_name = 'quantity'
  ) THEN
    ALTER TABLE garage_cars ADD COLUMN quantity INT DEFAULT 1 NOT NULL;
  END IF;
END $$;

-- Step 3: Add variant column (optional description)
-- Examples: "Mint in Box", "Opened", "Treasure Hunt", "Zamac", "Super Treasure Hunt"
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'garage_cars' AND column_name = 'variant'
  ) THEN
    ALTER TABLE garage_cars ADD COLUMN variant TEXT;
  END IF;
END $$;

-- Step 4: Add check constraint to ensure quantity is positive
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'chk_quantity_positive'
  ) THEN
    ALTER TABLE garage_cars
    ADD CONSTRAINT chk_quantity_positive
    CHECK (quantity > 0);
  END IF;
END $$;

-- Step 5: Create non-unique index on (user_id, toy_number) for query performance
-- This index helps with filtering and searching, but allows duplicates
CREATE INDEX IF NOT EXISTS idx_garage_cars_user_toy_number_nonunique
ON garage_cars(user_id, toy_number)
WHERE toy_number IS NOT NULL AND toy_number != '';

-- Step 6: Add column comments for documentation
COMMENT ON COLUMN garage_cars.quantity IS
'Number of copies of this specific variant (minimum: 1, default: 1)';

COMMENT ON COLUMN garage_cars.variant IS
'Optional variant description (e.g., "Mint in Box", "Opened", "Treasure Hunt", "Zamac")';
