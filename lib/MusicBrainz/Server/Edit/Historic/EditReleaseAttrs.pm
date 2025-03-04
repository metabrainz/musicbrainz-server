package MusicBrainz::Server::Edit::Historic::EditReleaseAttrs;
use strict;
use warnings;

use MusicBrainz::Server::Edit::Historic::Base;

use List::AllUtils qw( uniq );
use MusicBrainz::Server::Constants qw(
    $EDIT_HISTORIC_EDIT_RELEASE_ATTRS
);
use MusicBrainz::Server::Edit::Constants qw( %EDIT_KIND_LABELS );
use MusicBrainz::Server::Edit::Historic::Utils qw( get_historic_type upgrade_type_and_status );
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );
use MusicBrainz::Server::Translation qw( N_lp );

use aliased 'MusicBrainz::Server::Entity::Release';

sub edit_name     { N_lp('Edit release', 'edit type') }
sub edit_kind     { $EDIT_KIND_LABELS{'edit'} }
sub edit_type     { $EDIT_HISTORIC_EDIT_RELEASE_ATTRS }
sub historic_type { 26 }
sub edit_template { 'historic/EditReleaseAttributes' }

sub _changes     { return @{ shift->data->{changes} } }
sub _release_ids
{
    my $self = shift;
    return uniq map { @{ $_->{release_ids} } } $self->_changes;
}

sub _build_related_entities
{
    my $self = shift;
    return {
        release => [ $self->_release_ids ],
    };
}

sub foreign_keys
{
    my $self = shift;
    return {
        Release => [
            map { $_ => ['ArtistCredit'] } $self->_release_ids,
        ],
        ReleaseStatus    => [
            $self->data->{new_status_id},
            map { $_->{old_status_id} } $self->_changes,
        ],
        ReleaseGroupType => [
            $self->data->{new_type_id},
            map { $_->{old_type_id} } $self->_changes,
        ],
    };
}

sub build_display_data
{
    my ($self, $loaded) = @_;
    return {
        changes => [ map {
            releases => [ do {
                if (my @ids = @{ $_->{release_ids} }) {
                    map { ## no critic (ProhibitVoidMap) - False positive
                        to_json_object($loaded->{Release}{$_})
                    } @ids;
                }
                else {
                    to_json_object(Release->new(name => $_->{release_name}));
                }
            } ],
            status => $_->{old_status_id} && to_json_object($loaded->{ReleaseStatus}{ $_->{old_status_id} }),
            type   => get_historic_type($_->{old_type_id}, $loaded),
        }, $self->_changes ],
        status => $self->data->{new_status_id} && to_json_object($loaded->{ReleaseStatus}{ $self->data->{new_status_id} }),
        type   => get_historic_type($self->data->{new_type_id}, $loaded),
    };
}

sub upgrade
{
    my $self = shift;

    my @changes;
    for (my $i = 0; 1; $i++) {
        my $album_id = $self->new_value->{"AlbumId$i"}
            or last;

        my $prev = $self->new_value->{"Prev$i"};
        my ($type_id, $status_id) = upgrade_type_and_status($prev);

        push @changes, {
            release_ids   => $self->album_release_ids($album_id),
            release_name  => $self->new_value->{"AlbumName$i"},
            old_type_id   => $type_id,
            old_status_id => $status_id,
        };
    }

    my $attrs = $self->new_value->{Attributes};
    my ($new_type, $new_status) = upgrade_type_and_status($attrs);

    $self->data({
        changes       => [@changes],
        new_type_id   => $new_type,
        new_status_id => $new_status,
    });

    return $self;
}

1;

