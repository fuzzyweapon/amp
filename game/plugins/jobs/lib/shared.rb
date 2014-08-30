module AresMUSH
  module Jobs
    def self.can_access_jobs?(actor)
      return actor.has_any_role?(Global.config["jobs"]["roles"]["can_access_jobs"])
    end
    
    def self.categories
      Global.config["jobs"]["categories"]
    end
    
    def self.status_vals
      [ 'NEW', 'OPEN', 'HOLD', 'DONE' ]
    end
    
    def self.status_color(status)
      return "" if status.nil?
      case status.upcase
      when "NEW"
        "%xg"
      when "OPEN"
        "%xb"
      when "HOLD"
        "%xr"
      when "DONE"
        "%xy"
      end
    end
    
    def self.with_a_job(client, number, &block)
      job = Job.where(number: number.to_i).first
      if (job.nil?)
        client.emit_failure t('jobs.invalid_job_number')
        return
      end
      
      yield job
    end
    
    def self.with_a_request(client, number, &block)
      job = client.char.submitted_requests.where(number: number.to_i).first
      if (job.nil?)
        client.emit_failure t('jobs.invalid_job_number')
        return
      end
      
      yield job
    end
    
    def self.comment(job, author, message, admin_only)
      JobReply.create(:author => author, 
        :job => job,
        :admin_only => admin_only,
        :message => message)
      if (admin_only)
        notification = t('jobs.discussed_job', :name => author.name, :number => job.number, :title => job.title)
        Jobs.notify(job, notification, author, false)
      else
        notification = t('jobs.responded_to_job', :name => author.name, :number => job.number, :title => job.title)
        Jobs.notify(job, notification, author)
      end
    end
    
    def self.notify(job, message, author, notify_submitter = true)
      Global.client_monitor.logged_in_clients.each do |c|
        job.readers = [ author ]
        job.save
        
        if (Jobs.can_access_jobs?(c.char) || (notify_submitter && (c.char == job.author)))
          c.emit_ooc message
        end
      end
    end
    
    def self.mark_read(job, char)
      job.readers << char
      job.save
    end
    
  end
end