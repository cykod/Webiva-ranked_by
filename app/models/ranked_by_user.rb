

class RankedByUser < DomainModel
  has_many :ranked_by_lists

  def lookup(value)
    self.search_amazon value
  end

  def lookup_by_identifier(identifier)
    self.lookup_amazon identifier
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
      :identifier => item['ASIN'],
      :images => images
    }
  end

  def search_amazon(value)
    self.amazon_product_web_service.item_search(value, 'All').collect { |item| self.parse_amazon_item(item) }
  end
  
  def lookup_amazon(value)
    item = self.amazon_product_web_service.item_lookup(value)
    self.parse_amazon_item item
  end
  
  def amazon_product_web_service
    @amazon_product_web_service ||= RankedBy::AdminController.module_options.create_amazon_product_web_service
  end
end
