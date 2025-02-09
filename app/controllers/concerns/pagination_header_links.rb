# frozen_string_literal: true

module PaginationHeaderLinks
  def page_params
    return unless action_name == 'index'

    page = params[:page] || default_page
    page_size = params[:page_size] || default_page_size

    { page: page, page_size: page_size }
  end

  def default_page_size
    20
  end

  def default_page
    1
  end

  def set_pagination_headers(paginated_scope, root_scope = nil, options = {})
    request_params = request.query_parameters
    url_without_params = request.original_url.slice(0..(request.original_url.index('?') - 1)) unless request_params.empty?
    url_without_params ||= request.original_url

    page = {}
    page[:first] = 1 if paginated_scope.total_pages > 1 && !paginated_scope.first_page?
    page[:last] = paginated_scope.total_pages  if paginated_scope.total_pages > 1 && !paginated_scope.last_page?
    page[:next] = paginated_scope.current_page + 1 unless paginated_scope.last_page?
    page[:prev] = paginated_scope.current_page - 1 unless paginated_scope.first_page?

    pagination_links = page.map do |k, v|
      new_request_hash = request_params.merge(page: v)
      "<#{url_without_params}?#{new_request_hash.to_param}>; rel=\"#{k}\""
    end

    headers['Link'] = pagination_links.join(', ') unless pagination_links.empty?
    headers['Total'] = root_scope.size if root_scope.present?
    headers['PageSize'] = options[:page_size] if options[:page_size].present?
  end
end
