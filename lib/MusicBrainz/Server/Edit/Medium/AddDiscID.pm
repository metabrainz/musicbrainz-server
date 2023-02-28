package MusicBrainz::Server::Edit::Medium::AddDiscID;
use Moose;
use Method::Signatures::Simple;
use MooseX::Types::Structured qw( Dict Optional );
use MooseX::Types::Moose qw( Int Str );
use MusicBrainz::Server::Constants qw( $EDIT_MEDIUM_ADD_DISCID );
use MusicBrainz::Server::Edit::Types qw( NullableOnPreview );
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );
use MusicBrainz::Server::Translation qw( N_l );

sub edit_name { N_l('Add disc ID') }
sub edit_kind { 'add' }
sub edit_type { $EDIT_MEDIUM_ADD_DISCID }
sub edit_template { 'AddDiscId' }

sub medium_id { shift->data->{medium_id} }

use aliased 'MusicBrainz::Server::Entity::CDTOC';
use aliased 'MusicBrainz::Server::Entity::Medium';
use aliased 'MusicBrainz::Server::Entity::MediumCDTOC';
use aliased 'MusicBrainz::Server::Entity::Release';

extends 'MusicBrainz::Server::Edit';
with 'MusicBrainz::Server::Edit::Role::Insert';
with 'MusicBrainz::Server::Edit::Medium';
with 'MusicBrainz::Server::Edit::Medium::RelatedEntities';
with 'MusicBrainz::Server::Edit::Role::Preview';
with 'MusicBrainz::Server::Edit::Role::AlwaysAutoEdit';

has '+data' => (
    isa => Dict[
        cdtoc           => Str,
        medium_id       => NullableOnPreview[Int],
        medium_position => Optional[Int],
        release         => NullableOnPreview[Dict[
            id => NullableOnPreview[Int],
            name => Str
        ]],
    ]
);

method release_id { $self->data->{release}{id} }

method alter_edit_pending
{
    return {
        MediumCDTOC => [ $self->entity_id ],
    }
}

sub initialize {
    my ($self, %opts) = @_;

    my $release_name = delete $opts{release_name} // '';
    # For linkedEntities to work with edit previews
    my $fake_release_id = 1000000000000;

    if ($self->preview) {
       $opts{release} = { id => $fake_release_id, name => $release_name };
    } else {
        my $release = $opts{release} or die 'Missing "release" argument';
        $opts{release} = {
            id => $release->id,
            name => $release->name
        };
    }

    $self->data(\%opts);
};

sub _edit_hash {
    my ($self, $data) = @_;

    delete $data->{medium_position};
    return $data;
}

method foreign_keys {
    my $data = {};

    # May be undefined when previewing.
    if ($self->data->{medium_id}) {
        $data->{Medium} = { $self->data->{medium_id} => ['Release ArtistCredit', 'MediumFormat'] };
    }

    if ($self->release_id) {
        $data->{Release} = { $self->release_id => ['ArtistCredit'] };
    }

    if ($self->entity_id) {
        $data->{MediumCDTOC} = { $self->entity_id => ['CDTOC'] };
    }

    return $data;
}

method build_display_data ($loaded)
{
    my $pos = $self->data->{medium_position};

    return {
        medium => to_json_object(
            $loaded->{Medium}{ $self->data->{medium_id} // -1 } //
                  Medium->new( release_id => $self->release_id,
                               release => $loaded->{Release}{ $self->release_id } //
                                           Release->new(
                                               id   => $self->release_id,
                                               name => $self->data->{release}{name},
                                            ),
                               $pos ? ( position => $pos ) : (),
                  ),
        ),
        medium_cdtoc => to_json_object(
            ($self->entity_id && $loaded->{MediumCDTOC}{ $self->entity_id }) ||
            MediumCDTOC->new(
                cdtoc => CDTOC->new_from_toc($self->data->{cdtoc})
            )
        ),
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

override 'reject' => sub {
    my ($self) = @_;
    my $cdtoc_id = $self->c->model('CDTOC')->find_or_insert($self->data->{cdtoc});
    my $medium_cdtoc = $self->c->model('MediumCDTOC')->get_by_medium_cdtoc(
        $self->data->{medium_id},
        $cdtoc_id
    );
    $self->c->model('MediumCDTOC')->delete($medium_cdtoc->id);
};

no Moose;
__PACKAGE__->meta->make_immutable;
