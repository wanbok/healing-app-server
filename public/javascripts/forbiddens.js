$(function() {
	for (var i = 1; i < 8; i++) {
		$( "#selectable"+i ).selectable({
			stop: function() {
				var result = $( "#select-result"+i ).empty();
				alert("test");
				$( ".ui-selected", this ).each(function() {
					var index = $(".ui-selectee").index( this );
					alert("ay: "+index);
					result.append( " #" + ( index + 1 ) );
				});
			}
		});
	};
});

