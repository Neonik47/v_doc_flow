class DocsController < ApplicationController

  before_filter :check_admin!, except: :show
  #before_filter :set_doc, only: [:show, :edit, :update, :destroy,
  #                              :change_responsible, :to_review, :reject,
  #                              :to_revision, :accept, :to_execution,
  #                              :to_confirmation_of_execution, :to_executed]

  before_filter :set_doc, except: [:index, :new, :create]
  def index
    @docs = Doc.all
  end

  def show
    @users_for_response = User.all
  end

  def new
    @doc = Doc.new
    @doctypes = DocType.active.to_a
  end

  def edit
  end

  def create
    @doc = current_user.docs.new(doc_params)
    @doc.doc_type.lines.each{|l| @doc.doc_lines.build(l.as_document)}
    @doctypes = DocType.active.to_a

    if @doc.save
      create_work_log(__method__)
      redirect_to edit_doc_path(@doc), notice: 'Doc was successfully created.'
    else
      render action: "new"
    end
  end

  def update
    images_to_destroy = params.delete("images_to_delete") || []
    if @doc.update_attributes(doc_params)
      images_to_destroy.each do |image_id|
        image = @doc.images.select{|i| i.id.to_s == image_id}.first
        image.destroy if image
      end
      create_work_log(__method__)
      redirect_to @doc, notice: 'Doc was successfully updated.'
    else
      render action: "edit"
    end
  end

  def change_responsible
    @doc.change_responsible
    create_work_log(__method__)
    redirect_to :back, notice: "change_responsible"
  end

  def to_review
    @doc.to_review
    create_work_log(__method__)
    redirect_to :back, notice: "to_review"
  end

  def reject
    @doc.reject
    create_work_log(__method__)
    redirect_to :back, notice: "reject"
  end

  def to_revision
    @doc.to_revision
    create_work_log(__method__)
    redirect_to :back, notice: "to_revision"
  end

  def accept
    @doc.accept
    create_work_log(__method__)
    redirect_to :back, notice: "accept"
  end

  def to_execution
    @doc.to_execution
    create_work_log(__method__)
    redirect_to :back, notice: "to_execution"
  end

  def to_confirmation_of_execution
    @doc.to_confirmation_of_execution
    create_work_log(__method__)
    redirect_to :back, notice: "to_confirmation_of_execution"
  end

  def to_executed
    @doc.to_executed
    create_work_log(__method__)
    redirect_to :back, notice: "to_executed"
  end


  def destroy
    @doc.destroy
    redirect_to docs_url
  end

  def create_chat_room
    chat_room = ChatRoom.new do |chat|
      chat.doc_id = @doc.id
      chat.user_id = current_user.id
      chat.member_ids = [current_user.id]
      chat.name = "Обсуждение документа '#{@doc.name}'"
    end

    if chat_room.save
      chat_room.build_system_message(:create_room, current_user)
      @doc.chat_room_id = chat_room.id
      @doc.save
      redirect_to chat_room_path(chat_room), notice: t('chat_created_successfull')
    else
      render action: "new"
    end
  end

  private

  def check_admin!
    redirect_to :back, alert: 'Only admins allowed!' and return unless current_user.admin?
  end

  def set_doc
    @doc = Doc.find(params[:id])
  rescue Mongoid::Errors::DocumentNotFound
    redirect_to root_path, alert: t('not_found') and return
  end

  def create_work_log(action = nil)
    @work_log = @doc.work_logs.build(user_id: current_user.id, time: Time.now, action: action, comment: params[:comment])
    @work_log.save
  end

  def doc_params
    params.require(:doc).permit!
  end

end
