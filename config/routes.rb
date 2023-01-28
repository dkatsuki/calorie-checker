Rails.application.routes.draw do
  root 'pages#top'
  get 'dishes/index'
  get 'foodstuffs/index'
end
