/*
 * @flow strict-local
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

export default function Footer(props) {
  return (
    <section className={'section-footer ' + props.theme}>
      <div className="container">
        <div className="row">
          <div className="col-sm-12 col-md-4">
            <h3 className="navbar-brand text-brand">
              <img alt="image" src="../../../../static/images/meb-icons/MusicBrainz.svg" width="52" />
              {' '}
              <span className="color-purple">Music</span>
              <span
                className="color-orange"
              >
                Brainz
              </span>
            </h3>
            <br />
            <p className="color-gray">
              is an open music encyclopedia that collects music metadata and makes it available to the public.
            </p>
            <ul className="list-unstyled">
              <li className="color-a">
                <span className="color-gray">Development IRC: </span>
                {' '}
                <a href="https://kiwiirc.com/nextclient/irc.libera.chat/?#metabrainz" rel="noopener noreferrer" target="_blank"> #metabrainz</a>
              </li>
              <li className="color-a">
                <span className="color-gray">Discussion IRC: </span>
                {' '}
                <a href="https://kiwiirc.com/nextclient/irc.libera.chat/?#metabrainz" rel="noopener noreferrer" target="_blank"> #musicbrainz</a>
              </li>
              <li className="color-a">
                <span className="color-gray">Email: </span>
                {' '}
                <a href="mailto:support@metabrainz.org">support@metabrainz.org </a>
              </li>
            </ul>
          </div>
          <br />
          <div className="col-sm-12 col-md-3 section-md-t3">
            <h3 className="w-title-a text-brand">Useful Links</h3>
            <ul className="list-unstyled">
              <li className="item-list-a">
                <i className="bi bi-chevron-right" />
                {' '}
                <a href="https://metabrainz.org/donate" rel="noopener noreferrer" target="_blank">Donate</a>
              </li>
              <li className="item-list-a">
                <i className="bi bi-chevron-right" />
                {' '}
                <a href="https://wiki.musicbrainz.org/Main_Page" rel="noopener noreferrer" target="_blank">Wiki</a>
              </li>
              <li className="item-list-a">
                <i className="bi bi-chevron-right" />
                {' '}
                <a href="https://community.metabrainz.org/" rel="noopener noreferrer" target="_blank">Community</a>
              </li>
              <li className="item-list-a">
                <i className="bi bi-chevron-right" />
                {' '}
                <a href="https://blog.metabrainz.org/" rel="noopener noreferrer" target="_blank">Blog</a>
              </li>
              <li className="item-list-a">
                <i className="bi bi-chevron-right" />
                {' '}
                <a href="https://www.redbubble.com/people/metabrainz/shop" rel="noopener noreferrer" target="_blank">Shop</a>
              </li>
              <li className="item-list-a">
                <i className="bi bi-chevron-right" />
                {' '}
                <a href="https://metabrainz.org/" rel="noopener noreferrer" target="_blank">MetaBrainz</a>
              </li>

            </ul>
          </div>
          <div className="col-sm-12 col-md-3 section-md-t3">
            <h3 className="w-title-a text-brand">Fellow Projects</h3>
            <ul className="list-unstyled">
              <li className="item-list-a">
                <i className="bi bi-chevron-right" />
                {' '}
                <img alt="image" height="24" src="../../../../static/images/meb-icons/ListenBrainz.svg" width="24" />
                {' '}
                <a href="https://listenbrainz.org/" rel="noopener noreferrer" target="_blank">ListenBrainz</a>
              </li>
              <li className="item-list-a">
                <i className="bi bi-chevron-right" />
                {' '}
                <img alt="image" height="24" src="../../../../static/images/meb-icons/CritiqueBrainz.svg" width="24" />
                {' '}
                <a href="https://critiquebrainz.org/" rel="noopener noreferrer" target="_blank">CritiqueBrainz</a>
              </li>
              <li className="item-list-a">
                <i className="bi bi-chevron-right" />
                {' '}
                <img alt="image" height="24" src="../../../../static/images/meb-icons/Picard.svg" width="24" />
                {' '}
                <a href="https://picard.musicbrainz.org/" rel="noopener noreferrer" target="_blank">Picard</a>
              </li>
              <li className="item-list-a">
                <i className="bi bi-chevron-right" />
                {' '}
                <img alt="image" height="24" src="../../../../static/images/meb-icons/BookBrainz.svg" width="24" />
                {' '}
                <a href="https://bookbrainz.org/" rel="noopener noreferrer" target="_blank">BookBrainz</a>
              </li>
              <li className="item-list-a">
                <i className="bi bi-chevron-right" />
                {' '}
                <img alt="image" height="24" src="../../../../static/images/meb-icons/AcousticBrainz.svg" width="24" />
                {' '}
                <a href="https://acousticbrainz.org/" rel="noopener noreferrer" target="_blank">AcousticBrainz</a>
              </li>
              <li className="item-list-a">
                <i className="bi bi-chevron-right" />
                {' '}
                <img alt="image" height="24" src="../../../../static/images/meb-icons/CoverArtArchive.svg" width="24" />
                {' '}
                <a href="https://coverartarchive.org" rel="noopener noreferrer" target="_blank">Cover Art Archive</a>
              </li>

            </ul>
          </div>

          <div className="col-sm-12 col-md-2 section-md-t3">
            <h3 className="w-title-a text-brand">Join Us</h3>
            <ul className="list-unstyled">
              <li className="item-list-a">
                <i className="bi bi-chevron-right" />
                {' '}
                <a href="https://musicbrainz.org/doc/Beginners_Guide" rel="noopener noreferrer" target="_blank">Beginner&apos;s Guide</a>
              </li>
              <li className="item-list-a">
                <i className="bi bi-chevron-right" />
                {' '}
                <a href="https://musicbrainz.org/doc/Style" rel="noopener noreferrer" target="_blank">Style Guidelines</a>
              </li>
              <li className="item-list-a">
                <i className="bi bi-chevron-right" />
                {' '}
                <a href="https://musicbrainz.org/doc/How_To" rel="noopener noreferrer" target="_blank">How Tos</a>
              </li>
              <li className="item-list-a">
                <i className="bi bi-chevron-right" />
                {' '}
                <a href="https://musicbrainz.org/doc/Frequently_Asked_Questions" rel="noopener noreferrer" target="_blank">FAQs</a>
              </li>
              <li className="item-list-a">
                <i className="bi bi-chevron-right" />
                {' '}
                <a href="https://musicbrainz.org/doc/MusicBrainz_Documentation" rel="noopener noreferrer" target="_blank">Doc Index</a>
              </li>
              <li className="item-list-a">
                <i className="bi bi-chevron-right" />
                {' '}
                <a href="https://musicbrainz.org/doc/Development" rel="noopener noreferrer" target="_blank">Development</a>
              </li>

            </ul>
          </div>
        </div>
        <div className="row center-p">
          <div className="col-md-3 d-none d-md-block">
            <p className="color-gray section-line">
              OSS Geek?
              {' '}
              <a href="https://github.com/metabrainz/musicbrainz-server" rel="noopener noreferrer" target="_blank">
                {' '}
                <span className="color-a"> Contribute Here </span>
                {' '}
              </a>
            </p>
          </div>
          <div className="col-md-6">
            <p className="section-line">
              Brought to you by
              {' '}
              <img alt="image" height="30" src="../../../../static/images/meb-icons/MetaBrainz.svg" width="30" />
              {' '}
              <span className="color-a"> MetaBrainz Foundation </span>
            </p>
          </div>
          <div className="col-md-3 d-none d-md-block">
            <p className="color-gray section-line">
              Found an Issue?
              {' '}
              <a href="https://tickets.metabrainz.org/" rel="noopener noreferrer" target="_blank">
                {' '}
                <span className="color-a"> Report Here </span>
              </a>
            </p>
          </div>
        </div>
      </div>

    </section>
  );
}
