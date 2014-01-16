package MusicBrainz::Server::Edit::Historic::EditLink;
use Moose;

use MusicBrainz::Server::Edit::Types qw( PartialDateHash );
use MusicBrainz::Server::Edit::Historic::Utils qw( upgrade_date upgrade_type );
use MusicBrainz::Server::Constants qw( $EDIT_HISTORIC_EDIT_LINK );
use MusicBrainz::Server::Data::Utils qw( remove_equal type_to_model );
use MusicBrainz::Server::Translation qw ( N_l );

use aliased 'MusicBrainz::Server::Entity::Link';
use aliased 'MusicBrainz::Server::Entity::LinkType';
use aliased 'MusicBrainz::Server::Entity::PartialDate';
use aliased 'MusicBrainz::Server::Entity::Relationship';

extends 'MusicBrainz::Server::Edit::Historic::Relationship';

sub edit_name     { N_l('Edit relationship (historic)') }
sub edit_kind     { 'edit' }
sub edit_type     { $EDIT_HISTORIC_EDIT_LINK }
sub historic_type { 34 }
sub edit_template { 'historic/edit_relationship' }

sub _links {
    my $self = shift;
    return (
        @{ $self->data->{new}{links} },
        @{ $self->data->{old}{links} },
    );
}

sub _upgrade
{
    my ($self, $hash, $prefix) = @_;

    return {
        link_type_id     => $hash->{$prefix . 'linktypeid'},
        link_type_phrase => $hash->{$prefix . 'linktypephrase'},
        links            => [
            $self->_expand_relationships(
                $self->new_value->{$prefix . 'linktypeid'},
                $self->new_value->{$prefix . 'entity0type'},
                $self->new_value->{$prefix . 'entity0id'},
                $self->new_value->{$prefix . 'entity0name'},
                $self->new_value->{$prefix . 'entity1type'},
                $self->new_value->{$prefix . 'entity1id'},
                $self->new_value->{$prefix . 'entity1name'},
                $self->new_value->{$prefix . 'linktypephrase'},
            )
        ],
        begin_date       => upgrade_date($hash->{$prefix . 'begindate'}),
        end_date         => upgrade_date($hash->{$prefix . 'enddate'}),
        attributes       => [ split / /, ($hash->{$prefix . 'attrs'} || '') ]
    }
}

sub build_display_data
{
    my ($self, $loaded) = @_;
    return {
        relationship => {
            old => $self->_display_relationships($self->data->{old}, $loaded),
            new => $self->_display_relationships($self->data->{new}, $loaded),
        }
    }
}

sub upgrade
{
    my $self = shift;

    my $data = {
        link_id => $self->new_value->{linkid},
        old     => $self->_upgrade($self->new_value, 'old'),
        new     => $self->_upgrade($self->new_value, 'new'),
    };

    $self->data($data);

    return $self;
}

1;
