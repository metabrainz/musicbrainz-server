package MusicBrainz::Server::Edit::Historic::RemoveReleases;
use strict;
use warnings;

use MusicBrainz::Server::Constants qw( $EDIT_HISTORIC_REMOVE_RELEASES );
use MusicBrainz::Server::Data::Release;
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );
use MusicBrainz::Server::Translation qw( N_l );

use MusicBrainz::Server::Edit::Historic::Base;

sub edit_name     { N_l('Remove releases (historic)') }
sub edit_kind     { 'remove' }
sub historic_type { 24 }
sub edit_type     { $EDIT_HISTORIC_REMOVE_RELEASES }
sub edit_template { 'historic/RemoveReleases' }

sub _build_related_entities {
    my $self = shift;
    return {
        release => [ map { $_->{id} } @{ $self->data->{releases} } ],
    }
}

sub foreign_keys
{
    my $self = shift;

    return {
        Release => { map { $_->{id} => [ 'ArtistCredit' ] } @{ $self->data->{releases} } },
    }
}

sub build_display_data
{
    my ($self, $loaded) = @_;
    return {
        releases => [
            map {
                to_json_object(
                    $loaded->{Release}{$_->{id}} ||
                    MusicBrainz::Server::Entity::Release->new(
                        id => $_->{id},
                        name => $_->{name},
                    )
                )
            } @{ $self->data->{releases} }
        ]
    };
}

sub upgrade
{
    my $self = shift;

    my @releases;
    for (my $i = 0; ; $i++) {
        my $id = $self->new_value->{"AlbumId$i"} or last;
        my $name = $self->new_value->{"AlbumName$i"} or last;

        if (my @ids = @{ $self->album_release_ids($id) }) {
            push @releases, map +{
                id => $_, name => $name
            }, @ids;
        }
        else {
            # If the release has been removed, we won't be able to resolve the IDs
            push @releases, {
                id => 0, name => $name
            }
        }
    }


    $self->data({ releases => \@releases });

    return $self;
}

1;
