import MB from './common/MB.js';
import setInputValueForReact
  from './common/utility/setInputValueForReact.mjs';
import {errorField, errorFields, errorsExist} from './edit/validation.js';

/*
 * Used by the Selenium tests under /t/selenium/ to make sure that no errors
 * occurred on the page.
 */
MB.js_errors = [];
window.onerror = function (message, source, lineno, colno, error) {
  MB.js_errors.push(error && error.stack ? error.stack : message);
};

MB.validation = {
  errorField,
  errorFields,
  errorsExist,
};

// Used by our implementation of the Selenium 'type' command.
MB.setInputValueForReact = setInputValueForReact;
