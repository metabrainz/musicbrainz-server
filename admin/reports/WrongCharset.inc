%# vi: set ts=2 sw=2 ft=mason :

<& /comp/sidebar, title =>
				'Tracks which might well be encoded using the wrong character set' &>

<p>
    When data is imported from FreeDB, it is meant to be in the
    iso-8859-1 ("Latin-1") character set.&nbsp;
    However, if the data was actually in a different character set
    - say, the Chinese "Big5" set - then the data which ends up in 
    MusicBrainz is corrupted.&nbsp;
    It's not worthless, though, because with a little effort
    the correct character set can be deduced, and the existing data
    converted into the correct form.
</p>

<p>
    All tracks which look like they might have been encoded
    using the wrong character set are listed below.&nbsp;
</p>

<p>
    (Specifically we're looking for tracks which only contain
    characters from the latin-1 character set, but which don't
    contain any of A-Z a-z 0-9.&nbsp;
    Finally we ignore a few track
    names which fit this category but which occur very often,
    e.g. ".", "?", "???" etc.)
</p>


<& /reports/show_tracks.inc, %ARGS &>

<& /comp/footer &>
