

class RankedByList < DomainModel

  before_create :create_permalink
  validates_uniqueness_of :permalink

  belongs_to :ranked_by_user
  has_many :items, :class_name => 'RankedByItem', :foreign_key => 'ranked_by_list_id', :order => 'ranking DESC'


  def add_item(item_data)
    item_data[:images] ||= {}
    self.items.create(:name => item_data[:name],
                      :item_type => item_data[:item_type],
                      :identifier => item_data[:identifier],
                      :source_domain => item_data[:source_domain],
                      :url => item_data[:link], 
                      :small_image_url => item_data[:images][:thumb],
                      :large_image_url => item_data[:images][:preview],
                      :description => Util::TextFormatter.text_plain_generator(item_data[:description]).to_s[0..200])
  end

  def as_json(options = {})
    self.attributes.merge(:items => self.items.as_json) 
  end

  def num_items
    self.items.count
  end

  def refresh(opts={})
    self.items.each { |i| i.refresh self.ranked_by_user }
  end

  def must_refresh
    if (self.updated_at + 1.day) < Time.now
      self.updated_at = Time.now
      self.save
      self.run_worker(:refresh)
    end
  end
  
  protected

  def create_permalink
    self.permalink = DomainModel.generate_hash[0..20]
  end
end
