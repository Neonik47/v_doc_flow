class ChatRoomsController < ApplicationController
  before_action :set_chat_room, only: [:show, :edit, :update, :destroy, :post_message, :leave]
  before_action :clean_notifications, only: [:show, :leave]
  before_action :check_owner_abilities, only: [:edit, :update, :destroy]
  before_action :check_member_abilities, only: [:show, :post_message]
  before_action :set_token_params, only: [:create, :update]

  def index
    @chat_rooms = ChatRoom.where(member_ids: current_user.id).sort_by{|c| (c.messages.last || c).send(:c_at)}.reverse

    @has_ntf = {}
    @chat_rooms.each do |c|
      @has_ntf[c.id] = !c.message_notifications_by_user(current_user).blank?
    end
  end

  def show

  end

  def new
    @chat_room = ChatRoom.new(member_ids:  [current_user.id])
  end

  def edit
  end

  def post_message
    message = @chat_room.messages.new(message_params)
    message.save
    redirect_to @chat_room
  end

  def leave
    if @chat_room.user == current_user.id
      redirect_to chat_rooms_path, alert: t('.cannot_leave_owner') and return
    elsif @chat_room.member_ids.include?(current_user.id.to_s)
      @chat_room.build_system_message(:leave_room, current_user)
      @chat_room.member_ids.delete(current_user.id.to_s)
      @chat_room.save
      redirect_to chat_rooms_path, notice: t('.successfully') and return
    else
      redirect_to chat_rooms_path, alert: t('.cannot_leave_not_member') and return
    end
  end

  def create
    @chat_room = ChatRoom.new(chat_room_params)
    @chat_room.member_ids = @member_ids
    # raise @chat_room.member_ids.inspect#@member_ids.inspect

    if @chat_room.save
      @chat_room.build_system_message(:create_room, current_user)
      @chat_room.build_system_message(:added_users, current_user, @chat_room.members)
      redirect_to @chat_room, notice: 'Чат создан успешно.'
    else
      render action: 'new'
    end
  end

  def update
    # raise params[:chat_room][:member_tokens].inspect

    if @member_ids.blank?
      flash.now[:alert] = t('cannot_be_blank')
      render action: 'edit'
      return
    end

    deleted_members = @chat_room.members - @members_after
    added_members = @members_after - @chat_room.members

    if @chat_room.update(chat_room_params)
      @chat_room.member_ids = @member_ids
      @chat_room.build_system_message(:added_users, current_user, added_members) unless added_members.blank?
      @chat_room.build_system_message(:deleted_users, current_user, deleted_members) unless deleted_members.blank?
      @chat_room.save
      # raise @chat_room.member_ids.inspect
      redirect_to @chat_room, notice: 'Чат обновлен успешно.'
    else
      render action: 'edit'
    end
  end

  def destroy
    @chat_room.destroy
    redirect_to chat_rooms_url, notice: 'Чат удален.'
  end

  private

  def set_chat_room
    @chat_room = ChatRoom.find(params[:id])
  end

  def clean_notifications
    @chat_room.message_notifications_by_user(current_user).each{|n| n.delete }
  end

  def check_owner_abilities
    redirect_to root_path, alert: t('.not_chat_owner') and return unless
      @chat_room.user_id == current_user.id
  end

  def check_member_abilities
    redirect_to root_path, alert: t('.not_chat_member') and return unless
      @chat_room.member_ids.include?(current_user.id.to_s)
  end

  def chat_room_params
    params.require(:chat_room).permit!
  end

  def message_params
    params.require(:message).permit!
  end

  def set_token_params
    @member_ids = (params[:chat_room][:member_tokens].split(',')).unshift(current_user.id.to_s).uniq
    @members_after = @member_ids.map{|m| User.find(m)}
  end
end
