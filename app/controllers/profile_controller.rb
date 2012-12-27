# Provides actions to show/update the users profiles.
class ProfileController < ApplicationController
  before_filter { body_class << :users }

  skip_before_filter :authorize

  # Serves the users profile. Admins are redirected to their edit page.
  #
  # GET /profile
  def edit
    if current_user.admin?
      redirect_to edit_user_url(current_user)
    else
      @user = current_user
      @title = t('labels.user.profile')
    end
  end

  # Updates a users profile. If a user wants to change his(her password, the
  # old password is required.
  #
  # PUT /profile
  def update
    @user = current_user
    @user.check_old_password_before_save

    if @user.update_attributes(params[:user])
      I18n.locale = @user.locale
      flash.now[:notice] = t('messages.generics.success.save')
    else
      flash.now[:alert] = t('messages.generics.errors.save')
    end

    @title = t('labels.user.profile')
    body_class << :edit
    render :edit
  end
end
