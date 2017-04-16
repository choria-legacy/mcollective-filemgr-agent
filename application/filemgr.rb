class MCollective::Application::Filemgr<MCollective::Application
  description "Generic File Manager Client"
  usage "Usage: mco filemgr [--file FILE] [--content CONTENT] [--force] [touch|remove|status|write]"

  option :file,
         :description    => "File to manage",
         :arguments      => ["--file FILE", "-f FILE"],
         :required       => true

  option :details,
         :description    => "Show full file details",
         :arguments      => ["--details", "-d"],
         :type           => :bool

  option :content,
         :description    => "Content to use for file creation",
         :arguments      => ["--content", "-c"],
         :type           => :string

  option :force,
         :description    => "Force file write, if file exists already",
         :arguments      => ["--force", "-f"],
         :type           => :bool

  def post_option_parser(configuration)
    configuration[:command] = ARGV.shift if ARGV.size > 0
  end

  def validate_configuration(configuration)
    configuration[:command] = "touch" unless configuration.include?(:command)
  end

  def main
    mc = rpcclient("filemgr")

    case configuration[:command]
    when "remove"
      printrpc mc.remove(:file => configuration[:file])

    when "touch"
      printrpc mc.touch(:file => configuration[:file])

    when "status"
      if configuration[:details]
        printrpc mc.status(:file => configuration[:file])
      else
        mc.status(:file => configuration[:file]).each do |resp|
          printf("%-40s: %s\n", resp[:sender], resp[:data][:output] || resp[:statusmsg])
        end
      end

    when "write"
      if configuration[:force]
        printrpc mc.write(:file => configuration[:file], :content => configuration[:content], :force => true)
      else
        printrpc mc.write(:file => configuration[:file], :content => configuration[:content])
      end

    else
      puts "Valid commands are 'touch', 'status', 'remove' and 'write'"
      exit 1
    end

    printrpcstats

    halt mc.stats
  end
end
