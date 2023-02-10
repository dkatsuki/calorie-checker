Rails.application.routes.draw do
  root 'pages#top'
  get 'admin', to: 'admin/pages#top'

  resources :dishes
  resources :foodstuffs
  resources :recipes

  namespace :admin do
    resources :foodstuffs
    resources :dishes
    resources :recipes
  end
end
