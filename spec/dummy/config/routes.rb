RailsApp::Application.routes.draw do
  resources :foos
  get "foo/two_in_one" => "foos#two_in_one", as: :two_in_one
  root to: 'foos#index'
end
