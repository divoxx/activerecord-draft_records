$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'rubygems'
require 'active_record'
require 'active_record/draft_records'
require 'spec'
require 'spec/autorun'
require 'database_cleaner'
require 'logger'

# Initiate the connection
ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => ':memory:')
DatabaseCleaner.strategy = :transaction
  
# Define the database schema
ActiveRecord::Schema.define do
  create_table :users do |t|
    t.string :username, :email
    t.integer :age
    t.boolean :draft
  end
end

class User < ActiveRecord::Base
  include ActiveRecord::DraftRecords
  validates_presence_of :username, :email
  validates_uniqueness_of :username, :email, :scope => :draft
end

Spec::Runner.configure do |config|
  config.before(:each) do
    DatabaseCleaner.start
  end
  
  config.after(:each) do
    DatabaseCleaner.clean
  end
end