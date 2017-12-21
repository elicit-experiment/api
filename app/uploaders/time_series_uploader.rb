class TimeSeriesUploader < CarrierWave::Uploader::Base

  process :unzip

  storage :file

  def gunzip(filename)
    command = "gunzip --force #{filename}"
    success = system(command)

    success && $?.exitstatus == 0
  end

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def unzip
    gzip_content = @file.content_type.ends_with? "+gzip"
    file_suffix = File.extname(@filename)
    file_gzip = file_suffix.ends_with? "gz"

    if gzip_content ^ file_gzip
      logger.error "MIME type #{@file.content_type} doesn't match file extension #{filename}!"
      return
    end

    return unless file_gzip

    gunzip @file.file

    @filename = @filename.gsub(/\.gz/, '')
    @file.instance_variable_set(:@file, @file.file.gsub(/\.gz/, ''))
    @file.instance_variable_set(:@content_type, @file.file.gsub(/\+gzip/, ''))
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url(*args)
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # ActionController::Base.helpers.asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  # process scale: [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end

  # Create different versions of your uploaded files:
  # version :thumb do
  #   process resize_to_fit: [50, 50]
  # end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
   def extension_whitelist
     %w(csv tsv gz)
   end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end

end
