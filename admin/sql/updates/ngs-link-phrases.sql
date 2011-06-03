BEGIN;

-- name: name (entity_type0-entity_type1)
--update link_type set
--	link_phrase = 'new link phrase', -- original link phrase
--	reverse_link_phrase = 'new reverse link phrase' -- original reverse link phrase
--	where gid = 'gid';

-- name: Affiliate links (release-url)
--update link_type set
--	link_phrase = 'links to affiliates', -- links to affiliates
--	reverse_link_phrase = 'links to affiliates' -- links to affiliates
--	where gid = '7c5c80e8-ed3a-4c9d-96bb-1131cdecb89d';

-- name: amazon asin (release-url)
update link_type set
	link_phrase = 'ASIN', -- has Amazon ASIN
	reverse_link_phrase = 'ASIN' -- from Amazon belongs to
	where gid = '4f2e710d-166c-480c-a293-2e2c8d658d87';

-- name: arranger (artist-release)
update link_type set
	link_phrase = '{additional:additionally} {instrument} arranged', -- {additional:additionally} arranged {instrument:% on}
	reverse_link_phrase = '{additional} {instrument} arranger' -- {instrument:has %|was} {additional:additionally} arranged by
	where gid = '18f159bb-44f0-4aef-b198-a4736ad9b659';

-- name: arranger (artist-work)
update link_type set
	link_phrase = '{additional:additionally} {instrument} arranged', -- {additional:additionally} arranged {instrument:% on}
	reverse_link_phrase = '{additional} {instrument} arranger' -- {instrument:has %|was} {additional:additionally} arranged by
	where gid = '4820daa1-98d6-4f8b-aa4b-6895c5b79b27';

-- name: art direction (artist-recording)
update link_type set
	link_phrase = '{additional} art direction', -- provided {additional} art direction on
	reverse_link_phrase = '{additional} art direction' -- has {additional} art direction by
	where gid = '9aae9a3d-7cc2-4eee-881d-b8b73d0ceef3';

-- name: art direction (artist-release)
update link_type set
	link_phrase = '{additional} art direction', -- provided {additional} art direction on
	reverse_link_phrase = '{additional} art direction' -- has {additional} art direction by
	where gid = 'f3b80a09-5ebf-4ad2-9c46-3e6bce971d1b';

-- name: art direction (recording-url)
update link_type set
	link_phrase = 'art direction', -- has art direction by
	reverse_link_phrase = 'art direction' -- provided art direction on
	where gid = '55f04b5f-26ee-454f-8ffa-37bb8fb4ef28';

-- name: artists and repertoire (artist-recording)
update link_type set
	link_phrase = 'artist & repertoire support', -- provided artist & repertoire support for
	reverse_link_phrase = 'artist & repertoire support' -- has artist & repertoire support by
	where gid = '8dc10cef-3116-4b3d-8e3e-33ffb84a97df';

-- name: artists and repertoire (artist-release)
update link_type set
	link_phrase = 'artist & repertoire support', -- provided artist & repertoire support for
	reverse_link_phrase = 'artist & repertoire support' -- has artist & repertoire support by
	where gid = '25dd0db4-189f-436c-a610-aacb979f13e2';

-- name: artists and repertoire (recording-url)
update link_type set
	link_phrase = 'artist & repertoire support', -- has artist & repertoire support by
	reverse_link_phrase = 'artist & repertoire support' -- provided artist & repertoire support on
	where gid = '8166aa25-8c4f-4a96-9bbe-b71e07fe323d';

-- name: audio (artist-recording)
update link_type set
	link_phrase = '{additional:additionally} {assistant} {associate} {co:co-}audio engineered', -- {additional:additionally} {assistant} {associate} {co:co-}audio engineered
	reverse_link_phrase = '{additional} {assistant} {associate} {co:co-}audio engineer' -- was {additional:additionally} {assistant} {associate} {co:co-}audio engineered by
	where gid = 'ca8d6d99-b847-439c-b0ec-33d8a1b942bc';

-- name: audio (artist-release)
update link_type set
	link_phrase = '{additional:additionally} {assistant} {associate} {co:co-}audio engineered', -- {additional:additionally} {assistant} {associate} {co:co-}audio engineered
	reverse_link_phrase = '{additional} {assistant} {associate} {co:co-}audio engineer' -- was {additional:additionally} {assistant} {associate} {co:co-}audio engineered by
	where gid = 'b04848d7-dbd9-4be0-9d8c-13df6d6e40db';

-- name: BBC Music page (artist-url)
update link_type set
	link_phrase = 'BBC Music', -- has a BBC Music page at
	reverse_link_phrase = 'BBC Music page for' -- is a BBC Music page for
	where gid = 'd028a975-000c-4525-9333-d3c8425e4b54';

-- name: biography (artist-url)
update link_type set
	link_phrase = 'biographies', -- has a biography page at
	reverse_link_phrase = 'biography of' -- is the biography page of
	where gid = '78f75830-94e1-4138-8f8a-643e3bb21ce5';

-- name: blog (artist-url)
update link_type set
	link_phrase = 'blogs', -- has a blog at
	reverse_link_phrase = 'blog of' -- is a blog of
	where gid = 'eb535226-f8ca-499d-9b18-6a144df4ae6f';

-- name: blog (label-url)
update link_type set
	link_phrase = 'blogs', -- has a blog at
	reverse_link_phrase = 'blog of' -- is a blog of
	where gid = '1b431eba-0d25-4f27-9151-1bb607f5c8f8';

-- name: booking (artist-recording)
update link_type set
	link_phrase = 'booking', -- provided booking for
	reverse_link_phrase = 'booking' -- was booked by
	where gid = 'b1edc6f6-283d-4e32-b625-b96cfb192056';

-- name: booking (artist-release)
update link_type set
	link_phrase = 'booking', -- provided booking for
	reverse_link_phrase = 'booking' -- was booked by
	where gid = 'b0f98226-7121-4db5-a69c-552e6d061da2';

-- name: booking (recording-url)
update link_type set
	link_phrase = 'booking', -- was booked by
	reverse_link_phrase = 'booking' -- provided booking on
	where gid = '1e952f5c-ee6e-4596-aa37-fc6d922eb17c';

-- name: business association (label-label)
--update link_type set
--	link_phrase = 'business association', -- business association
--	reverse_link_phrase = 'business association' -- business association
--	where gid = '0c1ff137-fca5-4148-82b7-8bce3c69165a';

-- name: catalog site (label-url)
update link_type set
	link_phrase = 'catalog of records', -- has a catalog of records at
	reverse_link_phrase = 'catalog of records' -- presents a catalog of records released by
	where gid = '5ac35a29-d29b-4390-b279-587bcd42fc73';

-- name: catalogued (artist-artist)
update link_type set
	link_phrase = '{additional:additionally} catalogued by', -- was {additional:additionally} catalogued by
	reverse_link_phrase = '{additional:additionally} catalogued' -- {additional:additionally} catalogued the works of
	where gid = '47200337-edd6-43d1-88b4-86f979a427bc';

-- name: chorus master (artist-recording)
update link_type set
	link_phrase = '{additional} chorus master', -- performed {additional} chorus master on
	reverse_link_phrase = '{additional} chorus master' -- has {additional} chorus master performed by
	where gid = '45115945-597e-4cb9-852f-4e6ba583fcc8';

-- name: chorus master (artist-release)
update link_type set
	link_phrase = '{additional} chorus master', -- performed {additional} chorus master on
	reverse_link_phrase = '{additional} chorus master' -- has {additional} chorus master performed by
	where gid = 'b9129850-73ec-4af5-803c-1c12b97e25d2';

-- name: collaboration (artist-artist)
update link_type set
	link_phrase = '{additional} {minor} collaborator on', -- collaborated {minor:minorly} {additional:additionally} on
	reverse_link_phrase = '{additional} {minor} collaborators' -- was {additional:an additional|a} {minor} collaboration between
	where gid = '75c09861-6857-4ec0-9729-84eefde7fc86';

-- name: compilation (recording-recording)
update link_type set
	link_phrase = 'compilation of', -- is a compilation of
	reverse_link_phrase = 'compiled in' -- has been compiled in
	where gid = '1b6311e8-5f81-43b7-8c55-4bbae71ec00c';

-- name: compilations (artist-recording)
--update link_type set
--	link_phrase = 'compilations', -- compilations
--	reverse_link_phrase = 'compilations' -- compilations
--	where gid = '438dac11-af4a-4074-81fc-77e5a07534c8';

-- name: compilations (artist-release)
--update link_type set
--	link_phrase = 'compilations', -- compilations
--	reverse_link_phrase = 'compilations' -- compilations
--	where gid = '7a12df1d-f35e-43f3-b64c-574ba2eb595e';

-- name: compilations (recording-recording)
--update link_type set
--	link_phrase = 'compilations', -- compilations
--	reverse_link_phrase = 'compilations' -- compilations
--	where gid = 'fd79803e-272c-4e9c-9c66-eb58bc136a82';

-- name: compilations (release_group-release_group)
--update link_type set
--	link_phrase = 'compilations', -- compilations
--	reverse_link_phrase = 'compilations' -- compilations
--	where gid = '3efa186f-8528-4490-bf6f-5fec4ca771fa';

-- name: compilations (work-work)
--update link_type set
--	link_phrase = 'compilations', -- compilations
--	reverse_link_phrase = 'compilations' -- compilations
--	where gid = '75c8f975-c952-3004-81e7-10209228bbd0';

-- name: compiler (artist-recording)
update link_type set
	link_phrase = 'compiled', -- compiled
	reverse_link_phrase = 'compiler' -- was compiled by
	where gid = '35ba2b3b-aaeb-4db1-bc5f-f42154e785d8';

-- name: compiler (artist-release)
update link_type set
	link_phrase = 'compiled', -- compiled
	reverse_link_phrase = 'compiler' -- was compiled by
	where gid = '2f81887a-8674-4d8b-bd48-8bfd4c6fa332';

