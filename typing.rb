require 'dotenv/load'
require 'slack-ruby-client'

TEXTS =
  [
    'draw!',
    'not fast enough?',
    'quick draw!',
    'haha',
    "i won't say who's your daddy, because you know the answer.",
    "what's up?",
    'howdy',
    'bang',
    'headshot',
    'hi'
  ]

$stdout.sync = true
Log = Logger.new($stdout).tap { |log| log.level = Logger::DEBUG }

raise 'Missing ENV[SLACK_API_TOKEN]!' unless ENV.key?('SLACK_API_TOKEN')
Slack.configure do |config|
  config.token = ENV['SLACK_API_TOKEN']
end

Webclient = Slack::Web::Client.new
Webclient.auth_test

channels = Webclient.channels_list['channels'].map { |c| c['id'] }

@rlstate = {}
Rlclient = Slack::RealTime::Client.new

Rlclient.on :hello do
  Log.info "Successfully connected, welcome '#{Rlclient.self.name}' to the '#{Rlclient.team.name}' team at https://#{Rlclient.team.domain}.slack.com."
end

Rlclient.on(:user_typing) do |data|
  Log.info data
  Rlclient.typing channel: data.channel
  channels = Webclient.channels_list['channels'].to_a.map { |c| c['id'] }
  unless channels.include? data.channel
    Log.info 'direct message'
    @rlstate[data.user] ||= (Time.now - 60 * 6)
    if @rlstate[data.user] < (Time.now - 60 * 5)
      Log.info 'send a text'
      Rlclient.message channel: data.channel, text: TEXTS.sample
      @rlstate[data.user] = Time.now
    end
  end
end

Rlclient.start!
