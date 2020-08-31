/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import mutate from 'mutate-cow';
import * as React from 'react';
import * as ReactDOM from 'react-dom';
import * as Sentry from '@sentry/browser';

import {SanitizedCatalystContext} from '../context';

import escapeClosingTags from './escapeClosingTags';

type Config = {+$c?: CatalystContextT, ...};

export function renderPropsScript<C: Config, SanitizedC = C>(
  props: C,
  mungeProps?: ((C) => SanitizedC) | null,
): React.Element<'script'> {
  let dataProps = {...props};
  if (dataProps.$c) {
    delete dataProps.$c;
  }
  if (mungeProps) {
    dataProps = mungeProps(dataProps);
  }
  return (
    <script
      dangerouslySetInnerHTML={{
        __html: escapeClosingTags(JSON.stringify(dataProps) ?? ''),
      }}
      type="application/json"
    />
  );
}

export function performHydrate<C: Config, SanitizedC = C>(
  containerSelector: string,
  Component: React.AbstractComponent<C | SanitizedC>,
) {
  if (typeof document !== 'undefined') {
    // This should only run on the client.
    const $ = require('jquery');
    $(function () {
      const roots = document.querySelectorAll(containerSelector);
      for (const root of roots) {
        const propScript = root.previousElementSibling;
        if (!propScript || propScript.tagName.toLowerCase() !== 'script') {
          const errorMsg =
            'Props <script> for ' + containerSelector + ' not found.';
          console.error(errorMsg);
          Sentry.captureException(new Error(errorMsg));
          continue;
        }
        const propString = propScript.textContent;
        if (propString) {
          const $c: SanitizedCatalystContextT =
            window[GLOBAL_CATALYST_CONTEXT_NAMESPACE];
          const props: SanitizedC = JSON.parse(propString);
          ReactDOM.hydrate(
            <SanitizedCatalystContext.Provider value={$c}>
              <Component $c={$c} {...props} />
            </SanitizedCatalystContext.Provider>,
            root,
          );
        }
      }
    });
  }
}

export default function hydrate<C: Config, SanitizedC = C>(
  containerSelector: string,
  Component: React.AbstractComponent<C | SanitizedC>,
  mungeProps?: ((C) => SanitizedC) | null,
): React.AbstractComponent<C, void> {
  performHydrate(containerSelector, Component);
  return (props: C) => {
    const propsScript = renderPropsScript(props, mungeProps);
    const [containerTag, ...classes] = containerSelector.split('.');
    return (
      <>
        {propsScript}
        {React.createElement(
          containerTag,
          {className: classes.join(' ')},
          <Component {...props} />,
        )}
      </>
    );
  };
}

type PropsWithEntity = {entity: MinimalCoreEntityT, ...};

export function minimalEntity<T: $ReadOnly<PropsWithEntity>>(
  props: $Exact<T>,
): $Exact<T> {
  const entity = props.entity;
  return mutate<PropsWithEntity, _>(props, newProps => {
    newProps.entity = {
      entityType: entity.entityType,
      gid: entity.gid,
    };
  });
}
