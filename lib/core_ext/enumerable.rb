module Enumerable

  def threaded_map(thread_limit=8)
    threads = []
    each do |object|
      until threads.map(&:status).count("run") < thread_limit do sleep 0.1 end
      threads << Thread.new { yield object }
    end
    threads.map(&:value)
  end

end
