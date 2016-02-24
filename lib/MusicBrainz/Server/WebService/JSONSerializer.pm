package MusicBrainz::Server::WebService::JSONSerializer;

use Class::Load qw( load_class );
use Moose;
use JSON;
use List::MoreUtils qw( any );
use List::UtilsBy 'sort_by';
use MusicBrainz::Server::Data::Utils qw( non_empty ref_to_type type_to_model );
use MusicBrainz::Server::WebService::WebServiceInc;
use MusicBrainz::Server::WebService::Serializer::JSON::2::Utils qw( list_of number serializer serialize_entity );

sub mime_type { 'application/json' }
sub fmt { 'json' }

sub serialize
{
    my ($self, $type, @data) = @_;

    $type =~ s/-/_/g;

    my $override = $self->meta->find_method_by_name($type);
    return $override->execute($self, @data) if $override;

    my ($entity, $inc, $opts) = @data;

    my $ret = serialize_entity($entity, $inc, $opts, 1);
    return encode_json($ret);
}

sub entity_list
{
    my ($self, $list, $inc, $opts, $type, $type_plural) = @_;

    my %ret;

    if (defined $list->{offset} || defined $list->{total})
    {
        $ret{$type."-offset"} = number($list->{offset});
        $ret{$type."-count"} = number($list->{total});
    }
    $ret{$type_plural} = [
        map { serialize_entity($_, $inc, $opts, 1) }
        sort_by { $_->gid } @{ $list->{items} }];

    return encode_json(\%ret);
}

sub artist_list        { shift->entity_list(@_, "artist", "artists") };
sub label_list         { shift->entity_list(@_, "label", "labels") };
sub recording_list     { shift->entity_list(@_, "recording", "recordings") };
sub release_list       { shift->entity_list(@_, "release", "releases") };
sub release_group_list { shift->entity_list(@_, "release-group", "release-groups") };
sub work_list          { shift->entity_list(@_, "work", "works") };
sub area_list          { shift->entity_list(@_, "area", "areas") };
sub place_list         { shift->entity_list(@_, "place", "places") };
sub event_list         { shift->entity_list(@_, "event", "events") };

sub collection_list    {
    my ($self, $list, $inc, $opts) = @_;

    $self->entity_list($list, $inc, $opts, 'collection', 'collections');
}

sub serialize_internal {
    my ($self, $c, $entity) = @_;

    my $type = ref_to_type($entity);
    my $model = type_to_model($type);

    my $js_model = "MusicBrainz::Server::Controller::WS::js::$model";
    load_class($js_model);
    $js_model->_load_entities($c, $entity);

    return $entity->TO_JSON;
}

sub get_entity_json {
    return shift->{entity}->TO_JSON;
}

sub autocomplete_label {
    my ($self, $results, $pager) = @_;

    my $output = _with_primary_alias($results);

    push @$output, {
        pages => $pager->last_page,
        current => $pager->current_page
    } if $pager;

    return encode_json($output);
}

sub autocomplete_release {
    my ($self, $results, $pager) = @_;

    my $output = _with_primary_alias($results);

    push @$output, {
        pages => $pager->last_page,
        current => $pager->current_page
    } if $pager;

    return encode_json($output);
}

sub autocomplete_area {
    my ($self, $results, $pager) = @_;

    my $output = _with_primary_alias($results);

    push @$output, {
        pages => $pager->last_page,
        current => $pager->current_page
    } if $pager;

    return encode_json($output);
}

sub autocomplete_artist {
    my ($self, $results, $pager) = @_;

    my $output = _with_primary_alias($results);

    push @$output, {
        pages => $pager->last_page,
        current => $pager->current_page
    } if $pager;

    return encode_json($output);
}

sub autocomplete_editor {
    my ($self, $output, $pager) = @_;

    return encode_json([
        (map +{
            name => $_->name,
            id => $_->id,
        }, @$output),
        {
            pages => $pager->last_page,
            current => $pager->current_page
        }
    ]);
}

sub output_error {
    my ($self, $err) = @_;

    return encode_json({ error => $err });
}

sub autocomplete_release_group {
    my ($self, $results, $pager) = @_;

    my $output = _with_primary_alias($results);

    push @$output, {
        pages => $pager->last_page,
        current => $pager->current_page
    } if $pager;

    return encode_json($output);
}

sub autocomplete_recording {
    my ($self, $results, $pager) = @_;

    my $output = _with_primary_alias(
        $results,
        sub {
            my $item = shift;
            my $out = get_entity_json($item);

            $out->{appearsOn} = {
                hits => $item->{appearsOn}{hits},
                results => [map +{ name => $_->name, gid => $_->gid }, @{ $item->{appearsOn}{results} }],
            };

            return $out;
        }
    );

    push @$output, {
        pages => $pager->last_page,
        current => $pager->current_page
    } if $pager;

    return encode_json($output);
}

sub autocomplete_work {
    my ($self, $results, $pager) = @_;

    my $output = _with_primary_alias(
        $results,
        sub {
            my $result = shift;

            my $out = get_entity_json($result);
            $out->{artists} = $result->{artists};

            return $out;
        }
    );

    push @$output, {
        pages => $pager->last_page,
        current => $pager->current_page
    } if $pager;

    return encode_json($output);
}

sub _with_primary_alias {
    my ($results, $renderer) = @_;

    $renderer //= \&get_entity_json;

    my @output;
    if (@$results) {
        my $munge_lang = sub {
            my $lang = shift;
            $lang =~ s/_[A-Z]{2}/_/;
            return $lang;
        };

        my %alias_preference = (
            en => 2,
            en_ => 1
        );
        my $lang = $munge_lang->($results->[0]->{current_language});
        $lang =~ s/_$//;
        $alias_preference{$lang} = 4 if $lang ne 'en';
        $alias_preference{$lang . '_'} = 3 if $lang ne 'en';

        for my $result (@$results) {
            my $out = $renderer->($result);

            my ($primary_alias, @others) =
                reverse sort {
                    my $pref_a = $alias_preference{$munge_lang->($a->locale)};
                    my $pref_b = $alias_preference{$munge_lang->($b->locale)};

                    defined($pref_a) && defined($pref_b)
                        ? $pref_a <=> $pref_b
                        : defined($pref_a) || -(defined($pref_b)) || 0;
                } grep {
                    $_->primary_for_locale
                } @{ $result->{aliases} };

            $out->{primaryAlias} = $primary_alias && $primary_alias->name;
            push @output, $out;
        }
    }

    return \@output;
}

sub autocomplete_place {
    my ($self, $results, $pager) = @_;

    my $output = _with_primary_alias($results);

    push @$output, {
        pages => $pager->last_page,
        current => $pager->current_page
    } if $pager;

    return encode_json($output);
}

sub autocomplete_instrument {
    my ($self, $results, $pager) = @_;

    my $output = _with_primary_alias($results);

    push @$output, {
        pages => $pager->last_page,
        current => $pager->current_page
    } if $pager;

    return encode_json($output);
}

sub autocomplete_event {
    my ($self, $results, $pager) = @_;

    my $output = _with_primary_alias(
        $results,
        sub {
            my $result = shift;

            my $out = get_entity_json($result);
            $out->{related_entities} = $result->{related_entities};

            return $out;
        }
    );

    push @$output, {
        pages => $pager->last_page,
        current => $pager->current_page
    } if $pager;

    return encode_json($output);
}

sub autocomplete_series {
    my ($self, $results, $pager) = @_;

    my $output = _with_primary_alias($results);

    push @$output, {
        pages => $pager->last_page,
        current => $pager->current_page
    } if $pager;

    return encode_json($output);
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
