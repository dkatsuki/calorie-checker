Rails.application.routes.draw do
  root 'pages#top'
  resources :dishes
  resources :foodstuffs
  resources :recipes
end
