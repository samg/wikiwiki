require 'open3'
require 'haml'
require 'fileutils'
# WikiWiki
module W2
  module Helpers
    include Rack::Utils

    alias_method :h, :escape_html

    # FILE SYSTEM HELPERS
    ###########################
    def path_to_safe_filename(path)
      path = '/' if path == ''
      normalize_path(path).gsub('/', '?')
    end

    def wiki_text_for(path)
      fp = file_path(path)
      if File.exist?(fp)
        File.read(fp)
      end
    end

    def parsed_wiki_text_for(path)
      text = wiki_text_for(path)
      if text
        Open3.popen3(File.dirname(__FILE__) + '/../../vendor/parser') do |i,o,e|
          i.write text
          i.close
          t = o.read
        end
      end
    end

    def file_path(path)
      File.dirname(__FILE__) + '/../../wiki/' + path_to_safe_filename(path)
    end

    def save_file uri_path, wiki_text
      fp = file_path(show_path(uri_path))
      File.open(fp, 'w') do |f|
        f.write wiki_text
      end
    end

    # VIEW HELPERS
    ###########################
    def path_to_title(path)
      path.gsub(/^\//, '' ).gsub('_', ' ')
    end

    def file_name_to_path(fn)
      fn.gsub('?', '/').strip
    end

    # hacky js for coloring future links
    def blue_links
      `ls #{File.dirname(__FILE__) + '/../../wiki'}`.inject('{') do |memo, fp|
        memo + %'"#{file_name_to_path(fp)}":true,'
      end + '}'
    end

    # ROUTE HELPERS
    ###########################
    def show_path path
      parts = path_parts(path)
      parts.pop if parts.last == 'edit'
      parts = ['/'] if %w[/ /edit].member? path
      join_parts(parts)
    end

    def edit_path path
      parts = path_parts(path)
      parts.push('edit') unless parts.last == 'edit'
      join_parts(parts)
    end

    private

    def normalize_path(path)
      join_parts(path_parts(path))
    end
    def path_parts(path)
      parts = path.split(%r{/+})
      parts.push '/' if path == '/'
      parts
    end

    def join_parts(parts)
      parts.join('/').squeeze('/')
    end
  end
end
