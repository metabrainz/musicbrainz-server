/*
 * @flow
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import ko, {type Observable as KnockoutObservable} from 'knockout';
import * as React from 'react';

import {SanitizedCatalystContext} from '../../../../context.mjs';
import MB from '../../common/MB.js';
import withLoadedTypeInfo from '../../edit/components/withLoadedTypeInfo.js';
import {errorField} from '../../edit/validation.js';
import {
  createInitialState,
  reducer,
} from '../state.js';
import {
  hasErrorsOnNewOrChangedLinks,
} from '../validation.js';

import ExternalLinksEditor from './ExternalLinksEditor.js';

component _StandaloneExternalLinksEditor(
  /*:: ref: React.RefSetter<void>, */
) {
  const $c = React.useContext(SanitizedCatalystContext);

  const [state, dispatch] = React.useReducer(
    reducer,
    $c,
    createInitialState,
  );

  const errorObservableRef =
    React.useRef<KnockoutObservable<boolean> | null>(null);

  React.useEffect(() => {
    let errorObservable = errorObservableRef.current;
    if (!errorObservable) {
      if (state.source.entityType === 'release') {
        // $FlowFixMe[prop-missing]
        errorObservable = MB.releaseEditor.hasInvalidLinks as
          KnockoutObservable<boolean>;
      } else {
        errorObservable = errorField(ko.observable(false)) as
          KnockoutObservable<boolean>;
      }
      errorObservableRef.current = errorObservable;
    }
    errorObservable(hasErrorsOnNewOrChangedLinks(state.links));
  }, [state.links, state.source.entityType]);

  return <ExternalLinksEditor dispatch={dispatch} state={state} />;
}

const StandaloneExternalLinksEditor:
  component(
    ...React.PropsOf<_StandaloneExternalLinksEditor>
  ) =
    hydrate<React.PropsOf<_StandaloneExternalLinksEditor>>(
      'div.external-links-editor-container',
      withLoadedTypeInfo<React.PropsOf<_StandaloneExternalLinksEditor>, void>(
        _StandaloneExternalLinksEditor,
        new Set(['link_type', 'link_attribute_type']),
      ),
    );

export default StandaloneExternalLinksEditor;
