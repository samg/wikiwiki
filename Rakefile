require 'spec/rake/spectask'

task :default => :spec

desc "Run all specs in spec directory"
Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
end

root = File.dirname(__FILE__)
namespace :parser do
  desc "update the source code of the yapwtp parser"
  task :update => :record_version do
    `bash -c 'rm -rf #{root}/ext/yapwtp/*.{c,h,o}'`
    `bash -c 'cp -v #{root}/../YAPWTP/src/*.{c,h} #{root}/ext/yapwtp/src/'`
    `bash -c 'cp -v #{root}/../YAPWTP/Makefile #{root}/ext/yapwtp/'`
  end

  task :record_version do
    sha = `cd ../YAPWTP/ && git log | head -n1 | awk '{print $2}'`
    File.open("#{root}/ext/yapwtp/VERSION.txt", 'w') do |f|
      f.puts sha
    end
  end

  desc "make the parser if ruby gems didn't do it for you"
  task :make do
    `bash -c 'cd #{root}/ext/yapwtp && ruby extconf.rb && make'`
  end

  desc "make clean the parser"
  task :clean do
    `bash -c 'cd #{root}/ext/yapwtp && ruby extconf.rb && make clean'`
  end
end
