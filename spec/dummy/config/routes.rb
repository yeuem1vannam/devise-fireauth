Rails.application.routes.draw do
  root to: 'visitors#index'
  devise_for :users, path: '', path_names: { sign_in: 'login', sign_out: 'logout'}
  resources :users
  resources :posts
end
