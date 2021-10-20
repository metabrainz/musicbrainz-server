import React from "react";

function Supporters(props) {
    let theme;
    if (props.isDarkThemeActive) {
        theme = "theme-dark";
    } else {
        theme = "theme-light";
    }
    return (
        <section id="supporters" className={"section-with-bg "+ theme}>

            <div className="container" data-aos="fade-up">
                <div className="section-header">
                    <h2>Supporters</h2>
                </div>

                <div className="row no-gutters supporters-wrap clearfix" data-aos="zoom-in" data-aos-delay="100">

                    <div className="col-lg-3 col-md-4 col-xs-6">
                        <div className="supporter-logo">
                            <img src="assets/img/supporters/google.svg" className="img-thumbnail" alt=""/>
                        </div>
                    </div>

                    <div className="col-lg-3 col-md-4 col-xs-6">
                        <div className="supporter-logo">
                            <img src="assets/img/supporters/bbc.svg" className="img-thumbnail" alt=""/>
                        </div>
                    </div>

                    <div className="col-lg-3 col-md-4 col-xs-6">
                        <div className="supporter-logo">
                            <img src="assets/img/supporters/plex.svg" className="img-thumbnail" alt=""/>
                        </div>
                    </div>

                    <div className="col-lg-3 col-md-4 col-xs-6">
                        <div className="supporter-logo">
                            <img src="assets/img/supporters/lastfm.svg" className="img-thumbnail" alt=""/>
                        </div>
                    </div>

                    <div className="col-lg-3 col-md-4 col-xs-6">
                        <div className="supporter-logo">
                            <img src="assets/img/supporters/microsoft.png" className="img-thumbnail" alt=""/>
                        </div>
                    </div>

                    <div className="col-lg-3 col-md-4 col-xs-6">
                        <div className="supporter-logo">
                            <img src="assets/img/supporters/pandora.png" className="img-thumbnail" alt=""/>
                        </div>
                    </div>

                    <div className="col-lg-3 col-md-4 col-xs-6">
                        <div className="supporter-logo">
                            <img src="assets/img/supporters/hubbard.png" className="img-thumbnail" alt=""/>
                        </div>
                    </div>

                    <div className="col-lg-3 col-md-4 col-xs-6">
                        <div className="supporter-logo">
                            <img src="assets/img/supporters/Amazon_logo.svg" className="img-thumbnail" alt=""/>
                        </div>
                    </div>

                    <div className="col-lg-3 col-md-4 col-xs-6">
                        <div className="supporter-logo">
                            <img src="assets/img/supporters/ticketmaster.svg" className="img-thumbnail" alt=""/>
                        </div>
                    </div>

                    <div className="col-lg-3 col-md-4 col-xs-6">
                        <div className="supporter-logo">
                            <img src="assets/img/supporters/umg.svg" className="img-thumbnail" alt=""/>
                        </div>
                    </div>

                    <div className="col-lg-3 col-md-4 col-xs-6">
                        <div className="supporter-logo">
                            <img src="assets/img/supporters/siriusxm.jpg" className="img-thumbnail" alt=""/>
                        </div>
                    </div>

                    <div className="col-lg-3 col-md-4 col-xs-6">
                        <div className="supporter-logo">
                            <img src="assets/img/supporters/mc.svg" className="img-thumbnail" alt=""/>
                        </div>
                    </div>

                </div>

            </div>

        </section>
    )
}

export default Supporters;