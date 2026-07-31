require "test_helper"

class SolidErrors::MarkdownTest < ActionDispatch::IntegrationTest
  setup do
    begin
      raise StandardError, "Something <went> wrong"
    rescue => exception
      Rails.error.report(exception, context: {controller: "UsersController", action: "show"})
    end

    @error = SolidErrors::Error.last
    @occurrence = @error.occurrences.last
  end

  test "renders the occurrence as a plain text prompt" do
    get "/solid_errors/#{@error.id}/occurrences/#{@occurrence.id}.md"

    assert_response :success
    assert_equal "text/plain", response.media_type

    assert_includes response.body, "Investigate and fix the root cause of this error:"
    assert_includes response.body, "<class>StandardError</class>"
    assert_includes response.body, "<backtrace>"
    assert_includes response.body, "\"controller\": \"UsersController\""
    # Not HTML escaped: the exception message survives verbatim.
    assert_includes response.body, "<message>Something <went> wrong</message>"
  end

  test "404s when the occurrence does not belong to the error" do
    other = SolidErrors::Error.create!(exception_class: "Other", message: "other",
      severity: "error", fingerprint: "other")

    get "/solid_errors/#{other.id}/occurrences/#{@occurrence.id}.md"

    assert_response :not_found
  end

  test "the error page links to the copy prompt" do
    get "/solid_errors/#{@error.id}"

    assert_response :success
    assert_includes response.body, "Copy for LLM"
    assert_includes response.body, "/solid_errors/#{@error.id}/occurrences/#{@occurrence.id}"
  end
end
