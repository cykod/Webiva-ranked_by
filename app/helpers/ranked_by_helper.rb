
module RankedByHelper 


  def ranked_by_user
    return @ranked_by_user if @ranked_by_user
    if session[:ranked_by_user]
      @ranked_by_user = RankedByUser.find_by_id(session[:ranked_by_user])
    elsif myself.id
      @ranked_by_user = RankedByUser.find_by_end_user_id(myself.id)
    end

    if !@ranked_by_user
      @ranked_by_user = RankedByUser.create(:end_user_id => myself.id ? myself.id : nil)
      session[:ranked_by_user_id] = @ranked_by_user.id
    end

    @ranked_by_user
  end
end
