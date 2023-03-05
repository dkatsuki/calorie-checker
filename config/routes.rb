Rails.application.routes.draw do
  root 'pages#top'
  get 'admin', to: 'admin/pages#top'

  resources :dishes
  resources :dish_articles
  resources :foodstuffs
  resources :recipes

  namespace :admin do
    resources :foodstuffs
    resources :dishes
    resources :dish_articles do
      post :parse_markdown, on: :collection
    end
    resources :recipes
  end
end
