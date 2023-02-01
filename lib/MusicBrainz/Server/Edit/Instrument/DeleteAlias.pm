package MusicBrainz::Server::Edit::Instrument::DeleteAlias;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_INSTRUMENT_DELETE_ALIAS );
use MusicBrainz::Server::Entity::Types;
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );
use MusicBrainz::Server::Translation qw( N_l );

extends 'MusicBrainz::Server::Edit::Alias::Delete';
with 'MusicBrainz::Server::Edit::Instrument';

use aliased 'MusicBrainz::Server::Entity::Instrument';

sub _alias_model { shift->c->model('Instrument')->alias }

sub edit_name { N_l('Remove instrument alias') }
sub edit_kind { 'remove' }
sub edit_type { $EDIT_INSTRUMENT_DELETE_ALIAS }

sub _build_related_entities { { instrument => [ shift->instrument_id ] } }

sub adjust_edit_pending {
    my ($self, $adjust) = @_;

    $self->c->model('Instrument')->adjust_edit_pending($adjust, $self->instrument_id);
    $self->c->model('Instrument')->alias->adjust_edit_pending($adjust, $self->alias_id);
}

has 'instrument_id' => (
    isa => 'Int',
    is => 'rw',
    lazy => 1,
    default => sub { shift->data->{entity}{id} }
);

sub foreign_keys {
    my $self = shift;
    return {
        Instrument => [ $self->instrument_id ],
    };
}

around 'build_display_data' => sub {
    my $orig = shift;
    my ($self, $loaded) = @_;

    my $data = $self->$orig($loaded);
    $data->{instrument} = to_json_object(
        $loaded->{Instrument}{ $self->instrument_id } ||
        Instrument->new(name => $self->data->{entity}{name})
    );

    return $data;
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
