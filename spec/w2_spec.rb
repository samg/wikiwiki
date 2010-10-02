require File.dirname(__FILE__) + '/../wikiwiki'
require 'spec'
require 'rack/test'

set :environment, :test

describe 'The WikiWiki App' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def redirect_to(expected)
    simple_matcher "to redirect to #{expected}" do |given|
      (300..399) === given.status and
      given.headers['Location'].should == expected
    end
  end
  it "should redirect edit home page to '/'" do
    post '/edit'
    last_response.should redirect_to('/')
  end

end

describe W2::Helpers do
  before do
    @helper = Object.new
    @helper.extend W2::Helpers
  end
  def helper
    @helper
  end

  describe "path_to_safe_filename" do
    it "should convert /'s to ?'s" do
      helper.path_to_safe_filename('foo/bar/baz').
        should == 'foo?bar?baz'
    end

    it "should strip and squeeze slashes/question marks" do
      helper.path_to_safe_filename('///foo//bar////baz//').
        should == '?foo?bar?baz'
    end

    it "should conver spaces to _'s" do
      helper.path_to_safe_filename('foo bar_baz').
        should == 'foo_bar_baz'
    end
  end

  describe "edit_path" do
    it "should turn '/' => '/edit'" do
      helper.edit_path('/').should == '/edit'
    end

    it "should turn '/edit' => '/edit'" do
      helper.edit_path('/edit').should == '/edit'
    end

    it "should turn 'foo' into 'foo/edit'" do
      helper.edit_path('foo').should == 'foo/edit'
    end

    it "should turn '/foo/bar' into 'foo/bar/edit'" do
      helper.edit_path('/foo/bar').should == '/foo/bar/edit'
    end

    it "should turn '/foo/bar/edit' into 'foo/bar/edit'" do
      helper.edit_path('/foo/bar/edit').should == '/foo/bar/edit'
    end

    it "should turn '' into 'edit'" do
      helper.edit_path('').should == 'edit'
    end

    it "should turn 'edit' into 'edit'" do
      helper.edit_path('edit').should == 'edit'
    end
  end

  describe "show_path" do
    it "should turn '/edit' => '/'" do
      helper.show_path('/edit').should == '/'
    end

    it "should turn '/' => '/'" do
      helper.show_path('/').should == '/'
    end

    it "should turn 'foo/edit' into 'foo'" do
      helper.show_path('foo/edit').should == 'foo'
    end

    it "should turn '/foo/bar/edit' into 'foo/bar'" do
      helper.show_path('/foo/bar/edit').should == '/foo/bar'
    end

    it "should turn '/foo/bar/' into 'foo/bar'" do
      helper.show_path('/foo/bar/').should == '/foo/bar'
    end

    it "should turn 'edit' into ''" do
      helper.show_path('edit').should == ''
    end

    it "should turn '' into ''" do
      helper.show_path('').should == ''
    end
  end
end

