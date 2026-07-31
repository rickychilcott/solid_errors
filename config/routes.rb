SolidErrors::Engine.routes.draw do
  get "/", to: "errors#index", as: :root

  resources :errors, only: [:index, :show, :update, :destroy], path: "" do
    resources :occurrences, only: [:show]
  end
end
