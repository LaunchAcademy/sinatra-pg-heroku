require 'sinatra'
require 'sinatra/reloader'
require 'pg'

def production_database_config
  db_url_parts = ENV['DATABASE_URL'].split(/\/|:|@/)

  {
    user: db_url_parts[3],
    password: db_url_parts[4],
    host: db_url_parts[5],
    dbname: db_url_parts[7]
  }
end

configure :development do
  set :database_config, { dbname: 'birds_dev' }
end

configure :production do
  set :database_config, production_database_config
end

def db_connection
  begin
    connection = PG.connect(settings.database_config)
    yield(connection)
  ensure
    connection.close
  end
end

def all_birds
  db_connection do |conn|
    conn.exec('SELECT * FROM birds')
  end
end

get '/' do
  @birds = all_birds
  erb :index
end
