\set ON_ERROR_STOP 1
BEGIN;

INSERT INTO statistics.statistic_event (date, title, link, description)
  VALUES
  ('2016-02-22', 'New MusicBrainz design',
  'https://blog.musicbrainz.org/2016/02/22/server-update-2016-02-22/',
  'MusicBrainz itself gets a new design to better match the rest of the *Brainz family.'),
  ('2015-12-28', 'Edit note notifications',
  'https://blog.musicbrainz.org/2015/12/28/server-update-2015-12-28/',
  'A new banner message now notifies users whenever they receive a new edit note.'),
  ('2015-11-30', 'More auto-edits',
  'https://blog.musicbrainz.org/2015/11/30/server-update-2015-11-30/',
  'Edits made by editors to their own release additions within 1 hour of adding them are now auto-edits, as are "Add recording" and "Remove alias" edits.'),
  ('2015-11-16', 'Several new auto-edit types and translations',
  'https://blog.musicbrainz.org/2015/11/17/server-update-2015-11-16/',
  'More edit types are made auto-edits for everyone: "Add relationship" and "Add release"; and "Add", "Edit" and "Remove release label". Additionally, the German, French and Dutch translations are available on the main server.'),
  ('2015-09-17', 'The ListenBrainz project goes live',
  'https://twitter.com/ListenBrainz/status/644557316407324677',
  'The alpha version of ListenBrainz, an open source and open data alternative to Last.fm®, goes live.'),
  ('2015-09-04', 'Roman Tsukanov joins the MetaBrainz team',
  'https://blog.musicbrainz.org/2015/09/04/roman-tsukanov-joins-the-metabrainz-team/',
  'Former GSoC student Roman Tsukanov begins working for MetaBrainz part-time.'),
  ('2015-05-18', 'The new MetaBrainz website goes live',
  'https://blog.musicbrainz.org/2015/05/18/new-metabrainz-site-new-look-and-live-data-feed-access-tokens/',
  'The new MetaBrainz website, featuring an all-new design and online sign-up for commercial users, is launched, replacing the one designed in the year 2000!'),
  ('2014-11-19' , 'The AcousticBrainz project goes live',
  'https://blog.musicbrainz.org/2014/11/19/announcing-the-acousticbrainz-project/',
  'AcousticBrainz, which aims to crowd source acoustic information for music, is announced in cooperation with the Music Technology Group at Universitat Pompeu Fabra.'),
  ('2014-05-19', 'The CritiqueBrainz project goes live',
  'https://blog.musicbrainz.org/2014/05/19/announcing-the-beta-launch-of-critiquebrainz/',
  'The beta version of CritiqueBrainz is launched.');

COMMIT;
