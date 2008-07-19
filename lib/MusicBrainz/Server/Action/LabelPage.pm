package MusicBrainz::Server::Action::LabelPage;

use strict;
use warnings;
use base 'Catalyst::Action';

use Carp;
use ModDefs;
use MusicBrainz::Server::Adapter qw(LoadEntity);
use MusicBrainz::Server::Artist;
use MusicBrainz;

=head1 NAME

MusicBrainz::Server::Action::LabelPage - Custom Action for creating
label pages.

=head1 DESCRIPTION

This fills the Catalyst stash with variables to display the label header
on a page.

=head1 METHODS

=head2 execute

Executes the ArtistPage Action after the action has completed. This will
load the label with a given MBID/row id into the stash in the {_label} key.

=cut

sub execute
{
    my $self = shift;
    my ($controller, $c) = @_;

    my $mbid = $c->request->arguments->[0];
    if (defined $mbid)
    {
        my $mb = $c->mb;

        my $label = MusicBrainz::Server::Label->new($mb->{DBH});
        LoadEntity($label, $mbid);

        croak "The special label 'DELETED_LABEL' cannot be shown"
            if $label->GetId == ModDefs::DLABEL_ID;

        $c->stash->{_label} = $label;
        $c->stash->{label}  = $label->ExportStash;
    }
    else
    {
        croak "No MBID/row ID given.";
    }

    $self->NEXT::execute(@_);
}

1;
