
var RankedBy = (function($) {
  var self = this;
  var updateTimer = null;

  var lastLookup = null;

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
    var search =  $("#list_add_item").val();
    if(search == lastLookup) return;
    if(search.length <= 3) return;
    lastLookup = search;
    $("#loading-indicator").css('visibility', 'visible');
    $("#add-item-autocomplete").load("/website/ranked_by/user/lookup",
                            { value: $("#list_add_item").val() },
                            function() { 
                              self.updateAddLinks();
                              $("#add-item-autocomplete").slideDown(); 
                              $("#loading-indicator").css('visibility', 'hidden');
                            
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
    $("#add-item-autocomplete").slideUp(); 
    $.post("/website/ranked_by/user/add_item",
             { list_id: listId, identifier: identifier },
             function(data) {
               $(data).appendTo("#ranked_list");
               RankedBy.refreshJavascript();
             });
  }

  this.drawItems = function() {

  }

  this.queueChanges = function(itemId,fieldType,value) {
    
    //alert('Saving: ' + itemId + " " + fieldType + " " + value);
  }

  this.refreshJavascript = function() {
    $("#ranked_list script").remove();

    $('.edit').editable('/website/ranked_by/user/edit?list_id=' + RankedBy.listId,
    { cssclass: 'editable',
    indicator: '<img src="/components/ranked_by/images/indicator.gif"/>',
    onblur: 'submit'
    }
    );

    $('.editarea').editable('/website/ranked_by/user/edit?list_id=' + RankedBy.listId,
    { cssclass: 'editable',
       type: 'textarea',
       height: '150',
      indicator: '<img src="/components/ranked_by/images/indicator.gif"/>',
      submit: 'Save'
     }
    );

    $('#ranked_list').sortable({ handle: 'h3', update: RankedBy.updateSortables });

    $('a.delete').unbind('click').click(function() { 
      if(confirm("Remove this item from the list?")) 
      $.post('/website/ranked_by/user/remove_item',
             { list_id: self.listId, item_id: $(this).parent().data('item-id') });
        $(this).parent().remove();
        RankedBy.renumberSortables();
    });

    RankedBy.renumberSortables();
  }

  this.updateSortables = function() {
    $.post('/website/ranked_by/user/reorder?list_id=' + self.listId,
              $("#ranked_list").sortable("serialize"));
    renumberSortables();
  }

  this.renumberSortables = function()  {
    $("#ranked_list li h3").each(function(idx) {
      $(this).html("#" + (idx+1));
    });
  };

  return this;
})(jQuery);


$(function() {

  $("input").labelify();
  $('#list_add_item').bind("keyup",RankedBy.updateListItem).bind("change",RankedBy.updateListItem);


  RankedBy.refreshJavascript();

});
