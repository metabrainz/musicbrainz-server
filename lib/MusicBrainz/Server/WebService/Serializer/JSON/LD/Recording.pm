package MusicBrainz::Server::WebService::Serializer::JSON::LD::Recording;
use Moose;
use MusicBrainz::Server::WebService::Serializer::JSON::LD::Utils qw( list_or_single serialize_entity );
use MusicBrainz::Server::Constants qw( $INSTRUMENT_ROOT_ID $VOCAL_ROOT_ID );
use MusicBrainz::Server::Data::Utils qw( non_empty );
use List::AllUtils qw( uniq );

extends 'MusicBrainz::Server::WebService::Serializer::JSON::LD';
with 'MusicBrainz::Server::WebService::Serializer::JSON::LD::Role::Genre';
with 'MusicBrainz::Server::WebService::Serializer::JSON::LD::Role::GID';
with 'MusicBrainz::Server::WebService::Serializer::JSON::LD::Role::Name';
with 'MusicBrainz::Server::WebService::Serializer::JSON::LD::Role::Length';
with 'MusicBrainz::Server::WebService::Serializer::JSON::LD::Role::Producer';
with 'MusicBrainz::Server::WebService::Serializer::JSON::LD::Role::Aliases';

around serialize => sub {
    my ($orig, $self, $entity, $inc, $stash, $toplevel) = @_;
    my $ret = $self->$orig($entity, $inc, $stash, $toplevel);

    $ret->{'@type'} = 'MusicRecording';

    if ($stash->store($entity)->{trackNumber}) {
        $ret->{trackNumber} = $stash->store($entity)->{trackNumber};
    }

    if ($entity->all_isrcs) {
       $ret->{'isrcCode'} = list_or_single(map { $_->isrc } $entity->all_isrcs);
    }

    my @works = @{ $entity->relationships_by_link_type_names('performance') };
    if (@works) {
        $ret->{recordingOf} = list_or_single(map { serialize_entity($_->target, $inc, $stash) } @works);
    }

    # XXX: should this include conductors, chorus masters, etc.? What about engineers, remixers, photographers, etc.?
    my @contributors = grep { $_->direction == 2 } @{ $entity->relationships_by_link_type_names('performance', 'performer', 'vocal', 'instrument', 'performing orchestra', 'chorusmaster', 'conductor') };
    if (@contributors) {
        my %seen_contributors;
        for my $contributor (@contributors) {
            $seen_contributors{$contributor->target->gid} = contributor_relationship($contributor, $inc, $stash, $seen_contributors{$contributor->target->gid});
        }
        $ret->{contributor} = [ map { $seen_contributors{$_} } sort keys %seen_contributors ];
    }

    return $ret;
};

sub contributor_relationship {
    my ($relationship, $inc, $stash, $ret) = @_;
    my $is_new = 0;
    if (!$ret) {
        $ret = { '@type' => 'OrganizationRole',
                 contributor => serialize_entity($relationship->target, $inc, $stash) };
        $is_new = 1;
    }

    # XXX: role names are instruments (or, where available, credits), not
    # things like 'bassist' or 'keyboardist', since we don't have that
    # information.
    my @roles;
    if (ref $ret->{roleName} eq 'ARRAY') {
        @roles = @{ $ret->{roleName} };
    } else {
        push(@roles, $ret->{roleName}) if $ret->{roleName};
    }
    for my $attr ($relationship->link->all_attributes) {
        my $root = $attr->type->root ? $attr->type->root->id : $attr->type->root_id;
        if ($root == $INSTRUMENT_ROOT_ID || $root == $VOCAL_ROOT_ID) {
            if (non_empty($attr->credited_as)) {
                push(@roles, $attr->credited_as);
            } else {
                push(@roles, $attr->type->name);
            }
        }
    }
    if ($relationship->link->type->name eq 'performing orchestra') {
        push(@roles, 'orchestra');
    }
    if ($relationship->link->type->name eq 'chorusmaster') {
        push(@roles, 'chorusmaster');
    }
    if ($relationship->link->type->name eq 'conductor') {
        push(@roles, 'conductor');
    }
    $ret->{roleName} = list_or_single(uniq(@roles)) if @roles;
    return $ret;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut

