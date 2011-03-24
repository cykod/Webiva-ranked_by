class RankedBy::ThumbnailController < ApplicationController
  def notify
    RankedByItem.update_cached_item(params[:id]) if params[:id]
    render :nothing => true
  end
end
