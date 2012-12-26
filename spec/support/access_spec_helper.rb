module AccessSpecHelper
  def self.included(base)
    base.before(:all) do
      @credentials = { username: 'john', password: 'secret' }
      @user = create(:user_with_login_hash, @credentials)
    end

    base.after(:all) do
      @user.destroy
    end
  end

  def login
    session[:login_hash] = @user.login_hash
  end

  def logout
    session[:login_hash] = nil
  end

  def set_access(section, value)
    @user.privilege.send("#{section}=", value)
    @user.save
  end

  def grant_access(section)
    set_access(section, true)
  end

  def revoke_access(section)
    set_access(section, false)
  end
end
