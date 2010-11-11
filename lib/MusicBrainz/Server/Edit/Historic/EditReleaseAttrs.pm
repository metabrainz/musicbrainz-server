package MusicBrainz::Server::Edit::Historic::EditReleaseAttrs;
use Moose;
use List::MoreUtils qw( uniq );
use MooseX::Types::Structured qw( Dict );
use MooseX::Types::Moose qw( ArrayRef Int Str );
use MusicBrainz::Server::Constants qw(
    $EDIT_HISTORIC_EDIT_RELEASE_ATTRS
);
use MusicBrainz::Server::Edit::Historic::Utils qw( upgrade_type_and_status );
use MusicBrainz::Server::Edit::Types qw( Nullable );
use MusicBrainz::Server::Translation qw ( l ln );

use aliased 'MusicBrainz::Server::Entity::Release';

extends 'MusicBrainz::Server::Edit::Historic';

sub edit_name     { l('Edit release attributes') }
sub edit_type     { $EDIT_HISTORIC_EDIT_RELEASE_ATTRS }
sub historic_type { 26 }

has '+data' => (
    isa => Dict[
        changes => ArrayRef[Dict[
            release_ids   => ArrayRef[Int],
            release_name  => Str,
            old_type_id   => Nullable[Int],
            old_status_id => Nullable[Int]
        ]],
        new_type_id   => Nullable[Int],
        new_status_id => Nullable[Int]
    ],
);

sub _changes     { return @{ shift->data->{changes} } }
sub _release_ids
{
    my $self = shift;
    return uniq map { @{ $_->{release_ids} } } $self->_changes
}

sub related_entities
{
    my $self = shift;
    return {
        release => [ $self->_release_ids ],
    }
}

sub foreign_keys
{
    my $self = shift;
    return {
        Release          => [ $self->_release_ids ],
        ReleaseStatus    => [
            $self->data->{new_status_id},
            map { $_->{old_status_id} } $self->_changes
        ],
        ReleaseGroupType => [
            $self->data->{new_type_id},
            map { $_->{old_type_id} } $self->_changes
        ],
    }
}

sub build_display_data
{
    my ($self, $loaded) = @_;
    return {
        changes => [ map {
            releases => [ do {
                if (my @ids = @{ $_->{release_ids} }) {
                    map { $loaded->{Release}->{$_} } @ids
                }
                else {
                    Release->new(name => $_->{release_name}),
                }
            } ],
            status => $loaded->{ReleaseStatus}{ $_->{old_status_id} },
            type   => $loaded->{ReleaseGroupType}{ $_->{old_type_id} },
        }, $self->_changes ],
        new_status => $loaded->{ReleaseStatus}{ $self->data->{new_status_id} },
        new_type   => $loaded->{ReleaseGroupType}{ $self->data->{new_type_id} },
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
        new_status_id => $new_status
    });

    return $self;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

