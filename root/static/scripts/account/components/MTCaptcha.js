/*
 * @flow strict
 * Copyright (C) 2023 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {SanitizedCatalystContext} from '../../../../context.mjs';
import escapeClosingTags from '../../../../utility/escapeClosingTags.js';
import {
  MTCAPTCHA_PRIVATE_TEST_KEY,
  MTCAPTCHA_PUBLIC_KEY,
} from '../../common/DBDefs-client.mjs';

component MTCaptcha() {
  const $c = React.useContext(SanitizedCatalystContext);

  React.useEffect(() => {
    const s = document.createElement('script');
    s.type = 'text/javascript';
    s.async = true;
    // $FlowExpectedError[prop-missing]
    s.nonce = $c.stash.mtcaptcha_script_nonce;
    const mtcaptchaConfig = {
      loadAnimation: 'false',
      sitekey: MTCAPTCHA_PUBLIC_KEY,
    };
    if (MUSICBRAINZ_RUNNING_TESTS) {
      // $FlowExpectedError[prop-missing]
      mtcaptchaConfig.enableTestMode = MTCAPTCHA_PRIVATE_TEST_KEY;
      // $FlowExpectedError[prop-missing]
      mtcaptchaConfig.lowFrictionInvisible = 'force-visible';
    }
    s.innerHTML = 'var mtcaptchaConfig = ' +
      escapeClosingTags(JSON.stringify(mtcaptchaConfig)) + ';';
    document.body?.appendChild(s);

    const mtService = document.createElement('script');
    mtService.src =
      'https://service.mtcaptcha.com/mtcv1/client/mtcaptcha.min.js';
    mtService.async = true;
    document.body?.appendChild(mtService);

    const mtService2 = document.createElement('script');
    mtService2.src =
      'https://service2.mtcaptcha.com/mtcv1/client/mtcaptcha2.min.js';
    mtService2.async = true;
    document.body?.appendChild(mtService2);
  }, [$c.stash.mtcaptcha_script_nonce]);

  return <div className="mtcaptcha" />;
}

export default MTCaptcha;
