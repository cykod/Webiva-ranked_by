

class RankedByUser < DomainModel
  has_many :ranked_by_lists


  def lookup(value)
     [ { :name => 'Testerma',
       :identifier => 'id1',
       :description => 'This is atesteasfd asoufh dasfhodas' },
       { :name => 'Item 2',
         :identifier => 'id2',
        :description => 'Item 2' }
     ]
  end

  def lookup_by_identifier(identifier)
       { :name => 'Item 2',
         :identifier => 'id2',
        :description => 'Item 2' }
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

end
