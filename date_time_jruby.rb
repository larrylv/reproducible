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

class DateTimeBugTest < ActiveSupport::TestCase

  test "a PDT parsed DateTime should convert to_i and back again" do
    original_date=DateTime.parse('2014-04-05T23:59:59-07:00')
    assert original_date == DateTime.strptime(original_date.to_i.to_s, '%s')
  end

  test "a GMT parsed DateTime should convert to_i and back again" do
    original_date=DateTime.parse('2014-04-05T23:59:59-00:00')
    assert original_date == DateTime.strptime(original_date.to_i.to_s, '%s')
  end

  test "a constructed PDT DateTime should convert to_i and back again" do
    original_date = DateTime.new(2014, 4, 5, 23, 59, 59, Rational(-7, 24))
    assert original_date == DateTime.strptime(original_date.to_i.to_s, '%s')
  end

  test "a constructed GMT DateTime should convert to_i and back again" do
    original_date = DateTime.new(2014, 4, 5, 23, 59, 59)
    assert original_date == DateTime.strptime(original_date.to_i.to_s, '%s')
  end

  test "a constructed PDT DateTime at midnight should convert to_i and back again" do
    original_date = DateTime.new(2014, 4, 5, 0, 0, 0, Rational(-7, 24))
    assert original_date == DateTime.strptime(original_date.to_i.to_s, '%s')
  end

  test "a constructed PDT DateTime at 23:59:00 should convert to_i and back again" do
    original_date = DateTime.new(2014, 4, 5, 23, 59, 0, Rational(-7, 24))
    assert original_date == DateTime.strptime(original_date.to_i.to_s, '%s')
  end

end
