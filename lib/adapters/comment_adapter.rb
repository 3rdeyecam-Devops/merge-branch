class CommentAdapter
  COMMENT_REGEXP = /\/merge to/
  BRANCH_REGEXP = /\/merge to ([0-9a-zA-Z_.\/-]+)/
  COMMAND_NAME = "/merge"

  def initialize(github_event)
    @event = github_event
    @comment_message = @event&.dig('comment', 'body')
  end

  def valid?
    @comment_message && @comment_message =~ COMMENT_REGEXP
  end

  def branch_name
    match_branch_name(@comment_message)
  rescue StandardError => e
    raise "Could not find branch name, #{e.message}"
  end

  def match_branch_name(str)
    if str =~ BRANCH_REGEXP
      # Extract the branch name from the regex match
      $1
    else
      # Use the old method as fallback
      arr = str.split(/\s+/)
      index = arr.index(COMMAND_NAME)
      return nil unless index && arr[index + 2]
      # Sanitize the branch name to prevent command injection
      arr[index + 2].gsub(/[^0-9a-zA-Z\-_.\/]/, '')
    end
  end
end