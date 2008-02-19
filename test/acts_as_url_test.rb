require 'test/unit'

begin
  require File.dirname(__FILE__) + '/../../../config/environment'
rescue LoadError
  require 'rubygems'
  gem 'activerecord'
  require 'active_record'
  
  RAILS_ROOT = File.dirname(__FILE__) 
end

require File.join(File.dirname(__FILE__), '../lib/lucky_sneaks/acts_as_url')

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :dbfile => "acts_as_url.sqlite3")

ActiveRecord::Migration.verbose = false
ActiveRecord::Schema.define(:version => 1) do
  create_table :documents, :force => true do |t|
    t.string :title, :url, :other
  end
  
  create_table :mocuments, :force => true do |t|
    t.string :title, :url, :other
  end
end
ActiveRecord::Migration.verbose = true

ActiveRecord::Base.send :include, LuckySneaks::ActsAsUrl

class Document < ActiveRecord::Base
  acts_as_url :title
end

class Mocument < ActiveRecord::Base
  acts_as_url :title, :scope => :other
end

class ActsAsUrlTest < Test::Unit::TestCase
  def test_should_create_url
    @doc = Document.create(:title => "Let's Make a Test Title, <em>Okay</em>?")
    assert_equal "lets-make-a-test-title-okay", @doc.url
  end
  
  def test_should_create_unique_url
    @doc = Document.create!(:title => "Unique")
    @other_doc = Document.create!(:title => "Unique")
    assert_equal "unique-1", @other_doc.url
  end
  
  def test_should_not_succ_on_repeated_saves
    @doc = Document.new(:title => "Continuous or Constant")
    5.times do
      @doc.save!
      assert_equal "continuous-or-constant", @doc.url
    end
  end
  
  def test_should_scope_uniqueness
    @moc = Mocument.create!(:title => "Mocumentary", :other => "I dunno why but I don't care if I'm unique")
    @other_moc = Mocument.create!(:title => "Mocumentary")
    assert_equal @moc.url, @other_moc.url
  end
  
  def test_should_still_create_unique_if_in_same_scope
    @moc = Mocument.create!(:title => "Mocumentary", :other => "Suddenly, I care if I'm unique")
    @other_moc = Mocument.create!(:title => "Mocumentary", :other => "Suddenly, I care if I'm unique")
    assert_not_equal @moc.url, @other_moc.url
  end
end