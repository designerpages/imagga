module Imagga
  class Client < CoreClient
    def extract(urls_or_images, options={})
      options.merge!(ImageOrUrlParametizer.new.parametrize(urls_or_images))
      ExtractResultBuilder.new.build_from(super(options))
    end

    def extract_with_category(urls_or_images, options={:extract_overall_colors => 1, :extract_object_colors =>0, :apply_color_threshold => 1, :classify_with_threshold => 99.6})
      options.merge!(ImageOrUrlParametizer.new.parametrize(urls_or_images))
      ExtractResultBuilder.new.build_from(super(options))
    end

    def rank(options={})
      colors = options.delete(:colors) { raise_missing('colors') }
      options.merge!(RankColorParametizer.new.parametrize(colors))
      RankResultBuilder.new.build_from(super(options))
    end

    def crop(urls_or_images, options={})
      options.merge!(ImageOrUrlParametizer.new.build_urls(urls_or_images))
      options.merge!(ResolutionParametizer.new.parametrize(options.fetch(:resolutions)))
      CropResultBuilder.new.build_from(super(options))
    end
  end
end
