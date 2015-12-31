Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, '458736997659776', '152116713f49785846298cbaf6e86437'
end