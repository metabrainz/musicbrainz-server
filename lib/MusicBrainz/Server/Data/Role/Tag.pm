package MusicBrainz::Server::Data::Role::Tag;
use MooseX::Role::Parameterized;

use MusicBrainz::Server::Data::EntityTag;

parameter 'tag_table';
parameter 'raw_tag_table';

role
{
    my $params    = shift;
    my $table     = $params->tag_table;
    my $raw_table = $params->raw_tag_table;

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
            c         => $self->c,
            rw_table  => $table,
            raw_table => $raw_table,
            parent    => $self,
        );
    };

};

1;
