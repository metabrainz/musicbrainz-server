/*
 * @flow
 * Copyright (C) 2023 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {SanitizedCatalystContext} from '../../../../context.mjs';
import escapeClosingTags from '../../../../utility/escapeClosingTags.js';
import {MTCAPTCHA_PUBLIC_KEY} from '../../common/DBDefs-client.mjs';

component MTCaptcha() {
  const $c = React.useContext(SanitizedCatalystContext);

  React.useEffect(() => {
    const s = document.createElement('script');
    s.type = 'text/javascript';
    s.async = true;
    // $FlowIssue[prop-missing]
    s.nonce = $c.stash.mtcaptcha_script_nonce;
    const quotedPublicKey =
      escapeClosingTags(JSON.stringify(MTCAPTCHA_PUBLIC_KEY));
    s.innerHTML = `function handleVerifiedMTCaptcha(state) {
                     console.log("MTCaptcha has verified the user.");
                     console.log("state => ", state);
                   }

                   function handleJSLoadedMTCaptcha() {
                     console.log("MTCaptcha library has loaded.");
                   }

                   function handleMTCaptchaError(state) {
                     console.log("MTCaptcha error has occurred, " +
                                 "such as bad sitekey, " +
                                 "or internet connection lost.");
                     console.log("state => ", state);
                   }

                   var mtcaptchaConfig = {
                     "sitekey": ${quotedPublicKey},
                     "loadAnimation": "false",
                     "verified-callback": "handleVerifiedMTCaptcha",
                     "jsloaded-callback": "handleJSLoadedMTCaptcha",
                     "error-callback": "handleMTCaptchaError"
                   };`;
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
