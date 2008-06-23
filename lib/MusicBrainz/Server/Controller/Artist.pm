package MusicBrainz::Server::Controller::Artist;

use strict;
use warnings;
use parent 'Catalyst::Controller';

=head1 NAME

MusicBrainz::Server::Controller::Artist - Catalyst Controller for working with Artist entities

=head1 DESCRIPTION

=head1 METHODS

=cut


=head2 show

Shows an artist's main landing page, showing all of the releases that are attributed to them

=cut

sub show : Path Args(1) {
    my ($self, $c, $mbid) = @_;

    require MusicBrainz;
    require MusicBrainz::Server::Validation;
    require MusicBrainz::Server::Artist;

    if($mbid ne "")
    {
	MusicBrainz::Server::Validation::IsGUID($mbid) or $c->error("Not a valid GUID");
    }

    my $mb = new MusicBrainz;
    $mb->Login();

    my $artist = MusicBrainz::Server::Artist->new($mb->{DBH});
    $artist->SetMBId($mbid);
    $artist->LoadFromId(1) or $c->error("Failed to load artist");

    $c->stash->{artist} = {
	name => $artist->GetName,
	type => MusicBrainz::Server::Artist::GetTypeName($artist->GetType) || '',
	datespan => {
	    start => $artist->GetBeginDate,
	    end => $artist->GetEndDate
	},
	quality => '',
    };

    $c->stash->{template} = 'artist/show.tt';
}


=head1 AUTHOR

Oliver Charles <oliver.g.charles@googlemail.com>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
