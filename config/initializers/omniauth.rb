Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, '721955464606146', '9b0e2bd86dc652a59ce90eb29effbc55'
end