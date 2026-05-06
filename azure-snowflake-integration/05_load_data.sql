COPY INTO HOSTS
  FROM @airbnb_azure_stage/hosts.csv
  FILE_FORMAT = (FORMAT_NAME = 'csv_format')
  ON_ERROR    = 'CONTINUE';

COPY INTO LISTINGS
  FROM @airbnb_azure_stage/listings.csv
  FILE_FORMAT = (FORMAT_NAME = 'csv_format')
  ON_ERROR    = 'CONTINUE';

COPY INTO BOOKINGS
  FROM @airbnb_azure_stage/bookings.csv
  FILE_FORMAT = (FORMAT_NAME = 'csv_format')
  ON_ERROR    = 'CONTINUE';


SELECT 'HOSTS'    AS table_name, COUNT(*) AS row_count FROM HOSTS    UNION ALL
SELECT 'LISTINGS' AS table_name, COUNT(*) AS row_count FROM LISTINGS  UNION ALL
SELECT 'BOOKINGS' AS table_name, COUNT(*) AS row_count FROM BOOKINGS;


SELECT *
FROM INFORMATION_SCHEMA.LOAD_HISTORY
WHERE TABLE_NAME IN ('HOSTS', 'LISTINGS', 'BOOKINGS')
ORDER BY LAST_LOAD_TIME DESC;
