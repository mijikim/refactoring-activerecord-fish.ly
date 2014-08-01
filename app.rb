require "sinatra"
require "gschool_database_connection"
require "rack-flash"
require 'sinatra/base'
require 'action_view'
require 'active_support'
require './models/user'
require './models/fish'


class App < Sinatra::Application
  enable :sessions
  use Rack::Flash

  def initialize
    super
    @database_connection = GschoolDatabaseConnection::DatabaseConnection.establish(ENV["RACK_ENV"])
  end

  get "/" do
    user = current_user

    if current_user
      users = User.where("id != ?", user[:id])
      fish = Fish.where(user_id: current_user[:id])
      erb :signed_in, locals: {current_user: user, users: users, fish_list: fish}
    else
      erb :signed_out
    end
  end

  get "/register" do
    erb :register
  end

  post "/registrations" do

    if validate_registration_params
      user = User.create(username: params[:username], password: params[:password])
      user.errors.messages
      flash[:notice] = "Thanks for registering"
      redirect "/"
    else
      erb :register
    end
  end

  post "/sessions" do
    if validate_authentication_params
      user = authenticate_user

      if user != nil
        session[:user_id] = user["id"]
      else
        flash[:notice] = "Username/password is invalid"
      end
    end

    redirect "/"
  end

  delete "/sessions" do
    session[:user_id] = nil
    redirect "/"
  end

  delete "/users/:id" do
    User.find(params[:id]).destroy
    redirect "/"
  end

  get "/fish/new" do
    erb :"fish/new", locals: {fish: Fish.new}
  end

  get "/fish/:id" do
    fish = Fish.find(params[:id])
    erb :"fish/show", locals: {fish: fish}
  end

  post "/fish" do
    fish = Fish.new(name: params[:name], wikipedia_page: params[:wikipedia_page], user_id: current_user[:id])

    if fish.save
      flash[:notice] = "Fish Created"

      redirect "/"
    else
      erb :"fish/new", locals: {fish: fish}
    end
  end

  private

  def validate_registration_params

    if params[:username] != "" && params[:password].length > 3 && username_available?(params[:username])
      return true
    end

    error_messages = []

    if params[:username] == ""
      error_messages.push("Username is required")
    end

    if !username_available?(params[:username])
      error_messages.push("Username has already been taken")
    end

    if params[:password] == ""
      error_messages.push("Password is required")
    elsif params[:password].length < 4
      error_messages.push("Password must be at least 4 characters")
    end

    flash[:notice] = error_messages.join(", ")

    false
  end

  def validate_authentication_params
    if params[:username] != "" && params[:password] != ""
      return true
    end

    error_messages = []

    if params[:username] == ""
      error_messages.push("Username is required")
    end

    if params[:password] == ""
      error_messages.push("Password is required")
    end

    flash[:notice] = error_messages.join(", ")

    false
  end

  def username_available?(username)
    existing_users =
      User.find_by_username(username)
    existing_users == nil
  end

  def authenticate_user
    User.find_by(username: params[:username], password: params[:password])
  end

  def current_user
    if session[:user_id]
      User.find(session[:user_id])
    else
      nil
    end
  end
end