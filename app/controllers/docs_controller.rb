class DocsController < ApplicationController

  # before_filter :check_admin!, except: :show
  before_filter :set_doc, only: [:show, :edit, :update, :destroy]

  def index
    @docs = Doc.all
  end

  def show
  end

  def new
    @doc = Doc.new
  end

  def edit
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

  private

  def set_doc
    @doc = Doc.find(params[:id])
  end
end
