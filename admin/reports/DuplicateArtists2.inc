%# vi: set ts=2 sw=2 ft=mason :

<& /comp/sidebar, title => 'More possibly duplicate artists' &>

<p>
	This report has been contributed by Wendell T. Hicken from
	<a href="http://music.predixis.com/">Predixis</a> using the
	MusicMagic database.&nbsp; Thanks!
</p>

% my $mtime = $m->comp("./TIMESTAMP");
<p>Data last supplied: <% $m->comp('/comp/datetime', $mtime) %></p>

<& /reports/show_artist_duplicates.inc, %ARGS &>

<& /comp/footer &>
