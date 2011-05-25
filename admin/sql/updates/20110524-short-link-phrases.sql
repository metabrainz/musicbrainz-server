BEGIN;

UPDATE link_type SET short_link_phrase = old_link_phrases.linkphrase
    FROM (
        SELECT mbid, linkphrase FROM public.lt_album_album     -- Now release_release
        UNION ALL
        SELECT mbid, rlinkphrase FROM public.lt_album_artist   -- Now artist_release
        UNION ALL
        SELECT mbid, rlinkphrase FROM public.lt_album_label    -- Now label_release
        UNION ALL
        SELECT mbid, rlinkphrase FROM public.lt_album_track    -- Now recording_release
        UNION ALL
        SELECT mbid, linkphrase FROM public.lt_album_url       -- Now release_url
        UNION ALL
        SELECT mbid, linkphrase FROM public.lt_artist_artist   -- Now artist_artist
        UNION ALL
        SELECT mbid, linkphrase FROM public.lt_artist_label    -- Now artist_label
        UNION ALL
        SELECT mbid, linkphrase FROM public.lt_artist_track    -- Now artist_recording
        UNION ALL
        SELECT mbid, linkphrase FROM public.lt_artist_url      -- Now artist_url
        UNION ALL
        SELECT mbid, linkphrase FROM public.lt_label_label     -- Now label_label
        UNION ALL
        SELECT mbid, linkphrase FROM public.lt_label_track     -- Now label_recording
        UNION ALL
        SELECT mbid, linkphrase FROM public.lt_label_url       -- Now label_url
        UNION ALL
        SELECT mbid, linkphrase FROM public.lt_track_track     -- Now recording_recording
        UNION ALL
        SELECT mbid, linkphrase FROM public.lt_track_url       -- Now recording_url
        UNION ALL
        SELECT mbid, linkphrase FROM public.lt_url_url         -- Now url_url

        UNION ALL VALUES
        ('99e550f3-5ab4-3110-b5b9-fe01d970b126', 'has a Discogs page at'),               -- discogs
        ('05ee6f18-4517-342d-afdf-5897f64276e3', 'published')       ,                    -- publishing
        ('7d166271-99c7-3a13-ae96-d2aab758029d', 'has a miscellaneous role on'),         -- misc
        ('00687ce8-17e1-3343-b6e5-0a91b919fe24', 'is a miscellaneous website for'),      -- misc
        ('c1dca2cd-194c-36dd-93f8-6a359167e992', 'is a medley of'),                      -- medley
        ('f600f326-5105-383b-aaf3-8e96c4163d9f', 'published'),                           -- publishing
        ('12ac9db0-ec26-3567-be3a-2e662e617803', 'is a medley of'),                      -- medley
        ('a3005666-a872-32c3-ad06-98af558e99b0', 'is a {cover} performance of'),         -- performance
        ('a442b140-830b-30b0-a4aa-2e36f098b6aa', 'published')                            -- publishing
    ) old_link_phrases ( mbid, linkphrase )
WHERE link_type.gid = old_link_phrases.mbid::uuid;

UPDATE link_type SET short_link_phrase = old_link_phrases.linkphrase
    FROM (VALUES
          ('206cf8e2-0a7c-4c17-b8bb-75722d9b9c6c', 'is an IBDb page for'),
          ('8845d830-fe9b-4ed6-a084-b1a3f193167a', 'is an IOBDb page for'),
          ('0cc8527e-ea40-40dd-b144-3b7588e759bf', 'contains the score for'),
          ('e38e65aa-75e0-42ba-ace0-072aeb91a538', 'contains the lyrics for'),
          ('28338ee6-d578-485a-bb53-61dbfd7c6545', 'DJ-mixed {medium}')
    ) old_link_phrases ( mbid, linkphrase )
WHERE link_type.gid = old_link_phrases.mbid::uuid;

COMMIT;
