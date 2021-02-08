package MusicBrainz::Server::Edit::Release::AddReleaseLabel;
use Carp;
use Moose;
use MooseX::Types::Moose qw( Int Str );
use MooseX::Types::Structured qw( Dict Optional );
use MusicBrainz::Server::Constants qw( $EDIT_RELEASE_ADDRELEASELABEL );
use MusicBrainz::Server::Edit::Types qw( Nullable NullableOnPreview );
use MusicBrainz::Server::Edit::Utils qw( gid_or_id );
use MusicBrainz::Server::Translation qw( N_l );

extends 'MusicBrainz::Server::Edit';
with 'MusicBrainz::Server::Edit::Role::Preview';
with 'MusicBrainz::Server::Edit::Release::RelatedEntities';
with 'MusicBrainz::Server::Edit::Release';
with 'MusicBrainz::Server::Edit::Role::Insert';
with 'MusicBrainz::Server::Edit::Role::AlwaysAutoEdit';

sub edit_name { N_l('Add release label') }
sub edit_kind { 'add' }
sub edit_type { $EDIT_RELEASE_ADDRELEASELABEL }
sub alter_edit_pending { { Release => [ shift->release_id ] } }
sub edit_template_react { 'AddReleaseLabel' }

use aliased 'MusicBrainz::Server::Entity::Label';
use aliased 'MusicBrainz::Server::Entity::Release';

around _build_related_entities => sub {
    my ($orig, $self, @args) = @_;
    my %related = %{ $self->$orig(@args) };
    $related{label} = [ $self->data->{label}{id} ]
        if $self->data->{label};

    return \%related;
};

has '+data' => (
    isa => Dict[
        release => NullableOnPreview[Dict[
            id => Int,
            gid => Optional[Str],
            name => Str
        ]],
        label => Nullable[Dict[
            id => Int,
            gid => Optional[Str],
            name => Str
        ]],
        catalog_number => Nullable[Str]
    ]
);

sub release_id { shift->data->{release}{id} }

sub initialize {
    my ($self, %opts) = @_;

    my $release = delete $opts{release};
    die 'Missing "release" argument' unless ($release || $self->preview);

    if ($release) {
        $self->c->model('ReleaseLabel')->load($release) unless $release->all_labels;

        $self->throw_if_release_label_is_duplicate(
            $release,
            $opts{label} ? $opts{label}->id : undef,
            $opts{catalog_number}
        );
    }

    $opts{release} = {
        id => $release->id,
        gid => $release->gid,
        name => $release->name
    } if $release;

    $opts{label} = {
        id => $opts{label}->id,
        gid => $opts{label}->gid,
        name => $opts{label}->name
    } if $opts{label};

    $self->data(\%opts);
};

sub foreign_keys {
    my $self = shift;

    my %fk;
    my $data = $self->data;

    $fk{Release} = { gid_or_id($data->{release}) => ['ArtistCredit'] } if $data->{release};
    $fk{Label} = [gid_or_id($data->{label})] if $data->{label};

    return \%fk;
};

sub build_display_data {
    my ($self, $loaded) = @_;

    my $data = $self->data;
    my $display_data = {
        catalog_number => $self->data->{catalog_number},
    };

    unless ($self->preview) {
        $display_data->{release} = $loaded->{Release}->{gid_or_id($data->{release})} //
            Release->new(name => $data->{release}{name});
    }

    if ($data->{label}) {
        $display_data->{label} = $loaded->{Label}->{gid_or_id($data->{label})} //
            Label->new(name => $data->{label}{name});
    }

    return $display_data;
}

sub insert
{
    my $self = shift;
    my %args = (
        release_id => $self->release_id,
    );

    $args{catalog_number} = $self->data->{catalog_number}
        if exists $self->data->{catalog_number};

    $args{label_id} = $self->data->{label}{id}
        if $self->data->{label};

    my $rl = $self->c->model('ReleaseLabel')->insert(\%args);
    $self->entity_id($rl->id);
}

sub reject
{
    my $self = shift;
    $self->c->model('ReleaseLabel')->delete($self->entity_id);
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
