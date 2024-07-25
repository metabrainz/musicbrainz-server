/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as Sentry from '@sentry/browser';
import * as React from 'react';
import {flushSync} from 'react-dom';
import * as ReactDOMClient from 'react-dom/client';

import {SanitizedCatalystContext} from '../context.mjs';
import {
  getCatalystContext,
} from '../static/scripts/common/utility/catalyst.js';

import escapeClosingTags from './escapeClosingTags.js';

type PropsDataT =
  | StrOrNum
  | $ReadOnlyArray<PropsDataT>
  | {+[key: string]: PropsDataT, ...}
  | null
  | void;

/*
 * During testing or development mode, ensure that hydration props do
 * not embed sensitive data like emails and birth dates of users. Only
 * `sanitizedEditorProps` are allowed wherever an object with entityType
 * "editor" appears.
 *
 * It may be valid to embed certain unsanitized data for the currently
 * logged-in user, but that should be part of `$c.user` in
 * `GLOBAL_JS_NAMESPACE`; we otherwise may need to relax this check for
 * admin-only forms in the future.
 */
let checkForUnsanitizedEditorData: ((PropsDataT) => void);
if (__DEV__) {
  /*
   * Please keep these keys in sync with what's returned by
   * root/utility/sanitizedEditor.js.
   */
  const sanitizedEditorProps = new Set([
    'deleted',
    'entityType',
    'avatar',
    'id',
    'name',
    'privileges',
  ]);

  const suspectKeyPattern = /(?:birth|email|password)/;

  checkForUnsanitizedEditorData = (
    data: PropsDataT,
  ): void => {
    if (data) {
      if (Array.isArray(data)) {
        data.forEach(checkForUnsanitizedEditorData);
      } else if (typeof data === 'object') {
        if (data.entityType === 'editor') {
          for (const key in data) {
            if (!sanitizedEditorProps.has(key)) {
              throw new Error(
                'Unsanitized editor data was found on the client: ' +
                JSON.stringify(data),
              );
            }
          }
        } else {
          for (const key in data) {
            const normalizedKey =
              key.toLowerCase().replace(/[_-]/g, '');
            if (suspectKeyPattern.test(normalizedKey)) {
              console.warn(
                'Possible unsanitized editor data was found on ' +
                'the client. If it\'s relevant to a particular *secure* ' +
                'page, or only relates to the current authorized user, ' +
                'you may ignore this warning; but please ensure that ' +
                `it's intended (check key ${JSON.stringify(key)}): ` +
                JSON.stringify(data),
              );
            }
            checkForUnsanitizedEditorData(data[key]);
          }
        }
      }
    }
  };
}

// Please keep the type signature in sync with root/vars.js.
export default function hydrate<
  Config: {...},
  SanitizedConfig = Config,
>(
  containerSelector: string,
  Component: React.AbstractComponent<Config | SanitizedConfig>,
  mungeProps?: (Config) => SanitizedConfig,
): React.AbstractComponent<Config, void> {
  const [containerTag, ...classes] = containerSelector.split('.');
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
        const $c = getCatalystContext();
        const propString = propScript.textContent;
        const props: SanitizedConfig =
          propString ? JSON.parse(propString) : ({}: any);

        if (__DEV__) {
          checkForUnsanitizedEditorData((props: any));
        }
        /*
         * Flush updates to the DOM immediately to try and avoid hydration
         * errors due to user scripts modifying the page. This is ultimately
         * affected by the order in which the scripts run, though.
         */
        flushSync(() => {
          ReactDOMClient.hydrateRoot(
            root,
            <React.StrictMode>
              <SanitizedCatalystContext.Provider value={$c}>
                <Component {...props} />
              </SanitizedCatalystContext.Provider>
            </React.StrictMode>,
          );
        });
        // Custom event that userscripts can listen for.
        root.dispatchEvent(new Event('mb-hydration', {bubbles: true}));
      }
    });
  }
  return (props: Config) => {
    invariant(
      !Object.hasOwn(props, '$c'),
      '`$c` should be accessed using the React context APIs, not props',
    );
    let sanitizedProps: ?SanitizedConfig;
    if (mungeProps) {
      sanitizedProps = mungeProps(props);
    }
    return (
      <>
        <script
          dangerouslySetInnerHTML={{
            __html: escapeClosingTags(
              JSON.stringify(
                ((sanitizedProps ?? props): Config | SanitizedConfig),
              ) ?? '',
            ),
          }}
          type="application/json"
        />
        {React.createElement(
          containerTag,
          {className: classes.join(' ')},
          <Component {...props} />,
        )}
      </>
    );
  };
}

type PropsWithEntity = {
  +entity: $ReadOnly<{...MinimalEntityT, ...}>,
  ...
};

export function minimalEntity<T: PropsWithEntity>(
  props: T,
): T {
  const entity = props.entity;
  const newProps: {...T, ...} = {...props};
  newProps.entity = {
    entityType: entity.entityType,
    gid: entity.gid,
  };
  return newProps;
}
