package MusicBrainz::Server::Edit::Genre::Create;
use Moose;
use namespace::autoclean;

use MusicBrainz::Server::Constants qw( $EDIT_GENRE_CREATE );
use MusicBrainz::Server::Edit::Types qw( Nullable );
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );
use MusicBrainz::Server::Translation qw( N_lp );
use aliased 'MusicBrainz::Server::Entity::PartialDate';
use Moose::Util::TypeConstraints;
use MooseX::Types::Moose qw( Str );
use MooseX::Types::Structured qw( Dict Optional );

use aliased 'MusicBrainz::Server::Entity::Genre';

extends 'MusicBrainz::Server::Edit::Generic::Create';
with 'MusicBrainz::Server::Edit::Role::Preview',
     'MusicBrainz::Server::Edit::Genre',
     'MusicBrainz::Server::Edit::Role::AlwaysAutoEdit',
     'MusicBrainz::Server::Edit::Role::CheckOverlongString' => {
        get_string => sub { shift->{name} },
     };

sub edit_name { N_lp('Add genre', 'edit type') }
sub edit_type { $EDIT_GENRE_CREATE }
sub _create_model { 'Genre' }
sub genre_id { shift->entity_id }


has '+data' => (
    isa => Dict[
        name       => Str,
        gid        => Optional[Str],
        comment    => Nullable[Str],
    ],
);

sub foreign_keys
{
    my $self = shift;
    return {
        Genre       => [ $self->entity_id ],
    };
}

sub build_display_data
{
    my ($self, $loaded) = @_;

    return {
        name    => $self->data->{name},
        comment => $self->data->{comment},
        genre   => to_json_object((defined($self->entity_id) &&
            $loaded->{Genre}{ $self->entity_id }) ||
            Genre->new( name => $self->data->{name} ),
        ),
    };
}

sub edit_template { 'AddGenre' }

__PACKAGE__->meta->make_immutable;
no Moose;

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2022 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
