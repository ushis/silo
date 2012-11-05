# The NotATagError should be raised if a model does not act like a tag.
class NotATagError < StandardError

  # Sets a proper error message.
  def initialize(name)
    super("Class does not act as a tag: #{name}")
  end
end
