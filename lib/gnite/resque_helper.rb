# encoding: utf-8
module Gnite
  class ResqueHelper
    def self.cleanup
      Resque.queues.each do |queue|
        Resque.remove_queue(queue.to_sym)
      end
      workers = Resque.workers
      workers.first.prune_dead_workers unless workers.empty?
    end
  end
end
