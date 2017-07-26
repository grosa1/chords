class ArchivesController < ApplicationController

  before_action :set_archive


  # GET /archives

  def index
    authorize! :manage, Archive
    
    @archive.get_credentials
    
    if @archive == nil
      Archive.initialize
      @archive = Archive.first
    end

  end



  # PATCH/PUT /archives/1
  def create
    authorize! :manage, Archive
  
  
    # update attributes
    if !@archive.update(archive_params)
      if (! @archive.valid?)
        flash.now[:alert] = @archive.errors.full_messages.to_sentence
      end

      render :index
      return
    end

      
    flash[:notice] = 'Archive configuration saved.'
    
    redirect_to archives_path
  end
  


  # PATCH/PUT /archives/1
  # PATCH/PUT /archives/1.json
  
  def update_credentials
    authorize! :manage, Archive

    respond_to do |format|
      if @archive.update_attributes(archive_params) && @archive.update_credentials(archive_params)
        format.html { redirect_to(archives_path, :notice => 'Archive Credentials successfully updated.') }
        format.json { respond_with_bip(@archive) }
      else
        format.html { render :action => "index" }
        format.json { respond_with_bip(@archive) }
      end
    end

  end

  def update
    authorize! :manage, Archive

    respond_to do |format|
      if @archive.update_attributes(archive_params)
        
        # rebuild the cron schedule of the send frequency is set.
        if @archive.send_frequency != nil
          Rails.logger.debug('*****************')
          @archive.rebuild_crontab_schedule
        end
        
        format.html { redirect_to(@archive, :notice => 'Configurations was successfully updated.') }
        format.json { respond_with_bip(@archive) }
      else
        format.html { render :action => "index" }
        format.json { respond_with_bip(@archive) }
      end
    end
  end




  private
    # Use callbacks to share common setup or constraints between actions.
    def set_archive
      @archive = Archive.first
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def archive_params
      params.require(:archive).permit(:id, :name, :base_url, :send_frequency, :last_archived_at, :created_at, :updated_at, :username, :password)
      
      
      
    end
end

