class ContactsController < ApplicationController

  helper :custom_fields
  helper :attachments
  include AttachmentsHelper

  before_filter :find_contact, :only => [:edit, :update, :destroy, :show]
  before_filter :find_project

  def index
    #contacts assigned to current project only
    @contacts = Contact.all.where(project_id: @project.id )
  end

  def new
    @contact = Contact.new
    @contact.safe_attributes = params[:contact]

  end

  def create
    @contact = Contact.new
    @contact.safe_attributes = params[:contact]
    @contact.save_attachments(params[:attachments])
    if @contact.save
      render_attachment_warning_if_needed(@contact)
      flash[:notice] = l(:notice_successful_create)
      redirect_to controller: 'contacts', action: 'index', project_id: @contact.project_id
    else
      #flash[:notice] = l(:notice_params_needed)
      render :action => 'new'
    end
  end

  def show
  end

  def edit
  end

  def update
    @contact.safe_attributes = params[:contact]
    @contact.save_attachments(params[:attachments])
    if @contact.update_attributes(params[:contact])
      render_attachment_warning_if_needed(@contact)
      flash[:notice] = l(:notice_successful_update)
      redirect_to contacts_path(@contact.project_id)
    else
      render :action => 'edit', project_id: @contact.project_id
    end
  end

  def destroy
    project_id = @contact.project_id
    @contact.destroy
    flash[:notice] = l(:notice_successful_delete)
    redirect_to contacts_path(project_id)
  end

  private


  def find_contact
    @contact = Contact.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

end