# Add the initial user
['ushi', 'hendrik'].each do |name|
  user = User.new(name: 'peter', prename: name)
  user.username = name
  user.password = name
  user.email = "#{name}@example.com"

  user.privilege = Privilege.new
  user.privilege.admin = true

  user.save
end
