require 'net/http'
require 'uri'

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # Example endpoint that calls the backend nodejs api
  def index
    begin
      res = Net::HTTP.get_response(URI(nodejs_uri))
      if res.code == '200'
        @text = res.body
      else
        @text = "no backend found"
      end

    rescue => e
      logger.error e.message
      @text = "no backend found"
    end

    begin
      crystalres = Net::HTTP.get_response(URI(crystal_uri))
      if crystalres.code == '200'
        @crystal = crystalres.body
      else
        @crystal = "no backend found"
      end

    rescue => e
      logger.error e.message
      @crystal = "no backend found"
    end
  end

  # This endpoint is used for health checks. It should return a 200 OK when the app is up and ready to serve requests.
  def health
    render plain: "OK"
  end

  def crystal_uri
    ENV["CRYSTAL_URL"]
  end

  def nodejs_uri
    ENV["NODEJS_URL"]
  end

  before_action :discover_availability_zone
  before_action :code_hash

  def discover_availability_zone
    @az = ENV["AZ"]
  end

  def code_hash
    @code_hash = ENV["CODE_HASH"]
  end

  def custom_header
    response.headers['Cache-Control'] = 'max-age=86400, public'
  end
end
