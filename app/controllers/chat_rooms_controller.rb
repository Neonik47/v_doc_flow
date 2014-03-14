class ChatRoomsController < ApplicationController
  before_action :set_chat_room, only: [:show, :edit, :update, :destroy]

  def index
    @chat_rooms = ChatRoom.where(member_ids: current_user.id)
  end

  def show
  end

  def new
    @chat_room = ChatRoom.new
  end

  def edit
  end

  def create
    @chat_room = ChatRoom.new(chat_room_params)
    @chat_room.member_ids = [current_user.id]

    if @chat_room.save
      @chat_room.build_system_message(:create_room, current_user)
      redirect_to @chat_room, notice: 'Chat room was successfully created.'
    else
      render action: 'new'
    end
  end

  def update
    if @chat_room.update(chat_room_params)
      redirect_to @chat_room, notice: 'Chat room was successfully updated.'
    else
      render action: 'edit'
    end
  end

  def destroy
    @chat_room.destroy
    redirect_to chat_rooms_url, notice: 'Chat room was successfully destroyed.'
  end

  private
    def set_chat_room
      @chat_room = ChatRoom.find(params[:id])
    end

    def chat_room_params
      params.require(:chat_room).permit!
    end
end
