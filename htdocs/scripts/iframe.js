function resizeFrameAsRequired(iframe)
{
	var body;
	if (!body && iframe.contentDocument && iframe.contentDocument.body)
		body = iframe.contentDocument.body;
	if (!body && iframe.contentWindow && iframe.contentWindow.document && iframe.contentWindow.document.body)
		body = iframe.contentWindow.document.body;
	if (!body) return;

	var h;
	if (!h && body.scrollHeight) h = body.scrollHeight;
	if (!h && body.offsetHeight) h = body.offsetHeight;
	if (!h) return;

	iframe.height = h + 6;
}
