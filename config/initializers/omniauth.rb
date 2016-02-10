Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, '999266156778410', 'acfe9ca3316d262cbc32053b2e5f90b4'
end