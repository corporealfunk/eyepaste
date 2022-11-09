workers Integer(ENV['WEB_CONCURRENCY'] || 2)
threads_count = Integer(ENV['THREAD_COUNT'] || 5)
threads threads_count, threads_count

preload_app!

port        ENV['PORT']      || 3000
environment ENV['RAILS_ENV'] || 'development'
