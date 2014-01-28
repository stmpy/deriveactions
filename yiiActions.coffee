###
# @author Travis Jeppson <travis@plaidtie.net>
# @depends DeriveActions, jQuery
###
class YiiActions extends DeriveActions
	updateGridView: (gridViews) ->
		$('#'+id).yiiGridView('update') for id in gridViews when $('#'+id).length > 0
	updateListView: (listViews) ->
		$.fn.yiiListView.update(id) for id in listViews when $('#'+id).length > 0
