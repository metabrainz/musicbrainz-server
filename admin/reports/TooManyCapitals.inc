%# vi: set ts=2 sw=2 ft=mason :

<& /comp/sidebar, title => 'Tracks with too many capital letters' &>

<p>
	All tracks which contain at least five sequential capital
	characters are listed below:
</p>

<& /reports/show_tracks.inc, %ARGS &>

<& /comp/footer &>
