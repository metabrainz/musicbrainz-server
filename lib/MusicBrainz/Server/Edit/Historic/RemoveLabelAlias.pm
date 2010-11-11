package MusicBrainz::Server::Edit::Historic::RemoveLabelAlias;
use Moose;
use namespace::autoclean;

use MooseX::Types::Moose qw( Int Str );
use MooseX::Types::Structured qw( Dict );
use MusicBrainz::Server::Constants qw( $EDIT_HISTORIC_REMOVE_LABEL_ALIAS );
use MusicBrainz::Server::Translation qw ( l ln );

extends 'MusicBrainz::Server::Edit::Historic';
with 'MusicBrainz::Server::Edit::Historic::NoSerialization';

sub edit_name { l('Remove label alias') }
sub historic_type { 62 }
sub edit_type { $EDIT_HISTORIC_REMOVE_LABEL_ALIAS }
sub edit_template { 'historic/remove_label_alias' }

has '+data' => (
    isa => Dict[
        alias => Str,
        alias_id => Int
    ]
);

sub build_display_data
{
    my $self = shift;
    return {
        alias => $self->data->{alias}
    }
}

sub upgrade
{
    my $self = shift;

    $self->data({
        alias => $self->previous_value,
        alias_id => $self->row_id
    });
    
    return $self;
}

__PACKAGE__->meta->make_immutable;
1;
