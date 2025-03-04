package MusicBrainz::Server::Edit::Historic::RemoveLink;
use Moose;
use namespace::autoclean;

use MusicBrainz::Server::Constants qw( $EDIT_HISTORIC_REMOVE_LINK );
use MusicBrainz::Server::Edit::Constants qw( %EDIT_KIND_LABELS );
use MusicBrainz::Server::Edit::Historic::Utils qw( upgrade_date );
use MusicBrainz::Server::Translation qw( N_lp );

extends 'MusicBrainz::Server::Edit::Historic::Relationship';

sub edit_name     { N_lp('Remove relationship', 'edit type') }
sub edit_kind     { $EDIT_KIND_LABELS{'remove'} }
sub historic_type { 35 }
sub edit_type     { $EDIT_HISTORIC_REMOVE_LINK }
sub edit_template { 'historic/RemoveRelationship' }

sub _links {
    my $self = shift;
    return @{ $self->data->{links} };
}

sub build_display_data
{
    my ($self, $loaded) = @_;
    return {
        relationships => $self->_display_relationships($self->data, $loaded),
    };
}

sub upgrade
{
    my $self = shift;

    $self->data({
        links => [
            $self->_expand_relationships(
                $self->new_value->{linktypeid},
                $self->new_value->{entity0type},
                $self->new_value->{entity0id},
                $self->new_value->{entity0name},
                $self->new_value->{entity1type},
                $self->new_value->{entity1id},
                $self->new_value->{entity1name},
                $self->new_value->{linktypephrase},
            ),
        ],
        link_type_id => $self->new_value->{linktypeid},
        link_id      => $self->new_value->{linkid},
        link_type_phrase => $self->new_value->{linktypephrase},
        begin_date => upgrade_date($self->new_value->{begindate}),
        end_date => upgrade_date($self->new_value->{enddate}),
    });

    return $self;
}

1;
