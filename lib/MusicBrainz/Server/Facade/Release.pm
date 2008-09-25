package MusicBrainz::Server::Facade::Release;

use strict;
use warnings;

use base 'Class::Accessor';

use Carp;
use MusicBrainz::Server::Release;

__PACKAGE__->mk_accessors( qw{
    artist_id
    attributes
    cover_art_url
    disc_ids
    first_release_date
    id
    language
    language_code
    mbid
    name
    puid_count
    quality
    release_status
    release_type
    script
    track_count
});

sub entity_type { 'release' }

sub get_release { shift->{_r}; }

sub release_type_name
{
    my $self = shift;
    $self->{_r}->attribute_name($self->release_type);
}

sub release_type_plural
{
    my $self = shift;
    $self->{_r}->attribute_name_as_plural($self->release_type);
}

sub release_status_name
{
    my $self = shift;
    $self->{_r}->attribute_name($self->release_status);
}

sub new_from_release
{
    my ($class, $release) = @_;

    my @attributes      = $release->attributes;
    my ($type, $status) = $release->release_type_and_status;

    return $class->new({
        artist_id          => $release->artist,
        attributes         => [ map { $release->attribute_name($_) } @attributes ],
        cover_art_url      => $release->coverart_url,
        disc_ids           => $release->discid_count,
        first_release_date => $release->GetFirstReleaseDate,
        id                 => $release->id,
        language_code      => $release->language ? $release->language->iso_code_3t : '',
        language           => $release->language ? $release->language->name : '',
        mbid               => $release->mbid,
        name               => $release->name,
        puid_count         => $release->puid_count,
        quality            => ModDefs::GetQualityText($release->quality),
        release_status     => $status,
        release_type       => $type,
        script             => $release->script   ? $release->script->name : '',
        track_count        => $release->track_count,

        _r                 => $release,
    });
}

1;