-- name: composer (artist-release)
update link_type set
	link_phrase = '{additional:additionally} composed', -- {additional:additionally} composed
	reverse_link_phrase = '{additional} composer' -- was {additional:additionally} composed by
	where gid = '01ce32b0-d873-4baa-8025-714b45c0c754';

-- name: composer (artist-work)
update link_type set
	link_phrase = '{additional:additionally} composed', -- {additional:additionally} composed
	reverse_link_phrase = '{additional} composer' -- was {additional:additionally} composed by
	where gid = 'd59d99ea-23d4-4a80-b066-edca32ee158f';

-- name: composition (artist-release)
--update link_type set
--	link_phrase = 'composition', -- composition
--	reverse_link_phrase = 'composition' -- composition
--	where gid = '800a8a16-5426-4f4e-8dd6-9371d8bc8398';

-- name: composition (artist-work)
--update link_type set
--	link_phrase = 'composition', -- composition
--	reverse_link_phrase = 'composition' -- composition
--	where gid = 'cc9fcb45-7ab5-4629-bc5f-277f2592fa5a';

-- name: conductor (artist-recording)
update link_type set
	link_phrase = '{additional:additionally} conducted', -- {additional:additionally} conducted
	reverse_link_phrase = '{additional} conductor' -- was {additional:additionally} conducted by
	where gid = '234670ce-5f22-4fd0-921b-ef1662695c5d';

-- name: conductor (artist-release)
update link_type set
	link_phrase = '{additional:additionally} conducted', -- {additional:additionally} conducted
	reverse_link_phrase = '{additional} conductor' -- was {additional:additionally} conducted by
	where gid = '9ae9e4d0-f26b-42fb-ab5c-1149a47cf83b';

-- name: contract (artist-label)
--update link_type set
--	link_phrase = 'contract', -- contract
--	reverse_link_phrase = 'contract' -- contract
--	where gid = 'e74a40e7-0f27-4e05-bdbd-eb10f5309472';

-- name: cover (release_group-release_group)
update link_type set
	link_phrase = '{translated} {parody:parody|cover} of', -- is a {translated} {parody} cover of
	reverse_link_phrase = '{translated} {parody:parodies|covers}' -- is covered by {translated} {parody}
	where gid = 'cf02e524-9d5b-46b7-a88e-329737395818';

-- name: cover art link (release-url)
update link_type set
	link_phrase = 'cover art', -- has cover art at
	reverse_link_phrase = 'cover art for' -- is the cover art for
	where gid = '2476be45-3090-43b3-a948-a8f972b4065c';

-- name: covers and versions (recording-recording)
--update link_type set
--	link_phrase = 'covers or other versions', -- covers or other versions
--	reverse_link_phrase = 'covers or other versions' -- covers or other versions
--	where gid = '6a76ad99-cc5d-4ebc-a6e4-b2eb2eb3ad98';

-- name: covers and versions (release-release)
--update link_type set
--	link_phrase = 'covers or other versions', -- covers or other versions
--	reverse_link_phrase = 'covers or other versions' -- covers or other versions
--	where gid = '3676d4aa-2fa7-435f-b83f-cdbbe4740938';

-- name: covers and versions (release_group-release_group)
--update link_type set
--	link_phrase = 'covers or other versions', -- covers or other versions
--	reverse_link_phrase = 'covers or other versions' -- covers or other versions
--	where gid = 'd912cce3-6a10-3a5c-8e79-7e26f70eff85';

-- name: covers and versions (work-work)
--update link_type set
--	link_phrase = 'covers or other versions', -- covers or other versions
--	reverse_link_phrase = 'covers or other versions' -- covers or other versions
--	where gid = '237814ee-6aaa-3626-b7ed-4a402cd0c8ec';

-- name: creative commons licensed download (recording-url)
update link_type set
	link_phrase = 'Creative Commons {license} licensed download', -- is available for download under the Creative Commons {license} license at
	reverse_link_phrase = 'Creative Commons {license} licensed download page for' -- is the download location for Creative Commons {license} licensed
	where gid = '87c9a8ed-36fc-4e39-8219-c5c63a755d56';

-- name: creative commons licensed download (release-url)
update link_type set
	link_phrase = 'Creative Commons {license} licensed download', -- is available for download under the Creative Commons {license} license at
	reverse_link_phrase = 'Creative Commons {license} licensed download page for' -- is the download location for Creative Commons {license} licensed
	where gid = 'd9ea0f04-5abf-48a6-98ca-13fa4de7b678';

-- name: creative direction (artist-recording)
update link_type set
	link_phrase = '{additional} creative direction', -- provided {additional} creative direction on
	reverse_link_phrase = '{additional} creative direction' -- has {additional} creative direction by
	where gid = '0eb67a3e-796b-4394-ab6e-1224f43236b6';

-- name: creative direction (artist-release)
update link_type set
	link_phrase = '{additional} creative direction', -- provided {additional} creative direction on
	reverse_link_phrase = '{additional} creative direction' -- has {additional} creative direction by
	where gid = 'e035ac25-a2ff-48a6-9fb6-077692c67241';

-- name: creative direction (recording-url)
update link_type set
	link_phrase = 'creative direction', -- has creative direction by
	reverse_link_phrase = 'creative direction' -- provided creative direction on
	where gid = '1abcef91-589d-4235-9e99-87f7376dff30';

-- name: creative position (artist-label)
update link_type set
	link_phrase = 'creative position', -- had a creative position at
	reverse_link_phrase = 'creative persons' -- contracted as a creative person
	where gid = '85d1947c-1986-42f0-947c-80aab72a548f';

-- name: design/illustration (artist-recording)
update link_type set
	link_phrase = '{additional} design/illustration', -- provided {additional} design/illustration on
	reverse_link_phrase = '{additional} design/illustration' -- has {additional} design/illustration by
	where gid = '4af8e696-2690-486f-87db-bc8ec2bfe859';

-- name: design/illustration (artist-release)
update link_type set
	link_phrase = '{additional} design/illustration', -- provided {additional} design/illustration on
	reverse_link_phrase = '{additional} design/illustration' -- has {additional} design/illustration by
	where gid = '307e95dd-88b5-419b-8223-b146d4a0d439';

-- name: design/illustration (recording-url)
update link_type set
	link_phrase = 'design/illustration', -- has design/illustration by
	reverse_link_phrase = 'design/illustration' -- provided design/illustration on
	where gid = 'cefaf12f-2111-4972-a8ed-cd8a9f05bb4c';

-- name: discography (artist-url)
update link_type set
	link_phrase = 'discography pages', -- has a discography page at
	reverse_link_phrase = 'discography page for' -- is the discography page of
	where gid = '4fb0eeec-a6eb-4ae3-ad52-b55765b94e8f';

-- name: discography (artist-url)
--update link_type set
--	link_phrase = 'discography', -- discography
--	reverse_link_phrase = 'discography' -- discography
--	where gid = 'd0c5cf3a-8afb-4d24-ad47-00f43dc509fe';

-- name: discography (release_group-url)
--update link_type set
--	link_phrase = 'discography', -- discography
--	reverse_link_phrase = 'discography' -- discography
--	where gid = '89fe4da2-ced3-4fd0-8739-fd22d823acdb';

-- name: discogs (artist-url)
update link_type set
	link_phrase = 'Discogs', -- has a Discogs page at
	reverse_link_phrase = 'Discogs page for' -- is a Discogs page for
	where gid = '04a5b104-a4c2-4bac-99a1-7b837c37d9e4';

-- name: discogs (label-url)
update link_type set
	link_phrase = 'Discogs', -- has a Discogs page at
	reverse_link_phrase = 'Discogs page for' -- is a Discogs page for
	where gid = '5b987f87-25bc-4a2d-b3f1-3618795b8207';

-- name: discogs (release-url)
update link_type set
	link_phrase = 'Discogs', -- has a Discogs page at
	reverse_link_phrase = 'Discogs page for' -- is a Discogs page for
	where gid = '4a78823c-1c53-4176-a5f3-58026c76f2bc';

-- name: discogs (release_group-url)
update link_type set
	link_phrase = 'Discogs', -- has a Discogs page at
	reverse_link_phrase = 'Discogs page for' -- is a Discogs page for
	where gid = '99e550f3-5ab4-3110-b5b9-fe01d970b126';

-- name: DJ-mix (recording-recording)
update link_type set
	link_phrase = 'DJ-mix of', -- is a DJ-mix of
	reverse_link_phrase = 'DJ-mixes' -- has been compiled in a DJ-mix
	where gid = '451076df-61cf-46ab-9921-555cab2f050d';

-- name: DJ-mix (release_group-release_group)
update link_type set
	link_phrase = 'DJ-mix of', -- is a DJ-mix of
	reverse_link_phrase = 'DJ-mixed versions' -- has DJ-mixed version(s)
	where gid = 'd3286b50-a9d9-4cc3-94ad-cd7e2ffc787a';

-- name: download for free (artist-url)
update link_type set
	link_phrase = 'download music for free', -- music can be downloaded for free at
	reverse_link_phrase = 'free download page for' -- is a free download page for
	where gid = '34ae77fe-defb-43ea-95d4-63c7540bac78';

-- name: download for free (recording-url)
update link_type set
	link_phrase = 'download for free', -- can be downloaded for free at
	reverse_link_phrase = 'free download page for' -- is a free download page for
	where gid = '45d0cbc5-d65b-4e77-bdfd-8a75207cb5c5';

-- name: download for free (release-url)
update link_type set
	link_phrase = 'download for free', -- can be downloaded for free at
	reverse_link_phrase = 'free download page for' -- is a free download page for
	where gid = '9896ecd0-6d29-482d-a21e-bd5d1b5e3425';

-- name: editor (artist-recording)
update link_type set
	link_phrase = '{additional:additionally} {assistant} {associate} {co:co-}edited', -- {additional:additionally} {assistant} {associate} {co:co-}edited
	reverse_link_phrase = '{additional} {assistant} {associate} {co:co-}editor' -- was {additional:additionally} {assistant} {associate} {co:co-}edited by
	where gid = '40dff87a-e475-4aa6-b615-9935b564d756';

