%# vi: set ts=2 sw=2 ft=mason :

<& /comp/sidebar, title => 'Albums with Duplicate Track Numbers' &>

<p>
	This report identifies albums where at least one track number appears more
	than once (e.g. there are two "track 4"s).
</p>

<& /reports/show_albums.inc, %ARGS &>

<& /comp/footer &>
