/**
 * Initialization code for the home page.
 */

'use strict';

var $ = require('jquery');
var m = require('mithril');
var lodashGet = require('lodash.get');

var QuickSearchProject = require('js/home-page/quickProjectSearchPlugin');
var NewAndNoteworthy = require('js/home-page/newAndNoteworthyPlugin');
var MeetingsAndConferences = require('js/home-page/meetingsAndConferencesPlugin');
var Preprints = require('js/home-page/preprintsPlugin');
//var Prereg = require('js/home-page/preregPlugin');
var PreregBanner = require('js/home-page/preregBannerPlugin');
var ScheduledBanner = require('js/home-page/scheduledBannerPlugin');
var InstitutionsPanel = require('js/home-page/institutionsPanelPlugin');
var ensureUserTimezone = require('js/ensureUserTimezone');

var columnSizeClass = '.col-md-10 col-md-offset-1 col-lg-8 col-lg-offset-2';

$(document).ready(function(){
    var osfHome = {
        view : function(ctrl, args) {
            // Camel-case institutions keys
            var _affiliatedInstitutions = lodashGet(window, 'contextVars.currentUser.institutions') || [];
            var affiliatedInstitutions = _affiliatedInstitutions.map(function(inst) {
                return {logoPath: inst.logo_path, id: inst.id, name: inst.name};
            });
            var _dashboardInstitutions = lodashGet(window, 'contextVars.dashboardInstitutions') || [];
            var dashboardInstitutions = _dashboardInstitutions.map(function(inst) {
                return {logoPath: inst.logo_path, id: inst.id, name: inst.name};
            });
            return [
                m('.scheduled-banner-background', m('.container',
                    [
                        m(columnSizeClass, m.component(ScheduledBanner, {}))
                    ]
                )),
                m('.prereg-banner', m('.container',
                    [
                        m('.row', [
                            m(columnSizeClass,  m.component(PreregBanner, {}))
                        ])
                    ]
                )),
                m('.quickSearch', m('.container.p-t-lg',
                    [
                        m('.row.m-t-lg', [
                            m(columnSizeClass, m.component(QuickSearchProject, {}))
                        ])
                    ]
                )),
                // TODO: We hide the institution logos on small screens. Better to make the carousel responsive.
                m('.institutions-panel.hidden-xs', m('.container',
                    [
                        m('.row', [
                            m(columnSizeClass,  m.component(InstitutionsPanel, {
                                affiliatedInstitutions: affiliatedInstitutions,
                                allInstitutions: dashboardInstitutions
                            }))
                        ])
                    ]
                )),
                m('.newAndNoteworthy', m('.container',
                    [
                        m('.row', [
                            m(columnSizeClass, m('h3', 'Discover Public Projects'))
                        ]),
                        m('.row', [
                            m(columnSizeClass, m.component(NewAndNoteworthy, {}))
                        ])

                    ]
                )),
                /*
                m('.prereg', m('.container',
                    [
                        m('.row', [
                            m(columnSizeClass,  m.component(Prereg, {}))
                        ])
                    ]
                )),
                */
                m('.meetings', m('.container',
                    [
                        m('.row', [
                            m(columnSizeClass,  m.component(MeetingsAndConferences, {}))
                        ])

                    ]
                )),
                m('.preprints', m('.container',
                    [
                        m('.row', [
                            m(columnSizeClass,  m.component(Preprints, {}))
                        ])

                    ]
                ))
            ];
        }
    };
    m.mount(document.getElementById('osfHome'), m.component(osfHome, {}));


    // If logged in...
    var user = window.contextVars.currentUser;
    if (user) {
        // Update user's timezone and locale
        ensureUserTimezone(user.timezone, user.locale, user.id);
    }
});