-- name: editor (artist-release)
update link_type set
	link_phrase = '{additional:additionally} {assistant} {associate} {co:co-}edited', -- {additional:additionally} {assistant} {associate} {co:co-}edited
	reverse_link_phrase = '{additional} {assistant} {associate} {co:co-}editor' -- was {additional:additionally} {assistant} {associate} {co:co-}edited by
	where gid = 'f30c29d3-a3f1-420d-9b6c-a750fd6bc2aa';

-- name: engineer (artist-recording)
update link_type set
	link_phrase = '{additional:additionally} {assistant} {associate} {co:co-}{executive:executive }engineered', -- {additional:additionally} {assistant} {associate} {co:co-}{executive:executive }engineered
	reverse_link_phrase = '{additional} {assistant} {associate} {co:co-}{executive:executive }engineer' -- was {additional:additionally} {assistant} {associate} {co:co-}{executive:executive }engineered by
	where gid = '5dcc52af-7064-4051-8d62-7d80f4c3c907';

-- name: engineer (artist-release)
update link_type set
	link_phrase = '{additional:additionally} {assistant} {associate} {co:co-}{executive:executive }engineered', -- {additional:additionally} {assistant} {associate} {co:co-}{executive:executive }engineered
	reverse_link_phrase = '{additional} {assistant} {associate} {co:co-}{executive:executive }engineer' -- was {additional:additionally} {assistant} {associate} {co:co-}{executive:executive }engineered by
	where gid = '87e922ba-872e-418a-9f41-0a63aa3c30cc';

-- name: engineer position (artist-label)
update link_type set
	link_phrase = 'engineer position', -- had an engineer position at
	reverse_link_phrase = 'engineers' -- contracted as an engineer
	where gid = '5f9374d2-a0fa-4958-8a6f-80ca67e4aaa5';

-- name: fanpage (artist-url)
update link_type set
	link_phrase = 'fan pages', -- has a fan page at
	reverse_link_phrase = 'fan page for' -- is the fan page of
	where gid = 'f484f897-81cc-406e-96f9-cd799a04ee24';

-- name: fanpage (label-url)
update link_type set
	link_phrase = 'fan pages', -- has a fan page at
	reverse_link_phrase = 'fan page for' -- is a fan page of
	where gid = '6b91b233-a68c-4854-ba33-3b9ae27f86ae';

-- name: first album release (release-release)
update link_type set
	link_phrase = 'later releases', -- is the earliest release of
	reverse_link_phrase = 'earliest release' -- is a later release of
	where gid = '6e3da545-582b-4d54-a1ac-e519c8d92466';

-- name: first track release (recording-recording)
update link_type set
	link_phrase = 'later releases', -- is the earliest release of
	reverse_link_phrase = 'earliest release' -- is a later release of
	where gid = 'f5f41b82-ecc7-488e-adf3-12356885d724';

-- name: get the music (artist-url)
--update link_type set
--	link_phrase = 'get the music', -- get the music
--	reverse_link_phrase = 'get the music' -- get the music
--	where gid = '919db454-212f-495a-a9bb-f69631729953';

-- name: get the music (recording-url)
--update link_type set
--	link_phrase = 'get the music', -- get the music
--	reverse_link_phrase = 'get the music' -- get the music
--	where gid = '44598c7e-01f9-438b-950a-183720a2cbbe';

-- name: get the music (release-url)
--update link_type set
--	link_phrase = 'get the music', -- get the music
--	reverse_link_phrase = 'get the music' -- get the music
--	where gid = '759935d6-c9c6-4362-8978-2f0d46d67deb';

-- name: graphic design (artist-recording)
update link_type set
	link_phrase = '{additional} graphic design', -- provided {additional} graphic design on
	reverse_link_phrase = '{additional} graphic design' -- has {additional} graphic design by
	where gid = '38751410-ee52-435b-af75-957cb4c34149';

-- name: graphic design (artist-release)
update link_type set
	link_phrase = '{additional} graphic design', -- provided {additional} graphic design on
	reverse_link_phrase = '{additional} graphic design' -- has {additional} graphic design by
	where gid = 'cf43b79e-3299-4b0c-9244-59ea06337107';

-- name: graphic design (recording-url)
update link_type set
	link_phrase = 'graphic design', -- has graphic design by
	reverse_link_phrase = 'graphic design' -- provided graphic design on
	where gid = '120c8c28-55ff-4a8e-81a4-a5e839da82ea';

-- name: history site (label-url)
update link_type set
	link_phrase = 'history page', -- has its history presented at
	reverse_link_phrase = 'history page for' -- presents the history of
	where gid = '5261835c-0c23-4a63-94db-ad3a86bda846';

-- name: ibdb (artist-url)
update link_type set
	link_phrase = 'IBDb', -- has an IBDb page at
	reverse_link_phrase = 'IBDb page for' -- is an IBDb page for
	where gid = '5728c659-56b2-4e23-97d1-80e1f229c7d3';

-- name: ibdb (release_group-url)
update link_type set
	link_phrase = 'IBDb', -- has an IBDb page at
	reverse_link_phrase = 'IBDb page for' -- is the IBDb page for
	where gid = 'a7f96734-716e-48b8-9040-adc5b3256836';

-- name: ibdb (url-work)
update link_type set
	link_phrase = 'IBDb page for', -- is an IBDb page for
	reverse_link_phrase = 'IBDb' -- has an IBDb page at
	where gid = '206cf8e2-0a7c-4c17-b8bb-75722d9b9c6c';

-- name: image (artist-url)
update link_type set
	link_phrase = 'pictures', -- has a picture at
	reverse_link_phrase = 'picture of' -- is a picture of
	where gid = '221132e9-e30e-43f2-a741-15afc4c5fa7c';

-- name: IMDb (artist-url)
update link_type set
	link_phrase = 'IMDb', -- has an IMDb page at
	reverse_link_phrase = 'IMDb page for' -- is an IMDb page for
	where gid = '94c8b0cc-4477-4106-932c-da60e63de61c';

-- name: IMDb (release_group-url)
update link_type set
	link_phrase = 'IMDb', -- has an IMDb page at
	reverse_link_phrase = 'IMDb page for' -- is the IMDb page for
	where gid = '85b0a010-3237-47c7-8476-6fcefd4761af';

-- name: IMDB samples (recording-url)
update link_type set
	link_phrase = 'samples IMDb entry', -- contains samples from the IMDb entry at
	reverse_link_phrase = 'IMDb entry sampled in' -- is an IMDb entry for the work sampled in
	where gid = 'dad34b86-5a1a-4628-acf5-a48ccb0785f2';

-- name: IMDB samples (release-url)
update link_type set
	link_phrase = 'samples IMDb entry', -- contains samples from the IMDb entry at
	reverse_link_phrase = 'IMDb entry sampled in' -- is an IMDb entry for the work sampled in
	where gid = '7387c5a2-9abe-4515-b667-9eb5ed4dd4ce';

-- name: IMDB samples (release_group-url)
update link_type set
	link_phrase = 'samples IMDb entry', -- contains samples from the IMDb entry at
	reverse_link_phrase = 'IMDb entrysampled in' -- is an IMDb entry for the work sampled in
	where gid = '85b0a010-3237-47c7-8476-6fcefd4761af';

-- name: instrument (artist-recording)
update link_type set
	link_phrase = '{additional} {guest} {instrument}', -- performed {additional} {guest} {instrument} on
	reverse_link_phrase = '{additional} {guest} {instrument}' -- has {additional} {guest} {instrument} performed by
	where gid = '59054b12-01ac-43ee-a618-285fd397e461';

-- name: instrument (artist-release)
update link_type set
	link_phrase = '{additional} {guest} {instrument}', -- performed {additional} {guest} {instrument} on
	reverse_link_phrase = '{additional} {guest} {instrument}' -- has {additional} {guest} {instrument} performed by
	where gid = '67555849-61e5-455b-96e3-29733f0115f5';

-- name: instrumental supporting musician (artist-artist)
update link_type set
	link_phrase = 'supporting {instrument} for', -- does/did {instrument} support for
	reverse_link_phrase = 'supporting {instrument} by' -- is/was supported with {instrument} by
	where gid = 'ed6a7891-ce70-4e08-9839-1f2f62270497';

-- name: instrumentator (artist-release)
update link_type set
	link_phrase = '{additional} {instrument} instrumentation', -- provided {additional} {instrument} instrumentation for
	reverse_link_phrase = '{additional} {instrument} instrumentation' -- has {additional} {instrument} instrumentation by
	where gid = '9b6b59d9-6bcc-49d8-9099-6bd843a232f7';

-- name: instrumentator (artist-work)
update link_type set
	link_phrase = '{additional} {instrument} instrumentation', -- provided {additional} {instrument} instrumentation for
	reverse_link_phrase = '{additional} {instrument} instrumentation' -- has {additional} {instrument} instrumentation by
	where gid = 'a787b410-3033-4fdd-8080-791424b8d4a4';

-- name: involved with (artist-artist)
update link_type set
	link_phrase = 'involved with', -- is/was involved with
	reverse_link_phrase = 'involved with ' -- is/was involved with
	where gid = 'fd3927ba-fd51-4fa9-bcc2-e83637896fe8';

-- name: iobdb (artist-url)
update link_type set
	link_phrase = 'IOBDb', -- has an IOBDb page at
	reverse_link_phrase = 'IOBDb page for' -- is an IOBDb page for
	where gid = '689043e3-2b9e-47ba-ad86-2742589e0743';

-- name: iobdb (release_group-url)
update link_type set
	link_phrase = 'IOBDb', -- has an IOBDb page at
	reverse_link_phrase = 'IOBDb page for' -- is the IOBDb page for
	where gid = 'fd87657e-aa2f-44ad-b5d8-d97c0c938a4d';

-- name: iobdb (url-work)
update link_type set
	link_phrase = 'IOBDb page for', -- is an IOBDb page for
	reverse_link_phrase = 'IOBDb' -- has an IOBDb page at
	where gid = '8845d830-fe9b-4ed6-a084-b1a3f193167a';

