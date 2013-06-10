<p>Hello <%= @resource.email %>!</p>

<p>Your account has been locked due to an excessive amount of unsuccessful sign in attempts.</p>

<p>Click the link below to unlock your account:</p>

<p><%= link_to 'Unlock my account', unlock_url(@resource, :unlock_token => @resource.unlock_token) %></p>
Bulk Invitations
If you are selecting only a few dozen initial users, this process of manual selection will be adequate. If you are ready to launch and want to invite hundreds or thousands of users, you’ll need a way to invite multiple users with a single action. We need to implement a “bulk invitations” feature.

You should set up an SMTP relay service such as Mandrill or SendGrid before you attempt to send more than a few dozen email messages. The Configuration chapter of this tutorial showed how to set up Mandrill. See the article Send Email with Rails for details.

We’ll add a bulk_invite action to the controller file app/controllers/users_controller.rb:

class UsersController < ApplicationController
  before_filter :authenticate_user!

  def index
    authorize! :index, @user, :message => 'Not authorized as an administrator.'
    @users = User.all
  end

  def show
    @user = User.find(params[:id])
  end

  def update
    authorize! :update, @user, :message => 'Not authorized as an administrator.'
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user], :as => :admin)
      redirect_to users_path, :notice => "User updated."
    else
      redirect_to users_path, :alert => "Unable to update user."
    end
  end

  def destroy
    authorize! :destroy, @user, :message => 'Not authorized as an administrator.'
    user = User.find(params[:id])
    unless user == current_user
      user.destroy
      redirect_to users_path, :notice => "User deleted."
    else
      redirect_to users_path, :notice => "Can't delete yourself."
    end
  end

  def invite
    authorize! :invite, @user, :message => 'Not authorized as an administrator.'
    @user = User.find(params[:id])
    @user.send_confirmation_instructions
    redirect_to :back, :only_path => true, :notice => "Sent invitation to #{@user.email}."
  end

  def bulk_invite
    authorize! :bulk_invite, @user, :message => 'Not authorized as an administrator.'
    users = User.where(:confirmation_token => nil).order(:created_at).limit(params[:quantity])
    count = users.count
    users.each do |user|
      user.send_confirmation_instructions
    end
    redirect_to :back, :only_path => true, :notice => "Sent invitation to #{count} users."
  end

end