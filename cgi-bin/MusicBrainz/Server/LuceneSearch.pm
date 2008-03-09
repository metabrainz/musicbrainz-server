package MusicBrainz::Server::LuceneSearch;

use strict;
use Exporter qw( import );
our @EXPORT_OK = qw( TagLookupQuery );

# Escape special characters in a Lucene search query
sub EscapeQuery
{
	my $str = shift;
	$str =~  s/([+\-&|!(){}\[\]\^"~*?:\\])/\\$1/g;
	return $str;
}

sub TagLookupQuery
{
	my ($artist, $release, $track, $tracknum, $duration) = @_;

	my ($type, $query);
	if ($track) {
		$type = "track";
		$query = EscapeQuery($track);
		if ($release) {
			$query .= " release:(" . EscapeQuery($release) . ")";
		}
		if ($artist) {
			$query .= " artist:(" . EscapeQuery($artist) . ")";
		}
		if ($tracknum) {
			$tracknum = int($tracknum);
			if ($tracknum) {
				$query .= " tnum:$tracknum";
			}
		}
		if ($duration) {
			$duration = int($duration);
			if ($duration) {
				my $qdur = int($duration / 2000);
				$query .= " qdur:$qdur qdur:" . ($qdur + 1);
				if ($qdur > 0) {
					$query .= " qdur:" . ($qdur - 1);
				}
			}
		}
	}
	elsif ($release)
	{
		$type = "release";
		$query = EscapeQuery($release);
		if ($artist) {
			$query .= " artist:(" . EscapeQuery($artist) . ")";
		}
	}
	else
	{
		$type = "artist";
		$query = EscapeQuery($artist);
		$query = "artist:($query) (sortname:($query) alias:($query) !artist:($query))";
	}

	return ($query, $type);
}
