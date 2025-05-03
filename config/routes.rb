Rails.application.routes.draw do
  get "example_basic_product_data_sheet/show", as: :example_basic_product_data_sheet
  get "example_advanced_pagedjs_interface/show", as: :example_advanced_pagedjs_interface
  get "example_book_spread/show", as: :example_book_spread

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "example_routes#index"
end
