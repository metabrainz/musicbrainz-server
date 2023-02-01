package MusicBrainz::Server::Edit::Relationship::RemoveLinkAttribute;
use Moose;
use MooseX::Types::Structured qw( Dict Optional );
use MooseX::Types::Moose qw( Str Int );
use MusicBrainz::Server::Constants qw( $EDIT_RELATIONSHIP_REMOVE_LINK_ATTRIBUTE );
use MusicBrainz::Server::Edit::Types qw( Nullable );
use MusicBrainz::Server::Translation qw( N_l );

extends 'MusicBrainz::Server::Edit';
with 'MusicBrainz::Server::Edit::Relationship';
with 'MusicBrainz::Server::Edit::Role::AlwaysAutoEdit';

sub edit_name { N_l('Remove relationship attribute') }
sub edit_kind { 'remove' }
sub edit_type { $EDIT_RELATIONSHIP_REMOVE_LINK_ATTRIBUTE }
sub edit_template { 'RemoveRelationshipAttribute' }

has '+data' => (
    isa => Dict[
        name        => Str,
        description => Nullable[Str],
        id          => Int,
        parent_id   => Nullable[Int],
        child_order => Optional[Str]
    ]
);

sub build_display_data {
    my ($self, $loaded) = @_;

    return {
        description => $self->data->{description},
        name => $self->data->{name},
    };
}

sub accept {
    my $self = shift;
    $self->c->model('LinkAttributeType')->delete($self->data->{id})
};

no Moose;
__PACKAGE__->meta->make_immutable;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
