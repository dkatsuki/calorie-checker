Rails.application.routes.draw do
  get 'recipes/index'
  root 'pages#top'
  resources :dishes
  resources :foodstuffs
  
end
