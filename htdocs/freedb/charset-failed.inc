%# vi: set ts=4 sw=4 ft=mason :
<%perl>
$session{"freedb_offer_charset"} = 0;
</%perl>
<& /comp/sidebar, title => 'FreeDB - Select Encoding' &>

<p>
	No other encodings available - perhaps the data is already
	using the correct encoding.&nbsp;
</p>

<form method="post" action="select-macsac.html">
	<p>
		<input type="submit" value="Continue">
	</p>
</form>

<& /comp/footer &>