-- name: is person (artist-artist)
update link_type set
	link_phrase = 'performs as', -- performs as
	reverse_link_phrase = 'legal name' -- is a performance name for the person
	where gid = 'dd9886f2-1dfe-4270-97db-283f6839a666';

-- name: karaoke (recording-recording)
update link_type set
	link_phrase = 'karaoke versions', -- has a karaoke version
	reverse_link_phrase = 'karaoke version of' -- is a karaoke version of
	where gid = '39a08d0e-26e4-44fb-ae19-906f5fe9435d';

-- name: label distribution (label-label)
update link_type set
	link_phrase = 'distributor for', -- is/was distributing the catalog of
	reverse_link_phrase = 'distributors' -- has/had its catalog distributed by
	where gid = 'e0636054-32b7-4dd5-97a9-6e5664d443bc';

-- name: label founder (artist-label)
update link_type set
	link_phrase = 'founded', -- founded
	reverse_link_phrase = 'founders' -- was founded by
	where gid = '577996f3-7ff9-45cf-877e-740fb1267a63';

-- name: label ownership (label-label)
update link_type set
	link_phrase = 'subsidiaries', -- is/was the parent label of
	reverse_link_phrase = 'parent label' -- is/was a subsidiary of
	where gid = 'ab7a9be0-c060-4852-8f2e-4faf5b33231e';

-- name: label reissue (label-label)
update link_type set
	link_phrase = 'reissuing the catalog of', -- is/was reissuing the catalog of
	reverse_link_phrase = 'catalog reissued by' -- has/had its catalog reissued by
	where gid = '1a502d1c-2c30-4efa-8cd7-39af664e3af8';

-- name: label rename (label-label)
update link_type set
	link_phrase = 'renamed into', -- was renamed into
	reverse_link_phrase = 'renamed from' -- is the later name of
	where gid = 'e6159066-6013-4d09-a2f8-bc473f21e89e';

-- name: legal representation (artist-recording)
update link_type set
	link_phrase = 'legal representation', -- provided legal representation for
	reverse_link_phrase = 'legal representation' -- has legal representation by
	where gid = '75e37b65-7b50-4080-bf04-8c59c66b5f65';

-- name: legal representation (artist-release)
update link_type set
	link_phrase = 'legal representation', -- provided legal representation for
	reverse_link_phrase = 'legal representation' -- has legal representation by
	where gid = '1a900189-53ba-442a-9406-49c43ddecb3f';

-- name: legal representation (recording-url)
update link_type set
	link_phrase = 'legal representation', -- has legal representation by
	reverse_link_phrase = 'legal representation for' -- provided legal representation for
	where gid = 'a0547287-5767-48b8-b271-db8504c779c9';

-- name: librettist (artist-release)
update link_type set
	link_phrase = '{additional} {translated:libretto translation|librettist}', -- {additional:additionally} {translated:translated|wrote} the libretto for
	reverse_link_phrase = '{additional} {translated:libretto translation|librettist}' -- libretto was {additional:additionally} {translated:translated|written} by
	where gid = 'dd182715-ca2b-4e4b-80b1-d21742fda0dc';

-- name: librettist (artist-work)
update link_type set
	link_phrase = '{additional} {translated} libretto', -- {additional:additionally} {translated:translated|wrote} the libretto for
	reverse_link_phrase = '{additional} {translated:libretto translation|librettist}' -- libretto was {additional:additionally} {translated:translated|written} by
	where gid = '7474ab81-486f-40b5-8685-3a4f8ea624cb';

-- name: liner notes (artist-recording)
update link_type set
	link_phrase = '{additional} liner notes', -- wrote {additional} liner notes for
	reverse_link_phrase = '{additional} liner notes' -- has {additional} liner notes by
	where gid = 'b64b96e6-7535-4ee8-9840-6ecf43959050';

-- name: liner notes (artist-release)
update link_type set
	link_phrase = '{additional} liner notes', -- wrote {additional} liner notes for
	reverse_link_phrase = '{additional} liner notes' -- has {additional} liner notes by
	where gid = '01323b4f-7aba-410c-8c91-cb224b963a40';

-- name: live performance (release_group-release_group)
update link_type set
	link_phrase = 'live performance of', -- is a live performance of
	reverse_link_phrase = 'live performances' -- was performed live as
	where gid = '62beff0a-679c-43f3-8fe6-f6c8ed8581e4';

-- name: live sound (artist-recording)
update link_type set
	link_phrase = '{additional:additionally} {assistant} {associate} {co:co-}live sound engineered', -- {additional:additionally} {assistant} {associate} {co:co-}live sound engineered
	reverse_link_phrase = '{additional} {assistant} {associate} {co:co-}live sound engineer' -- was {additional:additionally} {assistant} {associate} {co:co-}live sound engineered by
	where gid = '793acda8-6884-4f7e-ace0-87038b76d042';

-- name: live sound (artist-release)
update link_type set
	link_phrase = '{additional:additionally} {assistant} {associate} {co:co-}live sound engineered', -- {additional:additionally} {assistant} {associate} {co:co-}live sound engineered
	reverse_link_phrase = '{additional} {assistant} {associate} {co:co-}live sound engineer' -- was {additional:additionally} {assistant} {associate} {co:co-}live sound engineered by
	where gid = '4eb323ef-0c3e-4cfd-a5c1-db876e9e81e6';

-- name: logo (label-url)
update link_type set
	link_phrase = 'logos', -- has a logo at
	reverse_link_phrase = 'logo of' -- is a logo of
	where gid = 'b35f7822-bf3c-4148-b306-fb723c63ee8b';

-- name: lyricist (artist-release)
update link_type set
	link_phrase = '{additional} {translated} lyrics', -- {additional:additionally} {translated:translated|wrote} the lyrics for
	reverse_link_phrase = '{additional} {translated:translator|lyricist}' -- lyrics were {additional:additionally} {translated:translated|written} by
	where gid = 'a2af367a-b040-46f8-af21-310f92dfe97b';

-- name: lyricist (artist-work)
update link_type set
	link_phrase = '{additional} {translated} lyrics', -- {additional:additionally} {translated:translated|wrote} the lyrics for
	reverse_link_phrase = '{additional} {translated:translator|lyricist}' -- lyrics were {additional:additionally} {translated:translated|written} by
	where gid = '3e48faba-ec01-47fd-8e89-30e81161661c';

-- name: lyrics (artist-url)
update link_type set
	link_phrase = 'lyrics page', -- has lyrics available at
	reverse_link_phrase = 'lyrics page for' -- contains lyrics for
	where gid = 'e4d73442-3762-45a8-905c-401da65544ed';

-- name: lyrics (release-url)
update link_type set
	link_phrase = 'lyrics page', -- has lyrics available at
	reverse_link_phrase = 'lyrics page for' -- contains lyrics for
	where gid = '156344d3-da8b-40c6-8b10-7b1c22727124';

-- name: lyrics (release_group-url)
update link_type set
	link_phrase = 'lyrics page', -- has lyrics available at
	reverse_link_phrase = 'lyrics page for' -- contains lyrics for
	where gid = '156344d3-da8b-40c6-8b10-7b1c22727124';

-- name: lyrics (url-work)
update link_type set
	link_phrase = 'lyrics page for', -- contains lyrics for
	reverse_link_phrase = 'lyrics page' -- has lyrics available at
	where gid = 'e38e65aa-75e0-42ba-ace0-072aeb91a538';

-- name: married (artist-artist)
update link_type set
	link_phrase = 'married', -- is/was married to
	reverse_link_phrase = 'married' -- is/was married to
	where gid = 'b2bf7a5d-2da6-4742-baf4-e38d8a7ad029';

-- name: mashes up (recording-recording)
update link_type set
	link_phrase = 'mash-up of', -- is a mash-up of
	reverse_link_phrase = 'mash-ups' -- has mashed-up version(s)
	where gid = '579d0b4c-bf77-479d-aa59-a8af1f518958';

-- name: mashes up (release_group-release_group)
update link_type set
	link_phrase = 'mash-up of', -- is a mash-up of
	reverse_link_phrase = 'mash-ups' -- has mashed-up version(s)
	where gid = '03786c2a-cd9d-4148-b3ea-35ea61de1283';

-- name: mastering (artist-recording)
update link_type set
	link_phrase = '{additional} {assistant} {associate} {co:co-}mastering', -- {additional:additionally} {assistant} {associate} {co:co-}mastered
	reverse_link_phrase = '{additional} {assistant} {associate} {co:co-}mastering' -- was {additional:additionally} {assistant} {associate} {co:co-}mastered by
	where gid = '30adb2d7-dbcc-4393-9230-2098510ce3c1';

-- name: mastering (artist-release)
update link_type set
	link_phrase = '{additional} {assistant} {associate} {co:co-}mastering', -- {additional:additionally} {assistant} {associate} {co:co-}mastered
	reverse_link_phrase = '{additional} {assistant} {associate} {co:co-}mastering' -- was {additional:additionally} {assistant} {associate} {co:co-}mastered by
	where gid = '84453d28-c3e8-4864-9aae-25aa968bcf9e';

-- name: medley (work-work)
update link_type set
	link_phrase = 'medley of', -- is a medley of
	reverse_link_phrase = 'medleys' -- has been referred to in medley
	where gid = '6f2c3c97-9070-49a4-9b2f-8c961e1a427e';

-- name: member of band (artist-artist)
update link_type set
	link_phrase = '{additional} {founder:founding} member of', -- is/was {additional:an additional|a} member of {founder:and founded|}
	reverse_link_phrase = '{additional} {founder:founding} members' -- has/had {additional} {founder:founding|} member(s)
	where gid = '5be4c609-9afa-4ea0-910b-12ffb71e3821';

-- name: merchandise (artist-recording)
update link_type set
	link_phrase = 'merchandising', -- provided merchandising for
	reverse_link_phrase = 'merchandising' -- has merchandising by
	where gid = '718bff0c-b8c8-408e-b57f-89f2f3116baf';

