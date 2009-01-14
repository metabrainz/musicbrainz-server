function MbPopup()
{

	this._visible = false;

	this.show = function(coords, html, caption, opts)
	{
		var overDiv = $('overDiv');
		var width = 200;

		var content = DIV();
		content.innerHTML = html;

		var closeLink = 
			A({'href': ''},
				IMG({'src': '/images/es/close.gif', 'border': '0'})
			);
		connect(closeLink, 'onclick', function(e) { e.stop(); mb.popup.hide(); });
		
		var header =
			TABLE({'cellpadding': '0', 'cellspacing': '0', 'width': '100%'},
				TR({},
					TD({'style': '', 'class': opts['captionfontclass']}, caption),
					TD({'style': 'text-align:right;', 'class': opts['closefontclass']}, closeLink)
				)
			);
		
		replaceChildNodes(overDiv,
  			TABLE({'cellpadding': '0', 'cellspacing': '1', 'style': '', 'class': opts['bgclass']},
				TR({}, TD({'style': ''}, header)),
				TR({}, TD({'style': 'padding: 2px;', 'class': opts['fgclass']}, content))
			)
		);
		setStyle(overDiv, {
			'visibility': '',
			'width': width + 'px'
		});
		setElementPosition(overDiv, new Coordinates(coords.x + 10, coords.y + 10));
		this._visible = true;
	}

	this.hide = function()
	{
		setStyle('overDiv', {'visibility': 'hidden'});
		this._visible = false;
	}

	this.isVisible = function()
	{
		return this._visible;
	}

}

mb.popup = new MbPopup();
