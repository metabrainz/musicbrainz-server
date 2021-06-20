package MusicBrainz::Server::WebService::Serializer::JSON::LD::Artist;
use Moose;
use MusicBrainz::Server::WebService::Serializer::JSON::LD::Utils qw( serialize_entity list_or_single );
use aliased 'MusicBrainz::Server::Entity::PartialDate';

use MusicBrainz::Server::Constants qw(
    $ARTIST_TYPE_PERSON
    $INSTRUMENT_ROOT_ID
    $VOCAL_ROOT_ID
);
use MusicBrainz::Server::Data::Utils qw( non_empty );
use List::MoreUtils qw( uniq );

extends 'MusicBrainz::Server::WebService::Serializer::JSON::LD';
with 'MusicBrainz::Server::WebService::Serializer::JSON::LD::Role::Genre';
with 'MusicBrainz::Server::WebService::Serializer::JSON::LD::Role::GID';
with 'MusicBrainz::Server::WebService::Serializer::JSON::LD::Role::Name';
with 'MusicBrainz::Server::WebService::Serializer::JSON::LD::Role::LifeSpan' =>
    { begin_properties => sub { is_person(shift) ? qw( birthDate ) : qw( foundingDate ) },
      end_properties   => sub { is_person(shift) ? qw( deathDate ) : qw( dissolutionDate ) } };
with 'MusicBrainz::Server::WebService::Serializer::JSON::LD::Role::Aliases';
with 'MusicBrainz::Server::WebService::Serializer::JSON::LD::Role::Area' => { include_birth_death => sub { my $artist = shift; return $artist->type && $artist->type->name eq 'Person' } };

sub is_person {
    my $artist = shift;
    return ($artist->type_id && $artist->type_id == $ARTIST_TYPE_PERSON) ? 1 : 0;
}

around serialize => sub {
    my ($orig, $self, $entity, $inc, $stash, $toplevel) = @_;
    my $ret = $self->$orig($entity, $inc, $stash, $toplevel);

    my $is_person = is_person($entity);
    $ret->{'@type'} = $is_person ? ['Person', 'MusicGroup'] : 'MusicGroup';

    if ($toplevel) {
        if (!$is_person && $entity->begin_area) {
            $ret->{groupOrigin} = serialize_entity($entity->begin_area, $inc, $stash);
        }

        my $member_rels = $entity->relationships_by_link_type_names('member of band');
        my @members;
        my @member_ofs;

        for my $member_rel (@{ $member_rels }) {
            if ($member_rel->direction == 1) {
                push(@member_ofs, $member_rel);
            } elsif ($member_rel->direction == 2) {
                push(@members, $member_rel);
            }
        }

        if (@members) {
            my %seen_members;
            for my $member (@members) {
                # We separate different dates, but keep together
                # different roles with the same dates
                my $key = $member->target->gid;
                my $begin_date = $member->link->begin_date;
                my $end_date = $member->link->end_date;
                if ($begin_date && $begin_date->defined_run) {
                    $key .= '-begin-' . join('-', $begin_date->defined_run);
                }
                if ($end_date && $end_date->defined_run) {
                    $key .= '-end-' . join('-', $end_date->defined_run);
                }
                $seen_members{$key} = member_relationship($member, 'member', $inc, $stash, $seen_members{$key});
            }
            $ret->{member} = [ map { $seen_members{$_} } sort keys %seen_members ];
        }

        if (@member_ofs) {
            my %seen_members_of;
            for my $member_of (@member_ofs) {
                $seen_members_of{$member_of->target->gid} = member_relationship($member_of, 'memberOf', $inc, $stash, $seen_members_of{$member_of->target->gid});
            }
            $ret->{memberOf} = [ map { $seen_members_of{$_} } sort keys %seen_members_of ];
        }

        if ($stash->store($entity)->{release_groups}) {
            my $items = $stash->store($entity)->{release_groups}{items};
            my @rgs = map { serialize_entity($_, $inc, $stash) } @$items;
            $ret->{album} = list_or_single(@rgs) if @rgs;
        }

        if ($stash->store($entity)->{recordings}) {
            my $items = $stash->store($entity)->{recordings}{items};
            my @recordings = map { serialize_entity($_, $inc, $stash) } @$items;
            $ret->{track} = list_or_single(@recordings) if @recordings;
        }

        my @identities = @{ $stash->store($entity)->{identities} // [] };
        if (@identities) {
            $ret->{alternateName} = [uniq @{ $ret->{alternateName} // [] }, map { $_->name } @identities];
        }

        my @other_identities = @{ $stash->store($entity)->{other_identities} // [] };
        if (@other_identities) {
            $ret->{performsAs} = list_or_single(map { serialize_entity($_, $inc, $stash) } @other_identities);
        }
    }

    return $ret;
};

sub member_relationship {
    my ($relationship, $type, $inc, $stash, $ret) = @_;
    my $is_new = 0;
    if (!$ret) {
        $ret = {
            '@type' => 'OrganizationRole',
            $type => serialize_entity($relationship->target, $inc, $stash)
        };
        $is_new = 1;
    }

    if ($is_new && $relationship->link->begin_date && $relationship->link->begin_date->defined_run) {
        my @run = $relationship->link->begin_date->defined_run;
        my $date = PartialDate->new(year => $run[0], month => $run[1], day => $run[2]);
        $ret->{startDate} = $date->format;
    }
    if ($is_new && $relationship->link->end_date && $relationship->link->end_date->defined_run) {
        my @run = $relationship->link->end_date->defined_run;
        my $date = PartialDate->new(year => $run[0], month => $run[1], day => $run[2]);
        $ret->{endDate} = $date->format;
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
    $ret->{roleName} = list_or_single(uniq(@roles));
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

