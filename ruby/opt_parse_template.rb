require 'optparse'

##
# Taken from this gist: https://gist.github.com/michaelvdnest/160551860721421f1306bb16204deea9
options = {}

class Parser
  def self.parse(args)
    options = {}
    opt_parser = OptionParser.new do |opts|
      opts.banner = 'Usage: demo.rb [options] ARG...'
      opts.separator 'A demo of optparse.'
      opts.separator 'Example: ruby demo.rb -nMICHAEL foo bar'

      opts.separator ''
      opts.separator 'Options:'

      opts.on('-nNAME', '--name=NAME', 'Name to say hello to') do |n|
        options[:name] = n
      end

      opts.on('-v', '--[no-]verbose', 'Run verbosely') do |v|
        options[:verbose] = v
      end

      opts.separator ''
      opts.separator 'Help options:'

      opts.on('-h', '--help', 'Prints this help') do
        puts opts
        exit
      end
    end

    opt_parser.parse!(args)
    return options
  end
end

begin
  options = Parser.parse ARGV
rescue Exception => e
  puts "Exception encountered: #{e}"
  exit 1
end

#Print the usage if there are no arguments.
Parser.parse %w[--help] if ARGV.empty?

# Set the verbose option if the ruby verbose flag is on
options[:verbose] = true if $VERBOSE

# Print options
puts options

if options[:verbose]
  @start = Time.now
end

# process each argument
ARGV.each do|a|
  puts a
end

if options[:verbose]
  elapsed = Time.now - @start
  puts 'Elapsed time: ' +  elapsed.to_s + ' seconds'
end
