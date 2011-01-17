package MusicBrainz::Server::Edit::Medium::AddDiscID;
use Moose;
use Method::Signatures::Simple;
use MooseX::Types::Structured qw( Dict );
use MooseX::Types::Moose qw( Int Str );
use MusicBrainz::Server::Constants qw( $EDIT_MEDIUM_ADD_DISCID );
use MusicBrainz::Server::Edit::Types qw( NullableOnPreview );
use MusicBrainz::Server::Translation qw( l ln );
use MusicBrainz::Server::Translation qw( l ln );

sub edit_name { l('Add disc ID') }
sub edit_type { $EDIT_MEDIUM_ADD_DISCID }

extends 'MusicBrainz::Server::Edit';
with 'MusicBrainz::Server::Edit::Role::Insert';
with 'MusicBrainz::Server::Edit::Role::Preview';
with 'MusicBrainz::Server::Edit::Medium';

has '+data' => (
    isa => Dict[
        cdtoc      => Str,
        medium_id  => NullableOnPreview[Int],
        release_id => NullableOnPreview[Int],
    ]
);

method release_id { $self->data->{release_id} }

method alter_edit_pending
{
    return {
        MediumCDTOC => [ $self->entity_id ],
    }
}

after initialize => sub {
    my $self = shift;

    if ($self->preview)
    {
       $self->entity_id(0);
       return;
    }
};

method related_entities
{
    return {
        release => [ $self->release_id ]
    }
}

method foreign_keys
{
    return {
        Release => { $self->release_id => [ 'ArtistCredit' ] },
        MediumCDTOC => [ $self->entity_id => [ 'CDTOC' ] ]
    }
}

method build_display_data ($loaded)
{
    return {
        release => $loaded->{Release}{ $self->release_id },
        medium_cdtoc => $loaded->{MediumCDTOC}{ $self->entity_id },
    }
}

override 'insert' => sub {
    my ($self) = @_;
    my $cdtoc_id = $self->c->model('CDTOC')->find_or_insert($self->data->{cdtoc});
    my $medium_cdtoc = $self->c->model('MediumCDTOC')->insert({
        medium => $self->data->{medium_id},
        cdtoc => $cdtoc_id
    });
    $self->entity_id($medium_cdtoc);
};

no Moose;
__PACKAGE__->meta->make_immutable;
