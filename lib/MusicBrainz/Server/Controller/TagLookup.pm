package MusicBrainz::Server::Controller::TagLookup;
use Moose;
BEGIN { extends 'MusicBrainz::Server::Controller' }

use MusicBrainz::Server::Form::TagLookup;
use MusicBrainz::Server::Data::Search qw( alias_query escape_query );

use constant LOOKUPS_PER_NAG => 5;

sub _parse_filename
{
   my ($filename) = @_;
   my (@parts);

   my $data = {};

   return $data unless $filename;

   if ($filename =~ s/^(\d+)\.//)
   {
       $data->{tracknum} = $1;
   }

   for(;;)
   {
       if ($filename =~ s/^([^-]*)-//)
       {
            $_ = $1;
            s/^\s*(.*?)\s*$/$1/;

            push @parts, $_ if (defined $_ and $_ ne '');
        }
        else
        {
            $_ = $filename;
            s/^(.*?)\..*$/$1/;
            s/^\s*(.*?)\s*$/$1/;
            push @parts, $_;
            last;
        }
   }
   if (scalar(@parts) == 4)
   {
        $data->{artist} ||= $parts[0];
        $data->{album} ||= $parts[1];
        if ($parts[2] =~ /^\d+$/)
        {
            $data->{tracknum} ||= $parts[2];
        }
        $data->{track} ||= $parts[3];
   }
   elsif (scalar(@parts) == 3)
   {
        $data->{artist} ||= $parts[0];
        if ($parts[1] =~ /^\d+$/)
        {
            $data->{tracknum} ||= $parts[1];
        }
        else
        {
            $data->{album} ||= $parts[1];
        }
        $data->{track} ||= $parts[2];
   }
   elsif (scalar(@parts) == 2)
   {
        $data->{artist} ||= $parts[0];
        $data->{track} ||= $parts[1];
   }
   elsif (scalar(@parts) == 1)
   {
        $data->{track} ||= $parts[0];
   }

   return $data;
}

# returns 1 if the user should get a "please donate" screen, 0 otherwise.
sub nag_check
{
    my ($self, $c) = @_;

    # Always nag users who are not logged in
    return 1 unless $c->user_exists;

    # Editors with special privileges should not get nagged.
    my $editor = $c->user;
    return 0 if ($editor->is_nag_free ||
                 $editor->is_auto_editor ||
                 $editor->is_bot ||
                 $editor->is_relationship_editor ||
                 $editor->is_wiki_transcluder);

    # Otherwise, do the normal nagging per LOOKUPS_PER_NAG check
    my $session = $c->session;
    $session->{nag} = 0 unless defined $session->{nag};

    return 0 if ($session->{nag} == -1);

    if (!defined $session->{nag_check_timeout} || $session->{nag_check_timeout} <= time())
    {
        my $result = $c->model('Editor')->donation_check ($c->user);
        my $nag = $result ? $result->{nag} : 0; # don't nag if metabrainz is unreachable.

        $session->{nag} = -1 unless $nag;
        $session->{nag_check_timeout} = time() + (24 * 60 * 60); # check again tomorrow.
    }

    $session->{nag}++;

    return 0 if ($session->{nag} < LOOKUPS_PER_NAG);

    $session->{nag} = 0;
    return 1; # nag this user.
}


sub puid : Private
{
    my ($self, $c, $form) = @_;

    my $puid = $form->field('puid')->value();
    my @releases = $c->model('Release')->find_by_puid($puid);

    $c->model('ArtistCredit')->load(@releases);
    $c->model('Medium')->load_for_releases(@releases);
    $c->model('Script')->load(@releases);
    $c->model('Language')->load(@releases);

    my @results = map { { entity => $_ } } @releases;

    $c->stash(
        # A PUID search displays releases as results
        type    => 'release',
        results => \@results
    );
}

sub external : Private
{
    my ($self, $c, $form) = @_;

    my @terms;
    my $parsed = _parse_filename($form->field('filename')->value());
    my $term_to_field = {
        artist => 'artist',
        recording => 'track',
        release => 'release',
        dur => 'duration',
        tnum => 'tracknum'
    };

    # Collect all the terms we have
    my %terms;
    while (my ($term, $field) = each %$term_to_field)
    {
        if ($form->field($field)->value())
        {
            $terms{$term} = $form->field($field)->value();
        }
        elsif ($parsed->{$field})
        {
            $terms{$term} = $parsed->{$field};
        }
    }

    my @search_modifiers;
    for my $term (keys %terms) {
        if ($term eq 'artist') {
            push @search_modifiers, alias_query('artist', $terms{$term});
        }
        else {
            push @search_modifiers, "$term:" . q{"} . escape_query($terms{$term}) . q{"};
        }
    }

    # Try and find the most exact search
    my $type;
    if ($terms{recording} || $terms{tnum} || $terms{dur}) {
        $type = 'recording'
    }
    elsif ($terms{release}) {
        $type = 'release'
    }
    elsif ($terms{artist}) {
        $type = 'artist'
    }
    else {
        $c->detach('not_found');
    }

    $c->stash( type => $type );
    $c->controller('Search')->do_external_search($c,
                                                 query    => join(' ', @search_modifiers),
                                                 type     => $type,
                                                 advanced => 1);
}

sub not_found : Private
{
    my ($self, $c) = @_;
    $c->stash( template => 'taglookup/not_found.tt' );
    $c->detach;
}

sub index : Path('')
{
    my ($self, $c) = @_;

    my $form = $c->form( tag_lookup => 'TagLookup', name => 'tag-lookup' );
    $c->stash( nag => $self->nag_check($c) );

    my $mapped_params = {
        map {
            ("tag-lookup.$_" => $c->req->query_params->{"tag-lookup.$_"} //
                                $c->req->query_params->{$_})
        } qw( artist release tracknum track duration filename puid )
    };

    # All the fields are optional, but we shouldn't do anything unless at
    # least one of them has a value
    return unless grep { $_ } values %$mapped_params;
    return unless $form->submitted_and_valid( $mapped_params );

    if ($form->field('puid')->value()) {
        $self->puid($c, $form);
    }
    else {
        $self->external($c, $form);
    }

    $c->stash( template => 'taglookup/results.tt' );
}

1;

=head1 LICENSE

Copyright (C) 2010 MetaBrainz Foundation

This software is provided "as is", without warranty of any kind, express or
implied, including  but not limited  to the warranties of  merchantability,
fitness for a particular purpose and noninfringement. In no event shall the
authors or  copyright  holders be  liable for any claim,  damages or  other
liability, whether  in an  action of  contract, tort  or otherwise, arising
from,  out of  or in  connection with  the software or  the  use  or  other
dealings in the software.

GPL - The GNU General Public License    http://www.gnu.org/licenses/gpl.txt
Permits anyone the right to use and modify the software without limitations
as long as proper  credits are given  and the original  and modified source
code are included. Requires  that the final product, software derivate from
the original  source or any  software  utilizing a GPL  component, such  as
this, is also licensed under the GPL license.

=cut
