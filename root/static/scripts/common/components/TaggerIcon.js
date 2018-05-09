/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

const React = require('react');
const {withCatalystContext} = require('../../../../context');
const {pathTo} = require('../../../manifest');
const {l} = require('../i18n');

function buildTaggerLink(entity, tport: number): string {
  const gid = entity.gid;
  const t = Math.floor(Date.now() / 1000);
  let path = '';
  if (entity.entityType === 'release') {
    path = 'openalbum';
  } else if (entity.entityType === 'recording') {
    path = 'opennat';
  }
  return `http://127.0.0.1:${tport}/${path}?id=${gid}&t=${t}`;
}

type Props = {|
  +$c: CatalystContextT,
  +entity: RecordingT | ReleaseT,
|};

const TaggerIcon = ({$c, entity}: Props) => {
  const tport = $c.session ? $c.session.tport : null;
  if (!tport) {
    return null;
  }
  return (
    <a
      className="tagger-icon"
      href={buildTaggerLink(entity, tport)}
      title={l('Open in tagger')}
    >
      <img
        alt={l('Tagger')}
        src={pathTo('/images/icons/mblookup-tagger.png')}
      />
    </a>
  );
};

module.exports = withCatalystContext(TaggerIcon);
