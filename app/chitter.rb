ENV["RACK_ENV"] ||= "development"

require 'sinatra/base'
require 'sinatra/flash'
require_relative 'data_mapper_setup'

class Chitter < Sinatra::Base

  use Rack::MethodOverride
  register Sinatra::Flash
  enable :sessions
  set :session_secret, 'super secret'

  helpers do
    def current_user
      @current_user ||= User.get(session[:user_id])
    end
  end

  get '/' do
    if current_user
      redirect to '/home'
    else
      redirect to '/users/new'
    end
  end

  get '/home' do
    erb(:home)
  end

  get '/users/new' do
    @user = User.new
    erb(:'users/new')
  end

  post '/users' do
    @user = User.create(name: params[:name],
                        username: params[:username],
                        email: params[:email],
                        password: params[:password],
                        password_confirmation: params[:password_confirmation])
    if @user.save
      session[:user_id] = @user.id
      redirect to '/home'
    else
      flash.now[:errors] = @user.errors.full_messages
      erb(:'users/new')
    end
  end

  get '/sessions' do
    erb(:'sessions/index')
  end

  post '/sessions/new' do
    @user = User.authenticate(params[:email], params[:password])
    if @user
      session[:user_id] = @user.id
      redirect to '/home'
    else
      flash.now[:errors] = 'Incorrect email or password'
      erb(:'sessions/index')
    end
  end

  delete '/sessions' do
    session[:user_id] = nil
    flash.keep[:notice] = "You are logged out. See you next time!"
    redirect to '/sessions/end'
  end

  get '/sessions/end' do
    erb(:'sessions/end')
  end

  post '/chitter/new' do
    current_user = User.get(session[:user_id])
    current_user.posts.create(message: params[:message],
                              timestamp: Time.now.strftime("%I:%M%p %m/%d/%Y"))
    redirect to '/home'
  end

  delete '/chitter/delete' do
    Post.get(params[:delete_id]).destroy
    redirect to '/home'
  end

  post '/comments/new' do
    comment = Comment.create(comment: params[:comment],
                             timestamp: Time.now.strftime("%I:%M%p %m/%d/%Y"))
    current_user = User.get(session[:user_id])
    post = Post.get(params[:comment_id])
    current_user.comments << comment
    current_user.save
    post.comments << comment
    post.save
    redirect to '/home'
  end

  # start the server if ruby file executed directly
  run! if app_file == $0
end
