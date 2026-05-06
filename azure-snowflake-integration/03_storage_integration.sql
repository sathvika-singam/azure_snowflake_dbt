USE ROLE ACCOUNTADMIN;

CREATE OR REPLACE STORAGE INTEGRATION azure_airbnb_int
  TYPE                      = EXTERNAL_STAGE
  STORAGE_PROVIDER          = 'AZURE'
  ENABLED                   = TRUE
  AZURE_TENANT_ID           = '<your-azure-tenant-id>'
  STORAGE_ALLOWED_LOCATIONS = (
    'azure://awstoragedatalakenew.blob.core.windows.net/airbnbdata/'
  );

-- Run this and copy AZURE_CONSENT_URL + AZURE_MULTI_TENANT_APP_NAME and complete IAM
DESC INTEGRATION azure_airbnb_int;
