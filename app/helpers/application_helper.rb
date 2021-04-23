# frozen_string_literal: true

module ApplicationHelper
  def javascript_pack_tag(*names, **options)
    Rails.logger.info names
    sources_from_manifest_entries(names, type: :javascript).each { |path| controller.preload_header_assets.push({path: path, as: 'script'}) }
    #Webpacker::Helper::javascript_pack_tag(*names, options)
    javascript_include_tag(*sources_from_manifest_entries(names, type: :javascript), **options)
  end
end
