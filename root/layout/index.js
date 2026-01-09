/*
 * @flow strict
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {CatalystContext} from '../context.mjs';
import manifest from '../static/manifest.mjs';

import Banners from './components/Banners.js';
import Footer from './components/Footer.js';
import Head from './components/Head.js';
import Header from './components/Header.js';
import MergeHelper from './components/MergeHelper.js';
import SupportedBrowserCheck from './components/SupportedBrowserCheck.js';

component HeaderAndBanners(
  isHomepage: boolean,
) {
  return (
    <>
      <Header />
      {isHomepage ? null : <SupportedBrowserCheck />}
      {isHomepage ? null : <Banners />}
    </>
  );
}

component MergeHelperAndFooter(
  $c: CatalystContextT,
) {
  return (
    <>
      {$c.session?.merger && !$c.stash.hide_merge_helper /*:: === true */
        ? <MergeHelper merger={$c.session.merger} />
        : null}
      <Footer />
    </>
  );
}

component Layout(
  children: React.Node,
  fullWidth: boolean = false,
  ...headProps: React.PropsOf<Head>
) {
  const $c = React.useContext(CatalystContext);

  const isHomepage = headProps.isHomepage;

  return (
    <html lang={$c.stash.current_language_html}>
      <Head {...headProps} />

      <body
        className={
          isHomepage /*:: === true */ ? 'body-homepage' : ''
        }
      >
        {$c.stash.within_dialog === true
          ? null
          : <HeaderAndBanners isHomepage={isHomepage /*:: === true */} />}

        <div
          className={(fullWidth ? 'fullwidth ' : '') +
            (headProps.isHomepage /*:: === true */ ? 'homepage' : '')}
          id="page"
        >
          {children}
        </div>

        {$c.stash.within_dialog === true ||
          (headProps.isHomepage /*:: === true */)
          ? null
          : <MergeHelperAndFooter $c={$c} />}

        {manifest('common/banner', {async: true})}
      </body>
    </html>
  );
}

export default Layout;
