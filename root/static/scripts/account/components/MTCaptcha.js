/*
 * @flow strict
 * Copyright (C) 2023 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

type MTCaptchaPropsT = {
  +publicKey: string,
};

const MTCaptcha = ({
  publicKey,
}: MTCaptchaPropsT): React$Element<'div'> => {
    React.useEffect(() => {
      const s = document.createElement('script');
      s.type = 'text/javascript';
      s.async = true;
      s.innerHTML = `var mtcaptchaConfig = {"sitekey": "${publicKey}"};`;
      document.body?.appendChild(s);

      const mt_service = document.createElement("script");
      mt_service.src = "https://service.mtcaptcha.com/mtcv1/client/mtcaptcha.min.js";
      mt_service.async = true;
      document.body?.appendChild(mt_service);

      const mt_service2 = document.createElement("script");
      mt_service2.src = "https://service2.mtcaptcha.com/mtcv1/client/mtcaptcha2.min.js";
      mt_service2.async = true;
      document.body?.appendChild(mt_service2);

    }, [])
   return (<div className='mtcaptcha' />)
}

export default (hydrate<MTCaptchaPropsT>(
  'div.mtcaptcha-wrap',
  MTCaptcha,
): React$AbstractComponent<MTCaptchaPropsT, void>);
