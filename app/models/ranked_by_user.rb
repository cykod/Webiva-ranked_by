

class RankedByUser < DomainModel
  has_many :ranked_by_lists


  def lookup(value)
    self.search_amazon value
  end

  def lookup_by_identifier(identifier)
       { :name => 'Item ' + rand(100).to_s,
         :identifier => 'id2',
        :description => 'Item description' + rand(100).to_s }
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

  def search_amazon(value)
    self.amazon_product_web_service.item_search(value, 'All').collect do |item|
      { :name => item['ItemAttributes']['Title'],
        :link => item['ItemAttributes']['DetailPageURL'],
        :description => item['ItemAttributes']['Title'],
        :identifier => item['ItemAttributes']['DetailPageURL']
      }
    end
  end
  
  def amazon_product_web_service
    @amazon_product_web_service ||= AmazonProductWebService.new 'AKIAIWEJ7ZFJ7DGFFHMQ', 'lFdUklom35kExtQDJmU1Udl3xsGSuPznKxv7rEc6'
  end
end
