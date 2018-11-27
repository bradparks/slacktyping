require 'dotenv/load'
require 'slack-ruby-client'
require 'pry'

raise 'Missing ENV[SLACK_API_TOKENS]!' unless ENV.key?('SLACK_API_TOKENS')

texts =
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
logger = Logger.new($stdout)
logger.level = Logger::DEBUG

token = ENV['SLACK_API_TOKENS']
logger.info "Starting #{token[0..12]} ..."

client = Slack::RealTime::Client.new(token: token)

state =
  {
    'UAU4J3DLZ' => (Time.now - 60 * 5), # zoe
    'DB11PDM3M' => (Time.now - 60 * 5)  # jose
  }

client.on :hello do
  logger.info "Successfully connected, welcome '#{client.self.name}' to the '#{client.team.name}' team at https://#{client.team.domain}.slack.com."
end

client.on(:user_typing) do |data|
  logger.info data
  client.typing channel: data.channel
  if data.user == 'UAU4J3DLZ' # zoe
    state[data.user] ||= Time.now
    if state[data.user] < (Time.now - 60 * 5)
      client.message channel: data.channel, text: texts.sample
      state[data.user] = Time.now
    end
  end
  if data.channel == 'DB11PDM3M' # jose
    state[data.user] ||= Time.now
    if state[data.user] < (Time.now - 60 * 5)
      client.message channel: data.channel, text: texts.sample
      state[data.user] = Time.now
    end
  end
end

client.start!
