package MusicBrainz::Server::Edit::Relationship::EditLinkAttribute;
use Moose;
use MooseX::Types::Structured qw( Dict Optional );
use MooseX::Types::Moose qw( Bool Int Str );
use Data::Compare;
use MusicBrainz::Server::Constants qw( $EDIT_RELATIONSHIP_ATTRIBUTE );
use MusicBrainz::Server::Data::Utils qw( boolean_to_json );
use MusicBrainz::Server::Edit::Types qw( Nullable );
use MusicBrainz::Server::Edit::Utils qw( changed_display_data );
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );
use MusicBrainz::Server::Translation qw( N_l );

extends 'MusicBrainz::Server::Edit';
with 'MusicBrainz::Server::Edit::Relationship';
with 'MusicBrainz::Server::Edit::Role::AlwaysAutoEdit';

sub edit_name { N_l('Edit relationship attribute') }
sub edit_kind { 'edit' }
sub edit_type { $EDIT_RELATIONSHIP_ATTRIBUTE }
sub edit_template { 'EditRelationshipAttribute' }

sub change_fields
{
    return Dict[
        name        => Optional[Str],
        description => Nullable[Str],
        parent_id   => Nullable[Int],
        child_order => Optional[Int],
        creditable => Optional[Bool],
        free_text => Optional[Bool],
    ]
}

sub to_hash {
    my $data = shift->data;

    for ($data->{old}, $data->{new}) {
        $_->{creditable} = boolean_to_json($_->{creditable}) if exists $_->{creditable};
        $_->{free_text} = boolean_to_json($_->{free_text}) if exists $_->{free_text};
    }

    MusicBrainz::Server::Edit::Exceptions::NoChanges->throw
        if Compare($data->{old}, $data->{new});

    return $data;
}

has '+data' => (
    isa => Dict[
        entity_id => Int,
        old       => change_fields(),
        new       => change_fields()
    ]
);

sub foreign_keys
{
    my $self = shift;
    return {
        LinkAttributeType => [ map { $self->data->{$_}{parent_id} } qw( old new ) ],
    };
}

sub build_display_data
{
    my ($self, $loaded) = @_;

    my %map = (
        parent      => [ qw( parent_id LinkAttributeType )],
        name        => 'name',
        description => 'description',
        child_order => 'child_order',
        creditable  => 'creditable',
        free_text   => 'free_text',
    );

    my $data = changed_display_data($self->data, $loaded, %map);

    if (exists $data->{parent}) {
        $data->{parent}{old} = to_json_object($data->{parent}{old});
        $data->{parent}{new} = to_json_object($data->{parent}{new});
    }

    return $data;
}

sub accept {
    my $self = shift;
    $self->c->model('LinkAttributeType')->update($self->data->{entity_id},
                                                 $self->data->{new})
};

no Moose;
__PACKAGE__->meta->make_immutable;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
