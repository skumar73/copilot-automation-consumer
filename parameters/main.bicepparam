using '../main.bicep'

param appName = 'orders'
param env     = 'dev'
param tags = {
  application: 'orders'
  environment: 'dev'
  costCenter:  'adusa-platform'
}