-- name: merchandise (artist-release)
update link_type set
	link_phrase = 'merchandising', -- provided merchandising for
	reverse_link_phrase = 'merchandising' -- has merchandising by
	where gid = 'f57a3f40-eab1-4568-b9bd-7d5213e03c02';

-- name: merchandise (recording-url)
update link_type set
	link_phrase = 'merchandising', -- has merchandising by
	reverse_link_phrase = 'merchandising' -- provided merchandising on
	where gid = '9fa68bd7-55b7-44df-b4fe-1df621078b34';

-- name: microblog (artist-url)
update link_type set
	link_phrase = 'microblogs', -- has a microblog at
	reverse_link_phrase = 'microblog for' -- is a microblog for
	where gid = '9309af3a-ebb6-4960-aebb-d286bd3ed1c7';

-- name: microblog (label-url)
update link_type set
	link_phrase = 'microblogs', -- has a microblog at
	reverse_link_phrase = 'microblog for' -- is a microblog for
	where gid = '155de495-b920-4c52-97b1-6919355830ec';

-- name: misc (artist-recording)
update link_type set
	link_phrase = 'miscellaneous roles', -- has a miscellaneous role on
	reverse_link_phrase = 'miscellaneous support' -- contains miscellaneous support from
	where gid = '68330a36-44cf-4fa2-84e8-533c6fe3fc23';

-- name: misc (artist-release)
update link_type set
	link_phrase = 'miscellaneous roles', -- has a miscellaneous role on
	reverse_link_phrase = 'miscellaneous support' -- contains miscellaneous support from
	where gid = '0b63af5e-85b2-4891-8234-bddab251399d';

-- name: misc (artist-work)
update link_type set
	link_phrase = 'miscellaneous roles', -- has a miscellaneous role on
	reverse_link_phrase = 'miscellaneous support' -- contains miscellaneous support from
	where gid = '7d166271-99c7-3a13-ae96-d2aab758029d';

-- name: misc (recording-url)
update link_type set
	link_phrase = 'miscellaneous support', -- contains miscellaneous support from
	reverse_link_phrase = 'miscellaneous roles' -- has a miscellaneous role on
	where gid = 'a66bd6d4-c10e-44ae-a78e-4ffc4bd9fcb1';

-- name: misc (url-work)
update link_type set
	link_phrase = 'miscellaneous roles', -- has a miscellaneous role on
	reverse_link_phrase = 'miscellaneous support' -- contains miscellaneous support from
	where gid = '00687ce8-17e1-3343-b6e5-0a91b919fe24';

-- name: mix (artist-recording)
update link_type set
	link_phrase = '{additional:additionally} {assistant} {associate} {co:co-}mixed', -- {additional:additionally} {assistant} {associate} {co:co-}mixed
	reverse_link_phrase = '{additional} {assistant} {associate} {co:co-}mixer' -- was {additional:additionally} {assistant} {associate} {co:co-}mixed by
	where gid = '3e3102e1-1896-4f50-b5b2-dd9824e46efe';

-- name: mix (artist-release)
update link_type set
	link_phrase = '{additional:additionally} {assistant} {associate} {co:co-}mixed', -- {additional:additionally} {assistant} {associate} {co:co-}mixed
	reverse_link_phrase = '{additional} {assistant} {associate} {co:co-}mixer' -- was {additional:additionally} {assistant} {associate} {co:co-}mixed by
	where gid = '6cc958c0-533b-4540-a281-058fbb941890';

-- name: mix-DJ (artist-recording)
update link_type set
	link_phrase = 'DJ-mixed', -- DJ-mixed
	reverse_link_phrase = 'DJ-mixer' -- was DJ-mixed by
	where gid = '28338ee6-d578-485a-bb53-61dbfd7c6545';

-- name: mix-DJ (artist-release)
update link_type set
	link_phrase = 'DJ-mixed {medium}', -- DJ-mixed
	reverse_link_phrase = 'DJ-mixer {medium}' -- was DJ-mixed by
	where gid = '9162dedd-790c-446c-838e-240f877dbfe2';

-- name: musical relationships (artist-artist)
--update link_type set
--	link_phrase = 'musical relationship', -- musical relationship
--	reverse_link_phrase = 'musical relationship' -- musical relationship
--	where gid = '92859e2a-f2e5-45fa-a680-3f62ba0beccc';

-- name: musicmoz (artist-url)
update link_type set
	link_phrase = 'MusicMoz', -- has a MusicMoz page at
	reverse_link_phrase = 'MusicMoz page for' -- is a MusicMoz page for
	where gid = 'ded9a80a-e6de-4831-880c-c78b9981b54b';

-- name: musicmoz (release-url)
update link_type set
	link_phrase = 'MusicMoz', -- has a MusicMoz page at
	reverse_link_phrase = 'MusicMoz page for' -- is a MusicMoz page for
	where gid = 'd111c58d-0d9b-4675-99c1-ddc5a8e01847';

-- name: myspace (artist-url)
update link_type set
	link_phrase = 'MySpace', -- has a MySpace page at
	reverse_link_phrase = 'MySpace page for' -- is a MySpace page for
	where gid = 'bac47923-ecde-4b59-822e-d08f0cd10156';

-- name: myspace (label-url)
update link_type set
	link_phrase = 'MySpace', -- has a MySpace page at
	reverse_link_phrase = 'MySpace page for' -- is a MySpace page for
	where gid = '240ba9dc-9898-4505-9bf7-32a53a695612';

-- name: official homepage (artist-url)
update link_type set
	link_phrase = 'official homepages', -- has an official homepage at
	reverse_link_phrase = 'official homepage for' -- is an official homepage of
	where gid = 'fe33d22f-c3b0-4d68-bd53-a856badf2b15';

-- name: official site (label-url)
update link_type set
	link_phrase = 'official homepages', -- has an official homepage at
	reverse_link_phrase = 'official homepage for' -- is an official homepage of
	where gid = 'fe108f43-acb9-4ad1-8be3-57e6ec5b17b6';

-- name: online community (artist-url)
update link_type set
	link_phrase = 'online communities', -- has an online community page at
	reverse_link_phrase = 'online community page for' -- is an online community page for
	where gid = '35b3a50f-bf0e-4309-a3b4-58eeed8cee6a';

-- name: online data (label-url)
--update link_type set
--	link_phrase = 'online data', -- online data
--	reverse_link_phrase = 'online data' -- online data
--	where gid = '5f82afae-0473-458d-9f17-8a2fa1ce7918';

-- name: orchestrator (artist-release)
update link_type set
	link_phrase = '{additional:additionally} orchestrated', -- {additional:additionally} orchestrated
	reverse_link_phrase = '{additional:additionally} orchestrator' -- was {additional:additionally} orchestrated by
	where gid = '04e1f0b6-ef40-4168-ba25-42a87729fe09';

-- name: orchestrator (artist-work)
update link_type set
	link_phrase = '{additional:additionally} orchestrated', -- {additional:additionally} orchestrated
	reverse_link_phrase = '{additional} orchestrator' -- was {additional:additionally} orchestrated by
	where gid = '0a1771e1-8639-4740-8a43-bdafc050c3da';

-- name: other databases (artist-url)
--update link_type set
--	link_phrase = 'other databases', -- other databases
--	reverse_link_phrase = 'other databases' -- other databases
--	where gid = 'd94fb61c-fa20-4e3c-a19a-71a949fb2c55';

-- name: other databases (label-url)
--update link_type set
--	link_phrase = 'other databases', -- other databases
--	reverse_link_phrase = 'other databases' -- other databases
--	where gid = '83eca2b3-5ae1-43f5-a732-56fa9a8591b1';

-- name: other databases (release-url)
--update link_type set
--	link_phrase = 'other databases', -- other databases
--	reverse_link_phrase = 'other databases' -- other databases
--	where gid = 'c74dee45-3c85-41e9-a804-92ab1c654446';

-- name: other databases (release_group-url)
--update link_type set
--	link_phrase = 'other databases', -- other databases
--	reverse_link_phrase = 'other databases' -- other databases
--	where gid = '900072a2-ceec-369f-8cf5-2a9569a83f0c';

-- name: other databases (url-work)
--update link_type set
--	link_phrase = 'other databases', -- other databases
--	reverse_link_phrase = 'other databases' -- other databases
--	where gid = '190ea031-4355-405d-a43e-53eb4c5c4ada';

-- name: other version (work-work)
update link_type set
	link_phrase = 'later {translated} {parody} versions', -- is the earliest version of
	reverse_link_phrase = 'original {translated} {parody} version' -- is a later version of
	where gid = '7440b539-19ab-4243-8c03-4f5942ca2218';

-- name: parent (artist-artist)
update link_type set
	link_phrase = 'children', -- is the parent of
	reverse_link_phrase = 'parents' -- is the child of
	where gid = '9421ca84-934f-49fe-9e66-dea242430406';

-- name: part of set (release-release)
update link_type set
	link_phrase = '{bonus:bonus|next} disc', -- {bonus:may be|is} part of a set, the next disc in the set is
	reverse_link_phrase = 'previous disc' -- is part of a set, the previous disc in the set is
	where gid = '6d08ec1e-a292-4dac-90f3-c398a39defd5';

-- name: performance (recording-work)
update link_type set
	link_phrase = '{translated} {cover} performance of', -- is a performance of
	reverse_link_phrase = '{translated} {cover} performances' -- has performance
	where gid = 'a3005666-a872-32c3-ad06-98af558e99b0';

-- name: performance (artist-recording)
--update link_type set
--	link_phrase = 'performance', -- performance
--	reverse_link_phrase = 'performance' -- performance
--	where gid = 'f8673e29-02a5-47b7-af61-dd4519328dd0';

-- name: performance (artist-release)
--update link_type set
--	link_phrase = 'performance', -- performance
--	reverse_link_phrase = 'performance' -- performance
--	where gid = '8db9d0b7-ca39-43a6-8c72-9a47f811229e';

