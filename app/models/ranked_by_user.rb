

class RankedByUser < DomainModel
  has_many :ranked_by_lists

  def lookup(value)
    if value.include?('http://www.amazon.com')
      begin
        uri = URI.parse value
        [self.lookup_amazon(uri.path.split('/')[-2])]
      rescue URI::InvalidURIError
        []
      end
    elsif value =~ /https?:\/\//
      data = self.lookup_oembed value
      if data
        [data] + self.search_amazon(data[:name])
      else
        []
      end
    else
      self.search_amazon value
    end
  end

  def lookup_by_identifier(identifier)
    src_type, identifier = identifier.split '='
    case src_type
    when 'ASIN'
      self.lookup_amazon identifier
    when 'link'
      self.lookup_oembed identifier
    end
  end

  def get_list(permalink)
    self.ranked_by_lists.find_by_permalink(permalink)
  end

  def get_list_by_id(list_id)
    self.ranked_by_lists.find_by_id(list_id)
  end

  def create_list
    self.ranked_by_lists.create()
  end

  def lookup_oembed(link)
    oembed = RankedByOembed.new
    oembed.link = link
    oembed.process_request ? oembed.parse_item : nil
  end

  def parse_amazon_item(item)
    reviews = item['EditorialReviews'] && item['EditorialReviews']['EditorialReview'] ? item['EditorialReviews']['EditorialReview'] : nil
    reviews = reviews[0] if reviews.is_a?(Array)
    description = reviews ? reviews['Content'] : nil

    images = {}
    [['SmallImage', :thumb], ['MediumImage', :preview], ['LargeImage', :full]].each do |image|
      images[image[1]] = item[image[0]]['URL'] if item[image[0]]
    end

    { :name => item['ItemAttributes']['Title'],
      :link => item['DetailPageURL'],
      :description => description,
      :source_domain => 'amazon.com',
      :item_type => 'amazon',
      :identifier => "ASIN=#{item['ASIN']}",
      :images => images
    }
  end

  def search_amazon(value)
    items = self.amazon_product_web_service.item_search(value, 'All')
    items ? items.collect { |item| self.parse_amazon_item(item) } : []
  end
  
  def lookup_amazon(value)
    item = self.amazon_product_web_service.item_lookup(value)
    self.parse_amazon_item item
  end
  
  def amazon_product_web_service
    @amazon_product_web_service ||= RankedBy::AdminController.module_options.create_amazon_product_web_service
  end
end
