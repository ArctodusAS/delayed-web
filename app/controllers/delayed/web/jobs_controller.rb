module Delayed
  module Web
    class JobsController < Delayed::Web::ApplicationController
      WORKER_STR = 'delayed'

      def index
      end

      def queue
        if job.can_queue?
          job.queue!
          flash[:notice] = t(:notice, scope: 'delayed/web.flashes.jobs.queued')
        else
          status = t(job.status, scope: 'delayed/web.views.statuses')
          flash[:alert] = t(:alert, scope: 'delayed/web.flashes.jobs.queued', status: status)
        end
        redirect_to jobs_path
      end

      def destroy
        if job.can_destroy?
          job.destroy
          flash[:notice] = t(:notice, scope: 'delayed/web.flashes.jobs.destroyed')
        else
          status = t(job.status, scope: 'delayed/web.views.statuses')
          flash[:alert] = t(:alert, scope: 'delayed/web.flashes.jobs.destroyed', status: status)
        end
        redirect_to jobs_path
      end

      private

      def job
        @job ||= Delayed::Web::Job.find params[:id]
      end
      helper_method :job

      def jobs
        return @jobs if @jobs
        scope = Delayed::Web::Job.all(params[:scope], params[:queue])
      end
      helper_method :jobs

      def workers
        @workers ||= `ps aux | grep #{WORKER_STR}`.split("\n").collect{|p| p unless p.include?('grep')}.compact
      end
      helper_method :workers
    end
  end
end
