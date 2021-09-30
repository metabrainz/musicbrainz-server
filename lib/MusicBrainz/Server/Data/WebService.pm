package MusicBrainz::Server::Data::WebService;
use Moose;
use namespace::autoclean;

use DBDefs;
use Encode qw( decode );
use HTTP::Status ':constants';
use MusicBrainz::Server::Release;
use MusicBrainz::Server::Validation qw(
    is_non_negative_integer
    is_positive_integer
);
use URI::Escape qw( uri_escape_utf8 );

with 'MusicBrainz::Server::Data::Role::Context';

# Escape special characters in a Lucene search query
sub escape_query {
    (shift // '') =~ s/([+\-&|!(){}\[\]\^"~*?:\\])/\\$1/gr
}

# construct a lucene search query based on the args given and then pass it to a search server.
# Return the complete XML document, or a redirect for x-accel-redirect handling.
sub xml_search
{
    my ($self, $resource, $args) = @_;

    my $query = '';
    my $offset = 0;
    my $limit = 0;
    my $dismax = 'false';

    if (is_positive_integer($args->{offset})) {
        $offset = $args->{offset}
    }

    if (is_positive_integer($args->{limit})) {
        $limit = $args->{limit}
    }

    $limit = 25 if ($limit < 1 || $limit > 100);

    if (defined $args->{query} && $args->{query} ne '')
    {
        if (ref($args->{query})) {
            return {
                error => 'Must specify at most 1 query argument',
                code  => HTTP_BAD_REQUEST
            };
        }

        $query = $args->{query};

        # MBS-8994
        if (defined $args->{dismax} && $args->{dismax} eq 'true') {
            $dismax = 'true';
        }
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
        $query = '';
        my $term = escape_query($args->{release});
        $term =~ s/\s*(.*?)\s*$/$1/;
        if ($args->{release})
        {
            $query = '(' . join(' AND ', split /\s+/, $term) . ')';
        }
        if ($args->{artistid})
        {
            $query .= ' AND arid:' . escape_query($args->{artistid});
        }
        else
        {
            my $term = escape_query($args->{artist});
            $term =~ s/\s*(.*?)\s*$/$1/;
            if (not $term =~ /^\s*$/)
            {
                $query .= ' AND artist:(' . join(' AND ', split /\s+/, $term) . ')';
            }
        }
        if (defined $args->{releasetype} && $args->{releasetype} =~ /^\d+$/)
        {
            $query .= ' AND type:' . $args->{releasetype} . '^0.0001';
        }
        if (defined $args->{releasestatus} && $args->{releasestatus} =~ /^\d+$/)
        {
            $query .= ' AND status:' . ($args->{releasestatus} - MusicBrainz::Server::Release::RELEASE_ATTR_SECTION_STATUS_START + 1) . '^0.0001';
        }
        if (is_positive_integer($args->{count}))
        {
            $query .= ' AND tracks:' . $args->{count};
        }
        if (is_positive_integer($args->{discids}))
        {
            $query .= ' AND discids:' . $args->{discids};
        }
        if ($args->{date})
        {
            $query .= ' AND date:' . $args->{date};
        }
        if ($args->{asin})
        {
            $query .= ' AND asin:' . $args->{asin};
        }
        if ($args->{lang})
        {
            $query .= ' AND lang:' . $args->{lang};
        }
        if ($args->{script})
        {
            $query .= ' AND script:' . $args->{script};
        }
    }
    elsif ($resource eq 'recording')
    {
        $query = '';
        my $term =  escape_query($args->{track});
        $term =~ s/\s*(.*?)\s*$/$1/;
        if ($args->{track})
        {
            $query = '(' . join(' AND ', split /\s+/, $term) . ')';
        }
        if ($args->{artistid})
        {
            $query .= ' AND arid:' . escape_query($args->{artistid});
        }
        else
        {
            my $term = escape_query($args->{artist});
            $term =~ s/\s*(.*?)\s*$/$1/;
            if (not $term =~ /^\s*$/)
            {
                $query .= ' AND artist:(' . join(' AND ', split /\s+/, $term) . ')';
            }
        }
        if ($args->{releaseid})
        {
            $query .= ' AND reid:' . escape_query($args->{releaseid});
        }
        else
        {
            my $term = escape_query($args->{release});
            $term =~ s/\s*(.*?)\s*$/$1/;
            if (not $term =~ /^\s*$/)
            {
                $query .= ' AND release:(' . join(' AND ', split /\s+/, $term) . ')';
            }
        }
        if ($args->{duration})
        {
            my $qdur = int($args->{duration} / 2000);
            $query .= " AND (qdur:$qdur OR qdur:" . ($qdur - 1) . ' OR qdur:' . ($qdur + 1) . ')' if ($qdur);
        }
        if (is_non_negative_integer($args->{tracknumber}))
        {
            $query .= ' AND tnum:' . $args->{tracknumber};
        }
        if ($args->{releasetype})
        {
            $query .= ' AND type:' . $args->{releasetype};
        }
        if (is_positive_integer($args->{count}))
        {
            $query .= ' AND tracks:' . $args->{count};
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
    # In case we have a blank query (only whitespace, or whitespace surrounded by unescaped quotes)
    if ($query =~ /^(?:\s*|"\s*")$/)
    {
        return {
            error => q(You submitted a blank search query. You must include a non-blank 'query=' parameter with your search.),
            code  => HTTP_BAD_REQUEST
        };
    }

    my $url_ext;
    if (DBDefs->SEARCH_ENGINE eq 'LUCENE' || DBDefs->SEARCH_SERVER eq DBDefs::Default->SEARCH_SERVER) {
        my $format = ($args->{fmt} // '') eq 'json' ? 'jsonnew' : 'xml';
        $url_ext = "/ws/2/$resource/?" .
           "max=$limit&type=$resource&fmt=$format&offset=$offset" .
           '&query=' . uri_escape_utf8($query) . "&dismax=$dismax";
    } else {
        my $format = ($args->{fmt} // '') eq 'json' ? 'mbjson' : 'mbxml';
        my $endpoint = 'advanced';
        if ($dismax eq 'true')
        {
            # Solr has a bug where the dismax end point behaves differently
            # from edismax (advanced) when the query size is 1. This is a fix
            # for that. See https://issues.apache.org/jira/browse/SOLR-12409
            if (split(/[\P{Word}_]+/, $query, 2) == 1) {
                $endpoint = 'basic';
            } else {
                $endpoint = 'select';
            }
        }
        $url_ext = "/$resource/$endpoint?" .
            "rows=$limit&wt=$format&start=$offset" .
            '&q=' . uri_escape_utf8($query);
    }

    if (DBDefs->SEARCH_X_ACCEL_REDIRECT) {
        return { redirect_url => '/internal/search/' . DBDefs->SEARCH_SERVER . $url_ext }
    } else {
        my $url = 'http://' . DBDefs->SEARCH_SERVER . $url_ext;
        my $response = $self->c->lwp->get($url);
        if ( $response->is_success )
        {
            return { xml => $response->decoded_content };
        }
        else
        {
            if ($response->code == HTTP_BAD_REQUEST)
            {
                return {
                    error => 'Search server could not complete query: Bad request',
                    code  => HTTP_BAD_REQUEST
                }
            }
            else
            {
                return {
                    error => "Could not retrieve sub-document page from search server. Error: $url  -> " . $response->status_line,
                    code  => HTTP_SERVICE_UNAVAILABLE
                }
            }
        }
    }
}

__PACKAGE__->meta->make_immutable;
1;
