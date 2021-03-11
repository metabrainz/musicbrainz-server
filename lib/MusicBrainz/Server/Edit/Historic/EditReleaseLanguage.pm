package MusicBrainz::Server::Edit::Historic::EditReleaseLanguage;
use strict;
use warnings;

use MusicBrainz::Server::Constants qw( $EDIT_HISTORIC_EDIT_RELEASE_LANGUAGE );
use MusicBrainz::Server::Edit::Types qw( Nullable );
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );
use MusicBrainz::Server::Translation qw( N_l );
use MusicBrainz::Server::Validation qw( is_positive_integer );

use aliased 'MusicBrainz::Server::Entity::Release';

use MusicBrainz::Server::Edit::Historic::Base;

sub edit_name     { N_l('Edit release') }
sub edit_kind     { 'edit' }
sub historic_type { 44 }
sub edit_type     { $EDIT_HISTORIC_EDIT_RELEASE_LANGUAGE }
sub edit_template_react { 'historic/EditReleaseLanguage' }

sub _build_related_entities
{
    my $self = shift;
    return {
        release => [ map { @{ $_->{release_ids} } } @{ $self->data->{old} } ]
    }
}

sub foreign_keys
{
    my $self = shift;
    return {
        Release => { map {
            map { $_ => ['ArtistCredit'] } @{ $_->{release_ids} }
        } @{ $self->data->{old} } },
        Language => [
            grep { is_positive_integer($_) }
            $self->data->{language_id},
            map { $_->{language_id} } @{ $self->data->{old} }
        ],
        Script => [
            grep { is_positive_integer($_) }
            $self->data->{script_id},
            map { $_->{script_id} } @{ $self->data->{old} }
        ]
    }
}

sub build_display_data
{
    my ($self, $loaded) = @_;
    return {
        old => [
            map {
                my $release_name = $_->{release_name};
                +{
                    language => to_json_object($loaded->{Language}{ $_->{language_id} }),
                    script   => to_json_object($loaded->{Script}{ $_->{script_id} }),
                    releases => [
                        map {
                            to_json_object(
                                $loaded->{Release}{$_} ||
                                Release->new(
                                    id => $_,
                                    name => $release_name,
                                )
                            )
                        } @{ $_->{release_ids} }
                    ]
                }
            } @{ $self->data->{old} }
        ],
        language => to_json_object($loaded->{Language}{ $self->data->{language_id} }),
        script   => to_json_object($loaded->{Script}{ $self->data->{script_id} }),
    }
}

sub upgrade
{
    my $self = shift;

    my @old;
    for (my $i = 0;; $i++)
    {
        my $album_id = $self->new_value->{"AlbumId$i"}
            or last;
        my ($language_id, $script_id) = split /,/, $self->new_value->{"Prev$i"};

        push @old, {
            release_ids  => $self->album_release_ids($album_id),
            language_id  => $language_id,
            script_id    => $script_id,
            release_name => $self->new_value->{"AlbumName$i"}
        }
    }

    my ($language_id, $script_id) = split /,/, $self->new_value->{Language};
    $self->data({
        language_id => $language_id,
        script_id   => $script_id,
        old => \@old
    });

    return $self;
}

1;
