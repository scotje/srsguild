$j(document).ready(function() {
	$j(".raid_group").droppable({
		hoverClass: 'raid_group_hover',
		tolerance: 'intersect',
		scope: 'from_pool',

		drop: function(event, ui) {
			var dropped = $j(ui.draggable).clone(true);

			$j(this).children('.group_slots').append(dropped);

			dropped.removeClass('ui-draggable-dragging');
			dropped.removeClass('in_backup');
			
			
			dropped.css({
			//	position: null,
				left: null,
				top: null
			});
			

			dropped.addClass('in_group');

			dropped.hoverIntent({
				sensitivity: 3, // number = sensitivity threshold (must be 1 or higher)
		        interval: 50, // number = milliseconds for onMouseOver polling interval
		        timeout: 500, // number = milliseconds delay before onMouseOut
				over: function() {
					$j(this).addClass('with_char_tools');
				},

				out: function() {
					$j(this).removeClass('with_char_tools');
				}
			});

			dropped.find(".remove_from_group_button").click(function(e) {
				e.preventDefault();
				
				// Re-enable a drop target if a char is removed from it.
				$j(this).parents('.raid_group').droppable('enable');

				var to_backup = $j(this).parents('.plan_char').clone(false);

				to_backup.removeClass('in_group');
				to_backup.removeClass('with_char_tools');


				$j("#event_signups #end_of_signups").before(to_backup);

				$j(this).parents('.plan_char').remove();

				to_backup.draggable({
					revert: 'invalid',
					revertDuration: 250,
					scope: 'from_pool'
				});

				saveChanges();
			});

			setTimeout(function() {
				ui.draggable.remove();
			}, 1);
			
			// This drop target is full if there are 5 chars in it.
			if ($j(this).children('.group_slots').first().children().size() >= 5) {
				$j(this).droppable('disable');
			}

			saveChanges();
		}
	});
	
	$j(".raid_group").each(function() {
		if ($j(this).children('.group_slots').first().children().size() >= 5) {
			$j(this).droppable('disable');
		}
	});

	$j("#event_signups .plan_char").draggable({
		revert: 'invalid',
		revertDuration: 250,
		scope: 'from_pool'
	});

	$j(".group_slots").sortable({
		connectWith: '.group_slots',
		over: function() {
			if ($j(this).children().size() < 5) {
				$j(this).parent().addClass('raid_group_hover');
			}
		},
		out: function() {
			$j(this).parent().removeClass('raid_group_hover');
		},
		update: function() {
			saveChanges();
		},
		receive: function(event, ui) {
			if ($j(this).children().size() >= 5) {
				$j(ui.sender).sortable('cancel');
			}
		}
	});

	$j(".in_group").hoverIntent({
		sensitivity: 3, // number = sensitivity threshold (must be 1 or higher)
	    interval: 50, // number = milliseconds for onMouseOver polling interval
	    timeout: 500, // number = milliseconds delay before onMouseOut
		over: function() {
			$j(this).addClass('with_char_tools');
		},

		out: function() {
			$j(this).removeClass('with_char_tools');
		}
	});

	$j(".in_group").find(".remove_from_group_button").click(function(e) {
		e.preventDefault();

		// Re-enable a drop target if a char is removed from it.
		$j(this).parents('.raid_group').droppable('enable');

		var to_backup = $j(this).parents('.plan_char').clone(false);

		to_backup.removeClass('in_group');
		to_backup.removeClass('with_char_tools');


		$j("#event_signups #end_of_signups").before(to_backup);

		$j(this).parents('.plan_char').remove();

		to_backup.draggable({
			revert: 'invalid',
			revertDuration: 250,
			scope: 'from_pool'
		});

		saveChanges();
	});

	var groups = new Object;
	var groups_update_lock = false;

	function saveChanges() {
		if (groups_update_lock) {
			return;
		} else {
			groups_update_lock = true;

			$j('.raid_group').each(function(index, raid_group) {
				groups[raid_group.id] = new Array;

				$j(this).find('.plan_char').each(function(cindex, plan_char) {
					groups[raid_group.id].push(plan_char.id);
				});
			});

			$j('#saved_notice').hide();
			$j('#saving_notice').show();

			$j.ajax({
				data: { event_id: plan_event_id, group_setup: groups },
				type: "PUT",
				url: plan_event_url,
				success: function() {
					$j('#saving_notice').hide();
					$j('#saved_notice').show();
					
					updateStats();
					
					groups_update_lock = false;
				}
			});
		}
	}	
	
	function updateStats() {
		$j.ajax({
			data: { event_id: plan_event_id },
			type: "GET",
			url: plan_event_stats_url,
			success: function(data) {
				$j('#event_stats_content').html(data);
				$j('#event_stats').effect("highlight", { color: '#E1F3DB' }, 750);
			}
		});
	}
});
