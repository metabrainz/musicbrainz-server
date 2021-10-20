import React from "react";

const Footer = props => {
  let theme;
  if (props.isDarkThemeActive) {
    theme = "theme-dark";
  } else {
    theme = "theme-light";
  }
  return (
      <section className={"section-footer "+theme}>
        <div className="container">
          <div className="row">
            <div className="col-sm-12 col-md-4">
              <h3 className="navbar-brand text-brand"><img src="assets/img/meb-icons/MusicBrainz.svg" width="52" alt="image"/> <span className="color-purple">Music</span><span
                  className="color-orange">Brainz</span></h3>
              <br/>
              <p className="color-gray">
                is an open music encyclopedia that collects music metadata and makes it available to the public.
              </p>
              <ul className="list-unstyled">
                <li className="color-a">
                  <span className="color-gray">Development IRC: </span> <a href="https://kiwiirc.com/nextclient/irc.libera.chat/?#metabrainz" target="_blank" rel="noopener noreferrer" > #metabrainz</a>
                </li>
                <li className="color-a">
                  <span className="color-gray">Discussion IRC: </span> <a href="https://kiwiirc.com/nextclient/irc.libera.chat/?#metabrainz" target="_blank" rel="noopener noreferrer" > #musicbrainz</a>
                </li>
                <li className="color-a" >
                  <span className="color-gray">Email: </span> <a href="mailto:support@metabrainz.org">support@metabrainz.org </a>
                </li>
              </ul>
            </div>
            <br/>
            <div className="col-sm-12 col-md-3 section-md-t3">
              <h3 className="w-title-a text-brand">Useful Links</h3>
              <ul className="list-unstyled">
                <li className="item-list-a">
                  <i className="bi bi-chevron-right"/> <a href="https://metabrainz.org/donate" target="_blank" rel="noopener noreferrer" >Donate</a>
                </li>
                <li className="item-list-a">
                  <i className="bi bi-chevron-right"/> <a href="https://wiki.musicbrainz.org/Main_Page" target="_blank" rel="noopener noreferrer" >Wiki</a>
                </li>
                <li className="item-list-a">
                  <i className="bi bi-chevron-right"/> <a href="https://community.metabrainz.org/" target="_blank" rel="noopener noreferrer" >Community</a>
                </li>
                <li className="item-list-a">
                  <i className="bi bi-chevron-right"/> <a href="https://blog.metabrainz.org/" target="_blank" rel="noopener noreferrer" >Blog</a>
                </li>
                <li className="item-list-a">
                  <i className="bi bi-chevron-right"/> <a href="https://www.redbubble.com/people/metabrainz/shop" target="_blank" rel="noopener noreferrer" >Shop</a>
                </li>
                <li className="item-list-a">
                  <i className="bi bi-chevron-right"/> <a href="https://metabrainz.org/" target="_blank" rel="noopener noreferrer" >MetaBrainz</a>
                </li>

              </ul>
            </div>
            <div className="col-sm-12 col-md-3 section-md-t3">
              <h3 className="w-title-a text-brand">Fellow Projects</h3>
              <ul className="list-unstyled">
                <li className="item-list-a">
                  <i className="bi bi-chevron-right"/> <img src="assets/img/meb-icons/ListenBrainz.svg" width="24" height="24" alt="image"/> <a href="https://listenbrainz.org/" target="_blank" rel="noopener noreferrer" >ListenBrainz</a>
                </li>
                <li className="item-list-a">
                  <i className="bi bi-chevron-right"/> <img src="assets/img/meb-icons/CritiqueBrainz.svg" width="24" height="24" alt="image"/> <a href="https://critiquebrainz.org/" target="_blank" rel="noopener noreferrer" >CritiqueBrainz</a>
                </li>
                <li className="item-list-a">
                  <i className="bi bi-chevron-right"/> <img src="assets/img/meb-icons/Picard.svg" width="24" height="24" alt="image"/> <a href="https://picard.musicbrainz.org/" target="_blank" rel="noopener noreferrer" >Picard</a>
                </li>
                <li className="item-list-a">
                  <i className="bi bi-chevron-right"/> <img src="assets/img/meb-icons/BookBrainz.svg" width="24" height="24" alt="image"/> <a href="https://bookbrainz.org/" target="_blank" rel="noopener noreferrer" >BookBrainz</a>
                </li>
                <li className="item-list-a">
                  <i className="bi bi-chevron-right"/> <img src="assets/img/meb-icons/AcousticBrainz.svg" width="24" height="24" alt="image"/> <a href="https://acousticbrainz.org/" target="_blank" rel="noopener noreferrer" >AcousticBrainz</a>
                </li>
                <li className="item-list-a">
                  <i className="bi bi-chevron-right"/> <img src="assets/img/meb-icons/CoverArtArchive.svg" width="24" height="24" alt="image"/> <a href="https://coverartarchive.org" target="_blank" rel="noopener noreferrer" >Cover Art Archive</a>
                </li>

              </ul>
            </div>

            <div className="col-sm-12 col-md-2 section-md-t3">
              <h3 className="w-title-a text-brand">Join Us</h3>
              <ul className="list-unstyled">
                <li className="item-list-a">
                  <i className="bi bi-chevron-right"/> <a href="https://musicbrainz.org/doc/Beginners_Guide" target="_blank" rel="noopener noreferrer" >Beginner&apos;s Guide</a>
                </li>
                <li className="item-list-a">
                  <i className="bi bi-chevron-right"/> <a href="https://musicbrainz.org/doc/Style" target="_blank" rel="noopener noreferrer" >Style Guidelines</a>
                </li>
                <li className="item-list-a">
                  <i className="bi bi-chevron-right"/> <a href="https://musicbrainz.org/doc/How_To" target="_blank" rel="noopener noreferrer" >How Tos</a>
                </li>
                <li className="item-list-a">
                  <i className="bi bi-chevron-right"/> <a href="https://musicbrainz.org/doc/Frequently_Asked_Questions" target="_blank" rel="noopener noreferrer" >FAQs</a>
                </li>
                <li className="item-list-a">
                  <i className="bi bi-chevron-right"/> <a href="https://musicbrainz.org/doc/MusicBrainz_Documentation" target="_blank" rel="noopener noreferrer" >Doc Index</a>
                </li>
                <li className="item-list-a">
                  <i className="bi bi-chevron-right"/> <a href="https://musicbrainz.org/doc/Development" target="_blank" rel="noopener noreferrer" >Development</a>
                </li>

              </ul>
            </div>
          </div>
          <div className="row center-p">
            <div className="col-md-3 d-none d-md-block">
              <p className="color-gray section-line">
                OSS Geek?  <a href="https://github.com/metabrainz/musicbrainz-server" target="_blank" rel="noopener noreferrer" > <span  className="color-a"> Contribute Here </span> </a>
              </p>
            </div>
            <div className="col-md-6">
              <p className="section-line">
                Brought to you by <img src="assets/img/meb-icons/MetaBrainz.svg" width="30" height="30" alt="image"/> <span className="color-a"> MetaBrainz Foundation </span>
              </p>
            </div>
            <div className="col-md-3 d-none d-md-block">
              <p className="color-gray section-line">
                Found an Issue?  <a href="https://tickets.metabrainz.org/" target="_blank" rel="noopener noreferrer" > <span className="color-a"> Report Here </span></a>
              </p>
            </div>
          </div>
        </div>

      </section>
  )
}
export default Footer;