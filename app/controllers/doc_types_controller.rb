class DocTypesController < ApplicationController

  before_filter :check_admin!, except: [:show, :get_lines]
  before_filter :set_doc_type, only: [:show, :edit, :update, :destroy, :get_lines]

  def index
    @doc_types = DocType.all
  end

  def show
  end

  def new
    @doc_type = DocType.new
    @doc_type.lines.build
  end

  def edit
  end

  def create
    @doc_type = DocType.new(doc_type_params)
    if @doc_type.save
      redirect_to @doc_type, notice: 'Тип документа успешно создан.'
    else
      render action: "new"
    end
  end

  def update
    if @doc_type.update_attributes(doc_type_params)
      redirect_to @doc_type, notice: 'Тип документа успешно обновлен.'
    else
      render action: "edit"
    end
  end

  def destroy
    @doc_type.destroy
    redirect_to doc_types_url
  end

  def get_lines
    @lines = @doc_type.lines
    respond_to do |format|
      format.html { render layout: false}
      format.json { render json: @lines }
    end
  end

  private

  def check_admin!
    redirect_to :back, alert: t('only_admins') and return unless current_user.admin?
  end

  def set_doc_type
    @doc_type = DocType.find(params[:id])
  rescue Mongoid::Errors::DocumentNotFound
  end
  def doc_type_params
    params.require(:doc_type).permit!
  end
end
