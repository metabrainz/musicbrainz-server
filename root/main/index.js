import React, {useCallback, useState} from "react";
import './styles/colors.less';
import './styles/globals.less';
import './styles/Home.less';
import Header from './components/Home/Header/Header';
import Footer from './components/Home/Footer/Footer';
import ScrollToTop from "./components/Utils/ScrollToTop/ScrollToTop";
import Supporters from "./components/Home/Supporters/Supporters";
import Intro from "./components/Home/Intro/Intro";
import AppDownload from "./components/Home/AppDownload/AppDownload";
import About from "./components/Home/About/About";
import Facts from "./components/Home/Facts/Facts";
import Explore from "./components/Home/Explore/Explore";
import Projects from "./components/Home/Projects/Projects";
import Head from '../layout/components/Head';

function Home() {
    const DARK_MODE_KEY = 'dark_mode';
    const [ dark, setDark ] = useState(getSetting);
    let theme = dark ? "theme-dark" : "theme-light";

    function getSetting () {
        try {
            return JSON.parse(window.localStorage.getItem(DARK_MODE_KEY)) === true;
        } catch (e) {
            return false;
        }
    }

    function updateSetting (value) {
        try {
            window.localStorage.setItem(DARK_MODE_KEY, JSON.stringify(value === true));
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
            <Header theme={theme} switchActiveTheme={toggleDarkMode} isDarkThemeActive={dark}/>
            <Intro theme={theme}/>
            <About theme={theme}/>
            <Facts theme={theme}/>
            <Projects theme={theme}/>
            <Explore theme={theme}/>
            <Supporters theme={theme}/>
            <AppDownload theme={theme}/>
            <Footer theme={theme}/>
            <ScrollToTop
                icon="bi bi-caret-up-fill"
                backgroundColor = "#EB743B"
                position={{ bottom: "12%", right: "0%" }}
                hover={{ backgroundColor: "purple", opacity: "0.95" }}
                margin="24px"
            />
        </div>
    );
}
export default Home;