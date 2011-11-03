package MusicBrainz::Server::WebService::XMLSearch;

use base 'Exporter';
our @EXPORT_OK = qw( xml_search );

use MusicBrainz::Server::Validation qw( is_positive_integer );
use Encode qw( decode );
use URI::Escape qw( uri_escape_utf8 );
use HTTP::Status ':constants';

# Escape special characters in a Lucene search query
sub escape_query
{
    my $str = shift;
    $str =~  s/([+\-&|!(){}\[\]\^"~*?:\\])/\\$1/g;
    return $str;
}

# construct a lucene search query based on the args given and then pass it to a search server.
# Return the complete XML document.
sub xml_search
{
    my ($resource, $args) = @_;

    my $query = "";
    my $dur = 0;
    my $offset = 0;
    my $limit = $args->{limit} || 0;

    if (defined $args->{offset} && is_positive_integer($args->{offset}))
    {
        $offset = $args->{offset}
    }
    $limit = 25 if ($limit < 1 || $limit > 100);

    if (defined $args->{query} && $args->{query} ne "")
    {
        if (ref($args->{query})) {
            return {
                error => "Must specify at most 1 query argument",
                code  => HTTP_BAD_REQUEST
            };
        }

        $query = $args->{query};
    }
    elsif ($resource eq 'artist')
    {
        my $term = escape_query($args->{artist});
        $term =~ s/\s*(.*?)\s*$/$1/;
        if (not $term =~ /^\s*$/)
        {
            $query = "artist:($term)(sortname:($term) alias:($term) !artist:($term))";
        }
    }
    elsif ($resource eq 'label')
    {
        my $term = escape_query($args->{label});
        $term =~ s/\s*(.*?)\s*$/$1/;
        if (not $term =~ /^\s*$/)
        {
            $query = "label:($term)(sortname:($term) alias:($term) !label:($term))";
        }
    }
    elsif ($resource eq 'release')
    {
        $query = "";
        my $term = escape_query($args->{release});
        $term =~ s/\s*(.*?)\s*$/$1/;
        if ($args->{release})
        {
            $query = "(" . join(" AND ", split /\s+/, $term) . ")";
        }
        if ($args->{artistid})
        { 
            $query .= " AND arid:" . escape_query($args->{artistid});
        }
        else
        { 
            my $term = escape_query($args->{artist});
            $term =~ s/\s*(.*?)\s*$/$1/;
            if (not $term =~ /^\s*$/)
            {
                $query .= " AND artist:(" . join(" AND ", split /\s+/, $term) . ")";
            }
        }
        if (defined $args->{releasetype} && $args->{releasetype} =~ /^\d+$/)
        {
            $query .= " AND type:" . $args->{releasetype} . "^0.0001";
        }
        if (defined $args->{releasestatus} && $args->{releasestatus} =~ /^\d+$/)
        {
            $query .= " AND status:" . ($args->{releasestatus} - MusicBrainz::Server::Release::RELEASE_ATTR_SECTION_STATUS_START + 1) . "^0.0001";
        }
        if ($args->{count} > 0)
        {
            $query .= " AND tracks:" . $args->{count};
        }
        if ($args->{discids} > 0)
        {
            $query .= " AND discids:" . $args->{discids};
        }
        if ($args->{date})
        {
            $query .= " AND date:" . $args->{date};
        }
        if ($args->{asin})
        {
            $query .= " AND asin:" . $args->{asin};
        }
        if ($args->{lang})
        {
            $query .= " AND lang:" . $args->{lang};
        }
        if ($args->{script})
        {
            $query .= " AND script:" . $args->{script};
        }
    }
    elsif ($resource eq 'recording')
    {
        $query = "";
        my $term =  escape_query($args->{track});
        $term =~ s/\s*(.*?)\s*$/$1/;
        if ($args->{track})
        {
            $query = "(" . join(" AND ", split /\s+/, $term) . ")";
        }
        if ($args->{artistid})
        {
            $query .= " AND arid:" . escape_query($args->{artistid});
        }
        else
        {
            my $term = escape_query($args->{artist});
            $term =~ s/\s*(.*?)\s*$/$1/;
            if (not $term =~ /^\s*$/)
            {
                $query .= " AND artist:(" . join(" AND ", split /\s+/, $term) . ")";
            }
        }
        if ($args->{releaseid})
        { 
            $query .= " AND reid:" . escape_query($args->{releaseid});
        }
        else
        {
            my $term = escape_query($args->{release});
            $term =~ s/\s*(.*?)\s*$/$1/;
            if (not $term =~ /^\s*$/)
            {
                $query .= " AND release:(" . join(" AND ", split /\s+/, $term) . ")";
            }
        }
        if ($args->{duration})
        {
            my $qdur = int($args->{duration} / 2000);
            $query .= " AND (qdur:$qdur OR qdur:" . ($qdur - 1) . " OR qdur:" . ($qdur + 1) . ")" if ($qdur);
        }
        if ($args->{tracknumber} >= 0)
        {
            $query .= " AND tnum:" . $args->{tracknumber};
        }
        if ($args->{releasetype})
        {
            $query .= " AND type:" . $args->{releasetype};
        }
        if ($args->{count} > 0)
        {
            $query .= " AND tracks:" . $args->{count};
        }
    }
    elsif ($resource eq 'work')
    {
        my $term = escape_query($args->{label});
        $term =~ s/\s*(.*?)\s*$/$1/;
        if (not $term =~ /^\s*$/)
        {
            $query = $term;
        }
    }
    else
    {
        return { 
            error => "Invalid resource $resource.", 
            code  => HTTP_BAD_REQUEST
        };
    }

    $query =~ s/^ AND //;
    # In case we have a blank query
    if ($query =~ /^\s*$/)
    {
        return { 
            error => "Must specify a least one parameter (other than 'limit', 'offset' or empty 'query') for collections query.", 
            code  => HTTP_BAD_REQUEST
        };
    }

    my $url = 'http://' . &DBDefs::LUCENE_SERVER . "/ws/2/$resource/?" .
              "max=$limit&type=$resource&fmt=xml&offset=$offset&query=". uri_escape_utf8($query);

    require LWP::UserAgent;
    my $ua = LWP::UserAgent->new;
    $ua->env_proxy;
    my $response = $ua->get($url);
    $ua->timeout(2);
    if ( $response->is_success )
    {
        return { xml => decode('utf-8', $response->content) };
    }
    else
    {
        if ($response->code == HTTP_BAD_REQUEST)
        {
            return {
                error => "Search server could not complete query: Bad request",
                code  => HTTP_BAD_REQUEST
            }
        }
        else
        {
            return {
                error => "Could not retrieve sub-document page from search server. Error: $url  -> " . $response->status_line,
                code  => HTTP_BAD_REQUEST
            }
        }
    }
}

1;
