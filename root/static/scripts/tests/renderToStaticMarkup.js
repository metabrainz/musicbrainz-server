/*
 * @flow strict
 * Copyright (C) 2023 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as ReactDOMServer from 'react-dom/server';

/*
 * When using ReactDOMServer.renderToStaticMarkup in our tests,
 * it sometimes inserts an empty HTML comment at the start
 * of the returned string. That is never useful for testing,
 * so this wrapper removes it.
 */

export default function renderToStaticMarkup(element: React.Node): string {
  const unstrippedMarkup = ReactDOMServer.renderToStaticMarkup(element);
  return unstrippedMarkup.replace(/^<!-- -->/, '');
}
