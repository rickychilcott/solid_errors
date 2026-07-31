module SolidErrors
  class OccurrencesController < ApplicationController
    # GET /errors/1/occurrences/1
    #
    # Always renders the markdown prompt, whether or not the URL carried the
    # `.md` extension. Served as text/plain so browsers display it inline
    # instead of downloading it.
    def show
      @occurrence = Occurrence.find_by!(id: params[:id], error_id: params[:error_id])
      @error = @occurrence.error

      # Rendered as `text` rather than `md` so ActionView's ERB handler skips
      # HTML escaping (its escape_ignore_list covers text/plain), which would
      # otherwise mangle backtraces and exception messages.
      render "show", formats: [:text], content_type: "text/plain", layout: false
    end
  end
end
