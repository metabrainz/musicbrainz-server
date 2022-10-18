package MusicBrainz::Server::Controller::TagLookup;
use Moose;
use namespace::autoclean;
BEGIN { extends 'MusicBrainz::Server::Controller' }

use List::AllUtils qw( any );
use MusicBrainz::Server::Form::TagLookup;
use MusicBrainz::Server::ControllerUtils::JSON qw( serialize_pager );
use MusicBrainz::Server::Data::Search qw( escape_query );
use MusicBrainz::Server::Data::Utils qw( type_to_model );
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_array );

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

   for (;;)
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

    # Never nag users in non-core MB servers
    return 0 unless DBDefs->WEB_SERVER =~ /^(?:beta\.)?musicbrainz\.org$/;

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
        my $result = $c->model('Editor')->donation_check($c->user);
        my $nag = $result ? $result->{nag} : 0; # don't nag if metabrainz is unreachable.

        $session->{nag} = -1 unless $nag;
        $session->{nag_check_timeout} = time() + (24 * 60 * 60); # check again tomorrow.
    }

    $session->{nag}++;

    return 0 if ($session->{nag} < LOOKUPS_PER_NAG);

    $session->{nag} = 0;
    return 1; # nag this user.
}

sub external : Private
{
    my ($self, $c, $form) = @_;

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
        my $value = escape_query($terms{$term});
        push @search_modifiers, "$term:" . q{"} . $value . q{"};
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
    $c->stash(
        current_view => 'Node',
        component_path => 'taglookup/NotFound',
    );
    $c->detach;
}

sub index : Path('')
{
    my ($self, $c) = @_;

    my $form = $c->form( tag_lookup => 'TagLookup', name => 'tag-lookup' );
    $c->stash->{form} = $form;

    my $nag = $self->nag_check($c);

    my $mapped_params = {
        map {
            ("tag-lookup.$_" => $c->req->query_params->{"tag-lookup.$_"} //
                                $c->req->query_params->{$_})
        } qw( artist release tracknum track duration filename )
    };

    $c->stash(
        current_view => 'Node',
        component_path => 'taglookup/Index',
        component_props => {
            form => $form->TO_JSON,
            nag => $nag,
        },
    );

    # All the fields are optional, but we shouldn't do anything unless at
    # least one of them has a value
    return unless any { $_ } values %$mapped_params;
    return unless $c->form_submitted_and_valid($form, $mapped_params);

    $self->external($c, $form);

    my $model = type_to_model($c->stash->{type});
    $c->stash(
        current_view => 'Node',
        component_path => "taglookup/${model}Results",
        component_props => {
            form => $form->TO_JSON,
            nag => $nag,
            pager => serialize_pager($c->stash->{pager}),
            query => $c->stash->{query},
            results => to_json_array($c->stash->{results}),
        },
    );
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
