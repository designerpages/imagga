require "httparty"
require "json"

module Imagga
  class BaseCommand
    include HTTParty
    include Imagga::Exceptions

    attr_reader :api_key, :api_secret, :base_uri

    def initialize(api_key, api_secret, base_uri)
      @api_key, @api_secret, @base_uri = api_key, api_secret, base_uri
      self.class.base_uri @base_uri
    end

    def execute(options)
      #made json_response two lines so it is easier to debug calls the imagga service. when needed store a hard coded respose for testing
      json_response = self.class.post(service_path, body: args(options))
      JSON.parse(json_response).tap do |result|
        raise_if_request_failed!(result)
      end
    end

    def args(options)
      options_class.new(api_key, api_secret).options(options)
    end

    def options_class; BaseOptions; end
  end

  class ExtractCommand < BaseCommand
    def service_path; '/colorsearchserver.php'; end
    def options_class; ExtractOptions; end
  end

  class RankCommand < ExtractCommand
    def options_class; RankOptions; end
  end

  class CropCommand < BaseCommand
    def service_path; '/extractionrestserver.php'; end
    def options_class; CropOptions; end
  end
end
