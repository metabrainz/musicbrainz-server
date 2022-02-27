\set ON_ERROR_STOP 1
BEGIN;

CREATE TYPE cover_art_presence AS ENUM ('absent', 'present', 'darkened');

CREATE TYPE event_art_presence AS ENUM ('absent', 'present', 'darkened');

CREATE TYPE fluency AS ENUM (
    'basic',
    'intermediate',
    'advanced',
    'native'
);

CREATE TYPE oauth_code_challenge_method AS ENUM ('plain', 'S256');

COMMIT;
