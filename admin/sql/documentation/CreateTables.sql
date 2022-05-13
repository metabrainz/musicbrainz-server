\set ON_ERROR_STOP 1
BEGIN;

SET search_path = 'documentation';

CREATE TABLE l_area_area_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_area_area.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_area_artist_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_area_artist.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_area_event_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_area_event.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_area_genre_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_area_genre.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_area_instrument_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_area_instrument.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_area_label_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_area_label.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_area_mood_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_area_mood.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_area_place_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_area_place.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_area_recording_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_area_recording.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_area_release_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_area_release.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_area_release_group_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_area_release_group.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_area_url_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_area_url.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_area_work_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_area_work.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);


CREATE TABLE l_artist_artist_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_artist_artist.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_artist_event_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_artist_event.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_artist_genre_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_artist_genre.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_artist_instrument_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_artist_instrument.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_artist_label_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_artist_label.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_artist_mood_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_artist_mood.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_artist_place_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_artist_place.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_artist_recording_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_artist_recording.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_artist_release_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_artist_release.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_artist_release_group_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_artist_release_group.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_artist_url_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_artist_url.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_artist_work_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_artist_work.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);


CREATE TABLE l_event_event_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_event_event.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_event_genre_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_event_genre.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_event_instrument_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_event_instrument.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_event_label_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_event_label.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_event_mood_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_event_mood.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_event_place_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_event_place.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_event_recording_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_event_recording.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_event_release_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_event_release.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_event_release_group_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_event_release_group.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_event_series_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_event_series.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_event_url_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_event_url.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_event_work_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_event_work.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);


CREATE TABLE l_genre_genre_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_genre_genre.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_genre_instrument_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_genre_instrument.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_genre_label_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_genre_label.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_genre_mood_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_genre_mood.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_genre_place_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_genre_place.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_genre_recording_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_genre_recording.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_genre_release_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_genre_release.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_genre_release_group_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_genre_release_group.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_genre_series_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_genre_series.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_genre_url_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_genre_url.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_genre_work_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_genre_work.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);


CREATE TABLE l_instrument_instrument_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_instrument_instrument.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_instrument_label_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_instrument_label.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_instrument_mood_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_instrument_mood.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_instrument_place_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_instrument_place.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_instrument_recording_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_instrument_recording.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_instrument_release_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_instrument_release.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_instrument_release_group_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_instrument_release_group.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_instrument_series_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_instrument_series.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_instrument_url_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_instrument_url.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_instrument_work_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_instrument_work.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);


CREATE TABLE l_label_label_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_label_label.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_label_mood_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_label_mood.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_label_place_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_label_place.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_label_recording_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_label_recording.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_label_release_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_label_release.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_label_release_group_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_label_release_group.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_label_url_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_label_url.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_label_work_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_label_work.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);


CREATE TABLE l_mood_mood_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_mood_mood.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_mood_place_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_mood_place.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_mood_recording_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_mood_recording.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_mood_release_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_mood_release.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_mood_release_group_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_mood_release_group.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_mood_series_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_mood_series.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_mood_url_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_mood_url.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_mood_work_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_mood_work.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);


CREATE TABLE l_place_place_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_place_place.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_place_recording_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_place_recording.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_place_release_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_place_release.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_place_release_group_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_place_release_group.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_place_url_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_place_url.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_place_work_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_place_work.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);


CREATE TABLE l_recording_recording_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_recording_recording.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_recording_release_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_recording_release.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_recording_release_group_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_recording_release_group.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_recording_url_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_recording_url.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_recording_work_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_recording_work.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);


CREATE TABLE l_release_release_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_release_release.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_release_release_group_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_release_release_group.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_release_url_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_release_url.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_release_work_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_release_work.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);


CREATE TABLE l_release_group_release_group_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_release_group_release_group.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_release_group_url_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_release_group_url.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_release_group_work_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_release_group_work.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);


CREATE TABLE l_area_series_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_area_series.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_artist_series_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_artist_series.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_label_series_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_label_series.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_place_series_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_place_series.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_recording_series_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_recording_series.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_release_series_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_release_series.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_release_group_series_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_release_group_series.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_series_series_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_series_series.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_series_url_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_series_url.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_series_work_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_series_work.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);



CREATE TABLE l_url_url_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_url_url.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_url_work_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_url_work.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);



CREATE TABLE l_work_work_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_work_work.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);


CREATE TABLE link_type_documentation ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.link_type.id
  documentation TEXT NOT NULL,
  examples_deleted SMALLINT NOT NULL DEFAULT 0
);

COMMIT;
