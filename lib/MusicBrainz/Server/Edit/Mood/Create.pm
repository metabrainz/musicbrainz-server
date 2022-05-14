package MusicBrainz::Server::Edit::Mood::Create;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_MOOD_CREATE );
use MusicBrainz::Server::Edit::Types qw( Nullable );
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );
use MusicBrainz::Server::Translation qw( N_l );
use aliased 'MusicBrainz::Server::Entity::PartialDate';
use Moose::Util::TypeConstraints;
use MooseX::Types::Moose qw( Str );
use MooseX::Types::Structured qw( Dict Optional );

use aliased 'MusicBrainz::Server::Entity::Mood';

extends 'MusicBrainz::Server::Edit::Generic::Create';
with 'MusicBrainz::Server::Edit::Role::Preview';
with 'MusicBrainz::Server::Edit::Mood';
with 'MusicBrainz::Server::Edit::Role::AlwaysAutoEdit';

sub edit_name { N_l('Add mood') }
sub edit_type { $EDIT_MOOD_CREATE }
sub _create_model { 'Mood' }
sub mood_id { shift->entity_id }


has '+data' => (
    isa => Dict[
        name       => Str,
        gid        => Optional[Str],
        comment    => Nullable[Str],
    ]
);

sub foreign_keys
{
    my $self = shift;
    return {
        Mood       => [ $self->entity_id ],
    };
}

sub build_display_data
{
    my ($self, $loaded) = @_;

    return {
        name    => $self->data->{name},
        comment => $self->data->{comment},
        mood   => to_json_object((defined($self->entity_id) &&
            $loaded->{Mood}{ $self->entity_id }) ||
            Mood->new( name => $self->data->{name} )
        ),
    };
}

sub edit_template_react { 'AddMood' };

__PACKAGE__->meta->make_immutable;
no Moose;

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2022 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
