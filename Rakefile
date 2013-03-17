require 'rake'

desc "Install dot files in home directory"
task :install do
  replace_all = false
  Dir['lib/*'].each do |file|
    if File.exist?(File.join(ENV['HOME'], ".#{file}"))
      if replace_all
        replace_file(file)
      else
        print "overwrite ~/.#{file}? [ynaq] "
        case $stdin.gets.chomp
        when 'a'
          replace_all = true
          replace_file(file)
        when 'y'
          replace_file(file)
        when 'q'
          exit
        else
          puts "skipping ~/.#{file}"
        end
      end
    else
      link_file(file)
    end
  end
end

desc "Set up RVM"
task :rvm => ["rvm:setup"]

namespace :rvm do
  task :install do
    system %Q{rvm-install}
  end
  
  task :setup => [:install] do
    system %Q{./install_rvm.sh}
  end
end

namespace :mongodb do
  desc "Setup mongo:db as a launchd service so it starts on system start"
  task :setup do
    system %Q{sudo ./launchmongo.sh}
  end
end

def replace_file(file)
  system %Q{rm "$HOME/.#{file}"}
  link_file(file)
end

def link_file(file)
  if %w[gitconfig].include? file
    copy_file(file)
  else
    puts "linking ~/.#{file}"
    system %Q{ln -fs "$PWD/#{file}" "$HOME/.#{file}"}
  end
end

def copy_file(file)
  puts "copying ~/.#{file}, make your changes there"
  system %Q{cp -r "$PWD/#{file}" "$HOME/.#{file}"}
end
