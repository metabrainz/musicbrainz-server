/*
 * @flow
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';
import ButtonPopover from '../../common/components/ButtonPopover';
import type {ErrorT, LinkStateT} from '../externalLinks';
import {ERROR_TARGETS} from '../URLCleanup';

type PropsT = {
  cleanupUrl: (string) => string,
  link: LinkStateT,
  onConfirm: (string) => void,
  validateLink: (LinkStateT) => ErrorT,
};

const URLInputPopover = (props: PropsT): React.MixedElement => {
  const popoverButtonRef = React.useRef(null);
  const [isOpen, setIsOpen] = React.useState(false);
  const [link, setLink] = React.useState(props.link);

  React.useEffect(() => {
    setLink(props.link);
  }, [props.link]);

  const toggle = (open) => {
    /*
     * Will be called by ButtonPopover when closed
     * either by losing focus or click 'Close' button
     */
    setIsOpen(open);
  };

  const handleCancel = () => {
    toggle(false);
  };

  const handleUrlChange = (event) => {
    setLink({
      ...link,
      rawUrl: event.target.value,
      url: props.cleanupUrl(event.target.value),
    });
  };

  const buildPopoverChildren = (
    closeAndReturnFocus,
  ) => {
    const error = props.validateLink(link);
    return (
      <form
        onSubmit={(event) => {
          event.preventDefault();
          props.onConfirm(link.rawUrl);
          closeAndReturnFocus();
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
                  onChange={handleUrlChange}
                  style={{width: '336px'}}
                  value={link.rawUrl}
                />
                {error &&
                  error.target === ERROR_TARGETS.URL &&
                  <div
                    className="error field-error target-url"
                    data-visible="1"
                  >
                    {error.message}
                  </div>
                }
              </td>
            </tr>
            {link.url &&
              <tr>
                <td className="section" style={{whiteSpace: 'nowrap'}}>
                  {addColonText(l('Cleaned up to'))}
                </td>
                <td>
                  <a
                    className="clean-url"
                    href={link.url}
                    rel="noreferrer"
                    target="_blank"
                  >
                    {link.url}
                  </a>
                </td>
              </tr>
            }
          </tbody>
        </table>
        <div className="buttons" style={{display: 'block', marginTop: '1em'}}>
          <button
            className="negative"
            onClick={handleCancel}
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
              onClick={() => {
                props.onConfirm(link.rawUrl);
                closeAndReturnFocus();
              }}
              type="button"
            >
              {l('Done')}
            </button>
          </div>
        </div>
      </form>
    );
  };

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
