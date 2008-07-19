package MusicBrainz::Server::Controller::Label;

use strict;
use warnings;

use base 'Catalyst::Controller';

use MusicBrainz::Server::Adapter;
use MusicBrainz::Server::Adapter::Relations qw(LoadRelations);
use MusicBrainz::Server::Label;

=head1 NAME

MusicBrainz::Server::Controller::Label

=head1 DESCRIPTION

Handles user interaction with label entities

=head1 METHODS

=head2 relations

Show all relations to this label

=cut

sub relations : Local Args(1) MyAction('LabelPage')
{
    my ($self, $c, $mbid) = @_;

    my $label = $c->stash->{_label};
  
    $c->stash->{relations} = load_relations($label);
    $c->stash->{label}     = $label->ExportStash;

    $c->stash->{template}  = 'label/relations.tt';
}

=head2 show

Show this label to a user, including a summary of ARs, and the releases
that have been released through this label

=cut

sub show : Path Args(1) MyAction('LabelPage')
{
    my ($self, $c, $mbid) = @_;

    my $label = $c->stash->{_label};

    # Load releases
    my @releases = $label->GetReleases;

    for my $release (@releases)
    {
        # Munge name for sorting
		use Encode qw( decode );

		$release->{_name_sort_} = lc decode "utf-8", $release->GetName;
		$release->{_disc_max_}  = 0;
		$release->{_disc_no_}   = 0;

		# Attempt to sort "disc x [of y]" correctly
		if ($release->{_name_sort_} =~
			/^(.*)								# $1 <main title>
				(?:[(]disc\ (\d+)				# $2 (disc x
					(?:\ of\ (\d+))?			# $3 [of y]
					(?::[^()]*					#    [: <disc title>
						(?:[(][^()]*[)][^()]*)* #     [<1 level of nested par.>]
					)?                          #    ]
					[)]							#    )
				)
				(.*)$							# $4 [<rest of main title>]
			/xi)
		{
			$release->{_name_sort_} = "$1 $4";
			$release->{_disc_no_}   = $2;
			$release->{_disc_max_}  = $3 || 0;
		}

		# Sort albums with no release last
		$release->{_releasedate_} = ($release->{releasedate} || "9999-99-99");
    }

    use Switch;
    switch($c->req->params->{order})
    {
        case('title')   { @releases = sort sort_title @releases; }
        case('catno')   { @releases = sort sort_catalog @releases; }
        case('artist')  { @releases = sort sort_artist @releases; }
        case('date')    { @releases = sort sort_date @releases; }

        else            { @releases = sort sort_date @releases; }
    }

    # Export releases to stash
    $c->stash->{releases}  = [ map { export_release($_) } @releases ];
    $c->stash->{relations} = load_relations($label);

    $c->stash->{template} = 'label/show.tt';
}

=head2 details

Display detailed information about a given label

=cut

sub details : Local Args(1) MyAction('LabelPage')
{
    my ($self, $c, $mbid) = @_;

    my $label = $c->stash->{_label};

    $c->stash->{label}->{subscribers} = scalar $label->GetSubscribers;

    $c->stash->{template} = 'label/details.tt';
}

=head2 INTERNAL METHODS

=head2 load_relations

Load relations of this label for store in the stash.

=cut

sub load_relations
{
    return LoadRelations(shift, 'label');
}


# All of these sort routines use the same predicates *except* the first -
# and should probably be refactored.

=head2 sort_catalog

Sort by catalog number

=cut

sub sort_catalog
{
    my @predicates = (
        ($a->{catno}         cmp $b->{catno}),
		($a->{_releasedate_} cmp $b->{_releasedate_}),
        ($a->{_name_sort_}   cmp $b->{_name_sort_}),
        ($a->{_disc_max_}    <=> $b->{_disc_max_}),
        ($a->{_disc_no_}     <=> $b->{_disc_no_}),
        ($a->{_attr_status}  <=> $b->{_attr_status}),
        ($a->{trackcount}    cmp $b->{trackcount}),
        ($b->{trmidcount}    cmp $a->{trmidcount}),
        ($b->{puidcount}     cmp $a->{puidcount}),
        ($a->GetId           cmp $b->GetId),
    );

    for (@predicates) { return $_ if $_; }

    return 0;
}

=head2 sort_title

Sort releases by release title

=cut

sub sort_title
{
    my @predicates = (
        ($a->{_name_sort_}   cmp $b->{_name_sort_}),
        ($a->{_releasedate_} cmp $b->{_releasedate_}),
        ($a->{catno}         cmp $b->{catno}),
        ($a->{_disc_max_}    <=> $b->{_disc_max_}),
        ($a->{_disc_no_}     <=> $b->{_disc_no_}),
        ($a->{_attr_status}  <=> $b->{_attr_status}),
        ($a->{trackcount}    cmp $b->{trackcount}),
        ($b->{trmidcount}    cmp $a->{trmidcount}),
        ($b->{puidcount}     cmp $a->{puidcount}),
        ($a->GetId           cmp $b->GetId),
    );

    for (@predicates) { return $_ if $_; }

    return 0;
}

=head2 sort_date

Sort by the date of the release on this label

=cut

sub sort_date
{
	my @predicates = (
        ($a->{_releasedate_} cmp $b->{_releasedate_}),
		($a->{catno}         cmp $b->{catno}),
		($a->{_name_sort_}   cmp $b->{_name_sort_}),
		($a->{_disc_max_}    <=> $b->{_disc_max_}),
		($a->{_disc_no_}     <=> $b->{_disc_no_}),
		($a->{_attr_status}  <=> $b->{_attr_status}),
		($a->{trackcount}    cmp $b->{trackcount}),
		($b->{trmidcount}    cmp $a->{trmidcount}),
		($b->{puidcount}     cmp $a->{puidcount}),
		($a->GetId           cmp $b->GetId),
    );

    for (@predicates) { return $_ if $_; }

    return 0;
}

=head2 sort_artist

Sort releases by artist name
 
=cut

sub sort_artist
{
    # TODO We have data about sortname, is it possible to use this?

    my @predicates = (
        ($a->{artistname}    cmp $b->{artistname}),
		($a->{_name_sort_}   cmp $b->{_name_sort_}),
        ($a->{_releasedate_} cmp $b->{_releasedate_}),
        ($a->{catno}         cmp $b->{catno}),
        ($a->{_disc_max_}    <=> $b->{_disc_max_}),
        ($a->{_disc_no_}     <=> $b->{_disc_no_}),
        ($a->{_attr_status}  <=> $b->{_attr_status}),
        ($a->{trackcount}    cmp $b->{trackcount}),
        ($b->{trmidcount}    cmp $a->{trmidcount}),
        ($b->{puidcount}     cmp $a->{puidcount}),
        ($a->GetId           cmp $b->GetId),
    );
    
    for (@predicates) { return $_ if $_; }

    return 0;
}

=head2 export_release

Export data from a release to store in stash.

We can't just use $release->ExportStash as this doesn't give us the
artist name/mbid.

=cut

sub export_release
{
    my $release = shift;

    my $stash = $release->ExportStash qw/language type first_date/;

    $stash->{artist} = {
        name      => $release->{artistname},
        mbid      => $release->GetArtist,
        link_type => 'artist'
    };

    $stash->{catalog_number} = $release->{catno};

    return $stash;
}

1;
