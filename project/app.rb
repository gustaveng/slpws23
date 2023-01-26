require 'sinatra'
require 'sinatra/reloader'
require 'slim'
require 'sqlite3'

get('/') do 
    
    slim(:post)
end 

get('/post') do 

end 


get('/post/new') do 
    slim(:postnew)
end

post('post/new') do 


end 
