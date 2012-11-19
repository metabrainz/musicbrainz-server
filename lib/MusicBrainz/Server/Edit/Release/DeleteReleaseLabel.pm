package MusicBrainz::Server::Edit::Release::DeleteReleaseLabel;
use Moose;

use MooseX::Types::Moose qw( Int Str );
use MooseX::Types::Structured qw( Dict );
use MusicBrainz::Server::Constants qw( $EDIT_RELEASE_DELETERELEASELABEL );
use MusicBrainz::Server::Translation qw ( N_l );
use MusicBrainz::Server::Edit::Types qw( Nullable );

use aliased 'MusicBrainz::Server::Entity::Release';
use aliased 'MusicBrainz::Server::Entity::Label';

extends 'MusicBrainz::Server::Edit';
with 'MusicBrainz::Server::Edit::Role::Preview';
with 'MusicBrainz::Server::Edit::Release::RelatedEntities';
with 'MusicBrainz::Server::Edit::Release';

sub edit_name { N_l('Remove release label') }
sub edit_type { $EDIT_RELEASE_DELETERELEASELABEL }

sub release_id { shift->data->{release}{id} }
sub release_label_id { shift->data->{release_label_id} }

sub alter_edit_pending { { Release => [ shift->release_id ] } }
sub models { [qw( Release ReleaseLabel )] }

has '+data' => (
    isa => Dict[
        release_label_id => Int,
        release => Dict[
            id => Int,
            name => Str
        ],
        label => Nullable[Dict[
            id => Int,
            name => Str
        ]],
        catalog_number => Nullable[Str]
    ]
);

around '_build_related_entities' => sub {
    my $orig = shift;
    my $self = shift;
    my $related = $self->$orig;

    $related->{label} = [ $self->data->{label}{id} ] if $self->data->{label};

    return $related;
};

sub foreign_keys
{
    my $self = shift;

    my %fk = ( Release => { $self->release_id => [] } );

    if ($self->data->{label} && $self->data->{label}{id})
    {
        $fk{Label} = { $self->data->{label}{id} => [] };
    }

    return \%fk;
};

sub build_display_data
{
    my ($self, $loaded) = @_;
    my $label = $loaded->{Label}->{ $self->data->{label} };

    my $data = {
        release => $loaded->{Release}->{ $self->data->{release}{id} } ||
            Release->new( name => $self->data->{release}{name} ),
        catalog_number => $self->data->{catalog_number},
    };

    if (my $lbl = $self->data->{label}) {
        if ($lbl->{id} && $lbl->{name})
        {
            $data->{label} = $loaded->{Label}{ $lbl->{id} } ||
                Label->new( name => $lbl->{name}, id => $lbl->{id} );;
        }
        elsif ($lbl->{name})
        {
            $data->{label} = Label->new( name => $lbl->{name} );
        }
    }

    return $data;
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
            name => $release_label->label->name
        } : undef,
        release => {
            id => $release_label->release->id,
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
