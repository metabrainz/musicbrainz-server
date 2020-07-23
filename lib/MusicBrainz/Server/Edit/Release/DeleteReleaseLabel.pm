package MusicBrainz::Server::Edit::Release::DeleteReleaseLabel;
use Moose;

use MooseX::Types::Moose qw( Int Str );
use MooseX::Types::Structured qw( Dict Optional );
use MusicBrainz::Server::Constants qw( $EDIT_RELEASE_DELETERELEASELABEL );
use MusicBrainz::Server::Translation qw( N_l );
use MusicBrainz::Server::Edit::Types qw( Nullable );
use MusicBrainz::Server::Edit::Utils qw( gid_or_id );

use aliased 'MusicBrainz::Server::Entity::Release';
use aliased 'MusicBrainz::Server::Entity::Label';

extends 'MusicBrainz::Server::Edit';
with 'MusicBrainz::Server::Edit::Role::Preview';
with 'MusicBrainz::Server::Edit::Release::RelatedEntities';
with 'MusicBrainz::Server::Edit::Release';
with 'MusicBrainz::Server::Edit::Role::AlwaysAutoEdit';

sub edit_name { N_l('Remove release label') }
sub edit_kind { 'remove' }
sub edit_type { $EDIT_RELEASE_DELETERELEASELABEL }
sub edit_template_react { 'RemoveReleaseLabel' }

sub release_id { shift->data->{release}{id} }
sub release_label_id { shift->data->{release_label_id} }

sub alter_edit_pending { { Release => [ shift->release_id ] } }
sub models { [qw( Release ReleaseLabel )] }

has '+data' => (
    isa => Dict[
        release_label_id => Int,
        release => Dict[
            id => Int,
            gid => Optional[Str],
            name => Str
        ],
        label => Nullable[Dict[
            id => Int,
            gid => Optional[Str],
            name => Str
        ]],
        catalog_number => Nullable[Str]
    ]
);

around '_build_related_entities' => sub {
    my $orig = shift;
    my $self = shift;
    my $related = $self->$orig;

    $related->{label} = [gid_or_id($self->data->{label})] if $self->data->{label};

    return $related;
};

sub foreign_keys {
    my $self = shift;

    my $data = $self->data;
    my $label = $data->{label};

    my $fks = {
        Release => { gid_or_id($self->data->{release}) => ['ArtistCredit'] },
    };

    if ($label) {
        $fks->{Label} = { gid_or_id($data->{label}) => [] };
    }

    return $fks;
}

sub build_display_data {
    my ($self, $loaded) = @_;

    my $data = $self->data;
    my $label = $data->{label};

    my $display_data = {
        catalog_number => $data->{catalog_number},
        release => ($loaded->{Release}->{gid_or_id($data->{release})} //
                    Release->new(name => $data->{release}{name})),
    };

    if ($label) {
        $display_data->{label} = $loaded->{Label}{gid_or_id($label)} //
                                 Label->new(name => $label->{name});
    }

    return $display_data;
}

sub initialize
{
    my ($self, %opts) = @_;
    my $release_label = delete $opts{release_label};
    die "You must specify the release label object to delete"
        unless defined $release_label;

    unless ($release_label->release) {
        $self->c->model('Release')->load($release_label);
    }

    unless ($release_label->label) {
        $self->c->model('Label')->load($release_label);
    }

    $self->data({
        release_label_id => $release_label->id,
        catalog_number => $release_label->catalog_number,
        label => $release_label->label ? {
            id => $release_label->label->id,
            gid => $release_label->label->gid,
            name => $release_label->label->name
        } : undef,
        release => {
            id => $release_label->release->id,
            gid => $release_label->release->gid,
            name => $release_label->release->name
        }
    });
};

sub accept
{
    my $self = shift;
    $self->c->model('ReleaseLabel')->delete($self->release_label_id);
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2010 MetaBrainz Foundation

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

=cut
