package MusicBrainz::Server::WebService::2::Representation::XML::Artist;
use Moose;

with 'MusicBrainz::Server::WebService::2::Representation::XML::Serializer';

sub element { 'artist' }

sub attributes {
    my ($self, $artist) = @_;
    { id => $artist->gid };
}

sub serialize_inner {
    my ($self, $artist, %extra) = @_;

    return (
        # The name, sort-name and comment are always present
        $self->xml->name($artist->name),
        $self->xml->sort_name($artist->sort_name),
        $artist->comment ? $self->xml->disambiguation($artist->comment) : (),

        # We only show other information if this artist is 'top-level'
        $extra{toplevel} ? (
            $self->serialize($artist->gender),
            $self->serialize($artist->country),
            $self->serialize(bless [
                $artist->begin_date, $artist->end_date
            ], 'MusicBrainz::Server::Entity::DateSpan')
        ) : ()
    );
}

1;
