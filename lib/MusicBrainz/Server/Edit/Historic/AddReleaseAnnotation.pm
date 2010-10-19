package MusicBrainz::Server::Edit::Historic::AddReleaseAnnotation;
use Moose;
use MooseX::Types::Structured qw( Dict Optional );
use MooseX::Types::Moose qw( ArrayRef Int Str );
use MusicBrainz::Server::Constants qw( $EDIT_HISTORIC_ADD_RELEASE_ANNOTATION );
use MusicBrainz::Server::Edit::Types qw( Nullable );
use MusicBrainz::Server::Translation qw ( l ln );

use aliased 'MusicBrainz::Server::Entity::Release';

extends 'MusicBrainz::Server::Edit::Historic';

sub edit_name { l('Add release annotation') }
sub historic_type { 31 }
sub edit_type { $EDIT_HISTORIC_ADD_RELEASE_ANNOTATION }
sub edit_template { 'historic/add_release_annotation' }

has '+data' => (
    isa => Dict[
        release_ids => ArrayRef[Int],
        text => Str,
        changelog => Nullable[Str]
    ]
);

sub upgrade
{
    my $self = shift;
    $self->data({
        release_ids => $self->album_release_ids($self->row_id),
        text => $self->new_value->{Text},
        changelog => $self->new_value->{ChangeLog}
    });
    return $self;
};

sub foreign_keys
{
    my $self = shift;
    return {
        Release => { map { $_ => [ 'ArtistCredit' ] } @{ $self->data->{release_ids} } }
    };
}

sub build_display_data
{
    my ($self, $loaded) = @_;
    return {
        releases => [ map {
            $loaded->{Release}{$_}
        } @{ $self->data->{release_ids} } ],
        annotation => $self->data->{text},
        changelog => $self->data->{changelog}
    };
}

no Moose;
__PACKAGE__->meta->make_immutable;

