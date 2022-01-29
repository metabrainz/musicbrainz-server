/*
 * @flow strict-local
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {useCallback, useState} from 'react';

import './styles/colors.less';
import './styles/globals.less';
import './styles/Home.less';
import Head from '../layout/components/Head';
import Footer from '../layout/components/Footer';
import Header from '../layout/components/Header';
import ScrollToTop from '../components/ScrollToTop';
import Supporters from '../components/Home/Supporters';
import Intro from '../components/Home/Intro';
import AppDownload from '../components/Home/AppDownload';
import About from '../components/Home/About';
import Facts from '../components/Home/Facts';
import Explore from '../components/Home/Explore';
import Projects from '../components/Home/Projects';

export default function Home() {
  const DARK_MODE_KEY = 'dark_mode';
  const [dark, setDark] = useState(getSetting);
  const theme = dark ? 'theme-dark' : 'theme-light';
  const searchOptions = [
    'Artist',
    'Release',
    'Recording',
    'Label',
    'Work',
    'Release Group',
    'Area',
    'Place',
    'Annotation',
    'CD Stub',
    'Editor',
    'Tag',
    'Instrument',
    'Series',
    'Event',
    'Documentation',
  ];

  function getSetting() {
    try {
      return JSON.parse(window.localStorage.getItem(DARK_MODE_KEY)) === true;
    } catch (e) {
      return false;
    }
  }

  function updateSetting(value) {
    try {
      window.localStorage.setItem(
        DARK_MODE_KEY,
        JSON.stringify(value === true),
      );
    } catch (e) {}
  }

  const toggleDarkMode = useCallback(function () {
    setDark(prevState => {
      const newState = !prevState;
      updateSetting(prevState);
      return newState;
    });
  }, []);

  return (
    <div>
      <Head />
      <Header
        isDarkThemeActive={dark}
        projectName="musicbrainz"
        searchOptions={searchOptions}
        switchActiveTheme={toggleDarkMode}
        theme={theme}
      />
      <Intro theme={theme} />
      <About theme={theme} />
      <Facts theme={theme} />
      <Projects theme={theme} />
      <Explore theme={theme} />
      <Supporters theme={theme} />
      <AppDownload theme={theme} />
      <Footer theme={theme} />
      <ScrollToTop
        backgroundColor="#EB743B"
        hover={{backgroundColor: 'purple', opacity: '0.95'}}
        icon="bi bi-caret-up-fill"
        margin="24px"
        position={{bottom: '12%', right: '0%'}}
      />
    </div>
  );
}
