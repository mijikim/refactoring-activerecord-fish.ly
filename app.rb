require "sinatra"
require "gschool_database_connection"
require "rack-flash"

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
      erb :signed_in, locals: {user: user}
    else
      erb :signed_out
    end
  end

  get "/register" do
    erb :register
  end

  post "/registrations" do
    if validate_registration_params
      insert_sql = <<-SQL
      INSERT INTO users (username, password)
      VALUES ('#{params[:username]}', '#{params[:password]}')
      SQL

      @database_connection.sql(insert_sql)

      flash[:notice] = "Thanks for registering"
      redirect "/"
    else
      erb :register
    end
  end

  post "/sessions" do
    user = authenticate_user

    session[:user_id] = user["id"]

    redirect "/"
  end

  private

  def validate_registration_params
    if params[:username] != "" && params[:password].length > 3
      return true
    end

    error_messages = []

    if params[:username] == ""
      error_messages.push("Username is required")
    end

    if params[:password] == ""
      error_messages.push("Password is required")
    elsif params[:password].length < 4
      error_messages.push("Password must be at least 4 characters")
    end

    flash[:notice] = error_messages.join(", ")

    false
  end

  def authenticate_user
    select_sql = <<-SQL
    SELECT * FROM users
    WHERE username = '#{params[:username]}' AND password = '#{params[:password]}'
    SQL

    @database_connection.sql(select_sql).first
  end

  def current_user
    if session[:user_id]
      select_sql = <<-SQL
      SELECT * FROM users
      WHERE id = #{session[:user_id]}
      SQL

      @database_connection.sql(select_sql).first
    else
      nil
    end
  end
end
