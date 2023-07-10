package MusicBrainz::Server::Edit::Historic::MergeRelease;
use strict;
use warnings;

use MusicBrainz::Server::Constants qw( $EDIT_HISTORIC_MERGE_RELEASE );
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );
use MusicBrainz::Server::Translation qw( N_l );

use MusicBrainz::Server::Edit::Historic::Base;

use aliased 'MusicBrainz::Server::Entity::Release';

sub edit_name     { N_l('Merge releases') }
sub edit_kind     { 'merge' }
sub historic_type { 23 }
sub edit_type     { $EDIT_HISTORIC_MERGE_RELEASE }
sub edit_template { 'historic/MergeReleases' }

sub _build_related_entities
{
    my $self = shift;
    return {
        artist    => [ $self->artist_id ],
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
                    my $old_release = $_;
                    if (my @ids = @{ $_->{release_ids} }) {
                        map { ## no critic (ProhibitVoidMap) - False positive
                            to_json_object(
                                $loaded->{Release}{$_} //
                                Release->new(name => $old_release->{name})
                            )
                        } @ids;
                    }
                    else {
                        to_json_object(Release->new(name => $_->{name} ))
                    }
                } $self->_old_releases
            ],
            new => [ do {
                if (my @ids = $self->_new_release_ids) {
                    map { ## no critic (ProhibitVoidMap) - False positive
                        to_json_object(
                            $loaded->{Release}{$_} //
                            Release->new(name => $self->data->{new_release}{name})
                        )
                    } @ids;
                }
                else {
                    to_json_object(Release->new(name => $self->data->{new_release}{name}))
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

1;
