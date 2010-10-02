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

    get %r'(.*)' do |path|
      if File.exist? file_path(path)
        haml :show, :locals => {:path => path, :text => parsed_wiki_text_for(path)}
      else 
        haml :edit, :locals => {:path => path, :text => wiki_text_for(path)}
      end
    end

    post %r'(.*)' do |path|
      File.open(file_path(show_path(path)), 'w') do |f|
        f.write params['wiki_text']
      end
      redirect show_path(path)
    end
  end
end
