package MusicBrainz::Server::Edit::ReleaseGroup::DeleteAlias;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_RELEASEGROUP_DELETE_ALIAS );
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );
use MusicBrainz::Server::Translation qw( N_l );

extends 'MusicBrainz::Server::Edit::Alias::Delete';
with 'MusicBrainz::Server::Edit::ReleaseGroup';

use aliased 'MusicBrainz::Server::Entity::ReleaseGroup';

sub _alias_model { shift->c->model('ReleaseGroup')->alias }

sub edit_name { N_l('Remove release group alias') }
sub edit_kind { 'remove' }
sub edit_type { $EDIT_RELEASEGROUP_DELETE_ALIAS }

sub _build_related_entities { { release_group => [ shift->release_group_id ] } }

sub adjust_edit_pending {
    my ($self, $adjust) = @_;

    $self->c->model('ReleaseGroup')->adjust_edit_pending($adjust, $self->release_group_id);
    $self->c->model('ReleaseGroup')->alias->adjust_edit_pending($adjust, $self->alias_id);
}

has 'release_group_id' => (
    isa => 'Int',
    is => 'rw',
    lazy => 1,
    default => sub { shift->data->{entity}{id} }
);

sub foreign_keys {
    my $self = shift;
    return {
        ReleaseGroup => [ $self->release_group_id ],
    };
}

around 'build_display_data' => sub {
    my $orig = shift;
    my ($self, $loaded) = @_;

    my $data = $self->$orig($loaded);
    $data->{release_group} = to_json_object(
        $loaded->{ReleaseGroup}{ $self->release_group_id } ||
        ReleaseGroup->new(name => $self->data->{entity}{name})
    );

    return $data;
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2015 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
