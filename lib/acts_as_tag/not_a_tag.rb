module ActsAsTag

  # Should be raised when a model does not act as a tag.
  class NotATag < StandardError

    # Initializes the exception. Takes the name of the model.
    def initialize(name)
      super("#{name} does not act as tag.")
    end
  end
end
