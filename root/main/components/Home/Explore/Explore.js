export default function Explore(props) {
    return(
        <section id="services" className={"services "+props.theme}>
            <div className="container">

                <div className="section-title">
                    <h2 data-bs-aos="fade-in">Explore MusicBrainz</h2>
                </div>

                <div className="row">
                    <div className="col-md-6 d-flex" data-bs-aos="fade-right">
                        <div className="card">
                            <div className="card-body">
                                <h5 className="card-title"><a href="https://community.metabrainz.org" target="_blank" rel="noopener noreferrer">Community Driven</a></h5>
                                <p className="card-text">
                                    MusicBrainz is a community-maintained open source encyclopedia of music information.

                                    This means that anyone — including you — can help contribute to the project by adding information about your favorite artists and their works.
                                </p>
                            </div>
                        </div>
                    </div>
                    <div className="col-md-6 d-flex" data-bs-aos="fade-left">
                        <div className="card">
                            <div className="card-body">
                                <h5 className="card-title"><a href="https://musicbrainz.org/doc/Development" target="_blank" rel="noopener noreferrer">Development</a></h5>
                                <p className="card-text">
                                    If you have a digital music collection, MusicBrainz Picard will help you tag your files.

                                    If you are a developer, our developer resources will help you in making use of our data.

                                    If you are a commercial user, our live data feed will provide your local database with replication packets to keep it in sync.
                                </p>
                            </div>
                        </div>

                    </div>
                    <div className="col-md-6 d-flex" data-bs-aos="fade-right">
                        <div className="card">
                            <div className="card-body">
                                <h5 className="card-title"><a href="https://musicbrainz.org/doc/General_FAQ#Why_would_I_need_to_use_MusicBrainz.3F_What.27s_wrong_with_Gracenote.27s_CDDB.3F" target="_blank" rel="noopener noreferrer">History</a></h5>
                                <p className="card-text">
                                    In 2000, Gracenote took over the free CDDB project and commercialized it, essentially charging users for accessing the very data they themselves contributed. In response, Robert Kaye founded MusicBrainz. The project has since grown rapidly from a one-man operation to an international community of enthusiasts that appreciates both music and music metadata. Along the way, the scope of the project has expanded from its origins as a mere CDDB replacement to the true music encyclopedia MusicBrainz is today.
                                </p>
                            </div>
                        </div>
                    </div>

                    <div className="col-md-6 d-flex" data-bs-aos="fade-left">
                        <div className="card">
                            <div className="card-body">
                                <h5 className="card-title"><a href="https://musicbrainz.org/doc/MusicBrainz_Database" target="_blank" rel="noopener noreferrer">MusicBrainz Database</a></h5>
                                <p className="card-text">
                                    The MusicBrainz Database stores all of the various pieces of information we collect about music, from artists and their releases to works and their composers, and much more.
                                    Most of the data in the MusicBrainz Database is licensed under CC0, which effectively places the data into the Public Domain. The remaining data is released under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 license.
                                    All our data is available for commercial licensing. If you are interested in licensing this data for commercial use, please contact us.
                                </p>
                            </div>
                        </div>
                    </div>
                    <div className="col-md-6 d-flex" data-bs-aos="fade-left">
                        <div className="card">
                            <div className="card-body">
                                <h5 className="card-title"><a href="https://musicbrainz.org/doc/Editing_FAQ" target="_blank" rel="noopener noreferrer">Varied and Never Ending</a></h5>
                                <p className="card-text">
                                    As an encyclopedia and as a community, MusicBrainz exists only to collect as much information about music as we can. We do not discriminate or prefer one &quot;type&quot; of music over another, and we try to collect information about as many different types of music as possible. Whether it is published or unpublished, popular or fringe, western or non-western, human or non-human — we want it all in MusicBrainz.
                                </p>
                            </div>
                        </div>
                    </div>
                    <div className="col-md-6 d-flex" data-bs-aos="fade-left">
                        <div className="card">
                            <div className="card-body">
                                <h5 className="card-title"><a href="https://musicbrainz.org/doc/How_Editing_Works" target="_blank" rel="noopener noreferrer">Editing Philosophy</a></h5>
                                <p className="card-text">
                                    Maintaining a comprehensive database of all types of music is a large task, and MusicBrainz depends on its users to spot mistakes in the database and then to take the initiative to correct these errors. To help with that task the MusicBrainz editing and voting system was designed, it gives MusicBrainz users the ability to update and maintain the database effectively and easily.
                                </p>
                            </div>
                        </div>
                    </div>

                </div>

            </div>
        </section>
    )
}