%# vi: set ts=2 sw=2 ft=mason :

<& /comp/sidebar, title => 'Albums with "broken" Disc IDs' &>

<p>
	This report identifies albums with Disc IDs, where the tracks
	on the album don't agree with the disc id.
</p>

<p>
	For example, if the disc ID says that there are four tracks, then
	this report checks that the album has four tracks, and that the
	first track is track 1, and the last track is track 4.&nbsp; Note that
	it <i>doesn't</i> check all the intervening track numbers; for example,
	if the tracks on the album were numbered 1, 2, 2, 4, then this
	report would <i>not</i> detect that.&nbsp; However by using both
	this report and the
	<a href="DuplicateTrackNumbers">duplicate track report</a>
	it should be possible to identify and fix all track / discid problems.
</p>


<& /reports/show_albums.inc, %ARGS &>

<& /comp/footer &>
