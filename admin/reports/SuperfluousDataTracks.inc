%# vi: set ts=2 sw=2 ft=mason :

<& /comp/sidebar, title => 'Albums with superfluous data tracks' &>

<p>
	This report lists albums without CDIndex that probably contain
	<em>data tracks</em>.  A data track should be deleted if it is
	the last track of the album and there is no CDIndex.
</p>

<& /reports/show_albums.inc, %ARGS &>

<& /comp/footer &>
