/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';
import type {LinkStateT} from '../externalLinks';
import ButtonPopover from '../../common/components/ButtonPopover';

type PropsT = {
  errorMessage: string,
  onCancel: ($Shape<LinkStateT>) => void,
  onChange: (number, SyntheticEvent<HTMLInputElement>) => void,
  rawUrl: string,
  url: string,
};

const URLInputPopover = (props: PropsT): React.MixedElement => {
  const popoverButtonRef = React.useRef(null);
  const [isOpen, setIsOpen] = React.useState(false);
  const [
    originalLinkState,
    setOriginalLinkState,
  ] = React.useState({
    rawUrl: props.rawUrl,
    url: props.url,
  });

  const toggle = (open) => {
    if (open) {
      // Backup original link state
      setOriginalLinkState({
        rawUrl: props.rawUrl,
        url: props.url,
      });
    } else {
      // Restore original link state when cancelled
      props.onCancel(originalLinkState);
    }
    setIsOpen(open);
  };

  const buildPopoverChildren = (
    closeAndReturnFocus,
  ) => (
    <form
      onSubmit={(event) => {
        event.preventDefault();
        setIsOpen(false);
      }}
    >
      <table>
        <tbody>
          <tr>
            <td className="section">
              {l('URL:')}
            </td>
            <td>
              <input
                className="value raw-url"
                onChange={props.onChange}
                style={{width: '336px'}}
                type="url"
                value={props.rawUrl}
              />
              {props.errorMessage &&
                <div
                  className="error field-error target-url"
                  data-visible="1"
                >
                  {props.errorMessage}
                </div>
              }
            </td>
          </tr>
          <tr>
            <td className="section" style={{whiteSpace: 'nowrap'}}>
              {l('Cleaned up to:')}
            </td>
            <td>
              <a className="clean-url" href={props.url}>{props.url}</a>
            </td>
          </tr>
        </tbody>
      </table>
      <div className="buttons" style={{display: 'block', marginTop: '1em'}}>
        <button
          className="negative"
          onClick={closeAndReturnFocus}
          type="button"
        >
          {l('Cancel')}
        </button>
        <div
          className="buttons-right"
          style={{float: 'right', textAlign: 'right'}}
        >
          <button
            className="positive"
            onClick={() => setIsOpen(false)}
            type="button"
          >
            {l('Done')}
          </button>
        </div>
      </div>
    </form>
  );

  return (
    <ButtonPopover
      buildChildren={buildPopoverChildren}
      buttonContent={null}
      buttonProps={{className: 'icon edit-item'}}
      buttonRef={popoverButtonRef}
      id="url-input-popover"
      isOpen={isOpen}
      toggle={toggle}
    />
  );
};

export default URLInputPopover;
