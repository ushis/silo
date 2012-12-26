module ActsAsComment

  # Should be raised when a model does not act as a comment.
  class NotAComment < StandardError

    # Initializes the exception. Takes the model name as argument.
    def initialize(name)
      super("#{name} does not act as comment.")
    end
  end
end
