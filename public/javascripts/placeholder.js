document.observe('dom:loaded', function() {
	if (!Modernizr.input.placeholder) {
		$$('[placeholder]').each(function(el) {
			el.value = el.readAttribute('placeholder');
			
			el.observe('focus', function() {
				if (this.value == this.readAttribute('placeholder')) {
					this.value = '';
				}
			});

			el.observe('blur', function() {
				if (this.value == '') {
					this.value = this.readAttribute('placeholder');
				}
			});
		});
	}
});
