CREATE OR REPLACE STAGE airbnb_azure_stage
  STORAGE_INTEGRATION = azure_airbnb_int
  URL                 = 'azure://awstoragedatalakenew.blob.core.windows.net/airbnbdata/'
  FILE_FORMAT         = csv_format;

-- Should list: bookings.csv, hosts.csv, listings.csv
LIST @airbnb_azure_stage;
