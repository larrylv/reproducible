unless File.exist?('Gemfile')
  File.write('Gemfile', <<-GEMFILE)
    source 'https://rubygems.org'
    gem 'rails', github: 'rails/rails'
    gem 'arel', github: 'rails/arel'
  GEMFILE

  system 'bundle'
end

require 'bundler'
Bundler.setup(:default)

require 'rails'
require 'action_controller/railtie'

class TestApp < Rails::Application
  config.root = File.dirname(__FILE__)
  config.session_store :cookie_store, key: 'cookie_store_key'
  config.secret_token    = 'secret_token'
  config.secret_key_base = 'secret_key_base'

  config.logger = Logger.new($stdout)
  Rails.logger  = config.logger

  routes.draw do
    get 'without_respond_to' => 'test#without_respond_to'
    get 'with_respond_to' => 'test#with_respond_to'
  end
end

class TestController < ActionController::Base
  include Rails.application.routes.url_helpers

  def without_respond_to
  end

  def with_respond_to
    respond_to do |format|
      format.html
    end
  end
end

require 'minitest/autorun'
require 'rack/test'

class BugTest < Minitest::Test
  include Rack::Test::Methods

  def test_without_respond_to
    header 'Accept', 'images/jpeg'
    get 'without_respond_to'
    assert_equal 406, last_response.status
  end

  def test_with_respond_to
    header 'Accept', 'images/jpeg'
    get 'with_respond_to'
    assert_equal 406, last_response.status
  end

  private
    def app
      Rails.application
    end
end

