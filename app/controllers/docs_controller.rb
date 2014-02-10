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
    @doctypes = DocType.active.to_a #delete after good
  end

  def create
    @doc = Doc.new(params[:doc])
    @doc.user = current_user
    @doc.lines = @doc.doc_type.lines.map{|l| doc_line(l, params[:lines][l.id.to_s]) }
    if @doc.save
      redirect_to edit_doc_path(@doc), notice: 'Doc was successfully created.'
    else
      render action: "new"
    create_work_log(__method__)
    end
  end

  def update
    # raise params[:doc].inspect
    # images = params[:doc].delete(:images_attributes) || []
    images_to_destroy = params.delete("images_to_delete") || []
    if @doc.update_attributes(params[:doc])
      # images.each do |image|
      #   i = @doc.images.new(image)
      #   i.save
      # end
      images_to_destroy.each do |image_id|
        image = @doc.images.select{|i| i.id.to_s == image_id}.first
        image.destroy if image
      end
      redirect_to @doc, notice: 'Doc was successfully updated.'
    else
      render action: "edit"
    create_work_log(__method__)
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

  private

  def check_admin!
    redirect_to :back, alert: 'Only admins allowed!' and return unless current_user.admin?
  end

  def set_doc
    @doc = Doc.find(params[:id])
  rescue Mongoid::Errors::DocumentNotFound

  end

  def create_work_log(action = nil)
    @work_log = @doc.work_logs.build(user_id: current_user.id, time: Time.now, action: action, comment: params[:comment])
    @work_log.save
  end

  def doc_line(line, value)
    {line.id.to_s => {name: line.name, type: line.type, title: line.title, validates: line.validates, value: value}}
  end

  def destroy_image(image_id)
    image = @doc.images.select{|i| i.id == image_id}.first
    image.destroy if image
  end
end
