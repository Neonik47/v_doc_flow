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
    end
  end

  def update
    # raise params[:lines].inspect
    # raise params[:doc].delete(:lines).inspect
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

  def check_admin!
    redirect_to :back, alert: 'Only admins allowed!' and return unless current_user.admin?
  end

  def set_doc
    @doc = Doc.find(params[:id])
  end

  def doc_line(line, value)
    {line.id.to_s => {name: line.name, type: line.type, title: line.title, validates: line.validates, value: value}}
  end
end
