package MusicBrainz::Server::Edit::Historic::RemoveLabelAlias;
use strict;
use warnings;
use namespace::autoclean;

use MusicBrainz::Server::Constants qw( $EDIT_HISTORIC_REMOVE_LABEL_ALIAS );
use MusicBrainz::Server::Edit::Constants qw( %EDIT_KIND_LABELS );
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );
use MusicBrainz::Server::Translation qw( N_lp );

use MusicBrainz::Server::Edit::Historic::Base;

sub edit_name { N_lp('Remove label alias', 'edit type') }
sub edit_kind { $EDIT_KIND_LABELS{'remove'} }
sub historic_type { 62 }
sub edit_type { $EDIT_HISTORIC_REMOVE_LABEL_ALIAS }
sub edit_template { 'historic/RemoveLabelAlias' }

sub _build_related_entities {
    my $self = shift;
    return { };
}

sub build_display_data
{
    my $self = shift;
    return {
        alias => to_json_object($self->data->{alias}),
    };
}

sub upgrade
{
    my $self = shift;

    $self->data({
        alias => $self->previous_value,
        alias_id => $self->row_id,
    });

    return $self;
}

sub deserialize_new_value {
    my ($self, $value ) = @_;
    return $value;
}

sub deserialize_previous_value {
    my ($self, $value ) = @_;
    return $value;
}

1;
