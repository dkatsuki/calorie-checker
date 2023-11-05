Rails.application.routes.draw do
  root 'pages#top'
  get 'admin', to: 'admin/pages#top'
  get 'about_us', to: 'pages#about_us'

  get 'contact', to: 'contacts#new'
  post 'contact', to: 'contacts#create'

  resources :dishes
  resources :contact
  resources :dish_articles
  resources :foodstuffs
  resources :recipes

  namespace :admin do
    resources :foodstuffs
    resources :dishes
    resources :dish_articles do
      post :parse_markdown, on: :collection
      post :generate_article, on: :collection, defaults: { format: 'json' }
    end
    resources :recipes
  end
end
