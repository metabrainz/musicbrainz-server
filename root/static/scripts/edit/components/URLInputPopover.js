/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import ButtonPopover from '../../common/components/ButtonPopover.js';
import type {
  ErrorT,
  LinkRelationshipT,
  LinkStateT,
} from '../externalLinks.js';
import {ERROR_TARGETS} from '../URLCleanup.js';

type PropsT = {
  cleanupUrl: (string) => string,
  link: LinkRelationshipT,
  onConfirm: (string) => void,
  validateLink: (LinkRelationshipT | LinkStateT) => ErrorT | null,
};

const URLInputPopover = (props: PropsT): React.MixedElement => {
  const popoverButtonRef = React.useRef(null);
  const [isOpen, setIsOpen] = React.useState<boolean>(false);
  const [link, setLink] = React.useState<LinkRelationshipT>(props.link);

  React.useEffect(() => {
    setLink(props.link);
  }, [props.link]);

  const toggle = (open: boolean) => {
    // Will be called by ButtonPopover when closed by losing focus
    if (!open) {
      props.onConfirm(link.rawUrl);
    }
    setIsOpen(open);
  };

  const handleUrlChange = (event: SyntheticEvent<HTMLInputElement>) => {
    const rawUrl = event.currentTarget.value;
    setLink({
      ...link,
      rawUrl,
      url: props.cleanupUrl(rawUrl),
    });
  };

  const handleConfirm = (closeCallback: () => void) => {
    props.onConfirm(link.rawUrl);
    closeCallback();
  };

  const buildPopoverChildren = (
    closeAndReturnFocus: () => void,
  ) => {
    const error = props.validateLink(link);
    return (
      <form
        onSubmit={(event: SyntheticEvent<HTMLFormElement>) => {
          event.preventDefault();
          // Prevent the submit event from propagating to the parent form.
          event.stopPropagation();
          handleConfirm(closeAndReturnFocus);
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
                {error && error.target === ERROR_TARGETS.URL ? (
                  <div
                    className="error field-error target-url"
                    data-visible="1"
                  >
                    {error.message}
                  </div>
                ) : null}
              </td>
            </tr>
            {link.url ? (
              <tr>
                <td className="section" style={{whiteSpace: 'nowrap'}}>
                  {addColonText(l('Cleaned up to'))}
                </td>
                <td>
                  {error ? link.url : (
                    <a
                      className="clean-url"
                      href={link.url}
                      rel="noreferrer"
                      style={{overflowWrap: 'anywhere'}}
                      target="_blank"
                    >
                      {link.url}
                    </a>)}
                </td>
              </tr>
            ) : null}
          </tbody>
        </table>
        <div className="buttons" style={{display: 'block', marginTop: '1em'}}>
          <button
            className="negative"
            onClick={() => {
              // Reset input field value
              setLink(props.link);
              // Avoid calling toggle() otherwise changes will be saved
              setIsOpen(false);
            }}
            type="button"
          >
            {l('Cancel')}
          </button>
          <div className="buttons-right">
            <button
              className="positive"
              onClick={() => handleConfirm(closeAndReturnFocus)}
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
      buttonProps={{className: 'icon edit-item', title: l('Edit URL')}}
      buttonRef={popoverButtonRef}
      id="url-input-popover"
      isOpen={isOpen}
      toggle={toggle}
    />
  );
};

export default URLInputPopover;
