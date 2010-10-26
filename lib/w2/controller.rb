module W2
  module Controller
    get '/style.css' do
      render :text, File.read(File.dirname) + '/public/style.css'
    end

    get '/app.js' do
      render :text, File.read(File.dirname) + '/public/app.js'
    end

    get %r'(.*)/edit' do |path|
      haml :edit, :locals => {:path => path, :text => wiki_text_for(path)}
    end

    get %r'/recent_changes' do
      haml :changes, :locals => {
        :path => 'Recent Changes',
        :changes =>
          `cat #{(File.join(wiki_db_root, '.recent_changes'))}`.
            split.reverse.paginate(:page => params[:page])
      }
    end

    get %r'(.*)/changes' do |path|
      haml :changes, :locals => {:path => path, :changes => changes(path).paginate(:page => params[:page])}
    end

    get %r'(File|Image):(.*)' do |junk, path|
    real_path = File.join(filestore, path_to_safe_filename(path))
    if !File.exist? real_path
      status 404
        return "404 Not Found"
    end
      haml :image, :locals => {
      :src => [ filestore_url, path ].join('/'),
    :name => path,
    :mtime => File.open(real_path) { |f| f.mtime }
      }
    end

    get '/upload' do
      haml :upload, :locals => {:title => 'File Upload'}
    end

    post '/upload' do
      unless params[:file] &&
           (tmpfile = params[:file][:tempfile]) &&
           (name = params[:file][:filename])
        return haml :upload, :locals => {:title => 'File Upload', :err => "No file selected" }
      end

      filename = params[:filename].empty? ? name : params[:filename]
      STDERR.puts "#{Time.now}: Uploading file, original name #{name.inspect}"

      begin
        upload_file(tmpfile, filename)
      rescue IOError, Errno::ENOENT => e
        return haml :upload, :locals => {:title => 'File Upload', :err => h(e.to_s) }
      ensure
         tmpfile.close
         FileUtils.rm tmpfile.path
      end

      redirect "/Image:#{filename}"
    end

    # TODO: Can't figure out how to call a helper in the route definition!
    get %r'/files/(.*)' do |path|
      path = File.expand_path(File.join(filestore, safe_filename_to_path(path)))
      unless File.exist? path
        status 404
        return "404 Not Found"
      end
      send_file(path)
    end

    get %r'(.*)/(\d{10})' do |path, time|
      haml :diff, :locals => {:path => path, :time => time, :changes => changes(path)}
    end

    get %r'(.*)' do |path|
      if File.exist? file_path(path)
        haml :show, :locals => {:path => path, :text => parsed_wiki_text_for(path)}
      else
        haml :edit, :locals => {:path => path, :text => wiki_text_for(path)}
      end
    end

    post %r'(.*)' do |path|
      save_file path, params['wiki_text']
      redirect show_path(path)
    end
  end
end
