package MusicBrainz::Server::Edit::Label::DeleteAlias;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_LABEL_DELETE_ALIAS );
use MusicBrainz::Server::Entity::Types;
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );
use MusicBrainz::Server::Translation qw( N_lp );

extends 'MusicBrainz::Server::Edit::Alias::Delete';
with 'MusicBrainz::Server::Edit::Label';

use aliased 'MusicBrainz::Server::Entity::Label';

sub _alias_model { shift->c->model('Label')->alias }

sub edit_name { N_lp('Remove label alias', 'edit type') }
sub edit_kind { 'remove' }
sub edit_type { $EDIT_LABEL_DELETE_ALIAS }

sub _build_related_entities { { label => [ shift->label_id ] } }

sub adjust_edit_pending
{
    my ($self, $adjust) = @_;

    $self->c->model('Label')->adjust_edit_pending($adjust, $self->label_id);
    $self->c->model('Label')->alias->adjust_edit_pending($adjust, $self->alias_id);
}

sub models {
    my $self = shift;
    return [ $self->c->model('Label'), $self->c->model('Label')->alias ];
}

has 'label_id' => (
    isa => 'Int',
    is => 'rw',
    lazy => 1,
    default => sub { shift->data->{entity}{id} },
);

has 'label' => (
    isa => 'Label',
    is => 'rw',
);

sub foreign_keys
{
    my $self = shift;
    return {
        Label => [ $self->label_id ],
    };
}

around 'build_display_data' => sub
{
    my $orig = shift;
    my ($self, $loaded) = @_;

    my $data = $self->$orig($loaded);
    $data->{label} = to_json_object(
        $loaded->{Label}{ $self->label_id } ||
        Label->new(name => $self->data->{entity}{name}),
    );

    return $data;
};


__PACKAGE__->meta->make_immutable;
no Moose;

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
