# Add the initial user
['ushi', 'hendrik'].each do |name|
  user = User.new(name: 'Peter', prename: name.capitalize)
  user.username = name
  user.password = name
  user.email = "#{name}@example.com"
  user.privileges = { admin: true }
  user.save
end

# Add all available languages
I18n.t(:language).each do |k, _|
  Language.create(language: k)
end
