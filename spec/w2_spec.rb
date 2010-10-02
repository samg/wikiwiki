require File.dirname(__FILE__) + '/../w2'
require 'spec'
require 'rack/test'

set :environment, :test

describe 'The WikiWiki App' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
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
        should == 'foo?bar?baz'
    end
  end
end
