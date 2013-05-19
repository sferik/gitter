Gitter::Application.routes.draw do
  get '/statusboard(.json)', controller: 'api', action: 'statusboard'
end
