package MusicBrainz::Server::Data::Role::Tag;
use MooseX::Role::Parameterized;

use MusicBrainz::Server::Data::EntityTag;

parameter 'type' => (
    isa => 'Str',
    required => 1
);

parameter 'tag_table' => (
    isa => 'Str',
    lazy => 1,
    default => sub { shift->type . '_tag' }
);

role
{
    my $params = shift;

    requires 'c';

    has 'tags' => (
        is => 'ro',
        lazy => 1,
        builder => '_build_tags'
    );

    method '_build_tags' => sub
    {
        my $self = shift;
        MusicBrainz::Server::Data::EntityTag->new(
            c => $self->c,
            tag_table => $params->tag_table,
            type => $params->type,
            parent => $self,
        );
    };

};

1;
