
var RankedBy = (function($) {
  var self = this;
  var updateTimer = null;

  this.updateListItem = function(event) {
    var val = $(this).val();

    if(val.length > 3) {
      self.setAutocompleteTimer();
    }
  }

  this.setAutocompleteTimer = function() {
    if(updateTimer) clearTimeout(updateTimer);
    updateTimer = setTimeout(self.runAutocomplete,600);
  };

  this.runAutocomplete = function() {
    $("#add_item_autocomplete").load("/website/ranked_by/user/lookup",
                            { value: $("#list_add_item").val() },
                            function() { 
                              self.updateAddLinks();
                              $("#add_item_autocomplete").show(); 
                            
                            });
  };


  this.updateAddLinks = function() {
    $(".add-item").click(function() {
      var identifier = $(this).data('identifier');
      if(!self.listId) { 
        self.createListAndAddItem(identifier);
      } else {
        self.addItem(self.listId,identifier);
      }
    });

  };

  this.createListAndAddItem = function(identifier) {
    $.post("/website/ranked_by/user/create_list_add_item",
             { identifier: identifier },
             function(data) {
               document.location = "/list/" +  data['permalink'];
             });
  }

  this.addItem = function(listId,identifier) {
    $.post("/website/ranked_by/user/add_item",
             { list_id: listId, identifier: identifier },
             function(data) {
               $('#user-list').html(data);
             });
  }

  return this;
})(jQuery);


$(function() {


  $('#list_add_item').bind("keyup",RankedBy.updateListItem).bind("change",RankedBy.updateListItem);
});
