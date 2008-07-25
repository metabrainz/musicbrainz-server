package MusicBrainz::Server::Facade::Release;

use strict;
use warnings;

use base 'Class::Accessor';

use Carp;
use MusicBrainz::Server::Facade::Artist;
use MusicBrainz::Server::Release;

__PACKAGE__->mk_accessors( qw{
    artist
    attributes
    cover_art_url
    disc_ids
    first_release_date
    id
    language_code
    language
    mbid
    name
    puid_count
    quality
    script
    track_count
    release_type
    release_status
});

sub entity_type { 'release' }

sub get_release { shift->{_r}; }

sub release_type_name
{
    my $self = shift;
    $self->{_r}->GetAttributeName($self->release_type);
}

sub release_type_plural
{
    my $self = shift;
    $self->{_r}->GetAttributeNamePlural($self->release_type);
}

sub release_status_name
{
    my $self = shift;
    $self->{_r}->GetAttributeName($self->release_status);
}

sub new_from_release
{
    my ($class, $release) = @_;

    my @attributes      = $release->GetAttributes;
    my ($type, $status) = $release->GetReleaseTypeAndStatus;

    return $class->new({
        artist             => MusicBrainz::Server::Facade::Artist->new({ id => $release->GetArtist }),
        attributes         => [ map { $release->GetAttributeName($_) } @attributes ],
        cover_art_url      => $release->GetCoverartURL,
        disc_ids           => $release->GetDiscidCount,
        first_release_date => $release->GetFirstReleaseDate,
        id                 => $release->GetId,
        language_code      => $release->GetLanguage ? $release->GetLanguage->GetISOCode3T : '',
        language           => $release->GetLanguage ? $release->GetLanguage->GetName : '',
        mbid               => $release->GetMBId,
        name               => $release->GetName,
        puid_count         => $release->GetPuidCount,
        quality            => ModDefs::GetQualityText($release->GetQuality),
        script             => $release->GetScript   ? $release->GetScript->GetName   : '',
        track_count        => $release->GetTrackCount,
        release_type       => $type,
        release_status     => $status,

        _r                 => $release,
    });
}

1;
