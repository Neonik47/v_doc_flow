class DocTypesController < ApplicationController

  before_filter :check_admin!, except: :show
  before_filter :set_doc_type, only: [:show, :edit, :update, :destroy]

  def index
    @doc_types = DocType.all
  end

  def show
  end

  def new
    @doc_type = DocType.new
    3.times do
      line = @doc_type.lines.build
    end
  end

  def edit
  end

  def create
    @doc_type = DocType.new(params[:doc_type])
    if @doc_type.save
      redirect_to @doc_type, notice: 'Doc type was successfully created.'
    else
      render action: "new"
    end
  end

  def update
    if @doc_type.update_attributes(params[:doc_type])
      redirect_to @doc_type, notice: 'Doc type was successfully updated.'
    else
      render action: "edit"
    end
  end

  def destroy
    @doc_type.destroy
    redirect_to doc_types_url
  end

  private

  def check_admin!
    redirect_to :back, alert: 'Only admins allowed!' and return unless current_user.admin?
  end

  def set_doc_type
    @doc_type = DocType.find(params[:id])
  end
end
