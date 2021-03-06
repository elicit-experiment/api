module PaginationHeaderLinks
  def page_params
    if action_name == "index"
      page = params[:page] || self.default_page
      page_size = params[:page_size] || self.default_page_size
      { :page => page, :page_size => page_size}
    end
  end

  def default_page_size
    20
  end

  def default_page
    1
  end

  def set_pagination_headers(scope, options = {})
    request_params = request.query_parameters
    url_without_params = request.original_url.slice(0..(request.original_url.index("?")-1)) unless request_params.empty?
    url_without_params ||= request.original_url

    page = {}
    page[:first] = 1 if scope.total_pages > 1 && !scope.first_page?
    page[:last] = scope.total_pages  if scope.total_pages > 1 && !scope.last_page?
    page[:next] = scope.current_page + 1 unless scope.last_page?
    page[:prev] = scope.current_page - 1 unless scope.first_page?

    pagination_links = []
    page.each do |k, v|
      new_request_hash= request_params.merge({:page => v})
      pagination_links << "<#{url_without_params}?#{new_request_hash.to_param}>; rel=\"#{k}\""
    end
    headers["Link"] = pagination_links.join(", ")
  end
end
