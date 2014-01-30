package MusicBrainz::Server::Controller::ReleaseEditor;
use utf8;
use Moose;

BEGIN { extends 'MusicBrainz::Server::Controller' }

__PACKAGE__->config(
    namespace => 'release_editor'
);

use JSON::Any;
use Try::Tiny;
use Scalar::Util qw( looks_like_number );
use MusicBrainz::Server::CGI::Expand qw( expand_hash );
use MusicBrainz::Server::Track qw( unformat_track_length );
use MusicBrainz::Server::Translation qw( l );
use MusicBrainz::Server::Data::Utils qw( trim );
use MusicBrainz::Server::Form::Utils qw(
    language_options
    script_options
    select_options
    build_grouped_options
);
use aliased 'MusicBrainz::Server::Entity::CDTOC';
use aliased 'MusicBrainz::Server::Entity::PartialDate';
use aliased 'MusicBrainz::Server::WebService::JSONSerializer';

# Methods for the release editor
sub _init_release_editor
{
    my ($self, $c, %options) = @_;

    my $json = JSON::Any->new( utf8 => 1 );

    $options{redirect_uri} = (
        $c->req->query_params->{redirect_uri} //
        $c->req->body_params->{redirect_uri}
    );

    $options{seeded_data} = $json->encode($self->_seeded_data($c) // {});

    $c->stash(
        template        => 'release/edit/layout.tt',
        # These need to be accessed by root/release/edit/information.tt.
        primary_types   => select_options($c, 'ReleaseGroupType'),
        secondary_types => select_options($c, 'ReleaseGroupSecondaryType'),
        statuses        => select_options($c, 'ReleaseStatus'),
        languages       => build_grouped_options($c, language_options($c)),
        scripts         => build_grouped_options($c, script_options($c)),
        packagings      => select_options($c, 'ReleasePackaging'),
        countries       => select_options($c, 'CountryArea'),
        formats         => select_options($c, 'MediumFormat'),
        %options
    );
}

sub edit : Chained('/release/load') PathPart('edit') Edit RequireAuth
{
    my ($self, $c) = @_;

    my $release = $c->stash->{release};

    $self->_init_release_editor(
        $c,
        return_to => $c->uri_for_action('/release/show', [ $release->gid ])
    );
}

sub add : Path('/release/add') Edit RequireAuth
{
    my ($self, $c) = @_;

    my $release_group_gid = $c->req->query_params->{'release-group'};
    my $label_gid = $c->req->query_params->{'label'};
    my $artist_gid = $c->req->query_params->{'artist'};
    my $return_to;

    if ($release_group_gid) {
        $return_to = $c->uri_for_action('/release_group/show', [ $release_group_gid ]);
    }
    elsif ($label_gid) {
        $return_to = $c->uri_for_action('/label/show', [ $label_gid ]);
    }
    elsif ($artist_gid) {
        $return_to = $c->uri_for_action('/artist/show', [ $artist_gid ]);
    }
    else {
        $return_to = $c->uri_for_action('/index');
    }

    $self->_init_release_editor($c, return_to => $return_to);
}

sub _seeded_data
{
    my ($self, $c) = @_;

    my $params = expand_hash($c->req->body_params) // {};

    my $release_group_gid = $c->req->query_params->{'release-group'};
    my $artist_gid = $c->req->query_params->{'artist'};
    my $label_gid = $c->req->query_params->{'label'};

    $params->{release_group} = $release_group_gid if $release_group_gid;
    $params->{artist_credit} = { names => [ { mbid => $artist_gid } ] } if $artist_gid;
    $params->{labels} = [ { mbid => $label_gid } ] if $label_gid;

    return $self->_process_seeded_data($c, $params);
}

sub _process_seeded_data
{
    my ($self, $c, $params) = @_;

    my $result = {};
    my @errors;

    my @known_fields = qw( name release_group type comment annotation barcode
                           language script status packaging events labels
                           date country artist_credit mediums edit_note
                           redirect_uri as_auto_editor );

    _report_unknown_fields('', $params, \@errors, @known_fields);

    if (my $name = trim($params->{name} // '')) {
        $result->{name} = $name;
    }

    $result->{comment} = trim($params->{comment}) if $params->{comment};
    $result->{annotation} = $params->{annotation} if $params->{annotation};
    $result->{barcode} = (trim($params->{barcode}) // undef) if $params->{barcode};

    if (my $ac = $params->{artist_credit}) {
        $result->{artistCredit} = _seeded_hash($c, \&_seeded_artist_credit,
            $ac, "artist_credit", \@errors);
    }

    if (my $gid = $params->{release_group}) {
        my $release_group = $c->model('ReleaseGroup')->get_by_gid($gid);

        if ($release_group) {
            $c->model('ArtistCredit')->load($release_group);

            $result->{releaseGroup} = JSONSerializer->_release_group($release_group);

            $result->{name} ||= $result->{releaseGroup}->{name};
            $result->{artistCredit} ||= $result->{releaseGroup}->{artistCredit};
        } else {
            push @errors, "Invalid release_group: “$gid”.";
        }
    } elsif (my $types = $params->{type}) {
        $result->{releaseGroup} = { name => $result->{name} // '' };

        my @secondary_types_result;

        my %primary_types = map { lc($_->name) => $_ }
            $c->model('ReleaseGroupType')->get_all;

        my %secondary_types = map { lc($_->name) => $_ }
            $c->model('ReleaseGroupSecondaryType')->get_all;

        for my $type (ref($types) eq 'ARRAY' ? @$types : ($types)) {
            if ($primary_types{$type}) {
                $result->{releaseGroup}->{typeID} = $primary_types{$type}->id;

            } elsif ($secondary_types{$type}) {
                push @secondary_types_result, $secondary_types{$type}->id;

            } else {
                push @errors, "Invalid release group type: “$type”.";
            }
        }
        $result->{releaseGroup}->{secondaryTypeIDs} = \@secondary_types_result;
    }

    if (my $code = lc $params->{language}) {
        my $language = $c->model('Language')->find_by_code($code);

        if ($language) {
            $result->{languageID} = $language->id;
        } else {
            push @errors, "Invalid language: “$code”.";
        }
    }

    if (my $code = lc ucfirst $params->{script}) {
        my $script = $c->model('Script')->find_by_code($code);

        if ($script) {
            $result->{scriptID} = $script->id;
        } else {
           push @errors, "Invalid script: “$code”.";
        }
    }

    if (my $name = $params->{status}) {
        my $status = $c->model('ReleaseStatus')->find_by_name($name);

        if ($status) {
            $result->{statusID} = $status->id;
        } else {
            push @errors, "Invalid status: “$name”.";
        }
    }

    if (my $name = $params->{packaging}) {
        my $packaging = $c->model('ReleasePackaging')->find_by_name($name);

        if ($packaging) {
            $result->{packagingID} = $packaging->id;
        } else {
            push @errors, "Invalid packaging: “$name”.";
        }
    }

    if (exists $params->{country} || exists $params->{date}) {
        # schema 16 style country/date pair, convert to schema 18 release event.
        $params->{events} = [{}];
        $params->{events}->[0]->{date} = $params->{date} if exists $params->{date};
        $params->{events}->[0]->{country} = $params->{country} if exists $params->{country};
    }

    if (my $events = $params->{events}) {
        $result->{events} = _seeded_array($c, \&_seeded_event, $events, "events", \@errors);
    }

    if (my $labels = $params->{labels}) {
        $result->{labels} = _seeded_array($c, \&_seeded_label, $labels, "labels", \@errors);
    }

    if (my $mediums = $params->{mediums}) {
        $result->{mediums} = _seeded_array($c, \&_seeded_medium, $mediums, "mediums", \@errors);

        my $position = 0;

        for my $medium (@{ $result->{mediums} // [] }) {
            $medium->{position} = ++$position unless $medium->{position};
        }
    }

    $result->{editNote} = $params->{edit_note} if $params->{edit_note};

    if (defined $params->{as_auto_editor}) {
        $result->{asAutoEditor} = $params->{as_auto_editor};
    }

    return { seed => $result, errors => \@errors };
}

sub _seeded_hash
{
    my ($c, $parse, $params, $field_name, $errors) = @_;

    return unless defined $params;

    if (ref($params) eq "HASH") {
        return $parse->($c, $params, $field_name, $errors);
    } else {
        push @$errors, "$field_name must be a hash.";
        return undef;
    }
}

sub _seeded_array
{
    my ($c, $parse, $params, $field_name, $errors) = @_;

    unless (ref($params) eq "ARRAY") {
        push @$errors, "$field_name must be an array";

        if (ref($params) eq "HASH") {
            _report_unknown_fields($field_name, $params, $errors);
        }
        return undef;
    }

    my @results;

    for (my $i = 0; $i < scalar @$params; $i++) {
        my $param = $params->[$i];

        if (defined $param) {
            my $result = _seeded_hash($c, $parse, $param, "$field_name.$i", $errors);

            push @results, $result if defined $result;
        } else {
            push @$errors, "$field_name.$i isn’t defined, do your indexes start at 0?";
            return undef;
        }
    }

    return \@results;
}

sub _seeded_event
{
    my ($c, $params, $field_name, $errors) = @_;

    _report_unknown_fields($field_name, $params, $errors, qw( date country ));

    my $result = {};

    if (my $date = $params->{date}) {
        $result->{date} = PartialDate->new(%$date)->format;
    }

    if (my $iso = uc $params->{country}) {
        my $country = $c->model('Area')->get_by_iso_3166_1($iso)->{$iso};

        if ($country) {
            $result->{countryID} = $country->id;
        } else {
            push @$errors, "Invalid $field_name.country: “$iso”.";
        }
    }
    return $result;
}

sub _seeded_label
{
    my ($c, $params, $field_name, $errors) = @_;

    _report_unknown_fields($field_name, $params, $errors, qw( mbid name catalog_number ));

    my $result = {};

    if (my $gid = $params->{mbid}) {
        my $label = $c->model('Label')->get_by_gid($gid);

        if ($label) {
            $result->{label} = JSONSerializer->_label($label);
        } else {
            push @$errors, "Invalid $field_name.mbid: “$gid”."
        }
    } elsif (my $name = $params->{name}) {
        $result->{label} = { name => trim($name // '') };
    }

    $result->{catalogNumber} = trim($params->{catalog_number} // '');
    return $result;
}

sub _seeded_medium
{
    my ($c, $params, $field_name, $errors) = @_;

    my @known_fields = qw( format position name track toc );
    _report_unknown_fields($field_name, $params, $errors, @known_fields);

    my $result = { tracks => [] };

    if (my $name = $params->{format}) {
        my $format = $c->model('MediumFormat')->find_by_name($name);

        if ($format) {
            $result->{formatID} = $format->id;
        } else {
            push @$errors, "Invalid $field_name.format: “$format”.";
        }
    }

    if (my $position = $params->{position}) {
        if (looks_like_number($position)) {
            $result->{position} = $position;
        } else {
            push @$errors, "Invalid $field_name.position: “$position”.";
        }
    }

    $result->{name} = trim($params->{name}) if $params->{name};

    if (my $tracks = $params->{track}) {
        $result->{tracks} = _seeded_array($c, \&_seeded_track, $tracks, "track", $errors);
    }

    if (my $toc = $params->{toc}) {
        try {
            my $cdtoc = CDTOC->new_from_toc($toc);
            my $tracks = $result->{tracks};

            if (scalar @$tracks > 0 && scalar @$tracks != $cdtoc->track_count) {
                push @$errors, "Track counts of $field_name.toc and $field_name.track don’t match.";
            } else {
                my $details = $cdtoc->track_details;

                for my $i (0..$cdtoc->track_count - 1) {
                    $tracks->[$i] //= {};
                    $tracks->[$i]->{length} = $details->[$i]->{length_time};
                }
            }
        } catch {
            push @$errors, "Invalid $field_name.toc: “$toc”.";
        };
    }

    my $position = 0;

    for my $track (@{ $result->{tracks} }) {
        $track->{position} = ++$position;
        $track->{number} = $position unless $track->{number};
    }

    return $result;
}

sub _seeded_track
{
    my ($c, $params, $field_name, $errors) = @_;

    my @known_fields = qw( name number recording length artist_credit );
    _report_unknown_fields($field_name, $params, $errors, @known_fields);

    my $result = {};

    $result->{name} = trim($params->{name}) if $params->{name};
    $result->{number} = trim($params->{number}) if $params->{number};

    if (my $ac = $params->{artist_credit}) {
        $result->{artistCredit} = _seeded_hash($c, \&_seeded_artist_credit,
            $ac, "$field_name.artist_credit", $errors);
    }

    if (my $length = $params->{length}) {
        $result->{length} = ($length =~ /:/) ? unformat_track_length($length) : $length;
    }

    if (my $gid = $params->{recording}) {
        if (my $recording = $c->model('Recording')->get_by_gid($gid)) {
            $c->model('ArtistCredit')->load($recording);

            $result->{recording} = JSONSerializer->_recording($recording);
        } else {
            push @$errors, "Invalid $field_name.recording: “$gid”.";
        }
    }

    return $result;
}

sub _seeded_artist_credit
{
    my ($c, $params, $field_name, $errors) = @_;

    _report_unknown_fields($field_name, $params, $errors, 'names');

    return _seeded_array($c, \&_seeded_artist_credit_name, $params->{names},
            "$field_name.names", $errors);
}

sub _seeded_artist_credit_name
{
    my ($c, $params, $field_name, $errors) = @_;

    my @known_fields = qw( mbid name artist join_phrase );
    _report_unknown_fields($field_name, $params, $errors, @known_fields);

    my $result = {};

    $result->{name} = trim($params->{name}) if $params->{name};

    if (my $gid = $params->{mbid}) {
        my $entity = $c->model('Artist')->get_by_gid($gid);

        if ($entity) {
            $result->{artist} = JSONSerializer->_artist($entity);
            $result->{name} ||= $entity->name;
        } else {
            push @$errors, "Invalid $field_name.mbid: “$gid”.";
        }
    }

    $result->{joinPhrase} = $params->{join_phrase} if $params->{join_phrase};

    $result->{artist} //= _seeded_hash($c, \&_seeded_artist, $params->{artist},
        "$field_name.artist", $errors);

    return $result;
}

sub _seeded_artist
{
    my ($c, $params, $field_name, $errors) = @_;

    _report_unknown_fields($field_name, $params, $errors, 'name');

    return { name => trim($params->{name} // '') };
}

sub _report_unknown_fields
{
    my ($parent, $fields, $errors, @valid_fields) = @_;

    my %valid_keys = map { $_ => 1 } @valid_fields;
    my @unknown_keys = grep { !exists $valid_keys{$_} } keys %$fields;

    push @$errors, map {
        "Unknown field: " . ($parent ? "$parent." : "") . "$_"
    } @unknown_keys;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

=head1 COPYRIGHT

Copyright (C) 2013 MetaBrainz Foundation

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
