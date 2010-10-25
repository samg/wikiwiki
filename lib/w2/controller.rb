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

    get '/upload' do 
      haml :upload, :locals => {:title => 'File Upload'}
    end

    post '/upload' do 
      unless params[:file] &&
           (tmpfile = params[:file][:tempfile]) &&
           (src_name = params[:file][:filename])
        return haml :upload, :locals => {:title => 'File Upload', :err => "No file selected" }
      end

      filename = params[:filename].empty? ? name : params[:filename]
      STDERR.puts "#{Time.now}: Uploading file, original name #{name.inspect}"

      file_upload(tmpfile, filename)
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