-- name: performer (artist-recording)
update link_type set
	link_phrase = '{additional:additionally} {guest} performed', -- {additional:additionally} {guest} performed
	reverse_link_phrase = '{additional} {guest} performer' -- was {additional:additionally} {guest} performed by
	where gid = '628a9658-f54c-4142-b0c0-95f031b544da';

-- name: performer (artist-release)
update link_type set
	link_phrase = '{additional:additionally} {guest} performed', -- {additional:additionally} {guest} performed
	reverse_link_phrase = '{additional} {guest} performer' -- was {additional:additionally} {guest} performed by
	where gid = '888a2320-52e4-4fe8-a8a0-7a4c8dfde167';

-- name: performing orchestra (artist-recording)
update link_type set
	link_phrase = '{additional} {orchestra} orchestra', -- {orchestra} orchestra {additional:additionally} performed
	reverse_link_phrase = '{additional} {orchestra} orchestra' -- was {additional:additionally} performed by {orchestra} orchestra
	where gid = '3b6616c5-88ba-4341-b4ee-81ce1e6d7ebb';

-- name: performing orchestra (artist-release)
update link_type set
	link_phrase = '{additional} {orchestra} orchestra', -- {orchestra} orchestra {additional:additionally} performed
	reverse_link_phrase = '{additional} {orchestra} orchestra' -- was {additional:additionally} performed by {orchestra} orchestra
	where gid = '23a2e2e7-81ca-4865-8d05-2243848a77bf';

-- name: personal relationship (artist-artist)
--update link_type set
--	link_phrase = 'personal relationship', -- personal relationship
--	reverse_link_phrase = 'personal relationship' -- personal relationship
--	where gid = 'e794f8ff-b77b-4dfe-86ca-83197146ef10';

-- name: photography (artist-recording)
update link_type set
	link_phrase = '{additional} photography', -- provided {additional} photography on
	reverse_link_phrase = '{additional} photography' -- has {additional} photography by
	where gid = 'a7e408a1-8c64-4122-9ec2-906068955187';

-- name: photography (artist-release)
update link_type set
	link_phrase = '{additional} photography', -- provided {additional} photography on
	reverse_link_phrase = '{additional} photography' -- has {additional} photography by
	where gid = '0b58dc9b-9c49-4b19-bb58-9c06d41c8fbf';

-- name: photography (recording-url)
update link_type set
	link_phrase = '{additional} photography', -- has {additional} photography by
	reverse_link_phrase = '{additional} photography' -- provided {additional} photography on
	where gid = 'ac6513a0-03dd-45b0-810e-f8ea2d42ee97';

-- name: producer (artist-recording)
update link_type set
	link_phrase = '{additional:additionally} {assistant} {associate} {co:co-}{executive:executive }produced', -- {additional:additionally} {assistant} {associate} {co:co-}{executive:executive }produced
	reverse_link_phrase = '{additional} {assistant} {associate} {co:co-}{executive:executive }producer' -- was {additional:additionally} {assistant} {associate} {co:co-}{executive:executive }produced by
	where gid = '5c0ceac3-feb4-41f0-868d-dc06f6e27fc0';

-- name: producer (artist-release)
update link_type set
	link_phrase = '{additional:additionally} {assistant} {associate} {co:co-}{executive:executive }produced', -- {additional:additionally} {assistant} {associate} {co:co-}{executive:executive }produced
	reverse_link_phrase = '{additional} {assistant} {associate} {co:co-}{executive:executive }producer' -- was {additional:additionally} {assistant} {associate} {co:co-}{executive:executive }produced by
	where gid = '8bf377ba-8d71-4ecc-97f2-7bb2d8a2a75f';

-- name: producer position (artist-label)
update link_type set
	link_phrase = 'producer position', -- had a producer position at
	reverse_link_phrase = 'producers' -- contracted as a producer
	where gid = '46981330-d73c-4ba5-845f-47f467072cf8';

-- name: production (release-url)
--update link_type set
--	link_phrase = 'production', -- production
--	reverse_link_phrase = 'production' -- production
--	where gid = 'ee1c7888-99c7-4c22-aaee-6a34a907fa24';

-- name: production (release_group-url)
--update link_type set
--	link_phrase = 'production', -- production
--	reverse_link_phrase = 'production' -- production
--	where gid = 'db2a914f-ef72-35eb-a1d7-01c71995e606';

-- name: production (artist-recording)
--update link_type set
--	link_phrase = 'production', -- production
--	reverse_link_phrase = 'production' -- production
--	where gid = 'b367fae0-c4b0-48b9-a40c-f3ae4c02cffc';

-- name: production (artist-release)
--update link_type set
--	link_phrase = 'production', -- production
--	reverse_link_phrase = 'production' -- production
--	where gid = '3172a175-7c9d-44ce-a8b7-9a9187b33762';

-- name: production (recording-url)
--update link_type set
--	link_phrase = 'production', -- production
--	reverse_link_phrase = 'production' -- production
--	where gid = 'c0b9cc44-ea3b-4312-94f9-577c2605d305';

-- name: programming (artist-recording)
update link_type set
	link_phrase = '{additional} {assistant} {associate} {instrument} programming', -- {additional:additionally} {assistant} {associate} programmed {instrument:% on}
	reverse_link_phrase = '{additional} {assistant} {associate} {instrument} programming' -- {instrument:has %|was} {additional:additionally} {assistant} {associate} programmed by
	where gid = '36c50022-44e0-488d-994b-33f11d20301e';

-- name: programming (artist-release)
update link_type set
	link_phrase = '{additional} {assistant} {associate} {instrument} programming', -- {additional:additionally} {assistant} {associate} programmed {instrument:% on}
	reverse_link_phrase = '{additional} {assistant} {associate} {instrument} programming' -- {instrument:has %|was} {additional:additionally} {assistant} {associate} programmed by
	where gid = '617063ad-dbb5-4877-9ba0-ba2b9198d5a7';

-- name: publishing (artist-recording)
update link_type set
	link_phrase = 'published', -- published
	reverse_link_phrase = 'publisher' -- was published by
	where gid = '9ef2ba0d-953c-43a9-b1b5-cf2ba5986406';

-- name: publishing (artist-release)
update link_type set
	link_phrase = 'published', -- published
	reverse_link_phrase = 'publisher' -- was published by
	where gid = '7a573a01-8815-44db-8e30-693faa83fbfa';

-- name: publishing (artist-work)
update link_type set
	link_phrase = 'published', -- published
	reverse_link_phrase = 'publisher' -- was published by
	where gid = 'a442b140-830b-30b0-a4aa-2e36f098b6aa';

-- name: publishing (label-recording)
update link_type set
	link_phrase = 'published', -- published
	reverse_link_phrase = 'publisher' -- was published by
	where gid = '51e4a303-8215-4db6-9a9f-ebe95442dbef';

-- name: publishing (label-release)
update link_type set
	link_phrase = 'published', -- published
	reverse_link_phrase = 'publisher' -- was published by
	where gid = 'cee6eeeb-14f5-4079-9789-632b46acfd33';

-- name: publishing (label-work)
update link_type set
	link_phrase = 'published', -- published
	reverse_link_phrase = 'publisher' -- was published by
	where gid = '05ee6f18-4517-342d-afdf-5897f64276e3';

-- name: publishing (recording-url)
update link_type set
	link_phrase = 'publisher', -- was published by
	reverse_link_phrase = 'published' -- published
	where gid = '572adb66-5b64-4e1d-a893-270c15e39e07';

-- name: publishing (url-work)
update link_type set
	link_phrase = 'published', -- published
	reverse_link_phrase = 'publisher' -- was published by
	where gid = 'f600f326-5105-383b-aaf3-8e96c4163d9f';

-- name: purchase for download (artist-url)
update link_type set
	link_phrase = 'purchase music for download', -- music can be purchased for download at
	reverse_link_phrase = 'download purchase page for' -- is a download purchase page for
	where gid = 'f8319a2f-f824-4617-81c8-be6560b3b203';

-- name: purchase for download (recording-url)
update link_type set
	link_phrase = 'purchase for download', -- can be purchased for download at
	reverse_link_phrase = 'download purchase page for' -- is a download purchase page for
	where gid = '92777657-504c-4acb-bd33-51a201bd57e1';

-- name: purchase for download (release-url)
update link_type set
	link_phrase = 'purchase for download', -- can be purchased for download at
	reverse_link_phrase = 'download purchase page for' -- is a download purchase page for
	where gid = '98e08c20-8402-4163-8970-53504bb6a1e4';

-- name: purchase for mail-order (artist-url)
update link_type set
	link_phrase = 'purchase music for mail-order', -- music can be purchased for mail-order at
	reverse_link_phrase = 'mail-order purchase page for' -- is a mail-order purchase page for
	where gid = '611b1862-67af-4253-a64f-34adba305d1d';

-- name: purchase for mail-order (release-url)
update link_type set
	link_phrase = 'purchase for mail-order', -- can be purchased for mail-order at
	reverse_link_phrase = 'mail-order purchase page for' -- is a mail-order purchase page for
	where gid = '3ee51e05-a06a-415e-b40c-b3f740dedfd7';

-- name: purevolume (artist-url)
update link_type set
	link_phrase = 'PureVolume', -- has a PureVolume page at
	reverse_link_phrase = 'PureVolume page for' -- is a PureVolume page for
	where gid = 'b6f02157-a9d3-4f24-9057-0675b2dbc581';

-- name: recording (artist-recording)
update link_type set
	link_phrase = '{additional:additionally} {assistant} {associate} {co:co-}recorded', -- {additional:additionally} {assistant} {associate} {co:co-}recorded
	reverse_link_phrase = '{additional:additionally} {assistant} {associate} {co:co-}recorded by' -- was {additional:additionally} {assistant} {associate} {co:co-}recorded by
	where gid = 'a01ee869-80a8-45ef-9447-c59e91aa7926';

