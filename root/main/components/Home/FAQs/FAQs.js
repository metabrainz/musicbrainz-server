import React from "react";

function Intro(props) {
    let theme;
    if (props.isDarkThemeActive) {
        theme = "dark";
    }
    else {
        theme = "light";
    }

    return(
        <section id="faq" className={"faq " + theme}>
            <div className="container" data-aos="fade-up">

                <div className="section-title">
                    <h2>Frequently Asked Questions</h2>
                    <p>This is a set of basic guides and FAQs that are maintained by the MusicBrainz community. Chances are, that if you have a question on how to use MusicBrainz, you will find the answer here. If you do not, please contact us using IRC or the forums</p>
                </div>

                <div className="faq-list">
                    <ul>
                        <li data-aos="fade-up" data-aos-delay="100">
                            <i className="bi bi-question-circle icon-help"/>
                            <a data-bs-toggle="collapse" className="collapsed" data-bs-target="#faq-list-1">
                                Do I have to provide an email address?
                                <i className="bi bi-chevron-down icon-show"/>
                                <i className="bi bi-chevron-up icon-close"/>
                            </a>
                            <div id="faq-list-1" className="collapse" data-bs-parent=".faq-list">
                                <p>
                                    You don&apos;t need to provide an email address, unless you want to change the contents of the database. If you do, the email address will need to be verified, so that other MusicBrainz editors can better communicate with you.
                                    If you enter your email address:

                                    You will be able to enter changes into the database (see Introduction to Editing).
                                    Other editors will be able to send messages using the &quot;Send email to editor&quot; function.
                                    You will be notified when edit notes are added to your edits.
                                    You will have the option to subscribe to the artists you like and be notified when new edits are entered for them.
                                    In all cases your email address will not be revealed to other MusicBrainz users.
                                </p>
                            </div>
                        </li>

                        <li data-aos="fade-up" data-aos-delay="200">
                            <i className="bi bi-question-circle icon-help"/>
                            <a data-bs-toggle="collapse" data-bs-target="#faq-list-2" className="collapsed">
                                What about my privacy?
                                <i className="bi bi-chevron-down icon-show"/>
                                <i className="bi bi-chevron-up icon-close"/></a>
                            <div id="faq-list-2" className="collapse" data-bs-parent=".faq-list">
                                <p>
                                    Rest assured that we will not pass your email address on to anyone, including other MusicBrainz users, without your most explicit consent. At any time you can fill in your email address if it&apos;s currently blank, blank it if it&apos;s currently filled in, or change from one address to another. Read on for the full MusicBrainz Privacy Policy.
                                    We will not send you any newsletters, promotional mailings, etc.
                                </p>
                            </div>
                        </li>

                        <li data-aos="fade-up" data-aos-delay="300">
                            <i className="bi bi-question-circle icon-help"/>
                            <a data-bs-toggle="collapse" data-bs-target="#faq-list-3" className="collapsed">
                                How do I delete my account?
                                <i className="bi bi-chevron-down icon-show"/><i className="bi bi-chevron-up icon-close"/></a>
                            <div id="faq-list-3" className="collapse" data-bs-parent=".faq-list">
                                <p>
                                    You can&apos;t completely delete your account. We need to keep at least the information that an account existed at some point, so that the database is kept consistent. However, you can automatically remove all your personal information by editing your profile and clicking the delete account link.

                                    This will irreversibly rename your account and clear your password, biography, email address, preferences, subscriptions, collections, ratings and tags, as well as prevent any further logins.
                                </p>
                            </div>
                        </li>

                        <li data-aos="fade-up" data-aos-delay="400">
                            <i className="bi bi-question-circle icon-help"/>
                            <a data-bs-toggle="collapse" data-bs-target="#faq-list-4" className="collapsed">
                                Why the name MusicBrainz?
                                <i className="bi bi-chevron-down icon-show"/><i className="bi bi-chevron-up icon-close"/></a>
                            <div id="faq-list-4" className="collapse" data-bs-parent=".faq-list">
                                <p>
                                    It indicates the overall goal of the project: a lot of people (brains) collaborating to enhance the digital music experience.
                                </p>
                            </div>
                        </li>

                        <li data-aos="fade-up" data-aos-delay="500">
                            <i className="bi bi-question-circle icon-help"/>
                            <a data-bs-toggle="collapse" data-bs-target="#faq-list-5" className="collapsed">
                                Can I do whatever I want to the information in the database?
                                <i className="bi bi-chevron-down icon-show"/><i className="bi bi-chevron-up icon-close"/></a>
                            <div id="faq-list-5" className="collapse" data-bs-parent=".faq-list">
                                <p>
                                    Anything within reason. We want the MusicBrainz database to reflect as accurately as possible the information contained on the release. Since we will be receiving data from many sources, we want the changes to be reviewed by other users of MusicBrainz.
                                </p>
                            </div>
                        </li>

                        <li data-aos="fade-up" data-aos-delay="600">
                            <i className="bi bi-question-circle icon-help"/>
                            <a data-bs-toggle="collapse" data-bs-target="#faq-list-6" className="collapsed">
                                How long will my edit(s) take to be approved / applied?
                                <i className="bi bi-chevron-down icon-show"/><i className="bi bi-chevron-up icon-close"/></a>
                            <div id="faq-list-6" className="collapse" data-bs-parent=".faq-list">
                                <p>
                                    It depends.

                                    Some edits (punctuation, capitalization) are considered Auto-edits for all users and are applied immediately.

                                    If you are changing an entity you yourself added less than 24 hours ago, you can enter most changes as auto-edits. Otherwise, most changes will require voting, and if no-one votes against your edit, it will be applied after 7 days.

                                    If your edit receives three unanimous yes votes, it will generally be applied after 1 hour. If it is considered a destructive edit, however, the edit will be applied after 48 hours to allow adequate time for other editors to review.

                                    If your edit receives more yes votes than no votes, it will be applied after 7 days.

                                    For many edit types (anything that wouldn&apos;t result in lost data), an Auto-editor may approve your edit to apply it immediately. This is quite common for typo fixes, adding URL relationships and fixes to obvious mistakes but it is at the Auto-editor&apos;s discretion and they are not required to do so.

                                    If your edit is to a popular artist that has many subscribers, you are likely to gather votes more quickly. If you provide evidence to back up your edits (as suggested in the Code of Conduct and How to Write Edit Notes) and your edits are of good quality, you will also collect yes votes more quickly.                                </p>
                            </div>
                        </li>

                    </ul>
                </div>

            </div>
        </section>
    )
}
export default Intro;