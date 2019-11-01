Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root to: 'application#index'
  
  get 'debug' => 'application#debug'
  
  get 'standings' => 'application#standings'
  get 'bracket' => 'application#bracket'
end