-- name: recording (artist-release)
update link_type set
	link_phrase = '{additional:additionally} {assistant} {associate} {co:co-}recorded', -- {additional:additionally} {assistant} {associate} {co:co-}recorded
	reverse_link_phrase = '{additional:additionally} {assistant} {associate} {co:co-}recorded by' -- was {additional:additionally} {assistant} {associate} {co:co-}recorded by
	where gid = '023a6c6d-80af-4f88-ae69-f5f6213f9bf4';

-- name: recording contract (artist-label)
update link_type set
	link_phrase = 'signed by', -- had a recording contract with
	reverse_link_phrase = 'signed' -- signed
	where gid = 'b336d682-592f-4486-9f45-3d5d59895bdc';

-- name: recording studio (recording-url)
update link_type set
	link_phrase = 'recording studio', -- was recorded by studio at
	reverse_link_phrase = 'recording studio' -- studio recorded
	where gid = 'cae89823-7279-454d-a31c-f4696279d598';

-- name: recording studio (release-url)
update link_type set
	link_phrase = 'recording studio', -- was recorded by studio at
	reverse_link_phrase = 'recording studio' -- studio recorded
	where gid = 'b17e54df-dcff-4ce3-9ab6-83f4bc0ec50b';

-- name: recording studio (release_group-url)
update link_type set
	link_phrase = 'recording studio', -- was recorded by studio at
	reverse_link_phrase = 'recording studio' -- studio recorded
	where gid = 'b17e54df-dcff-4ce3-9ab6-83f4bc0ec50b';

-- name: remaster (recording-recording)
update link_type set
	link_phrase = 'remaster of', -- is a remaster of
	reverse_link_phrase = 'remasters' -- has remastered version(s)
	where gid = 'b984b8d1-76f9-43d7-aa3e-0b3a46999dea';

-- name: remaster (release-release)
update link_type set
	link_phrase = 'remaster of', -- is a remaster of
	reverse_link_phrase = 'remastered versions' -- has remastered version(s)
	where gid = '48e327b5-2d04-4518-93f1-fed5f0f0fa3c';

-- name: remix (recording-recording)
update link_type set
	link_phrase = 'remix of', -- is a remix of
	reverse_link_phrase = 'remixes' -- has remixed version(s)
	where gid = 'bfbdb55a-b857-473a-8f2e-a9c09e45c3f5';

-- name: remix (release_group-release_group)
update link_type set
	link_phrase = 'remix of', -- is a remix of
	reverse_link_phrase = 'remixes' -- has remixed version(s)
	where gid = '04e0449b-6fb0-48f6-8b9d-0bd41d9b8d76';

-- name: remixer (artist-recording)
update link_type set
	link_phrase = '{additional:additionally} remixed', -- {additional:additionally} remixed
	reverse_link_phrase = '{additional} remixer' -- was {additional:additionally} remixed by
	where gid = '7950be4d-13a3-48e7-906b-5af562e39544';

-- name: remixer (artist-release)
update link_type set
	link_phrase = '{additional:additionally} remixed', -- {additional:additionally} remixed
	reverse_link_phrase = '{additional} remixer' -- was {additional:additionally} remixed by
	where gid = 'ac6a86db-f757-4815-a07e-744428d2382b';

-- name: remixes (artist-recording)
--update link_type set
--	link_phrase = 'remixes', -- remixes
--	reverse_link_phrase = 'remixes' -- remixes
--	where gid = '91109adb-a5a3-47b1-99bf-06f88130e875';

-- name: remixes (artist-release)
--update link_type set
--	link_phrase = 'remixes', -- remixes
--	reverse_link_phrase = 'remixes' -- remixes
--	where gid = 'd6b8f1d2-5431-4c97-9688-44f73213ee5b';

-- name: remixes (recording-recording)
--update link_type set
--	link_phrase = 'remixes', -- remixes
--	reverse_link_phrase = 'remixes' -- remixes
--	where gid = '1baddd63-4539-4d49-ae43-600df9ef4647';

-- name: remixes (release_group-release_group)
--update link_type set
--	link_phrase = 'remixes', -- remixes
--	reverse_link_phrase = 'remixes' -- remixes
--	where gid = '3494ba38-4ac5-40b6-aa6f-4ac7546cd104';

-- name: review (release_group-url)
update link_type set
	link_phrase = 'reviews', -- has a review page at
	reverse_link_phrase = 'review page for' -- is the review page of
	where gid = 'c3ac9c3b-f546-4d15-873f-b294d2c1b708';

-- name: ROOT (artist-artist)
--update link_type set
--	link_phrase = '', -- 
--	reverse_link_phrase = '' -- 
--	where gid = 'b6043d7c-0b5e-472b-a545-3ac2d3038d2e';

-- name: ROOT (artist-label)
--update link_type set
--	link_phrase = '', -- 
--	reverse_link_phrase = '' -- 
--	where gid = 'cbf2d60c-64ca-45f2-a206-da99512932a2';

-- name: ROOT (artist-recording)
--update link_type set
--	link_phrase = '', -- 
--	reverse_link_phrase = '' -- 
--	where gid = 'f9da614a-e744-4e77-9d5a-e84dda3ffc52';

-- name: ROOT (artist-release)
--update link_type set
--	link_phrase = '', -- 
--	reverse_link_phrase = '' -- 
--	where gid = 'd4fd8c97-871d-4d01-90b8-0dddda13c49b';

-- name: ROOT (artist-release_group)
--update link_type set
--	link_phrase = '', -- 
--	reverse_link_phrase = '' -- 
--	where gid = '12546d25-0a44-3264-bdd8-7e0b277518f8';

-- name: ROOT (artist-url)
--update link_type set
--	link_phrase = '', -- 
--	reverse_link_phrase = '' -- 
--	where gid = 'bb346bfa-afe9-4341-a36f-44b5d6180445';

-- name: ROOT (artist-work)
--update link_type set
--	link_phrase = '', -- 
--	reverse_link_phrase = '' -- 
--	where gid = 'e68e310b-d33b-3dd0-b798-7f213cb7a7ae';

-- name: ROOT (label-label)
--update link_type set
--	link_phrase = '', -- 
--	reverse_link_phrase = '' -- 
--	where gid = 'ad251f0f-7e68-43a5-a075-c0c42cc5d229';

-- name: ROOT (label-recording)
--update link_type set
--	link_phrase = '', -- 
--	reverse_link_phrase = '' -- 
--	where gid = '2f08f452-f896-4279-b7dc-8915226f22c9';

-- name: ROOT (label-release)
--update link_type set
--	link_phrase = '', -- 
--	reverse_link_phrase = '' -- 
--	where gid = '192bdbfc-e4d0-4fa7-8f0d-3f4c77ab62e3';

-- name: ROOT (label-release_group)
--update link_type set
--	link_phrase = '', -- 
--	reverse_link_phrase = '' -- 
--	where gid = 'bff7066f-0115-37b8-91da-b7e2c318f944';

-- name: ROOT (label-url)
--update link_type set
--	link_phrase = '', -- 
--	reverse_link_phrase = '' -- 
--	where gid = '57d50c02-bf69-4fe7-8823-71f86646c9af';

-- name: ROOT (label-work)
--update link_type set
--	link_phrase = '', -- 
--	reverse_link_phrase = '' -- 
--	where gid = '67182131-8c69-3a1d-b69e-b8cbb221cbed';

-- name: ROOT (recording-recording)
--update link_type set
--	link_phrase = '', -- 
--	reverse_link_phrase = '' -- 
--	where gid = '8acab541-f813-4465-9b00-4e0e2bdd1ea9';

-- name: ROOT (recording-release)
--update link_type set
--	link_phrase = '', -- 
--	reverse_link_phrase = '' -- 
--	where gid = '52294c8f-2c1c-4178-b6d2-e1ba9e93eecc';

-- name: ROOT (recording-release_group)
--update link_type set
--	link_phrase = '', -- 
--	reverse_link_phrase = '' -- 
--	where gid = '3688eabd-bfdb-309a-8352-0b697f0b8a9d';

-- name: ROOT (recording-url)
--update link_type set
--	link_phrase = '', -- 
--	reverse_link_phrase = '' -- 
--	where gid = '71db9ab5-4092-4fa4-a1c5-65036f1da819';

-- name: ROOT (recording-work)
--update link_type set
--	link_phrase = '', -- 
--	reverse_link_phrase = '' -- 
--	where gid = '22c88473-0051-352b-90c9-4edfa3c49ecf';

-- name: ROOT (release-release)
--update link_type set
--	link_phrase = '', -- 
--	reverse_link_phrase = '' -- 
--	where gid = '9ea36219-8ac0-4aa7-9a70-f64492f907bf';

-- name: ROOT (release-url)
--update link_type set
--	link_phrase = '', -- 
--	reverse_link_phrase = '' -- 
--	where gid = 'dec8218f-2230-4da2-a848-29f89f2b201c';

-- name: ROOT (release_group-release_group)
--update link_type set
--	link_phrase = '', -- 
--	reverse_link_phrase = '' -- 
--	where gid = 'eb2de0c9-f5ef-3bfe-9669-398cb6d58e0d';

-- name: ROOT (release_group-url)
--update link_type set
--	link_phrase = '', -- 
--	reverse_link_phrase = '' -- 
--	where gid = '9a7453fa-76e2-3069-b5b5-e9c631c2ce20';

-- name: ROOT (url-url)
--update link_type set
--	link_phrase = '', -- 
--	reverse_link_phrase = '' -- 
--	where gid = '44105fe2-dc72-44b1-89ee-4c1e9746e3d9';

-- name: ROOT (url-work)
--update link_type set
--	link_phrase = '', -- 
--	reverse_link_phrase = '' -- 
--	where gid = '475b575d-3cd8-32b1-8255-1231762e5a69';

-- name: ROOT (work-work)
--update link_type set
--	link_phrase = '', -- 
--	reverse_link_phrase = '' -- 
--	where gid = '960dc96c-0d03-3b23-98c2-b7425f864d9a';

