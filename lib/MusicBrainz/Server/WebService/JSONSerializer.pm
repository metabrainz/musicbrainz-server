package MusicBrainz::Server::WebService::JSONSerializer;

use Class::Load qw( load_class );
use Moose;
use JSON;
use List::AllUtils qw( sort_by );
use MusicBrainz::Server::Constants qw( %ENTITIES );
use MusicBrainz::Server::Data::Utils qw( ref_to_type type_to_model );
use MusicBrainz::Server::WebService::WebServiceInc;
use MusicBrainz::Server::WebService::Serializer::JSON::2::Utils qw(
    number
    serialize_entity
);
use Try::Tiny;

sub mime_type { 'application/json' }
sub fmt { 'json' }

sub serialize
{
    my ($self, $type, $entity, $inc, $opts) = @_;

    $type =~ tr/-/_/;

    my $override = $self->meta->find_method_by_name($type);
    return $override->execute($self, $entity, $inc, $opts) if $override;

    if (substr($type, -5) eq '_list' && exists($entity->{items})) {
        my $list_type = substr($type, 0, -5);
        if (exists($ENTITIES{$list_type}) && exists($ENTITIES{$list_type}->{plural_url})) {
            my $singular = $ENTITIES{$list_type}->{url};
            my $plural   = $ENTITIES{$list_type}->{plural_url};
            my $ret = {
                $plural => [
                    map { serialize_entity($_, $inc, $opts, 1) }
                    sort_by { $list_type eq 'genre' ? $_->name : $_->gid }
                    @{ $entity->{items} }
                ],
            };
            $ret->{$singular . '-offset'} = number($entity->{offset}) if defined($entity->{offset});
            $ret->{$singular . '-count' } = number($entity->{total}) if defined($entity->{total});
            return encode_json($ret);
        }
    }

    my $ret = serialize_entity($entity, $inc, $opts, 1);
    return encode_json($ret);
}

sub serialize_internal {
    my ($self, $c, $entity) = @_;

    my $type = ref_to_type($entity);
    my $model = type_to_model($type);

    my $js_model = "MusicBrainz::Server::Controller::WS::js::$model";
    try {
        load_class($js_model);
    }
    catch {
        MusicBrainz::Server::Controller::WS::js->critical_error(
            $c,
            qq{Tried to load unsupported entity type "$type".},
        );
    };

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
        (map { $_->TO_JSON } @$output),
        {
            pages => $pager->last_page,
            current => $pager->current_page
        }
    ]);
}

sub output_error {
    my ($self, $err) = @_;

    return encode_json({
        error => $err,
        help => 'For usage, please see: https://musicbrainz.org/development/mmd',
    });
}

sub output_success {
  my ($self, $msg) = @_;

    $msg ||= 'OK';

    return encode_json({ message => $msg });
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
            $out->{related_artists} = $result->{related_artists};

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
            shift =~ s/_[A-Z]{2}/_/r
        };

        my %alias_preference = (
            en => 2,
            en_ => 1
        );
        my $lang = $munge_lang->($results->[0]->{current_language}) =~ s/_$//r;
        $alias_preference{$lang} = 4 if $lang ne 'en';
        $alias_preference{$lang . '_'} = 3 if $lang ne 'en';

        for my $result (@$results) {
            my $out = $renderer->($result);

            my ($primary_alias) =
                reverse sort {
                    my $pref_a = $alias_preference{$munge_lang->($a->locale)};
                    my $pref_b = $alias_preference{$munge_lang->($b->locale)};

                    defined($pref_a) && defined($pref_b)
                        ? $pref_a <=> $pref_b
                        : defined($pref_a) || -(defined($pref_b)) || 0;
                } grep {
                    $_->primary_for_locale
                } @{ $result->{aliases} };

            $out->{primaryAlias} = undef;
            if ($primary_alias && ($alias_preference{$munge_lang->($primary_alias->locale)} // 0) > 0) {
                $out->{primaryAlias} = $primary_alias->name;
            }
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

sub autocomplete_genre {
    my ($self, $results, $pager) = @_;

    my $output = _with_primary_alias($results, sub {
        shift->TO_JSON
    });

    push @$output, {
        pages => $pager->last_page,
        current => $pager->current_page
    } if $pager;

    return encode_json($output);
}

sub user_rating {
    my ($self, $entity, $inc, $opts) = @_;

    my $user_rating = $opts->store($entity)->{user_ratings};

    return encode_json({
        'user-rating' => {value => $user_rating},
    });
}

sub user_tag_list {
    my ($self, $entity, $inc, $opts) = @_;

    my $user_tags = $opts->store($entity)->{user_tags};

    return encode_json({
        'user-tags' => [
            sort { $a->{name} cmp $b->{name} }
            map +{ name => $_->tag->name }, @{ $user_tags }
        ],
    });
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
