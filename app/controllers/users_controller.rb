require 'securerandom'
class UsersController < ApplicationController
  before_filter :set_user, only: [:show, :edit, :update, :destroy]
  before_filter :check_admin!, except: :show
  before_filter :check_access!, only: :edit

  def index
    @users = User.all
  end

  def show
  end

  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  def create
    @user = User.new(params[:user])
    p = SecureRandom.urlsafe_base64(10)
    @user.password = p
    if @user.save
      redirect_to @user, notice: "Пользователь успешно создан.<br>Пароль пользователя <strong>'#{p}'</strong> (без кавычек)".html_safe
    else
      render action: "new"
    end
  end

  def update

    if @user.update_attributes(params[:user])
      redirect_to @user, notice: 'User was successfully updated.'
    else
      render action: "edit"
    end

  end

  def destroy
    @user.destroy
    redirect_to users_url 
  end

  protected
  
  def check_admin!
    redirect_to :back, alert: 'Only admins allowed!' and return unless current_user.admin?
  end 

  def check_access!
    redirect_to :back, alert: 'Only owner or admins allowed!' and return unless (current_user.id == @user.id or current_user.admin?)
  end
  
  private

  def set_user
    @user = User.find(params[:id])
  end
end
