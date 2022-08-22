/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

/* eslint-disable import/no-commonjs */

const React = require('react');
const ReactDOMClient = require('react-dom/client');

const Modal = require('../common/components/Modal').default;
const ButtonPopover = require('../common/components/ButtonPopover').default;
const useReturnFocus = require('../common/hooks/useReturnFocus').default;

const container = document.createElement('div');
document.body?.insertBefore(container, document.getElementById('page'));

type ActionT =
  | {+open: boolean, +type: 'toggle-modal'}
  | {+open: boolean, +type: 'toggle-popover'};

type StateT = {
  +isModalOpen: boolean,
  +isPopoverOpen: boolean,
};

function reducer(state: StateT, action: ActionT) {
  switch (action.type) {
    case 'toggle-modal':
      return {
        ...state,
        isModalOpen: action.open,
      };
    case 'toggle-popover':
      return {
        ...state,
        isPopoverOpen: action.open,
      };
  }
  return state;
}

function createInitialState() {
  return {
    isModalOpen: false,
    isPopoverOpen: false,
  };
}

const DialogTest = () => {
  const [state, dispatch] = React.useReducer(
    reducer,
    null,
    createInitialState,
  );

  const modalButtonRef = React.useRef(null);
  const popoverButtonRef = React.useRef(null);
  const modalDialogRef = React.useRef(null);
  const focusModalButton = useReturnFocus(modalButtonRef);

  const openModal = React.useCallback(() => {
    dispatch({
      open: true,
      type: 'toggle-modal',
    });
  }, []);

  const closeModal = React.useCallback(() => {
    focusModalButton.current = true;
    dispatch({
      open: false,
      type: 'toggle-modal',
    });
  }, [focusModalButton]);

  const togglePopover = React.useCallback((open: boolean) => {
    dispatch({open, type: 'toggle-popover'});
  }, []);

  const buildPopoverChildren = React.useCallback((
    closeAndReturnFocus,
  ) => (
    <form
      onSubmit={(event) => {
        event.preventDefault();
        closeAndReturnFocus();
      }}
    >
      <p>{'Pop'}</p>
      <p>
        <a href="#">{'Pop'}</a>
      </p>
      <p>
        <input defaultValue="Pop" type="text" />
      </p>
      <button
        onClick={closeAndReturnFocus}
        type="button"
      >
        {'Goodbye'}
      </button>
    </form>
  ), []);

  return (
    <>
      <textarea defaultValue="noop" />
      <h2>{'Modal'}</h2>
      <p>
        <button
          onClick={openModal}
          ref={modalButtonRef}
          type="button"
        >
          {'Open Modal'}
        </button>
        {state.isModalOpen ? (
          <Modal
            dialogRef={modalDialogRef}
            id="modal-test"
            onEscape={closeModal}
            title="Title"
          >
            <p>{'Hello!'}</p>
            <p>
              <a href="#">{'Hello!'}</a>
            </p>
            <p>
              <input defaultValue="Hello!" type="text" />
            </p>
            <button
              onClick={closeModal}
              type="button"
            >
              {'Goodbye'}
            </button>
          </Modal>
        ) : null}
      </p>
      <h2>{'Popover'}</h2>
      <p>
        <ButtonPopover
          buildChildren={buildPopoverChildren}
          buttonContent="Open Popover"
          buttonRef={popoverButtonRef}
          id="popover-test"
          isOpen={state.isPopoverOpen}
          toggle={togglePopover}
        />
      </p>
      <p>
        <textarea defaultValue="noop" />
      </p>
    </>
  );
};

const root = ReactDOMClient.createRoot(container);
root.render(<DialogTest />);
