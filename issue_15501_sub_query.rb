unless File.exist?('Gemfile')
  File.write('Gemfile', <<-GEMFILE)
    source 'https://rubygems.org'
    gem 'rails', github: 'rails/rails'
    gem 'arel', github: 'rails/arel'
    gem 'sqlite3'
  GEMFILE

  system 'bundle'
end

require 'bundler'
Bundler.setup(:default)

require 'active_record'
require 'minitest/autorun'

# Ensure backward compatibility with Minitest 4
Minitest::Test = MiniTest::Unit::TestCase unless defined?(Minitest::Test)

# This connection will do for database-independent bug reports.
ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
ActiveRecord::Base.logger = Logger.new(STDOUT)

ActiveRecord::Schema.define do
  create_table :users, force: true do |t|
  end

  create_table :memo_cards, force: true do |t|
    t.integer :question_id
    t.integer :user_id
  end

  create_table :questions, force: true do |t|
    t.integer :user_id
  end
end

class User < ActiveRecord::Base
  has_many :questions
  has_many :memo_cards
end

class MemoCard < ActiveRecord::Base
  belongs_to :user
  belongs_to :question
end

class Question < ActiveRecord::Base
  belongs_to :user
end

class TestSubquery < Minitest::Test
  def test_subquery
    user = User.create!
    question = user.questions.create!
    memo_card = user.memo_cards.create(question: question)

    relation = user.questions.where.not(id: user.memo_cards.select(:question_id))

    assert_equal 0, relation.count
  end
end
