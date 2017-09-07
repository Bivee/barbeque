class Barbeque::JobExecutionsController < Barbeque::ApplicationController
  MESSAGE_ID_REGEXP = /\A[0-9a-f-]+\z/

  def show
    if MESSAGE_ID_REGEXP === params[:id]
      job_execution = Barbeque::JobExecution.find_by(message_id: params[:id])
      if job_execution
        redirect_to(job_execution)
        return
      end
    end
    @job_execution = Barbeque::JobExecution.find(params[:id])
    @log = @job_execution.execution_log
    @job_retries = @job_execution.job_retries.order(id: :desc)
  end

  def retry
    @job_execution = Barbeque::JobExecution.find(params[:job_execution_id])
    raise ActionController::BadRequest unless @job_execution.retryable?

    result = Barbeque::MessageRetryingService.new(message_id: @job_execution.message_id).run
    @job_execution.retried!

    redirect_to @job_execution, notice: "Succeed to retry (message_id=#{result.message_id})"
  end
end
