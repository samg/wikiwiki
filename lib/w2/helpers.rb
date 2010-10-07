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

    # URL paths are converted file names.  Slashes are converted to question
    # marks to avoid directory related issues.
    # Care must be taken to escape the '?' when globbing for files since '?'
    # is a single character wildcard in bash.
    def path_to_safe_filename(path)
      path = '/' if path == ''
      normalize_path(path).gsub('/', '?').gsub(' ', '_')
    end

    def safe_filename_to_path(path)
      path = '?' if path == ''
      normalize_path(path.gsub('?', '/'))
    end

    def wiki_text_for(path)
      fp = file_path(path)
      File.read(fp) if File.exist?(fp)
    end

    def parsed_wiki_text_for(path)
      text = wiki_text_for(path)
      if text
        parse_wiki_text(text)
      end
    end

    def parse_wiki_text(text)
      Open3.popen3(File.dirname(__FILE__) + '/../../ext/yapwtp/parser') do |i,o,e|
        i.write text
        i.close
        o.read
      end
    end

    def wiki_db_root
      File.dirname(__FILE__) + "/../../wiki-#{Sinatra::Application.environment}/"
    end

    def file_path(path)
      wiki_db_root + path_to_safe_filename(show_path(path))
    end

    def revision_file_path(uri_path, timestamp = nil)
      fp = file_path(uri_path)
      bn = File.basename(fp)
      timestamp ||= Time.now.to_i
      fp.sub(bn, ".#{bn}/#{timestamp}.#{bn}")
    end

    def revision_path_to_main_file_path(path)
      safe_filename_to_path(File.basename(path)).
        gsub(/^\d{10}\./, '')
    end

    def revision_directory(uri_path)
      File.dirname(revision_file_path(uri_path))
    end

    def save_file uri_path, wiki_text
      # save current version
      FileUtils.mkdir_p( wiki_db_root )
      file_path = file_path( uri_path )
      File.open( file_path, 'w' ) { |f| f.write wiki_text }

      # save revsion in history folder
      rev_path = revision_file_path(uri_path)
      FileUtils.mkdir_p(File.dirname(rev_path))
      system('cp', file_path, rev_path)

      # update recent changes
      File.open( File.join(wiki_db_root, '.recent_changes'), 'a') do |f|
        f.puts rev_path
      end
    end

    def diff(rev_path)
      uri_path = (
        safe_filename_to_path(
          revision_path_to_main_file_path(
            rev_path
          )
        )
      ).strip
      changes = changes(uri_path)
      time = rev_path.scan(/\d{10}\./).first.to_s.gsub(/\D/, '')
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
      `ls #{wiki_db_root}`.inject('{') do |memo, fp|
        memo + %'"#{file_name_to_path(fp)}":true,'
      end + '}'
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
