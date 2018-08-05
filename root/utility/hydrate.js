/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import $ from 'jquery';
import React from 'react';
import ReactDOM from 'react-dom';
import type {ComponentType as ReactComponentType} from 'react';

export default function hydrate<T>(
  rootClass: string,
  Component: ReactComponentType<T>,
  stringifyProps: (T) => string = JSON.stringify,
): ReactComponentType<T> {
  if (typeof document !== 'undefined') {
    // This should only run on the client.
    $(function () {
      const roots = document.querySelectorAll('div.' + rootClass);
      for (const root of roots) {
        const propString = root.getAttribute('data-props');
        root.removeAttribute('data-props');
        if (propString) {
          const props: T = JSON.parse(propString);
          ReactDOM.hydrate(<Component {...props} />, root);
        }
      }
    });
  }
  return (props) => (
    <div className={rootClass} data-props={stringifyProps(props)}>
      <Component {...props} />
    </div>
  );
}
