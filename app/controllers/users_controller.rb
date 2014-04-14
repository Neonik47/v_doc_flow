require 'securerandom'
class UsersController < ApplicationController
  before_filter :set_user, only: [:show, :edit, :update, :toggle_status, :destroy]
  before_filter :check_admin!, except: :show
  before_filter :check_access!, only: :edit

  def index
    respond_to do |format|
      format.html { @users = User.all }
      format.json do
        q = params[:q] || ""
        @users = User.where(name: /.*#{q.mb_chars.downcase.to_s}.*/i)
        render :json => @users.map(&:alt_attrs)
      end
    end
  end

  def show
  end

  def new
    @user = User.new
  end

  def edit
  end

  def create
    @user = User.new(user_params)
    p = SecureRandom.urlsafe_base64(10) #like "v_2avsdlnN2a7w"
    @user.password = p
    if @user.save
      redirect_to @user, notice: "Пользователь успешно создан.<br>Пароль пользователя <strong>'#{p}'</strong> (без кавычек)".html_safe
    else
      render action: "new"
    end
  end

  def update

    password_changed = !params[:user][:password].blank?
    success =
    if password_changed
      password_ok = (params[:user][:password] == params[:user][:password_confirmation])
      if password_ok
        @user.password = params[:user][:password]
        @user.update_without_password(params_for_update)
      else
        flash[:alert] = t(".passwords_not_equal")
        @user.assign_attributes(params_for_update_with_password)
        false
      end
    else
      @user.update_without_password(params_for_update)
    end


    if success #@user.update_attributes(user_params)
      redirect_to @user, notice: 'Пользователь успешно обновлен'
    else
      render action: "edit"
    end
  end

  def toggle_status
    if params[:s] == '0'
      status = "disabled"
    elsif params[:s] == '1'
      status = "enabled"
    else
      redirect_to :back, alert: "Некорректный параметр для смены статуса!" and return
    end
    @user.status = status
    @user.save!
    redirect_to :back, notice: "Статус пользователя изменен!"
  end

  def destroy
    @user.destroy
    redirect_to users_url
  end

  protected

  def check_admin!
    redirect_to docs_path, alert: t('only_admins') and return unless current_user.admin?
  end

  def check_access!
    redirect_to docs_path, alert: 'Only owner or admins allowed!' and return unless (current_user.id == @user.id or current_user.admin?)
  end

  private

  def params_for_update_with_password(*additional_keys)
    params_for_update(:password, :password_confirmation, *additional_keys)
  end

  def params_for_update(*additional_keys)
    params.require(:user).permit(:email, :name, :role, *additional_keys)
  end

  def set_user
    @user = User.find(params[:id])
  rescue Mongoid::Errors::DocumentNotFound
  end

  def user_params
    params.require(:user).permit!
  end
end
