

class RankedByList < DomainModel

  before_create :create_permalink
  validates_uniqueness_of :permalink

  belongs_to :ranked_by_user
  has_many :items, :class_name => 'RankedByItem', :foreign_key => 'ranked_by_list_id', :order => 'ranking DESC'


  def add_item(item_data)
    self.items.create(:name => item_data[:name],
                      :description => item_data[:description])
  end

  def as_json(options = {})
    self.attributes.merge(:items => self.items.as_json) 
  end

  protected

  def create_permalink
    self.permalink = DomainModel.generate_hash[0..20]
  end
end
