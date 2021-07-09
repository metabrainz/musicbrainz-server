/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';
import ButtonPopover from '../../common/components/ButtonPopover';

type PropsT = {
  errorMessage: string,
  onCancel: () => void,
  onChange: (number, SyntheticEvent<HTMLInputElement>) => void,
  onToggle: (boolean) => void,
  rawUrl: string,
  url: string,
};

const URLInputPopover = (props: PropsT): React.MixedElement => {
  const popoverButtonRef = React.useRef(null);
  const [isOpen, setIsOpen] = React.useState(false);

  const toggle = (open) => {
    /*
     * Will be called by ButtonPopover when closed
     * either by losing focus or click 'Close' button,
     * therefore cancel action should be checked here.
     */
    if (!open) {
      props.onCancel();
    }
    setIsOpen(open);
    props.onToggle(open);
  };

  const onConfirm = () => {
    // Bypass 'toggle' to avoid trigering onCancel
    setIsOpen(false);
    props.onToggle(false);
  };

  const buildPopoverChildren = (
    closeAndReturnFocus,
  ) => (
    <form
      onSubmit={(event) => {
        event.preventDefault();
        onConfirm();
      }}
    >
      <table>
        <tbody>
          <tr>
            <td className="section">
              {addColonText(l('URL'))}
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
          {props.url &&
            <tr>
              <td className="section" style={{whiteSpace: 'nowrap'}}>
                {addColonText(l('Cleaned up to'))}
              </td>
              <td>
                <a className="clean-url" href={props.url}>{props.url}</a>
              </td>
            </tr>
          }
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
            onClick={onConfirm}
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
