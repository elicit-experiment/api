
module PreloadHeaders
  extend ActiveSupport::Concern
  included do
    after_action :set_preload_headers
    before_action :init_preload_headers

    attr_reader :preload_header_assets
  end

  protected

  def init_preload_headers
    @preload_header_assets = []
  end

  def set_preload_headers
    return if !request.format.html? || request.xhr? ||
      # Turbolinks 2
      request.headers['X-XHR-Referer'].present? ||
      # Turbolinks 5
      request.env['HTTP_TURBOLINKS_REFERRER']
    response.headers['Link'] = @preload_header_assets.map do |asset|
      "<#{view_context.asset_path(asset[:path])}>; rel=preload; as=#{asset[:as]}"
    end
  end
end
