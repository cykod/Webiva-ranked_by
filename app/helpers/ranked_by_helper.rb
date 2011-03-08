
module RankedByHelper 


  def ranked_by_user
    return @ranked_by_user if @ranked_by_user
    if session[:ranked_by_user_id]
      @ranked_by_user = RankedByUser.find_by_id(session[:ranked_by_user_id])
      if @ranked_by_user && !@ranked_by_user.end_user_id && myself.id
        @existing_ranked_by_user = RankedByUser.find_by_end_user_id(myself.id)
        if @existing_ranked_by_user
          RankedByList.find(:all,:conditions => { :ranked_by_user_id => @existing_ranked_by_user.id }).map do |list|
            list.update_attribute(:ranked_by_user_id,@existing_ranked_by_user.id)
          end
          @ranked_by_user.destroy
          @ranked_by_user= @existing_ranked_by_user
        else
          @ranked_by_user.update_attributes(:end_user_id => myself.id)
        end
      end
    elsif myself.id
      @ranked_by_user = RankedByUser.find_by_end_user_id(myself.id)
    end

    if !@ranked_by_user
      @ranked_by_user = RankedByUser.create(:end_user_id => myself.id ? myself.id : nil)
      session[:ranked_by_user_id] = @ranked_by_user.id
    end

    @ranked_by_user
  end

  def increment_list_views(list)
    session[:ranked_by_lists] ||= {}
    return if session[:ranked_by_lists].has_key?(list.id)
    list.increment_views
    session[:ranked_by_lists][list.id] = true
  end
end
