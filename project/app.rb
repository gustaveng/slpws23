require 'sinatra'
require 'sinatra/reloader'
require 'slim'
require 'sqlite3'
require 'bcrypt'
enable :sessions

before do
    db = SQLite3::Database.new("db/forum.db")
    if !session[:id].nil?
      session[:name] = db.execute("SELECT name FROM user WHERE id = ?", [session[:id]]).first
    else
      redirect('/login') unless ['/login', '/users/new'].include?(request.path_info)
    end
  end
  
  get('/') do
    redirect('/login')
  end

get('/post') do 
    db = SQLite3::Database.new("db/forum.db")
    db.results_as_hash = true
    @result = db.execute("SELECT post.title, post.content, post.tags, user.name, user.role FROM post INNER JOIN user ON post.user_id=user.id")
    slim(:post)
  end

  get('/your_post') do 

    id = session[:id].to_i
    db = SQLite3::Database.new("db/forum.db")
    db.results_as_hash = true
    @result = db.execute("SELECT * FROM post WHERE user_id = ?", id)
    slim(:your_post)
  end

  get('/logout') do
    session[:id] = nil
    redirect('/login')
  end

get('/post/new') do 
    slim(:postnew)
end

post('/post/new') do 

    title = params[:title]
    content = params[:content]
    tags = params[:tags]
    user_id = session[:id]
    # @current_user = db.execute('SELECT name FROM user WHERE id = ?', user_id)
    puts @current_user
    p "vi får in datan #{title}, #{content}, #{tags}"
    db = SQLite3::Database.new("db/forum.db")
    db.execute("INSERT INTO post(Title, Content, Tags, user_id) VALUES (?,?,?,?)", title, content, tags, user_id)
    redirect('/post')
end

get('/login') do 
slim(:login, layout:false)
end

post('/login') do
    name = params[:name]
    password = params[:password]
    db = SQLite3::Database.new('db/forum.db')
    db.results_as_hash = true
    result = db.execute("SELECT * FROM user WHERE name = ?", name).first
    if result
        pwdigest = result["pwdigest"]
        id = result["id"]
  
        if BCrypt::Password.new(pwdigest) == password 
            session[:id] = id
            redirect('/post')     
        else
            "Wrong password or user doesn't exist"
        end
    else
        "You have to create an account first!"
    end
  end

  post('/users/new') do 
    name = params[:name]
    password = params[:password]
    password_confirm = params[:password_confirm]
  
    if password == password_confirm
      password = BCrypt::Password.create(password)
      db = SQLite3::Database.new('db/forum.db')
      db.execute("INSERT INTO user (name, pwdigest) VALUES (?,?)", name, password)
      redirect('/')
    else
      "username and password don't match"
    end
  end
  
  get('/users/new') do 
    slim(:register, layout:false)
  end

  post('/your_post/:id/delete') do 
    id = params[:id].to_i
    db = SQLite3::Database.new("db/forum.db")
    db.execute("DELETE FROM post WHERE id = ?", id)
    redirect ('/your_post')
  end
 
  post('/your_post/:id/update') do 
    id = params[:id].to_i
    content = params[:edit_post]
    db = SQLite3::Database.new("db/forum.db")
    db.execute("UPDATE post SET content = ? WHERE id = ?", content, id)
    redirect ('/your_post')
  end
  