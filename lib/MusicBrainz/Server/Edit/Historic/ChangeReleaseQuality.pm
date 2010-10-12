package MusicBrainz::Server::Edit::Historic::ChangeReleaseQuality;
use Moose;
use MooseX::Types::Structured qw( Dict );
use MooseX::Types::Moose qw( ArrayRef Int Str );
use MusicBrainz::Server::Constants qw( $EDIT_HISTORIC_CHANGE_RELEASE_QUALITY );

use aliased 'MusicBrainz::Server::Entity::Release';

extends 'MusicBrainz::Server::Edit::Historic';

sub edit_type     { $EDIT_HISTORIC_CHANGE_RELEASE_QUALITY }
sub historic_type { 63 }
sub edit_name     { 'Change release quality' }
sub edit_template { 'historic/change_release_quality' }

sub related_entities
{
    my $self = shift;
    return {
        release => [ map {
            @{ $_->{release_ids} }
        } @{ $self->data->{changes} } ]
    }
}

has '+data' => (
    isa => Dict[
        changes => ArrayRef[Dict[
            release_ids  => ArrayRef[Int],
            release_name => Str,
            old          => Dict[ quality => Int ],
            new          => Dict[ quality => Int ],
        ]]
    ]
);

sub foreign_keys
{
    my $self = shift;
    return {
        Release => { map {
            map { $_ => ['ArtistCredit'] } @{ $_->{release_ids} }
        } @{ $self->data->{changes} } }
    }
}

sub build_display_data
{
    my ($self, $loaded) = @_;
    return {
        changes => [ map {
            my $change = $_;
            +{
                releases => [
                    map {
                        $loaded->{Release}{ $_ } ||
                        Release->new( name => $change->{release_name} )
                    } @{ $_->{release_ids} }
                ],
                quality => {
                    new => $_->{new}{quality},
                    old => $_->{old}{quality}
                }
            }
        } @{ $self->data->{changes} } ]
    }
}

sub upgrade
{
    my $self = shift;

    my @changes;
    for (my $i = 0;; $i++) {
        my $album_id = $self->new_value->{"ReleaseId$i"}
            or last;

        push @changes, {
            release_ids  => $self->album_release_ids($album_id),
            release_name => $self->new_value->{"ReleaseName$i"},
            old          => { quality => $self->new_value->{"Prev$i"} },
            new          => { quality => $self->new_value->{Quality} }
        };
    }

    $self->data({
        changes => \@changes
    });

    return $self;
}

no Moose;
__PACKAGE__->meta->make_immutable;
