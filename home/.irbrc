#!/usr/bin/ruby
require 'irb/completion'
require 'readline'

IRB.conf[:SAVE_HISTORY] = 100
IRB.conf[:HISTORY_FILE] = "#{ENV['HOME']}/.irb_history"
IRB.conf[:PROMPT_MODE] = :SIMPLE

%w[rubygems looksee/shortcuts wirble].each do |gem|
  begin
    require gem
  rescue LoadError
  end
end

class Object
  # list methods which aren't in superclass
  def local_methods(obj = self)
    (obj.methods - obj.class.superclass.instance_methods).sort
  end
  
  # print documentation
  #
  #   ri 'Array#pop'
  #   Array.ri
  #   Array.ri :pop
  #   arr.ri :pop
  def ri(method = nil)
    unless method && method =~ /^[A-Z]/ # if class isn't specified
      klass = self.kind_of?(Class) ? name : self.class.name
      method = [klass, method].compact.join('#')
    end
    puts `ri '#{method}'`
  end
end

def _clip_copy(str)
  if RUBY_PLATFORM =~ /darwin/
    IO.popen('pbcopy', 'w') { |io| io.write(str) }
  else
    IO.popen('xclip -selection clipboard', 'w') { |io| io.write(str) }
  end
end

def _clip_paste
  if RUBY_PLATFORM =~ /darwin/
    `pbpaste`
  else
    `xclip -selection clipboard -o`
  end
end

def _cp(kopimi = Readline::HISTORY.entries[-2], options = {})
  if kopimi.respond_to?(:join) && !options[:to_a]
    kopimi = kopimi.map{|i| ":#{i.to_s}" } if options.delete(:to_sym)
    delicious = kopimi.join(", ")
  elsif kopimi.respond_to?(:inspect)
    delicious = kopimi.is_a?(String) ? kopimi : kopimi.inspect
  end
  _clip_copy(delicious)
end

def copy(str)
  _clip_copy(str.to_s)
end

def paste
  _clip_paste
end

load File.dirname(__FILE__) + '/.railsrc' if $0 == 'irb' && ENV['RAILS_ENV']

#if defined? Rails
#  puts "Loading your blueprints..."
#  require Rails.root.join("spec", "blueprints") if File.exists?(Rails.root.join("spec", "blueprints.rb"))
#  require Rails.root.join("spec", "support", "blueprints") if File.exists?(Rails.root.join("spec", "support", "blueprints.rb"))
#end
