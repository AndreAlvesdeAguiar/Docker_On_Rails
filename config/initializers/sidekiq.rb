Sidekiq.configure_server do |config|
    config.redis = { url: 'redis://docker_on_rails-redis-1:6379/0' }
  end
  
  Sidekiq.configure_client do |config|
    config.redis = { url: 'redis://docker_on_rails-redis-1:6379/0' }
  end
  