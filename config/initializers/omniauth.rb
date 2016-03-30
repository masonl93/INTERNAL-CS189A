Rails.application.config.middleware.use OmniAuth::Builder do

  provider :facebook, 'NULL', 'NULL'    # Replace with facebook API keys


end

