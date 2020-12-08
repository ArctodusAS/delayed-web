module Delayed
  module Web
    class Job::ActiveRecord
      def self.find *args
        decorate Delayed::Job.find(*args)
      end

      def self.all(scope = nil)
        jobs = case scope
                  when 'running'
                    then Delayed::Job.where.not(locked_at: nil)
                  when 'failed'
                    then Delayed::Job.where.not(last_error: nil)
                  else
                    Delayed::Job.all
                  end
        jobs = jobs.order('id DESC').limit(1000)
        Enumerator.new do |enumerator|
          jobs.each do |job|
            enumerator.yield decorate(job)
          end
        end
      end

      def self.decorate job
        job = StatusDecorator.new job
        job = ActiveRecordDecorator.new job
        job
      end
    end
  end
end
