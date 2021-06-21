/*
 * @flow strict
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
  flash: {},
  relative_uri: '',
  req: {
    body_params: {},
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
};

const defaultSanitizedContext = {
  action: {
    name: '',
  },
  relative_uri: '',
  req: {
    uri: '',
  },
  stash: {
    current_language: 'en',
  },
  user: null,
};

const CatalystContext/*: React$Context<CatalystContextT> */ =
  React.createContext/*:: <CatalystContextT> */(defaultContext);

exports.CatalystContext = CatalystContext;

/*:: type SCC = React$Context<SanitizedCatalystContextT>; */

const SanitizedCatalystContext/*: SCC */ =
  React.createContext/*:: <SanitizedCatalystContextT> */(
    defaultSanitizedContext,
  );

exports.SanitizedCatalystContext = SanitizedCatalystContext;
