package MusicBrainz::Server::WebService::2::Representation::XML::ArtistCredit;
use Moose;

with 'MusicBrainz::Server::WebService::2::Representation::XML::Serializer';

sub element { 'artist-credit' }

sub serialize_inner {
    my ($self, $artist_credit, %extra) = @_;
    return (
        map {
            $self->xml->name_credit(
                {
                    $_->join_phrase ? ('joinphrase' => $_->join_phrase) : ()
                },
                $_->name ne $_->artist->name ? $self->xml->name($_->name) : (),
                $self->serialize($_->artist)
            )
        } @{ $artist_credit->names }
    );
}

1;
