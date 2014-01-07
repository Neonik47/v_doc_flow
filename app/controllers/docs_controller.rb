class DocsController < ApplicationController

  before_filter :check_admin!, except: :show
  before_filter :set_doc, only: [:show, :edit, :update, :destroy]

  def index
    @docs = Doc.all
  end

  def show
  end

  def new
    @doc = Doc.new
    @doctypes = DocType.active.to_a
  end

  def edit
    @doctypes = DocType.active.to_a
  end

  def create
    @doc = Doc.new(params[:doc])
    if @doc.save
      redirect_to @doc, notice: 'Doc was successfully created.'
    else
      render action: "new"
    end
  end

  def update
    if @doc.update_attributes(params[:doc])
      redirect_to @doc, notice: 'Doc was successfully updated.'
    else
      render action: "edit"
    end
  end

  def destroy
    @doc.destroy
    redirect_to docs_url
  end

  protected

  def check_admin!
    redirect_to :back, alert: 'Only admins allowed!' and return unless current_user.admin?
  end

  private

  def set_doc
    @doc = Doc.find(params[:id])
  end
end
