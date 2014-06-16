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


class StashPathInfoInGlobal
  def initialize(app)
    @app = app
  end

  def call(env)
    $last_path_info = env['PATH_INFO']
    @app.call(env)
  end
end

module DataCollecting
  class Engine < ::Rails::Engine
    isolate_namespace DataCollecting
  end
end

class TestApp < Rails::Application
  config.root = File.dirname(__FILE__)
  config.secret_key_base = 'secret_key_base'

  config.logger = Logger.new($stdout)
  Rails.logger  = config.logger

  routes.draw do
    namespace :admin do
      mount DataCollecting, at: "/data_collecting"
    end
  end
end


require 'minitest/autorun'
require 'rack/test'

class BugTest < Minitest::Test
  include Rack::Test::Methods

  def test_at_root
    get '/path'
    assert_equal "Rendering from DemoRackApp.", last_response.body
  end

  def test_at_deeper_mountpoint
    get '/deeper_mountpoint/path'
    assert_equal "Rendering from DemoRackApp.", last_response.body
  end

  def test_path_info_at_root
    get '/path'
    assert_equal "/path", $last_path_info
  end

  def test_path_info_at_deeper_mountpoint
    get '/deeper_mountpoint/path'
    assert_equal "/path", $last_path_info
  end

  private
    def app
      Rails.application
    end
end

