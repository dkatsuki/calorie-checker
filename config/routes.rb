Rails.application.routes.draw do
  root 'pages#top'
  resources :dishes
  resources :foodstuffs
  resources :recipes

  namespace :admin do
    resources :foodstuffs
  end
end
