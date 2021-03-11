package MusicBrainz::Server::Edit::Historic::AddReleaseAnnotation;
use strict;
use warnings;

use MusicBrainz::Server::Constants qw( $EDIT_HISTORIC_ADD_RELEASE_ANNOTATION );
use MusicBrainz::Server::Edit::Types qw( Nullable );
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );
use MusicBrainz::Server::Filters qw( format_wikitext );
use MusicBrainz::Server::Translation qw( N_l );

use aliased 'MusicBrainz::Server::Entity::Release';

use MusicBrainz::Server::Edit::Historic::Base;

sub edit_name { N_l('Add release annotation') }
sub edit_kind { 'add' }
sub historic_type { 31 }
sub edit_type { $EDIT_HISTORIC_ADD_RELEASE_ANNOTATION }
sub edit_template_react { 'historic/AddReleaseAnnotation' }

sub _build_related_entities {
    my $self = shift;
    return {
        release => $self->data->{release_ids}
    }
}

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
            to_json_object($loaded->{Release}{$_})
        } @{ $self->data->{release_ids} } ],
        text => $self->data->{text},
        html => format_wikitext($self->data->{text}),
        changelog => $self->data->{changelog}
    };
}

1;

