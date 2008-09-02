package MusicBrainz::Server::Facade::Url;

use strict;
use warnings;

use base 'Class::Accessor';

__PACKAGE__->mk_accessors(qw{
    url
    id
    mbid
    description
});

sub entity_type { 'url' }

sub new_from_url
{
    my ($class, $url) = @_;

    return $class->new({
        url         => $url->GetURL,
        id          => $url->id,
        mbid        => $url->mbid,
        description => $url->GetDesc,

        _u          => $url,
    });
}

1;
