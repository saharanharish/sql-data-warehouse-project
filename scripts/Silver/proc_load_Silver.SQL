USE DataWarehouse;
GO

-- Declare timing variables
DECLARE @start_time DATETIME,
        @end_time DATETIME;

BEGIN TRY

    SET @start_time = GETDATE();

    PRINT '========================================';
    PRINT 'Loading Silver Product Information';
    PRINT '========================================';

    -- Clear existing Silver product data
    PRINT '>> Truncating Table: silver.crm_prd_info';

    TRUNCATE TABLE silver.crm_prd_info;

    -- Insert transformed product data
    PRINT '>> Inserting Data Into: silver.crm_prd_info';

    INSERT INTO silver.crm_prd_info (
        prd_id,
        cat_id,
        prd_key,
        prd_nm,
        prd_cost,
        prd_line,
        prd_start_dt,
        prd_end_dt
    )
    SELECT
        prd_id,

        -- Extract category ID
        REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,

        -- Extract product key
        SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,

        -- Source column is prd_name; destination column is prd_nm
        prd_name,

        -- Replace missing costs with zero
        ISNULL(prd_cost, 0) AS prd_cost,

        -- Standardize product line
        CASE UPPER(TRIM(prd_line))
            WHEN 'M' THEN 'Mountain'
            WHEN 'R' THEN 'Road'
            WHEN 'S' THEN 'Other Sales'
            WHEN 'T' THEN 'Touring'
            ELSE 'n/a'
        END AS prd_line,

        -- Convert start date
        CAST(prd_start_dt AS DATE) AS prd_start_dt,

        -- End date is one day before the next version starts
        CAST(
            DATEADD(
                DAY,
                -1,
                LEAD(prd_start_dt) OVER (
                    PARTITION BY prd_key
                    ORDER BY prd_start_dt
                )
            ) AS DATE
        ) AS prd_end_dt

    FROM bronze.crm_prd_info;

    SET @end_time = GETDATE();

    PRINT '>> Load Duration: '
        + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(20))
        + ' seconds';

    PRINT '>> Product loading completed successfully.';

END TRY

BEGIN CATCH

    PRINT 'ERROR OCCURRED DURING PRODUCT LOADING';
    PRINT 'Error Number: '
        + CAST(ERROR_NUMBER() AS NVARCHAR(20));
    PRINT 'Error Message: ' + ERROR_MESSAGE();

    THROW;

END CATCH;
GO

-- Verify the loaded data
SELECT COUNT(*) AS total_rows
FROM silver.crm_prd_info;

SELECT TOP 20 *
FROM silver.crm_prd_info;
