require 'sinatra'
require 'sinatra/reloader'
require 'slim'
require 'sqlite3'
require 'bcrypt'

get('/') do 
    slim(:register)
end 

get('/post') do 
    db = SQLite3::Database.new("db/forum.db")
    @result = db.execute("SELECT * FROM post")
    db.results_as_hash = true

    slim(:post)
end 


get('/post/new') do 
    slim(:postnew)
end

post('/post/new') do 

    title = params[:title]
    content = params[:content]
    tags = params[:tags]
    p "vi får in datan #{title}, #{content}, #{tags}"
    db = SQLite3::Database.new("db/forum.db")
    db.execute("INSERT INTO post(Title, Content, Tags) VALUES (?,?,?)", title, content, tags)
    redirect('/post')
end

get('/login') do 

slim(:login)
end


post('/login') do
    name = params[:name]
    password = params[:password]
    db = SQLite3::Database.new('db/forum.db')
    db.results_as_hash = true
    result = db.execute("SELECT * FROM user WHERE name = ?", name).first
    password = result["password"]
    id = result["id"]
  
    if BCrypt::Password.new(password) == password 
      session[:id] = id
      redirect('/post')
      
    else
      "Wrong password or user doesn't exist"
    end
  
  end


post('/users/new') do 
    name = params[:name]
    password = params[:password]
    password_confirm = params[:password_confirm]
  
    if (password == password_confirm )
      password = BCrypt::Password.create(password)
      db = SQLite3::Database.new('db/forum.db')
      db.execute("INSERT INTO user (name,password) VALUES (?,?)", name, password)
      redirect('/')
  
    else
  
      "username and password dont match"
    end
  
  end 