/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

// NOTE: Don't convert to an ES module; this is used by root/server.js.
/* eslint-disable import/no-commonjs */

const React = require('react');
/*:: import type {ComponentType} from 'react'; */

const defaultContext = {
  action: {
    name: '',
  },
  linked_entities: {
    artist_type: {},
    language: {},
    link_attribute_type: {},
    link_type: {},
    release_group_primary_type: {},
    release_group_secondary_type: {},
    release_packaging: {},
    release_status: {},
    script: {},
    series: {},
    series_ordering_type: {},
    series_type: {},
    work: {},
    work_attribute_type: {},
  },
  relative_uri: '',
  req: {
    headers: {},
    query_params: {},
    secure: false,
    uri: '',
  },
  session: null,
  sessionid: null,
  stash: {
    current_language: 'en',
    current_language_html: 'en',
  },
  user_exists: false,
};

const CatalystContext =
  React.createContext/*:: <typeof defaultContext> */(defaultContext);

exports.CatalystContext = CatalystContext;

/*::
type ContextPropT = {
  +$c: CatalystContextT | SanitizedCatalystContextT,
};
*/

function withCatalystContext/*:: <P: ContextPropT> */(
  Component /*: ComponentType<P> */,
) /*: ComponentType<$Diff<P, ContextPropT>> */ {
  return (props) => React.createElement(
    CatalystContext.Consumer,
    null,
    ($c /*: CatalystContextT */) => (
      React.createElement(Component, {$c, ...props})
    ),
  );
}

exports.withCatalystContext = withCatalystContext;