-- name: samples from artist (artist-recording)
--update link_type set
--	link_phrase = 'produced {instrument} material that was {additional:additionally} sampled in', -- produced {instrument} material that was {additional:additionally} sampled in
--	reverse_link_phrase = 'contains {additional} {instrument} samples by' -- contains {additional} {instrument} samples by
--	where gid = '83f72956-2007-4bca-8a97-0ae539cca99d';

-- name: samples from artist (artist-release)
--update link_type set
--	link_phrase = 'produced material that was {additional:additionally} sampled in', -- produced material that was {additional:additionally} sampled in
--	reverse_link_phrase = 'contains {additional} samples by' -- contains {additional} samples by
--	where gid = '7ddb04ae-6c8a-41bd-95c2-392994d663db';

-- name: samples material (recording-recording)
update link_type set
	link_phrase = '{additional} samples', -- contains {additional} samples from
	reverse_link_phrase = '{additional:additionally} sampled by' -- provides {additional} samples for
	where gid = '9efd9ce9-e702-448b-8e76-641515e8fe62';

-- name: samples material (recording-release)
update link_type set
	link_phrase = '{additional} {instrument} samples from', -- has/had {additional} {instrument} samples taken from
	reverse_link_phrase = '{additional:additionally} {instrument} sampled by' -- provides {additional} {instrument} samples for
	where gid = '967746f9-9d79-456c-9d1e-50116f0b27fc';

-- name: score (release-url)
update link_type set
	link_phrase = 'score', -- has a score available at
	reverse_link_phrase = 'score for' -- contains the score for
	where gid = '89e70668-d56d-4888-9778-d43a3deb6944';

-- name: score (release_group-url)
update link_type set
	link_phrase = 'score', -- has a score available at
	reverse_link_phrase = 'score for' -- contains the score for
	where gid = '89e70668-d56d-4888-9778-d43a3deb6944';

-- name: score (url-work)
update link_type set
	link_phrase = 'score for', -- contains the score for
	reverse_link_phrase = 'score' -- has a score available at
	where gid = '0cc8527e-ea40-40dd-b144-3b7588e759bf';

-- name: sibling (artist-artist)
update link_type set
	link_phrase = 'siblings', -- has sibling(s)
	reverse_link_phrase = 'siblings' -- has sibling(s)
	where gid = 'b42b7966-b904-449e-b8f9-8c7297b863d0';

-- name: social network (artist-url)
update link_type set
	link_phrase = 'social networking', -- has a social networking page at
	reverse_link_phrase = 'social networking page for' -- is a social networking page for
	where gid = '99429741-f3f6-484b-84f8-23af51991770';

-- name: social network (label-url)
update link_type set
	link_phrase = 'social networking', -- has a social networking page at
	reverse_link_phrase = 'social networking page for' -- is a social networking page for
	where gid = '5d217d99-bc05-4a76-836d-c91eec4ba818';

-- name: sound (artist-recording)
update link_type set
	link_phrase = '{additional:additionally} {assistant} {associate} {co:co-}sound engineered', -- {additional:additionally} {assistant} {associate} {co:co-}sound engineered
	reverse_link_phrase = '{additional} {assistant} {associate} {co:co-}sound engineer' -- was {additional:additionally} {assistant} {associate} {co:co-}sound engineered by
	where gid = '0cd6aa63-c297-42ed-8725-c16d31913a98';

-- name: sound (artist-release)
update link_type set
	link_phrase = '{additional:additionally} {assistant} {associate} {co:co-}sound engineered', -- {additional:additionally} {assistant} {associate} {co:co-}sound engineered
	reverse_link_phrase = '{additional} {assistant} {associate} {co:co-}sound engineer' -- was {additional:additionally} {assistant} {associate} {co:co-}sound engineered by
	where gid = '271306ca-c77f-4fe0-94bc-dd4b87ae0205';

-- name: streaming music (artist-url)
update link_type set
	link_phrase = 'stream for free', -- music can be streamed for free at
	reverse_link_phrase = 'free music streaming page for' -- is a free music streaming page for
	where gid = '769085a1-c2f7-4c24-a532-2375a77693bd';

-- name: streaming music (recording-url)
update link_type set
	link_phrase = 'stream for free', -- can be streamed for free at
	reverse_link_phrase = 'free music streaming page for' -- is a free music streaming page for
	where gid = '7e41ef12-a124-4324-afdb-fdbae687a89c';

-- name: streaming music (release-url)
update link_type set
	link_phrase = 'stream for free', -- can be streamed for free at
	reverse_link_phrase = 'free music streaming page for' -- is a free music streaming page for
	where gid = '08445ccf-7b99-4438-9f9a-fb9ac18099ee';

-- name: streaming music (url-work)
update link_type set
	link_phrase = 'free music streaming page for', -- is a free music streaming page for
	reverse_link_phrase = 'stream for free' -- can be streamed for free at
	where gid = 'b365ddcf-0663-3dfd-bf09-385234813bd2';

-- name: supporting musician (artist-artist)
update link_type set
	link_phrase = 'supporting artist for', -- is/was a supporting artist for
	reverse_link_phrase = 'supporting artists' -- has/had supporting artist(s)
	where gid = '88562a60-2550-48f0-8e8e-f54d95c7369a';

-- name: transl-tracklisting (release-release)
update link_type set
	link_phrase = 'transl{transliterated:iter}ated track listings', -- is the original for the transl{transliterated:iter}ated track listing
	reverse_link_phrase = 'transl{transliterated:iter}ated track listing of' -- is a transl{transliterated:iter}ated track listing of
	where gid = 'fc399d47-23a7-4c28-bfcf-0607a562b644';

-- name: travel (artist-recording)
update link_type set
	link_phrase = 'travel arrangements for', -- provided travel arrangements for
	reverse_link_phrase = 'travel arrangements' -- has travel arrangements by
	where gid = '88d40706-0734-48e4-b9da-381f3adab058';

-- name: travel (artist-release)
update link_type set
	link_phrase = 'travel arrangements for', -- provided travel arrangements for
	reverse_link_phrase = 'travel arrangements' -- had travel arrangements by
	where gid = 'c2387b75-1811-4e33-83a5-3f70cdd21f1c';

-- name: travel (recording-url)
update link_type set
	link_phrase = 'travel arrangements', -- has travel arrangement by
	reverse_link_phrase = 'travel arrangements for' -- provided travel arrangement on
	where gid = 'cd774c8e-cf20-4a2d-92b1-50feef88069d';

-- name: tribute (artist-release_group)
update link_type set
	link_phrase = 'tribute albums', -- has tribute album(s)
	reverse_link_phrase = 'tribute to' -- is a tribute to
	where gid = '5e2907db-49ec-4a48-9f11-dfb99d2603ff';

-- name: vgmdb (artist-url)
update link_type set
	link_phrase = 'VGMdb', -- has a VGMdb page at
	reverse_link_phrase = 'VGMdb page for' -- has a VGMdb page at
	where gid = '0af15ab3-c615-46d6-b95b-a5fcd2a92ed9';

-- name: vgmdb (label-url)
update link_type set
	link_phrase = 'VGMdb', -- has a VGMdb page at
	reverse_link_phrase = 'VGMdb page for' -- is a VGMdb page for
	where gid = '8a2d3e55-d291-4b99-87a0-c59c6b121762';

-- name: vgmdb (release-url)
update link_type set
	link_phrase = 'VGMdb', -- has a VGMdb page at
	reverse_link_phrase = 'VGMdb page for' -- has a VGMdb page at
	where gid = '6af0134a-df6a-425a-96e2-895f9cd342ba';

-- name: vocal (artist-recording)
update link_type set
	link_phrase = '{additional} {guest} {vocal} vocals', -- performed {additional} {guest} {vocal} vocal on
	reverse_link_phrase = '{additional} {guest} {vocal} vocals' -- has {additional} {guest} {vocal} vocal performed by
	where gid = '0fdbe3c6-7700-4a31-ae54-b53f06ae1cfa';

-- name: vocal (artist-release)
update link_type set
	link_phrase = '{additional} {guest} {vocal} vocals', -- performed {additional} {guest} {vocal} vocal on
	reverse_link_phrase = '{additional} {guest} {vocal} vocals' -- has {additional} {guest} {vocal} vocal performed by
	where gid = 'eb10f8a0-0f4c-4dce-aa47-87bcb2bc42f3';

-- name: vocal supporting musician (artist-artist)
update link_type set
	link_phrase = '{vocal} vocal support for', -- does/did {vocal} vocal support for
	reverse_link_phrase = '{vocal} vocal support by' -- is/was supported with {vocal} vocal by
	where gid = '610d39a4-3fa0-4848-a8c9-f46d7b5cc02e';

-- name: wikipedia (artist-url)
update link_type set
	link_phrase = 'Wikipedia', -- has a Wikipedia page at
	reverse_link_phrase = 'Wikipedia page for' -- is a Wikipedia page for
	where gid = '29651736-fa6d-48e4-aadc-a557c6add1cb';

-- name: wikipedia (label-url)
update link_type set
	link_phrase = 'Wikipedia', -- has a Wikipedia page at
	reverse_link_phrase = 'Wikipedia page for' -- is a Wikipedia page for
	where gid = '51e9db21-8864-49b3-aa58-470d7b81fa50';

-- name: wikipedia (release_group-url)
update link_type set
	link_phrase = 'Wikipedia', -- has a Wikipedia page at
	reverse_link_phrase = 'Wikipedia page for' -- is a Wikipedia page for
	where gid = '6578f0e9-1ace-4095-9de8-6e517ddb1ceb';

-- name: youtube (artist-url)
update link_type set
	link_phrase = 'YouTube channels', -- has an official YouTube channel at
	reverse_link_phrase = 'YouTube channel for' -- is an official YouTube channel for
	where gid = '6a540e5b-58c6-4192-b6ba-dbc71ec8fcf0';

-- name: youtube (label-url)
update link_type set
	link_phrase = 'YouTube channels', -- has an official YouTube channel at
	reverse_link_phrase = 'YouTube channel for' -- is an official YouTube channel for
	where gid = 'd9c71059-ba9d-4135-b909-481d12cf84e3';

COMMIT;

