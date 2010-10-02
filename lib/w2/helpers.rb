module W2
  module Helpers
    include Rack::Utils
    alias_method :h, :escape_html
    def path_to_safe_filename(path)
      path.gsub(%r{^/+}, '').
        gsub(%r{/+$}, '').
        gsub(%r{/+}, '?')
    end

    def wiki_text_for(path)
      fp = file_path(path)
      if File.exist?(fp)
        File.read(fp)
      end
    end

    def file_path(path)
      File.dirname(__FILE__) + '/../../wiki/' + path_to_safe_filename(path)
    end
  end
end
