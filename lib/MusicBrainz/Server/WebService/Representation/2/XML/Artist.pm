package MusicBrainz::Server::WebService::Representation::2::XML::Artist;
use Moose;

with 'MusicBrainz::Server::WebService::Representation::2::XML::Serializer';

sub serialize_resource {
    my ($self, $artist, %extra) = @_;
    $self->xml->artist(
        { id => $artist->gid },

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
