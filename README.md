[![Code Climate](https://codeclimate.com/github/martkaru/imagga.png)](https://codeclimate.com/github/martkaru/imagga)
[![Build Status](https://travis-ci.org/martkaru/imagga.png?branch=master)](https://travis-ci.org/martkaru/imagga)

# Imagga

Client for Imagga image analytics services API

### Note: images MUST be passed in as http and NOT https

## Installation

Add this line to your application's Gemfile:

    gem 'imagga', :git => 'git://github.com/designerpages/imagga.git', :branch => 'master' #client for imagga services like color extraction and categorization

And then execute:

    $ bundle install

To install the original (NON-FORKED) verision one may do yourself as:

    $ gem install imagga

## Usage

Oringally to set up a client one did

    client = Imagga::Client.new(
      base_uri:   '0.0.0.0',                # IP of the Imagga server
      api_key:    '12345678',               # Your api key
      api_secret: '1234567890123456789'     # Your api secret
    )

but in the dp20 repository Rob added an initlizer named imagga with the following

    IMAGGA_API_KEY = '12345678'
    IMAGGA_API_SECRET = '1234567890123456789'
    IMAGGA_API_SERVER_IP = '0.0.0.0'
    
    #overwriting the core client with the proper values hardcoded inside
    module Imagga
      class CoreClient
        def initialize(opts={})
          @api_key     = IMAGGA_API_KEY
          @api_secret  = IMAGGA_API_SECRET 
          @base_uri    = IMAGGA_API_SERVER_IP
        end
      end
    end

by doing this when one does `client = Imagga::Client.new` they get back a client with the proper credentials already supplied


Extract image information

    results = client.extract('http://designerpages.s3.amazonaws.com/assets/33815872/137198173.jpg')

Extract image information with category information

    results = client.extract_with_category('http://designerpages.s3.amazonaws.com/assets/33815872/137198173.jpg')

default paramets for category extraction is `{ :extract_overall_colors => 1, :extract_object_colors =>0, :apply_color_threshold => 1, :classify_with_threshold => 99.61 `

example with
    #take first 5 images of first carpet product
    DPCategory.find(412).products.first.images.collect do |i| i.filename.to_s.gsub("https","http").gsub("-dev","") end.slice(0,4)



Extract image information with indexing and extraction options:

    results = client.extract(
      [
        Imagga::Image.new(url: 'http://image1', id: '333'),
        Imagga::Image.new(url: 'http://image2')
      ],
      extract_overall_colors: true,
      extract_object_colors: false
    )

Check the results, for example:

    results.each do |info|                   # iterate over all input image infos
      puts info.object_percentage            # percentage of the central object on image
      info.image_colors.each do |color|      # iterate over all significant colors
        puts color.info                      # 85.89%, rgb: (246,246,246), hex: #f6f6f6 
      end
    end

Multi-color search:

    client.rank(
      colors: [
        Imagga::RankColor.new(percent: 100, r: 82, g: 37, b: 43)   # use r g b values
        Imagga::RankColor.new(percent: 100, hex: '#336699')        # or use hex
      ],
      type: 'object',
      dist: 6000,
      count: 10
    ).each do |similarity|
      puts "Distance of #%i is %.4f" % [similarity.id, similarity.dist]  # Distance of #333 is 3581.5500
    end

Image crop suggestions:

    client.crop(
      [
        'http://image1',                        # Use urls
        Imagga::Image.new(url: 'http://image2') # or image object
      ],
      resolutions: ['100x40','50x100'],         # '100,40,50,100' or '100x40,50x100' instead of array would work also
      no_scaling: true
    ).each do |crop_info|
      puts crop_info.url
      crop_info.croppings.each do |cropping|
        puts cropping.info
      end
    end

## Contributors

martkaru

jprosevear


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
