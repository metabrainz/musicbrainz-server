import './About';

function About(props) {
  let theme;
  if (props.isDarkThemeActive) {
    theme = 'theme-dark';
  } else {
    theme = 'theme-light';
  }
  return (
    <section className={'about ' + theme} id="about">
      <div className="container">

        <div className="row">
          <div className="col-lg-6 order-1 order-lg-2" data-aos="zoom-in" data-aos-delay="150">
            <img alt="" className="img-fluid" src="assets/img/music.jpg" />
          </div>
          <div className="col-lg-6 pt-4 pt-lg-0 order-2 order-lg-1 content" data-aos="fade-right">
            <h3 className="navbar-brand text-brand">
              About
              <span className="color-purple">Music</span>
              <span
                className="color-orange"
              >
                Brainz
              </span>
            </h3>
            <p className="fst-italic">
              MusicBrainz is an open music encyclopedia that collects music metadata and makes it available to the public.
              <br />
              <br />
              MusicBrainz aims to be:

            </p>
            <ul>
              <li>
                <i className="bi bi-check-circle" />
                The ultimate source of music information by allowing anyone to contribute and releasing the data under open licenses.

              </li>
              <li>
                <i className="bi bi-check-circle" />
                The universal lingua franca for music by providing a reliable and unambiguous form of music identification, enabling both people and machines to have meaningful conversations about music.
              </li>
              <li>
                <i className="bi bi-check-circle" />
                Like Wikipedia, MusicBrainz is maintained by a global community of users and we want everyone — including you — to participate and contribute.
              </li>
            </ul>
            <a className="read-more" href="https://musicbrainz.org" rel="noopener noreferrer" target="_blank">
              Read More
              <i className="bi bi-long-arrow-right" />
            </a>
          </div>
        </div>

      </div>
    </section>
  );
}
export default About;
