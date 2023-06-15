package MusicBrainz::Server::Edit::Historic::AddLink;
use Moose;
use namespace::autoclean;

use MusicBrainz::Server::Edit::Historic::Utils qw( upgrade_date );
use MusicBrainz::Server::Constants qw( $EDIT_HISTORIC_ADD_LINK );
use MusicBrainz::Server::Translation qw( N_l );

extends 'MusicBrainz::Server::Edit::Historic::Relationship';

sub edit_name     { N_l('Add relationship') }
sub edit_kind     { 'add' }
sub historic_type { 33 }
sub edit_type     { $EDIT_HISTORIC_ADD_LINK }
sub edit_template { 'historic/AddRelationship' }

sub _links {
    my $self = shift;
    return @{ $self->data->{links} };
}

sub build_display_data
{
    my ($self, $loaded) = @_;
    return {
        relationships => $self->_display_relationships($self->data, $loaded)
    }
}

sub upgrade
{
    my $self = shift;

    $self->data({
        link_id          => $self->new_value->{linkid},
        link_type_id     => $self->new_value->{linktypeid},
        link_type_name   => $self->new_value->{linktypename},
        link_type_phrase => $self->new_value->{linktypephrase},
        reverse_link_type_phrase => $self->new_value->{rlinktypephrase},
        links            => [
            $self->_expand_relationships(
                $self->new_value->{linktypeid},
                $self->new_value->{entity0type},
                $self->new_value->{entity0id},
                $self->new_value->{entity0name},
                $self->new_value->{entity1type},
                $self->new_value->{entity1id},
                $self->new_value->{entity1name},
                $self->new_value->{linktypephrase}
            )
        ],
        begin_date       => upgrade_date($self->new_value->{begindate}),
        end_date         => upgrade_date($self->new_value->{enddate}),
    });

    return $self;
}

1;
