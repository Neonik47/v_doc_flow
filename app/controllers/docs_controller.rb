class DocsController < ApplicationController

  before_filter :check_admin!, only: :destroy
  before_action :clean_doc_notifications, only: [:show]
  before_filter :check_secretary!, only: [:new, :create]
  before_filter :set_mode, only: :index
  #before_filter :set_doc, only: [:show, :edit, :update, :destroy,
  #                              :change_responsible, :to_review, :reject,
  #                              :to_revision, :accept, :to_execution,
  #                              :to_confirmation_of_execution, :to_executed]

  before_filter :set_doc, except: [:index, :new, :create]
  before_filter :set_doc_types, only: [:new, :create]

  def index
    # @docs = Doc.all and return if current_user.admin?
    @docs = case @mode
    when "public"
      Doc.where(is_public: true)
    when "my_attention"
      Doc.all.select{|d| d.current_responsible_id == current_user.id}
    when "my_control"
      Doc.all.select{|d| d.executor_id == current_user.id}
    when "search"
      set_classifiers
      doc_filter_params = params[:doc_filter] || {user_id: current_user.id.to_s}
      @doc_filter = DocFilter.new(doc_filter_params, current_user)
      @doc_filter.search
    else
      Doc.or({responsibles: current_user.id}, {user_id: current_user.id})
    end
  end

  def show
    @users_for_response = @doc.users_by_doc_stage
  end

  def new
    @doc = Doc.new
  end

  def edit
  end

  def print
    pdf = PdfBuilder.new(@doc)
    send_file pdf.file, :filename => pdf.filename, x_sendfile: true
  end

  def create
    @doc = current_user.docs.new(doc_params)
    @doc.sender_id = current_user.id
    @doc.responsibles.push(current_user.id)
    @doc.doc_type.lines.each{|l| @doc.doc_lines.build(l.as_document)}
    @doc.doc_notifications.new
    if @doc.save
      create_work_log(__method__)
      redirect_to docs_path, notice: 'Документ успешно создан.'
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
      redirect_to docs_path, notice: 'Документ успешно обновлен.'
    else
      render action: "edit"
    end
  end

  def change_responsible
    new_responsible = BSON::ObjectId.from_string(params["new_responsible"])
    @doc.change_responsible
    @doc.responsibles.pop unless @doc.executor_id.nil?
    @doc.responsibles.push(new_responsible)
    @doc.executor_id = new_responsible
    @doc.save
    create_work_log(__method__, new_responsible)
    redirect_to :back, notice: t("change_responsible")
  end



  def to_review
    @doc.to_review
    create_work_log(__method__, @doc.executor_id)
    redirect_to :back, notice: t("to_review")
  end

  def reject
    @doc.reject
    create_work_log(__method__)
    redirect_to :back, notice: t("reject")
  end

  def to_revision
    @doc.to_revision
    create_work_log(__method__)
    redirect_to :back, notice: t("to_revision")
  end

  def accept
    @doc.accept
    @doc.sender_id, @doc.executor_id = @doc.executor_id, nil
    @doc.save
    create_work_log(__method__)
    redirect_to :back, notice: t("accept")
  end

  def to_execution
    @doc.to_execution
    create_work_log(__method__, @doc.executor_id)
    redirect_to :back, notice: t("to_execution")
  end

  def to_confirmation_of_execution
    @doc.to_confirmation_of_execution
    create_work_log(__method__, @doc.sender_id)
    redirect_to :back, notice: t("to_confirmation_of_execution")
  end

  def to_executed
    @doc.to_executed
    create_work_log(__method__)
    redirect_to :back, notice: t("to_executed")
  end


  def destroy
    @doc.destroy
    redirect_to docs_url
  end

  def create_chat_room
    redirect_to @doc, alert: t('.only_doc_owner') and return if @doc.user != current_user
    chat_room = ChatRoom.new do |chat|
      chat.doc_id = @doc.id
      chat.user_id = current_user.id
      chat.member_ids = [current_user.id.to_s]
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
    redirect_to root_path, alert: t('only_admins') and return unless current_user.admin?
  end

  def check_secretary!
    redirect_to root_path, alert: t('only_secretaries') and return unless current_user.role == "secretary"
  end

  def set_doc
    @doc = Doc.find(params[:id])
  rescue Mongoid::Errors::DocumentNotFound
    redirect_to root_path, alert: t('not_found') and return
  end

  def clean_doc_notifications
    @doc = Doc.find(params[:id])
    @doc.doc_notifications_by_user(current_user).each{|n| n.delete }
    @doc.doc_change_notifications_by_user(current_user).each{|n| n.delete }
  end

  def create_work_log(action = nil, target_id = nil)
    @work_log = @doc.work_logs.build(user_id: current_user.id, target_id: target_id, time: Time.now, action: action, comment: params[:comment])
    @work_log.save
  end

  def doc_params
    params.require(:doc).permit!
  end

  def set_mode
    mode = params[:mode]
    @mode = "search" and return unless params[:doc_filter].blank?
    @mode = %w(public my_attention my_control search).include?(mode) ? mode : "default"
  end

  def set_doc_types
    @doctypes = DocType.active.to_a
  end

  def set_classifiers
    set_doc_types
    @users = User.exists
    @states = Doc.state_machine.states.map &:value
  end
end
