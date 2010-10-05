require 'open3'
require 'haml'
require 'fileutils'
require 'dirb'
# WikiWiki
module W2
  module Helpers
    include Rack::Utils
    def changes(path)
      Dir[changes_glob(path)].reverse
    end

    def changes_glob(path)
      File.dirname(revision_file_path(path)).gsub('?', '\?') + '/*'
    end

    alias_method :h, :escape_html

    # FILE SYSTEM HELPERS
    ###########################
    def path_to_safe_filename(path)
      path = '/' if path == ''
      normalize_path(path).gsub('/', '?').gsub(' ', '_')
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
        Open3.popen3(File.dirname(__FILE__) + '/../../ext/yapwtp/parser') do |i,o,e|
          i.write text
          i.close
          t = o.read
        end
      end
    end

    def file_path(path)
      File.dirname(__FILE__) + '/../../wiki/' + path_to_safe_filename(show_path(path))
    end

    def revision_file_path(uri_path, timestamp = nil)
      fp = file_path(uri_path)
      bn = File.basename(fp)
      timestamp ||= Time.now.to_i
      fp.sub(bn, ".#{bn}/#{timestamp}.#{bn}")
    end

    def save_file uri_path, wiki_text
      fp = file_path(uri_path)
      File.open(fp, 'w') do |f|
        f.write wiki_text
      end
      FileUtils.mkdir_p(File.dirname(revision_file_path(uri_path)))
      system('cp', fp, revision_file_path(uri_path))
    end

    # VIEW HELPERS
    ###########################
    def path_to_title(path)
      path = path.gsub(/^\//, '' ).gsub('_', ' ')
      path == '' ? 'Home' : path
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

    def diff(path, time)
      changes = changes(path)
      current_index = changes.index(changes.detect{|c| c =~ /#{time}\./ })
      current = File.read(changes[current_index])
      previous_fn = changes[current_index + 1]
      if previous_fn
        previous = File.read(previous_fn)
      else 
        previous = ''
      end
      Dirb::Diff.new(previous, current).to_s(:html)
    end

    # ROUTE HELPERS
    ###########################
    def show_path path
      parts = path_parts(path)
      parts.pop if parts.last == 'edit'
      parts = ['/'] if %w[/ /edit /changes].member? path
      join_parts(parts)
    end

    def edit_path path
      path_for path, 'edit'
    end

    def changes_path path
      path_for path, 'changes'
    end

    private

    def path_for(path, action)
      parts = path_parts(path)
      parts.push(action) unless parts.last == action
      join_parts(parts)
    end

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
