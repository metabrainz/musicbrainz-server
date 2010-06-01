package MusicBrainz::Server::Edit::Historic::MergeRelease;
use Moose;
use MooseX::Types::Structured qw( Dict );
use MooseX::Types::Moose qw( ArrayRef Bool Int Str );
use MusicBrainz::Server::Constants qw( $EDIT_HISTORIC_MERGE_RELEASE );

extends 'MusicBrainz::Server::Edit::Historic';

use aliased 'MusicBrainz::Server::Entity::Release';

sub edit_name     { 'Merge releases' }
sub historic_type { 23 }
sub edit_type     { $EDIT_HISTORIC_MERGE_RELEASE }

sub related_entities
{
    my $self = shift;
    return {
        release   => [ $self->_release_ids ],
    }
}

sub _new_release_ids
{
    my $self = shift;
    return @{ $self->data->{new_release}{release_ids} };
}

sub _old_releases
{
    my $self = shift;
    return @{ $self->data->{old_releases} };
}

sub _old_release_ids
{
    my $self = shift;
    return map { @{ $_->{release_ids} } } $self->_old_releases;
}

sub _release_ids
{
    my $self = shift;
    return (
        $self->_old_release_ids,
        $self->_new_release_ids,
    );
}

has '+data' => (
    isa => Dict[
        old_releases => ArrayRef[Dict[
            release_ids => ArrayRef[Int],
            name        => Str
        ]],
        new_release => Dict[
            release_ids => ArrayRef[Int],
            name        => Str
        ],
        merge_attributes => Bool,
        merge_language   => Bool,
    ]
);

sub foreign_keys
{
    my $self = shift;
    return {
        Release => {
            map { $_ => [ 'ArtistCredit' ] } $self->_release_ids
        }
    }
}

sub build_display_data
{
    my ($self, $loaded) = @_;
    return {
        releases => {
            old => [
                map {
                    if (my @ids = @{ $_->{release_ids} }) {
                        map { $loaded->{Release}->{ $_ } } @ids;
                    }
                    else {
                        Release->new(name => $_->{name} )
                    }
                } $self->_old_releases
            ],
            new => [ do {
                if (my @ids = $self->_new_release_ids) {
                    map { $loaded->{Release}->{ $_ } } @ids;
                }
                else {
                    Release->new(name => $self->data->{new_release}{name})
                }
            } ],
        },
        merge_attributes => $self->data->{merge_attributes},
        merge_language   => $self->data->{merge_language}
    }
}

sub upgrade
{
    my $self = shift;

    my $new_release_id = $self->new_value->{AlbumId0};
    my @old_releases;

    for (my $i = 1; 1; $i++) {
        $self->new_value->{"AlbumId$i"} or last;
        push @old_releases, $i;
    }

    $self->data({
        new_release => {
            release_ids => $self->album_release_ids($new_release_id),
            name => $self->new_value->{AlbumName0}
        },
        old_releases => [
            map { +{
                release_ids => $self->album_release_ids(
                    $self->new_value->{"AlbumId$_"}),
                name => $self->new_value->{"AlbumName$_"}
            } } @old_releases
        ],
        merge_language   => $self->new_value->{merge_langscript} || 0,
        merge_attributes => $self->new_value->{merge_attributes} || 0,
    });

    return $self;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
