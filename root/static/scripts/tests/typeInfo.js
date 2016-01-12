// Automatically generated, do not edit.
MB.relationshipEditor.exportTypeInfo({
   "place-release_group" : [
      {
         "type1" : "release_group",
         "hasDates" : true,
         "type0" : "place",
         "description" : "This links a release group with the place that held its launch event.",
         "cardinality0" : 0,
         "reversePhrase" : "launch event at",
         "childOrder" : 0,
         "cardinality1" : 0,
         "deprecated" : false,
         "id" : 721,
         "orderableDirection" : 0,
         "phrase" : "hosted launch event for",
         "gid" : "0a8c832b-2a85-4ca2-9f22-1dcbd43573a2"
      }
   ],
   "recording-release" : [
      {
         "type1" : "release",
         "hasDates" : true,
         "type0" : "recording",
         "description" : "Indicates that the recording contains samples from this release.",
         "cardinality0" : 0,
         "reversePhrase" : "{additional:additionally} sampled by",
         "childOrder" : 0,
         "cardinality1" : 1,
         "deprecated" : false,
         "id" : 69,
         "attributes" : {
            "1" : {
               "min" : 0,
               "max" : 1
            },
            "3" : {
               "min" : 0,
               "max" : null
            },
            "14" : {
               "min" : 0,
               "max" : null
            }
         },
         "orderableDirection" : 0,
         "phrase" : "{additional} samples from",
         "gid" : "967746f9-9d79-456c-9d1e-50116f0b27fc"
      }
   ],
   "artist-work" : [
      {
         "type1" : "work",
         "hasDates" : false,
         "type0" : "artist",
         "children" : [
            {
               "type1" : "work",
               "hasDates" : true,
               "type0" : "artist",
               "children" : [
                  {
                     "type1" : "work",
                     "hasDates" : true,
                     "type0" : "artist",
                     "description" : "Indicates the composer for this work, i.e. the artist who wrote the music (not necessarily the lyrics).",
                     "cardinality0" : 1,
                     "reversePhrase" : "{additional} composer",
                     "childOrder" : 0,
                     "cardinality1" : 0,
                     "deprecated" : false,
                     "id" : 168,
                     "attributes" : {
                        "1" : {
                           "min" : 0,
                           "max" : 1
                        }
                     },
                     "orderableDirection" : 0,
                     "phrase" : "{additional:additionally} composed",
                     "gid" : "d59d99ea-23d4-4a80-b066-edca32ee158f"
                  },
                  {
                     "type1" : "work",
                     "hasDates" : true,
                     "type0" : "artist",
                     "description" : "Indicates the lyricist for this work.",
                     "cardinality0" : 1,
                     "reversePhrase" : "{additional} {translated:translator|lyricist}",
                     "childOrder" : 1,
                     "cardinality1" : 0,
                     "deprecated" : false,
                     "id" : 165,
                     "attributes" : {
                        "1" : {
                           "min" : 0,
                           "max" : 1
                        },
                        "517" : {
                           "min" : 0,
                           "max" : 1
                        }
                     },
                     "orderableDirection" : 0,
                     "phrase" : "{additional} {translated} lyrics",
                     "gid" : "3e48faba-ec01-47fd-8e89-30e81161661c"
                  },
                  {
                     "type1" : "work",
                     "hasDates" : true,
                     "type0" : "artist",
                     "description" : "Indicates the librettist for this work.",
                     "cardinality0" : 1,
                     "reversePhrase" : "{additional} {translated:libretto translation|librettist}",
                     "childOrder" : 2,
                     "cardinality1" : 0,
                     "deprecated" : false,
                     "id" : 169,
                     "attributes" : {
                        "1" : {
                           "min" : 0,
                           "max" : 1
                        },
                        "517" : {
                           "min" : 0,
                           "max" : 1
                        }
                     },
                     "orderableDirection" : 0,
                     "phrase" : "{additional} {translated} libretto",
                     "gid" : "7474ab81-486f-40b5-8685-3a4f8ea624cb"
                  }
               ],
               "description" : "This relationship is used to link a work to the artist responsible for writing the music and/or the words (lyrics, libretto, etc.), when no more specific information is available. If possible, the more specific composer, lyricist and/or librettist types should be used, rather than this relationship type.",
               "cardinality0" : 1,
               "reversePhrase" : "{additional} writer",
               "childOrder" : 0,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 167,
               "attributes" : {
                  "1" : {
                     "min" : 0,
                     "max" : 1
                  }
               },
               "orderableDirection" : 0,
               "phrase" : "{additional:additionally} wrote",
               "gid" : "a255bca1-b157-4518-9108-7b147dc3fc68"
            },
            {
               "type1" : "work",
               "hasDates" : true,
               "type0" : "artist",
               "children" : [
                  {
                     "type1" : "work",
                     "hasDates" : true,
                     "type0" : "artist",
                     "children" : [
                        {
                           "type1" : "work",
                           "hasDates" : true,
                           "type0" : "artist",
                           "description" : "This indicates the person who orchestrated the work. Orchestration is a special type of arrangement. It means the adaptation of a composition for an orchestra, done in a way that the musical substance remains essentially unchanged. The orchestrator is also responsible for writing scores for an orchestra, band, choral group, individual instrumentalist(s) or vocalist(s). In practical terms it consists of deciding which instruments should play which notes in a piece of music.",
                           "cardinality0" : 1,
                           "reversePhrase" : "{additional} orchestrator",
                           "childOrder" : 1,
                           "cardinality1" : 0,
                           "deprecated" : false,
                           "id" : 164,
                           "attributes" : {
                              "1" : {
                                 "min" : 0,
                                 "max" : 1
                              }
                           },
                           "orderableDirection" : 0,
                           "phrase" : "{additional:additionally} orchestrated",
                           "gid" : "0a1771e1-8639-4740-8a43-bdafc050c3da"
                        }
                     ],
                     "description" : "This indicates the artist who arranged a tune into a form suitable for performance. 'Arrangement' is used as a catch-all term for all processes that turn a composition into a form that can be played by a specific type of ensemble.",
                     "cardinality0" : 1,
                     "reversePhrase" : "{additional} {instrument:%|instruments} arranger",
                     "childOrder" : 1,
                     "cardinality1" : 0,
                     "deprecated" : false,
                     "id" : 282,
                     "attributes" : {
                        "1" : {
                           "min" : 0,
                           "max" : 1
                        },
                        "14" : {
                           "min" : 0,
                           "max" : null
                        }
                     },
                     "orderableDirection" : 0,
                     "phrase" : "{additional:additionally} {instrument:%|instruments} arranged",
                     "gid" : "0084e70a-873e-4f7f-b3ff-635b9e863dae"
                  },
                  {
                     "type1" : "work",
                     "hasDates" : true,
                     "type0" : "artist",
                     "description" : "This indicates the artist who arranged a tune into a form suitable for performance. 'Arrangement' is used as a catch-all term for all processes that turn a composition into a form that can be played by a specific type of ensemble.",
                     "cardinality0" : 1,
                     "reversePhrase" : "{additional} {vocal:%|vocals} arranger",
                     "childOrder" : 2,
                     "cardinality1" : 0,
                     "deprecated" : false,
                     "id" : 294,
                     "attributes" : {
                        "1" : {
                           "min" : 0,
                           "max" : 1
                        },
                        "3" : {
                           "min" : 0,
                           "max" : null
                        }
                     },
                     "orderableDirection" : 0,
                     "phrase" : "{additional:additionally} {vocal:%|vocals} arranged",
                     "gid" : "6a88b92b-8fb5-41b3-aa1f-169ee7e05ed6"
                  }
               ],
               "description" : "This indicates the artist who arranged a tune into a form suitable for performance. 'Arrangement' is used as a catch-all term for all processes that turn a composition into a form that can be played by a specific type of ensemble.",
               "cardinality0" : 1,
               "reversePhrase" : "{additional} arranger",
               "childOrder" : 0,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 293,
               "attributes" : {
                  "1" : {
                     "min" : 0,
                     "max" : 1
                  }
               },
               "orderableDirection" : 0,
               "phrase" : "{additional:additionally} arranged",
               "gid" : "d3fd781c-5894-47e2-8c12-86cc0e2c8d08"
            }
         ],
         "cardinality0" : 1,
         "reversePhrase" : "composition",
         "childOrder" : 0,
         "cardinality1" : 0,
         "deprecated" : false,
         "id" : 170,
         "orderableDirection" : 0,
         "phrase" : "composition",
         "gid" : "cc9fcb45-7ab5-4629-bc5f-277f2592fa5a"
      },
      {
         "type1" : "work",
         "hasDates" : true,
         "type0" : "artist",
         "children" : [
            {
               "type1" : "work",
               "hasDates" : true,
               "type0" : "artist",
               "description" : "Indicates the publisher of this work. This is <strong>not</strong> the same concept as the <a href=\"/doc/Label\">record label</a>.",
               "cardinality0" : 1,
               "reversePhrase" : "publisher",
               "childOrder" : 9,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 161,
               "orderableDirection" : 0,
               "phrase" : "published",
               "gid" : "a442b140-830b-30b0-a4aa-2e36f098b6aa"
            }
         ],
         "description" : "Indicates a miscellaneous support role. This is usually stated in the liner notes of an album.",
         "cardinality0" : 1,
         "reversePhrase" : "miscellaneous support",
         "childOrder" : 2,
         "cardinality1" : 0,
         "deprecated" : false,
         "id" : 162,
         "orderableDirection" : 0,
         "phrase" : "miscellaneous roles",
         "gid" : "7d166271-99c7-3a13-ae96-d2aab758029d"
      }
   ],
   "artist-series" : [
      {
         "type1" : "series",
         "hasDates" : false,
         "type0" : "artist",
         "description" : "This relationship is used to link a catalogue work series to a person whose work it catalogues.",
         "cardinality0" : 0,
         "reversePhrase" : "catalogues work of",
         "childOrder" : 0,
         "cardinality1" : 0,
         "deprecated" : false,
         "id" : 750,
         "orderableDirection" : 0,
         "phrase" : "has catalogue",
         "gid" : "b792d0a6-a443-4e00-8882-c4f2bef56511"
      },
      {
         "type1" : "series",
         "hasDates" : true,
         "type0" : "artist",
         "description" : "This relationship is used to link a catalogue work series to a person who was involved in compiling it.",
         "cardinality0" : 0,
         "reversePhrase" : "cataloguer",
         "childOrder" : 0,
         "cardinality1" : 0,
         "deprecated" : false,
         "id" : 751,
         "attributes" : {
            "1" : {
               "min" : 0,
               "max" : 1
            }
         },
         "orderableDirection" : 0,
         "phrase" : "catalogued",
         "gid" : "2a1b5f1d-b712-4791-8079-57f95ce197d7"
      }
   ],
   "label-recording" : [
      {
         "type1" : "recording",
         "hasDates" : true,
         "type0" : "label",
         "description" : "Indicates the publisher of this recording. This is <strong>not</strong> the same concept as the <a href=\"/doc/Label\">record label</a>.",
         "cardinality0" : 1,
         "reversePhrase" : "publisher",
         "childOrder" : 1,
         "cardinality1" : 0,
         "deprecated" : false,
         "id" : 206,
         "orderableDirection" : 0,
         "phrase" : "published",
         "gid" : "51e4a303-8215-4db6-9a9f-ebe95442dbef"
      }
   ],
   "area-work" : [
      {
         "type1" : "work",
         "hasDates" : true,
         "type0" : "area",
         "description" : "Designates that a work is or was the anthem for an area",
         "cardinality0" : 0,
         "reversePhrase" : "anthem of",
         "childOrder" : 0,
         "cardinality1" : 0,
         "deprecated" : false,
         "id" : 357,
         "orderableDirection" : 0,
         "phrase" : "anthem",
         "gid" : "536b4ee4-bb2d-3b6f-a3f1-082f22e5b17d"
      },
      {
         "type1" : "work",
         "hasDates" : true,
         "type0" : "area",
         "description" : "Indicates the area where the work had its first performance",
         "cardinality0" : 0,
         "reversePhrase" : "premiered at",
         "childOrder" : 0,
         "cardinality1" : 0,
         "deprecated" : false,
         "id" : 715,
         "orderableDirection" : 0,
         "phrase" : "premieres hosted",
         "gid" : "c6bd908f-41f1-4ff3-83f3-df514278d994"
      }
   ],
   "place-release" : [
      {
         "type1" : "release",
         "hasDates" : true,
         "type0" : "place",
         "description" : "Links a release to the place it was recorded at.",
         "cardinality0" : 1,
         "reversePhrase" : "recorded at",
         "childOrder" : 0,
         "cardinality1" : 0,
         "deprecated" : false,
         "id" : 695,
         "orderableDirection" : 0,
         "phrase" : "recording location for",
         "gid" : "3b1fae9f-5b22-42c5-a40c-d1e5c9b90251"
      },
      {
         "type1" : "release",
         "hasDates" : true,
         "type0" : "place",
         "description" : "Links a release to the place it was mixed at.",
         "cardinality0" : 1,
         "reversePhrase" : "mixed at",
         "childOrder" : 1,
         "cardinality1" : 0,
         "deprecated" : false,
         "id" : 696,
         "orderableDirection" : 0,
         "phrase" : "mixing location for",
         "gid" : "8ebfc2f6-0ac7-40f6-b03e-67fe3428f5d4"
      },
      {
         "type1" : "release",
         "hasDates" : true,
         "type0" : "place",
         "description" : "Links a release to the place it was mastered at.",
         "cardinality0" : 1,
         "reversePhrase" : "mastered at",
         "childOrder" : 2,
         "cardinality1" : 0,
         "deprecated" : false,
         "id" : 697,
         "orderableDirection" : 0,
         "phrase" : "mastering location for",
         "gid" : "5d075afa-6bb8-4327-9528-e3e4d3d68f49"
      },
      {
         "type1" : "release",
         "hasDates" : true,
         "type0" : "place",
         "description" : "This links a release with the place that held its launch event.",
         "cardinality0" : 1,
         "reversePhrase" : "launch event at",
         "childOrder" : 3,
         "cardinality1" : 0,
         "deprecated" : false,
         "id" : 720,
         "orderableDirection" : 0,
         "phrase" : "hosted launch event for",
         "gid" : "b76cedb7-3d5b-40b3-a885-0249c022c7b1"
      }
   ],
   "label-work" : [
      {
         "type1" : "work",
         "hasDates" : true,
         "type0" : "label",
         "description" : "Indicates the publisher of this work. This is <strong>not</strong> the same concept as the <a href=\"/doc/Label\">record label</a>.",
         "cardinality0" : 1,
         "reversePhrase" : "publisher",
         "childOrder" : 1,
         "cardinality1" : 0,
         "deprecated" : false,
         "id" : 208,
         "orderableDirection" : 0,
         "phrase" : "published",
         "gid" : "05ee6f18-4517-342d-afdf-5897f64276e3"
      }
   ],
   "release_group-release_group" : [
      {
         "type1" : "release_group",
         "hasDates" : false,
         "type0" : "release_group",
         "children" : [
            {
               "type1" : "release_group",
               "hasDates" : false,
               "type0" : "release_group",
               "description" : "This is used to indicate that a release group is a live performance of a studio release group.",
               "cardinality0" : 0,
               "reversePhrase" : "live performances",
               "childOrder" : 0,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 17,
               "orderableDirection" : 0,
               "phrase" : "live performance of",
               "gid" : "62beff0a-679c-43f3-8fe6-f6c8ed8581e4"
            },
            {
               "type1" : "release_group",
               "hasDates" : false,
               "type0" : "release_group",
               "description" : "This relationship type is used to indicate that a release group is a cover version of another release group, i.e. when an artist performs a new rendition of another artist's album.<br/> For individual songs, see the <a href=\"/relationship/a3005666-a872-32c3-ad06-98af558e99b0\">recording-work performance relationship type</a>.",
               "cardinality0" : 0,
               "reversePhrase" : "{translated} {parody:parodies|covers}",
               "childOrder" : 3,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 15,
               "attributes" : {
                  "517" : {
                     "min" : 0,
                     "max" : 1
                  },
                  "511" : {
                     "min" : 0,
                     "max" : 1
                  }
               },
               "orderableDirection" : 0,
               "phrase" : "{translated} {parody:parody|cover} of",
               "gid" : "cf02e524-9d5b-46b7-a88e-329737395818"
            }
         ],
         "cardinality0" : 0,
         "reversePhrase" : "covers or other versions",
         "childOrder" : 0,
         "cardinality1" : 0,
         "deprecated" : false,
         "id" : 12,
         "orderableDirection" : 0,
         "phrase" : "covers or other versions",
         "gid" : "38278b3b-30e6-304c-b0db-5ba701eb0268"
      },
      {
         "type1" : "release_group",
         "hasDates" : false,
         "type0" : "release_group",
         "children" : [
            {
               "type1" : "release_group",
               "hasDates" : false,
               "type0" : "release_group",
               "description" : "This is used to link a release group containing a <a href=\"/doc/Mix_Terminology#DJ_mix\">DJ-mixed</a> version of a release to the release group containing the source release. See <a href=\"/relationship/9162dedd-790c-446c-838e-240f877dbfe2\">DJ-mixer</a> for crediting the person who created the DJ-mix.",
               "cardinality0" : 0,
               "reversePhrase" : "DJ-mixed versions",
               "childOrder" : 0,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 8,
               "orderableDirection" : 0,
               "phrase" : "DJ-mix of",
               "gid" : "d3286b50-a9d9-4cc3-94ad-cd7e2ffc787a"
            },
            {
               "type1" : "release_group",
               "hasDates" : false,
               "type0" : "release_group",
               "description" : "This links a <a href=\"/doc/Mix_Terminology#remix\">remix</a> release group to the source release group and is used to indicate that the release group includes remixed versions of all (or most of) the tracks in the other release group.",
               "cardinality0" : 0,
               "reversePhrase" : "remixes",
               "childOrder" : 0,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 9,
               "orderableDirection" : 0,
               "phrase" : "remix of",
               "gid" : "04e0449b-6fb0-48f6-8b9d-0bd41d9b8d76"
            },
            {
               "type1" : "release_group",
               "hasDates" : false,
               "type0" : "release_group",
               "description" : "This is used to indicate that the release group is a mash-up <a href=\"/doc/Mix_Terminology#mash-up\">mash-up</a> of two (or more) other release groups.",
               "cardinality0" : 0,
               "reversePhrase" : "mash-ups",
               "childOrder" : 1,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 10,
               "orderableDirection" : 0,
               "phrase" : "mash-up of",
               "gid" : "03786c2a-cd9d-4148-b3ea-35ea61de1283"
            }
         ],
         "cardinality0" : 0,
         "reversePhrase" : "remixes and compilations",
         "childOrder" : 1,
         "cardinality1" : 0,
         "deprecated" : false,
         "id" : 13,
         "orderableDirection" : 0,
         "phrase" : "remixes and compilations",
         "gid" : "3494ba38-4ac5-40b6-aa6f-4ac7546cd104"
      },
      {
         "type1" : "release_group",
         "hasDates" : false,
         "type0" : "release_group",
         "description" : "This indicates that a single or EP release group includes at least one track taken from an album release group.​ This allows a release group to be linked to its associated singles and EPs.",
         "cardinality0" : 0,
         "reversePhrase" : "associated {EP:EPs|singles}",
         "childOrder" : 3,
         "cardinality1" : 0,
         "deprecated" : false,
         "id" : 11,
         "attributes" : {
            "545" : {
               "min" : 0,
               "max" : 1
            }
         },
         "orderableDirection" : 0,
         "phrase" : "{EP:EP|single} which was taken from",
         "gid" : "fcf680a9-6871-4519-8c4b-8c6549575b35"
      }
   ],
   "recording-work" : [
      {
         "type1" : "work",
         "hasDates" : true,
         "type0" : "recording",
         "description" : "This is used to link works to their recordings.",
         "cardinality0" : 0,
         "reversePhrase" : "{live} {medley:medleys including} {partial} {instrumental} {cover} recordings",
         "childOrder" : 0,
         "cardinality1" : 1,
         "deprecated" : false,
         "id" : 278,
         "attributes" : {
            "578" : {
               "min" : 0,
               "max" : 1
            },
            "750" : {
               "min" : 0,
               "max" : 1
            },
            "567" : {
               "min" : 0,
               "max" : 1
            },
            "580" : {
               "min" : 0,
               "max" : 1
            },
            "579" : {
               "min" : 0,
               "max" : 1
            }
         },
         "orderableDirection" : 0,
         "phrase" : "{live} {medley:medley including a} {partial} {instrumental} {cover} recording of",
         "gid" : "a3005666-a872-32c3-ad06-98af558e99b0"
      },
      {
         "type1" : "work",
         "hasDates" : true,
         "type0" : "recording",
         "description" : "This relationship is deprecated, please use the \"medley\" attribute of \"recording of\" instead.",
         "cardinality0" : 0,
         "reversePhrase" : "referred to in medleys",
         "childOrder" : 1,
         "cardinality1" : 1,
         "deprecated" : true,
         "id" : 244,
         "orderableDirection" : 0,
         "phrase" : "medley of",
         "gid" : "12ac9db0-ec26-3567-be3a-2e662e617803"
      }
   ],
   "label-release" : [
      {
         "type1" : "release",
         "hasDates" : true,
         "type0" : "label",
         "children" : [
            {
               "type1" : "release",
               "hasDates" : true,
               "type0" : "label",
               "description" : "This indicates the organization that promotes (or contracts out promotion) for a release. This is <strong>not</strong> the same concept as the <a href=\"/doc/Label\">record label</a>.",
               "cardinality0" : 1,
               "reversePhrase" : "promoted by",
               "childOrder" : 0,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 359,
               "orderableDirection" : 0,
               "phrase" : "promoted",
               "gid" : "b60d9455-aba8-4d81-b543-dbfa68044dcc"
            },
            {
               "type1" : "release",
               "hasDates" : true,
               "type0" : "label",
               "description" : "This indicates the organization that manufactures (or contracts out manufacturing).  This is <strong>not</strong> the same concept as the <a href=\"/doc/Label\">record label</a>.",
               "cardinality0" : 1,
               "reversePhrase" : "manufactured by",
               "childOrder" : 0,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 360,
               "orderableDirection" : 0,
               "phrase" : "manufactured",
               "gid" : "835e514a-c5bc-44f7-be7b-92452a3f5d60"
            },
            {
               "type1" : "release",
               "hasDates" : true,
               "type0" : "label",
               "description" : "This indicates the organization that distributes (or contracts out distribution).  This is <strong>not</strong> the same concept as the <a href=\"/doc/Label\">record label</a>.",
               "cardinality0" : 1,
               "reversePhrase" : "distributed by",
               "childOrder" : 0,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 361,
               "orderableDirection" : 0,
               "phrase" : "distributed",
               "gid" : "4f89b0a1-e135-41e4-94a7-e3d2a95f31a1"
            },
            {
               "type1" : "release",
               "hasDates" : true,
               "type0" : "label",
               "description" : "This indicates the organization which releases a release. This is <strong>not</strong> the same concept as the <a href=\"/doc/Label\">record label</a>.",
               "cardinality0" : 1,
               "reversePhrase" : "publisher",
               "childOrder" : 0,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 362,
               "orderableDirection" : 0,
               "phrase" : "published",
               "gid" : "25858332-bf31-4ad6-85b6-6a3bccebf02e"
            },
            {
               "type1" : "release",
               "hasDates" : true,
               "type0" : "label",
               "children" : [
                  {
                     "type1" : "release",
                     "hasDates" : true,
                     "type0" : "label",
                     "description" : "This relationship indicates the label is the <a href=\"//en.wikipedia.org/wiki/Sound_recording_copyright_symbol\">phonographic copyright</a> holder for this release. ​",
                     "cardinality0" : 1,
                     "reversePhrase" : "phonographic copyright by",
                     "childOrder" : 0,
                     "cardinality1" : 0,
                     "deprecated" : false,
                     "id" : 711,
                     "orderableDirection" : 0,
                     "phrase" : "holds phonographic copyright for",
                     "gid" : "287361d2-1dce-4d39-9f82-222b786e2b30"
                  },
                  {
                     "type1" : "release",
                     "hasDates" : true,
                     "type0" : "label",
                     "description" : "This relationship indicates the company that was the licensor of this release.",
                     "cardinality0" : 1,
                     "reversePhrase" : "licensed from",
                     "childOrder" : 0,
                     "cardinality1" : 0,
                     "deprecated" : false,
                     "id" : 712,
                     "orderableDirection" : 0,
                     "phrase" : "licensed",
                     "gid" : "45a18e5d-b610-412f-acfc-c43ca835c24f"
                  }
               ],
               "description" : "This relationship indicates the label is the copyright holder for this release.",
               "cardinality0" : 1,
               "reversePhrase" : "copyrighted by",
               "childOrder" : 0,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 708,
               "orderableDirection" : 0,
               "phrase" : "holds copyright for",
               "gid" : "2ed5a497-4f85-4b3f-831e-d341ad28c544"
            }
         ],
         "cardinality0" : 1,
         "reversePhrase" : "business association with",
         "childOrder" : 0,
         "cardinality1" : 0,
         "deprecated" : false,
         "id" : 66,
         "orderableDirection" : 0,
         "phrase" : "business association",
         "gid" : "cee6eeeb-14f5-4079-9789-632b46acfd33"
      },
      {
         "type1" : "release",
         "hasDates" : false,
         "type0" : "label",
         "description" : "This indicates the rights society associated with a release.​ The rights society is an organization which collects royalties on behalf of the artists.",
         "cardinality0" : 1,
         "reversePhrase" : "rights society",
         "childOrder" : 0,
         "cardinality1" : 0,
         "deprecated" : false,
         "id" : 349,
         "orderableDirection" : 0,
         "phrase" : "rights society associated with",
         "gid" : "06fc3d02-ae89-4566-ad49-624500d6beb7"
      }
   ],
   "instrument-instrument" : [
      {
         "type1" : "instrument",
         "hasDates" : false,
         "type0" : "instrument",
         "children" : [
            {
               "type1" : "instrument",
               "hasDates" : false,
               "type0" : "instrument",
               "description" : "type of",
               "cardinality0" : 0,
               "reversePhrase" : "type of",
               "childOrder" : 0,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 736,
               "orderableDirection" : 0,
               "phrase" : "subtypes",
               "gid" : "40b2bd3f-1457-3ceb-810d-57f87f0f74f0"
            },
            {
               "type1" : "instrument",
               "hasDates" : false,
               "type0" : "instrument",
               "description" : "derived from",
               "cardinality0" : 0,
               "reversePhrase" : "derived from",
               "childOrder" : 0,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 737,
               "orderableDirection" : 0,
               "phrase" : "derivations",
               "gid" : "deaf1d50-e624-3069-91bd-88e51cafd605"
            },
            {
               "type1" : "instrument",
               "hasDates" : false,
               "type0" : "instrument",
               "description" : "related to",
               "cardinality0" : 0,
               "reversePhrase" : "related instruments",
               "childOrder" : 0,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 738,
               "orderableDirection" : 0,
               "phrase" : "related instruments",
               "gid" : "0fd327f5-8be4-3b9a-8852-2982c1a830ee"
            },
            {
               "type1" : "instrument",
               "hasDates" : false,
               "type0" : "instrument",
               "description" : "parts",
               "cardinality0" : 0,
               "reversePhrase" : "part of",
               "childOrder" : 0,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 739,
               "orderableDirection" : 0,
               "phrase" : "consists of",
               "gid" : "5ee4568f-d8bd-321d-9426-0ff6819ae6b5"
            }
         ],
         "cardinality0" : 0,
         "reversePhrase" : "child of",
         "childOrder" : 0,
         "cardinality1" : 0,
         "deprecated" : false,
         "id" : 735,
         "orderableDirection" : 0,
         "phrase" : "children",
         "gid" : "12678b88-1adb-3536-890e-9b39b9a14b2d"
      }
   ],
   "label-label" : [
      {
         "type1" : "label",
         "hasDates" : false,
         "type0" : "label",
         "children" : [
            {
               "type1" : "label",
               "hasDates" : true,
               "type0" : "label",
               "description" : "This describes a situation where one label is (or was) a subsidiary of another label, during a given period of time.​ This should be used either to describe the fact a label is a subdivision of another one, or, through corporate acquisition of the former label, has become a subdivision of another one.",
               "cardinality0" : 0,
               "reversePhrase" : "parent label",
               "childOrder" : 0,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 200,
               "orderableDirection" : 0,
               "phrase" : "subsidiaries",
               "gid" : "ab7a9be0-c060-4852-8f2e-4faf5b33231e"
            },
            {
               "type1" : "label",
               "hasDates" : true,
               "type0" : "label",
               "description" : "This describes a situation where one label is reissuing, under its own name, (part of) another label's catalog.​ This can happen in at least three cases: <ul> <li>A label acquires a lease on another label's catalog, for a period of time, in a specific region of the world.</li> <li>A label buys the rights to a defunct label's catalog, or buys a label (with its catalog) and dismantles it.</li> <li>A bootleg label reissues another label's catalog.</li> </ul>",
               "cardinality0" : 0,
               "reversePhrase" : "catalog reissued by",
               "childOrder" : 1,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 201,
               "orderableDirection" : 0,
               "phrase" : "reissuing the catalog of",
               "gid" : "1a502d1c-2c30-4efa-8cd7-39af664e3af8"
            },
            {
               "type1" : "label",
               "hasDates" : true,
               "type0" : "label",
               "description" : "This describes a situation where a label has changed its name, either for purely aesthetic reasons or following a buyout/sellout/spin-off.​ Extra care should be taken with cases where complicated merge/split/restructure financial operations are done. For example, it's not a good idea to rename the label <a href=\"/label/99a24d71-54c1-4d3f-88cc-00fbcc4fce83\">Verve</a> into <a href=\"/label/4fb00dfd-7674-44c0-bf67-79daf8c61767\">The Verve Music Group</a>, as Verve continued its existence thereafter as an imprint.",
               "cardinality0" : 0,
               "reversePhrase" : "renamed from",
               "childOrder" : 2,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 202,
               "orderableDirection" : 0,
               "phrase" : "renamed into",
               "gid" : "e6159066-6013-4d09-a2f8-bc473f21e89e"
            },
            {
               "type1" : "label",
               "hasDates" : true,
               "type0" : "label",
               "description" : "This describes a situation where one label is distributing (part of) another label's catalog, in a country/region of the world, during a period of time.",
               "cardinality0" : 0,
               "reversePhrase" : "distributors",
               "childOrder" : 3,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 203,
               "orderableDirection" : 0,
               "phrase" : "distributor for",
               "gid" : "e0636054-32b7-4dd5-97a9-6e5664d443bc"
            },
            {
               "type1" : "label",
               "hasDates" : true,
               "type0" : "label",
               "description" : "This indicates that a record label (company) owns or has the right to use an imprint.",
               "cardinality0" : 0,
               "reversePhrase" : "imprint of",
               "childOrder" : 4,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 725,
               "orderableDirection" : 0,
               "phrase" : "imprints",
               "gid" : "23f8c592-006d-4214-9080-c4e5000c05d7"
            }
         ],
         "cardinality0" : 0,
         "reversePhrase" : "business association",
         "childOrder" : 0,
         "cardinality1" : 0,
         "deprecated" : false,
         "id" : 205,
         "orderableDirection" : 0,
         "phrase" : "business association",
         "gid" : "0c1ff137-fca5-4148-82b7-8bce3c69165a"
      }
   ],
   "instrument-url" : [
      {
         "type1" : "url",
         "hasDates" : false,
         "type0" : "instrument",
         "description" : "wikipedia",
         "cardinality0" : 0,
         "reversePhrase" : "Wikipedia",
         "childOrder" : 0,
         "cardinality1" : 0,
         "deprecated" : false,
         "id" : 731,
         "orderableDirection" : 0,
         "phrase" : "Wikipedia",
         "gid" : "b21fd997-c813-3bc6-99cc-c64323bd15d3"
      },
      {
         "type1" : "url",
         "hasDates" : false,
         "type0" : "instrument",
         "description" : "image",
         "cardinality0" : 0,
         "reversePhrase" : "image",
         "childOrder" : 0,
         "cardinality1" : 0,
         "deprecated" : false,
         "id" : 732,
         "orderableDirection" : 0,
         "phrase" : "image",
         "gid" : "f64eacbd-1ea1-381e-9886-2cfb552b7d90"
      },
      {
         "type1" : "url",
         "hasDates" : false,
         "type0" : "instrument",
         "description" : "wikidata",
         "cardinality0" : 0,
         "reversePhrase" : "Wikidata",
         "childOrder" : 0,
         "cardinality1" : 0,
         "deprecated" : false,
         "id" : 733,
         "orderableDirection" : 0,
         "phrase" : "Wikidata",
         "gid" : "1486fccd-cf59-35e4-9399-b50e2b255877"
      },
      {
         "type1" : "url",
         "hasDates" : false,
         "type0" : "instrument",
         "description" : "information page",
         "cardinality0" : 0,
         "reversePhrase" : "information page",
         "childOrder" : 0,
         "cardinality1" : 0,
         "deprecated" : false,
         "id" : 734,
         "orderableDirection" : 0,
         "phrase" : "information page",
         "gid" : "0e62afec-12f3-3d0f-b122-956207839854"
      }
   ],
   "recording-recording" : [
      {
         "type1" : "recording",
         "hasDates" : false,
         "type0" : "recording",
         "children" : [
            {
               "type1" : "recording",
               "hasDates" : false,
               "type0" : "recording",
               "description" : "This is used to link a karaoke version of a song to the original song.​<br/><br/> A karaoke version is a version of the song with the main vocals removed, designed to be used for karaoke. These are generally produced from the original masters by muting the main vocal track or by using post-processing filters to remove the vocals. Karaoke versions can be found labelled in numerous different ways other than \"karaoke\": instrumental (even if backing vocals are still present), off vocal, backing track, etc.",
               "cardinality0" : 0,
               "reversePhrase" : "karaoke version of",
               "childOrder" : 0,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 226,
               "orderableDirection" : 0,
               "phrase" : "karaoke versions",
               "gid" : "39a08d0e-26e4-44fb-ae19-906f5fe9435d"
            },
            {
               "type1" : "recording",
               "hasDates" : false,
               "type0" : "recording",
               "description" : "This links an edit to its original recording. An \"edit\", for this relationship, can be a radio edit (which involves streamlining a longer track to around the 3 minute mark in order to make it suitable for radio play), or a shortened, censored, or otherwise edited version of the same material. The person who edited the recording can be linked using the <a href=\"/relationship/40dff87a-e475-4aa6-b615-9935b564d756\">editor relationship type</a>.",
               "cardinality0" : 0,
               "reversePhrase" : "edits",
               "childOrder" : 0,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 309,
               "orderableDirection" : 0,
               "phrase" : "edit of",
               "gid" : "ce01b3ac-dd47-4702-9302-085344f96e84"
            },
            {
               "type1" : "recording",
               "hasDates" : true,
               "type0" : "recording",
               "description" : "This relationship type is <strong>deprecated</strong>! <a href=\"/doc/Style/Recording#Recordings_with_Different_Mastering\">Different remasters should be merged.</a>",
               "cardinality0" : 0,
               "reversePhrase" : "remasters",
               "childOrder" : 9,
               "cardinality1" : 0,
               "deprecated" : true,
               "id" : 236,
               "orderableDirection" : 0,
               "phrase" : "remaster of",
               "gid" : "b984b8d1-76f9-43d7-aa3e-0b3a46999dea"
            },
            {
               "type1" : "recording",
               "hasDates" : false,
               "type0" : "recording",
               "description" : "This relationship type is <strong>deprecated</strong>! If two recordings are identical, please merge them.",
               "cardinality0" : 0,
               "reversePhrase" : "earliest release",
               "childOrder" : 9,
               "cardinality1" : 0,
               "deprecated" : true,
               "id" : 238,
               "orderableDirection" : 0,
               "phrase" : "later releases",
               "gid" : "f5f41b82-ecc7-488e-adf3-12356885d724"
            }
         ],
         "cardinality0" : 0,
         "reversePhrase" : "other versions",
         "childOrder" : 0,
         "cardinality1" : 0,
         "deprecated" : false,
         "id" : 233,
         "orderableDirection" : 0,
         "phrase" : "other versions",
         "gid" : "6a76ad99-cc5d-4ebc-a6e4-b2eb2eb3ad98"
      },
      {
         "type1" : "recording",
         "hasDates" : false,
         "type0" : "recording",
         "children" : [
            {
               "type1" : "recording",
               "hasDates" : true,
               "type0" : "recording",
               "description" : "This is used to link a <a href=\"/doc/Mix_Terminology#DJ_mix\">DJ-mixed</a> recording to each of the source recordings. See <a href=\"/relationship/28338ee6-d578-485a-bb53-61dbfd7c6545\">DJ-mixer</a> for crediting the person who created the DJ-mix.",
               "cardinality0" : 0,
               "reversePhrase" : "DJ-mixes",
               "childOrder" : 0,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 227,
               "orderableDirection" : 0,
               "phrase" : "DJ-mix of",
               "gid" : "451076df-61cf-46ab-9921-555cab2f050d"
            },
            {
               "type1" : "recording",
               "hasDates" : true,
               "type0" : "recording",
               "description" : "This indicates that a recording is a compilation of several other recordings.​ This applies to one long recording that contains multiple songs, one after the other, in which the audio material of the original recordings has not been altered. If the tracks are pitched or blended into each other, the <a href=\"/relationship/451076df-61cf-46ab-9921-555cab2f050d\">DJ-mix relationship type</a> may be more appropriate.",
               "cardinality0" : 0,
               "reversePhrase" : "compiled in",
               "childOrder" : 0,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 228,
               "orderableDirection" : 0,
               "phrase" : "compilation of",
               "gid" : "1b6311e8-5f81-43b7-8c55-4bbae71ec00c"
            },
            {
               "type1" : "recording",
               "hasDates" : true,
               "type0" : "recording",
               "description" : "This links a <a href=\"/doc/Mix_Terminology#remix\">remixed</a> recording to the source recording.",
               "cardinality0" : 0,
               "reversePhrase" : "remixes",
               "childOrder" : 0,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 230,
               "orderableDirection" : 0,
               "phrase" : "remix of",
               "gid" : "bfbdb55a-b857-473a-8f2e-a9c09e45c3f5"
            },
            {
               "type1" : "recording",
               "hasDates" : true,
               "type0" : "recording",
               "description" : "Indicates that the recording contains samples from another.",
               "cardinality0" : 0,
               "reversePhrase" : "{additional:additionally} sampled by",
               "childOrder" : 0,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 231,
               "attributes" : {
                  "1" : {
                     "min" : 0,
                     "max" : 1
                  },
                  "3" : {
                     "min" : 0,
                     "max" : null
                  },
                  "14" : {
                     "min" : 0,
                     "max" : null
                  }
               },
               "orderableDirection" : 0,
               "phrase" : "{additional} samples",
               "gid" : "9efd9ce9-e702-448b-8e76-641515e8fe62"
            },
            {
               "type1" : "recording",
               "hasDates" : true,
               "type0" : "recording",
               "description" : "This is used to indicate that the recording is a <a href=\"/doc/Mix_Terminology#mash-up\">mash-up</a> of two (or more) other recordings.",
               "cardinality0" : 0,
               "reversePhrase" : "mash-ups",
               "childOrder" : 1,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 232,
               "orderableDirection" : 0,
               "phrase" : "mash-up of",
               "gid" : "579d0b4c-bf77-479d-aa59-a8af1f518958"
            }
         ],
         "cardinality0" : 0,
         "reversePhrase" : "remixes and compilations",
         "childOrder" : 1,
         "cardinality1" : 0,
         "deprecated" : false,
         "id" : 234,
         "orderableDirection" : 0,
         "phrase" : "remixes and compilations",
         "gid" : "1baddd63-4539-4d49-ae43-600df9ef4647"
      }
   ],
   "area-url" : [
      {
         "type1" : "url",
         "hasDates" : false,
         "type0" : "area",
         "children" : [
            {
               "type1" : "url",
               "hasDates" : false,
               "type0" : "area",
               "description" : "Points to the Wikipedia page for this area.",
               "cardinality0" : 0,
               "reversePhrase" : "Wikipedia page for",
               "childOrder" : 0,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 355,
               "orderableDirection" : 0,
               "phrase" : "Wikipedia",
               "gid" : "9228621d-9720-35c3-ad3f-327d789464ec"
            },
            {
               "type1" : "url",
               "hasDates" : false,
               "type0" : "area",
               "description" : "Points to the Wikidata page for this area.",
               "cardinality0" : 0,
               "reversePhrase" : "Wikidata page for",
               "childOrder" : 0,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 358,
               "orderableDirection" : 0,
               "phrase" : "Wikidata",
               "gid" : "85c5256f-aef1-484f-979a-42007218a1c2"
            },
            {
               "type1" : "url",
               "hasDates" : false,
               "type0" : "area",
               "description" : "Points to the Geonames page for this area.",
               "cardinality0" : 0,
               "reversePhrase" : "Geonames page for",
               "childOrder" : 0,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 713,
               "orderableDirection" : 0,
               "phrase" : "Geonames",
               "gid" : "c52f14c0-e9ac-4a8a-8f7a-c47328de168f"
            }
         ],
         "cardinality0" : 0,
         "reversePhrase" : "other databases",
         "childOrder" : 99,
         "cardinality1" : 0,
         "deprecated" : false,
         "id" : 730,
         "orderableDirection" : 0,
         "phrase" : "other databases",
         "gid" : "b879051b-10e6-43b4-a49a-efdecc695f02"
      }
   ],
   "place-place" : [
      {
         "type1" : "place",
         "hasDates" : true,
         "type0" : "place",
         "description" : "This indicates that a place is part of another place.",
         "cardinality0" : 0,
         "reversePhrase" : "part of",
         "childOrder" : 0,
         "cardinality1" : 0,
         "deprecated" : false,
         "id" : 717,
         "orderableDirection" : 0,
         "phrase" : "parts",
         "gid" : "ff683f48-eff1-40ab-a58f-b128098ffe92"
      }
   ],
   "place-url" : [
      {
         "type1" : "url",
         "hasDates" : true,
         "type0" : "place",
         "description" : "Indicates the official homepage for a place.",
         "cardinality0" : 0,
         "reversePhrase" : "official homepage for",
         "childOrder" : 0,
         "cardinality1" : 0,
         "deprecated" : false,
         "id" : 363,
         "orderableDirection" : 0,
         "phrase" : "official homepages",
         "gid" : "696b79da-7e45-40e6-a9d4-b31438eb7e5d"
      },
      {
         "type1" : "url",
         "hasDates" : false,
         "type0" : "place",
         "children" : [
            {
               "type1" : "url",
               "hasDates" : false,
               "type0" : "place",
               "description" : "Indicates a pictorial image (JPEG, GIF, PNG) of a place",
               "cardinality0" : 0,
               "reversePhrase" : "picture of",
               "childOrder" : 0,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 396,
               "orderableDirection" : 0,
               "phrase" : "pictures",
               "gid" : "68a4537c-f2a6-49b8-81c5-82a62b0976b7"
            },
            {
               "type1" : "url",
               "hasDates" : true,
               "type0" : "place",
               "children" : [
                  {
                     "type1" : "url",
                     "hasDates" : false,
                     "type0" : "place",
                     "description" : "This relationship type can be used to link a MusicBrainz artist to the equivalent entry in Myspace.",
                     "cardinality0" : 0,
                     "reversePhrase" : "Myspace page for",
                     "childOrder" : 0,
                     "cardinality1" : 0,
                     "deprecated" : false,
                     "id" : 462,
                     "orderableDirection" : 0,
                     "phrase" : "Myspace",
                     "gid" : "c809cb4a-2835-44fb-bc64-fd4882bd389c"
                  }
               ],
               "description" : "This link is used to associate an artist or label with their page on a social networking site such as Facebook or Twitter",
               "cardinality0" : 0,
               "reversePhrase" : "social networking page for",
               "childOrder" : 0,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 429,
               "orderableDirection" : 0,
               "phrase" : "social networking",
               "gid" : "040de4d5-ace5-4cfb-8a45-95c5c73bce01"
            },
            {
               "type1" : "url",
               "hasDates" : false,
               "type0" : "place",
               "children" : [
                  {
                     "type1" : "url",
                     "hasDates" : false,
                     "type0" : "place",
                     "description" : "This relationship type can be used to link an artist to the equivalent entry in YouTube. URLs should follow the format http://www.youtube.com/user/<username>",
                     "cardinality0" : 0,
                     "reversePhrase" : "YouTube channel for",
                     "childOrder" : 0,
                     "cardinality1" : 0,
                     "deprecated" : false,
                     "id" : 528,
                     "orderableDirection" : 0,
                     "phrase" : "YouTube channels",
                     "gid" : "22ec436d-bb65-4c83-a268-0fdb0dbd8834"
                  }
               ],
               "description" : "This links a place to a channel, playlist, or user page on a video sharing site containing videos curated by it.",
               "cardinality0" : 0,
               "reversePhrase" : "video channel for",
               "childOrder" : 0,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 495,
               "orderableDirection" : 0,
               "phrase" : "video channel",
               "gid" : "e5c5a0f6-9581-44d8-a5fb-d3688254dc9f"
            },
            {
               "type1" : "url",
               "hasDates" : true,
               "type0" : "place",
               "description" : "This relationship type can be used to link a place to its blog",
               "cardinality0" : 0,
               "reversePhrase" : "blog of",
               "childOrder" : 0,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 627,
               "orderableDirection" : 0,
               "phrase" : "blogs",
               "gid" : "e3051f32-527b-4c47-9993-71250a6cd99c"
            }
         ],
         "cardinality0" : 0,
         "reversePhrase" : "online data",
         "childOrder" : 1,
         "cardinality1" : 0,
         "deprecated" : false,
         "id" : 660,
         "orderableDirection" : 0,
         "phrase" : "online data",
         "gid" : "e13a6749-086a-4c52-a03f-fce7532113ba"
      },
      {
         "type1" : "url",
         "hasDates" : false,
         "type0" : "place",
         "children" : [
            {
               "type1" : "url",
               "hasDates" : false,
               "type0" : "place",
               "description" : "Points to the Wikidata page for this place",
               "cardinality0" : 0,
               "reversePhrase" : "Wikidata page for",
               "childOrder" : 0,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 594,
               "orderableDirection" : 0,
               "phrase" : "Wikidata",
               "gid" : "e6826618-b410-4b8d-b3b5-52e29eac5e1f"
            },
            {
               "type1" : "url",
               "hasDates" : false,
               "type0" : "place",
               "description" : "Points to the Wikipedia page for this place",
               "cardinality0" : 0,
               "reversePhrase" : "Wikipedia page for",
               "childOrder" : 0,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 595,
               "orderableDirection" : 0,
               "phrase" : "Wikipedia",
               "gid" : "82680bbb-0391-4344-9687-4f419df4b97a"
            },
            {
               "type1" : "url",
               "hasDates" : false,
               "type0" : "place",
               "description" : "This is used to link a place to the equivalent entry in Discogs.",
               "cardinality0" : 0,
               "reversePhrase" : "Discogs page for",
               "childOrder" : 0,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 705,
               "orderableDirection" : 0,
               "phrase" : "Discogs",
               "gid" : "1c140ac8-8dc2-449e-92cb-52c90d525640"
            },
            {
               "type1" : "url",
               "hasDates" : false,
               "type0" : "place",
               "description" : "Points to the Internet Movie Database page for this place.",
               "cardinality0" : 0,
               "reversePhrase" : "IMDb page for",
               "childOrder" : 0,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 706,
               "orderableDirection" : 0,
               "phrase" : "IMDb",
               "gid" : "815bc5ca-c2fb-4dc6-a89b-9150888b0d4d"
            }
         ],
         "description" : "This links an entity to the equivalent entry in another database. Please respect the <a href=\"/doc/Other_Databases_Relationship_Type/Whitelist\">whitelist</a>.",
         "cardinality0" : 0,
         "reversePhrase" : "other databases",
         "childOrder" : 99,
         "cardinality1" : 0,
         "deprecated" : false,
         "id" : 561,
         "orderableDirection" : 0,
         "phrase" : "other databases",
         "gid" : "87a0a644-0a69-46c0-9e48-0656b8240d89"
      }
   ],
   "artist-release" : [
      {
         "type1" : "release",
         "hasDates" : false,
         "type0" : "artist",
         "children" : [
            {
               "type1" : "release",
               "hasDates" : true,
               "type0" : "artist",
               "children" : [
                  {
                     "type1" : "release",
                     "hasDates" : true,
                     "type0" : "artist",
                     "description" : "Indicates an artist that performed one or more instruments on this release.",
                     "cardinality0" : 1,
                     "reversePhrase" : "{additional} {guest} {solo} {instrument:%|instruments}",
                     "childOrder" : 0,
                     "cardinality1" : 0,
                     "deprecated" : false,
                     "id" : 44,
                     "attributes" : {
                        "596" : {
                           "min" : 0,
                           "max" : 1
                        },
                        "1" : {
                           "min" : 0,
                           "max" : 1
                        },
                        "194" : {
                           "min" : 0,
                           "max" : 1
                        },
                        "14" : {
                           "min" : 0,
                           "max" : null
                        }
                     },
                     "orderableDirection" : 0,
                     "phrase" : "{additional} {guest} {solo} {instrument:%|instruments}",
                     "gid" : "67555849-61e5-455b-96e3-29733f0115f5"
                  },
                  {
                     "type1" : "release",
                     "hasDates" : true,
                     "type0" : "artist",
                     "description" : "Indicates an artist that performed vocals on this release.",
                     "cardinality0" : 1,
                     "reversePhrase" : "{additional} {guest} {solo} {vocal} {vocal:|vocals}",
                     "childOrder" : 1,
                     "cardinality1" : 0,
                     "deprecated" : false,
                     "id" : 60,
                     "attributes" : {
                        "596" : {
                           "min" : 0,
                           "max" : 1
                        },
                        "1" : {
                           "min" : 0,
                           "max" : 1
                        },
                        "194" : {
                           "min" : 0,
                           "max" : 1
                        },
                        "3" : {
                           "min" : 0,
                           "max" : null
                        }
                     },
                     "orderableDirection" : 0,
                     "phrase" : "{additional} {guest} {solo} {vocal} {vocal:|vocals}",
                     "gid" : "eb10f8a0-0f4c-4dce-aa47-87bcb2bc42f3"
                  }
               ],
               "description" : "Indicates an artist that performed on this release.",
               "cardinality0" : 1,
               "reversePhrase" : "{additional} {guest} {solo} performer",
               "childOrder" : 0,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 51,
               "attributes" : {
                  "596" : {
                     "min" : 0,
                     "max" : 1
                  },
                  "1" : {
                     "min" : 0,
                     "max" : 1
                  },
                  "194" : {
                     "min" : 0,
                     "max" : 1
                  }
               },
               "orderableDirection" : 0,
               "phrase" : "{additional:additionally} {guest} {solo} performed",
               "gid" : "888a2320-52e4-4fe8-a8a0-7a4c8dfde167"
            },
            {
               "type1" : "release",
               "hasDates" : true,
               "type0" : "artist",
               "description" : "Indicates an orchestra that performed on this release.",
               "cardinality0" : 1,
               "reversePhrase" : "{additional} orchestra",
               "childOrder" : 1,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 45,
               "attributes" : {
                  "1" : {
                     "min" : 0,
                     "max" : 1
                  }
               },
               "orderableDirection" : 0,
               "phrase" : "{additional} orchestra",
               "gid" : "23a2e2e7-81ca-4865-8d05-2243848a77bf"
            },
            {
               "type1" : "release",
               "hasDates" : true,
               "type0" : "artist",
               "description" : "This indicates an artist who conducted an orchestra, band or choir on this release.",
               "cardinality0" : 1,
               "reversePhrase" : "{additional} conductor",
               "childOrder" : 2,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 46,
               "attributes" : {
                  "1" : {
                     "min" : 0,
                     "max" : 1
                  }
               },
               "orderableDirection" : 0,
               "phrase" : "{additional:additionally} conducted",
               "gid" : "9ae9e4d0-f26b-42fb-ab5c-1149a47cf83b"
            },
            {
               "type1" : "release",
               "hasDates" : true,
               "type0" : "artist",
               "description" : "This indicates the chorus master of a choir which performed on this release.",
               "cardinality0" : 1,
               "reversePhrase" : "{additional} chorus master",
               "childOrder" : 3,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 53,
               "attributes" : {
                  "1" : {
                     "min" : 0,
                     "max" : 1
                  }
               },
               "orderableDirection" : 0,
               "phrase" : "{additional} chorus master",
               "gid" : "b9129850-73ec-4af5-803c-1c12b97e25d2"
            }
         ],
         "cardinality0" : 1,
         "reversePhrase" : "performance",
         "childOrder" : 0,
         "cardinality1" : 0,
         "deprecated" : false,
         "id" : 34,
         "orderableDirection" : 0,
         "phrase" : "performance",
         "gid" : "8db9d0b7-ca39-43a6-8c72-9a47f811229e"
      },
      {
         "type1" : "release",
         "hasDates" : false,
         "type0" : "artist",
         "children" : [
            {
               "type1" : "release",
               "hasDates" : true,
               "type0" : "artist",
               "description" : "This links a <a href=\"/doc/Mix_Terminology#DJ_mix\">DJ-mix</a> to the artist who mixed it.",
               "cardinality0" : 1,
               "reversePhrase" : "DJ-mixer {medium}",
               "childOrder" : 0,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 43,
               "attributes" : {
                  "568" : {
                     "min" : 0,
                     "max" : null
                  }
               },
               "orderableDirection" : 0,
               "phrase" : "DJ-mixed {medium}",
               "gid" : "9162dedd-790c-446c-838e-240f877dbfe2"
            },
            {
               "type1" : "release",
               "hasDates" : true,
               "type0" : "artist",
               "description" : "This links a release to the person who remixed it by taking one or more other tracks, substantially altering them and mixing them together with other material. Note that this includes the artist who created a mash-up or used samples as well.",
               "cardinality0" : 1,
               "reversePhrase" : "{additional} remixer",
               "childOrder" : 0,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 47,
               "attributes" : {
                  "1" : {
                     "min" : 0,
                     "max" : 1
                  }
               },
               "orderableDirection" : 0,
               "phrase" : "{additional:additionally} remixed",
               "gid" : "ac6a86db-f757-4815-a07e-744428d2382b"
            },
            {
               "type1" : "release",
               "hasDates" : true,
               "type0" : "artist",
               "description" : "This indicates the person who selected the tracks and the sequence for a compilation. If the tracks are pitched or blended into each other, it is more appropriate to credit this person as a <a href=\"/relationship/9162dedd-790c-446c-838e-240f877dbfe2\">DJ-mixer</a>.",
               "cardinality0" : 1,
               "reversePhrase" : "compiler",
               "childOrder" : 0,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 48,
               "orderableDirection" : 0,
               "phrase" : "compiled",
               "gid" : "2f81887a-8674-4d8b-bd48-8bfd4c6fa332"
            },
            {
               "type1" : "release",
               "hasDates" : true,
               "type0" : "artist",
               "description" : "Indicates that the release contains samples from material by the indicated artist. Use this only if you really cannot figure out the particular recording that has been sampled.",
               "cardinality0" : 1,
               "reversePhrase" : "contains {additional} samples by",
               "childOrder" : 1,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 49,
               "attributes" : {
                  "1" : {
                     "min" : 0,
                     "max" : 1
                  },
                  "3" : {
                     "min" : 0,
                     "max" : null
                  },
                  "14" : {
                     "min" : 0,
                     "max" : null
                  }
               },
               "orderableDirection" : 0,
               "phrase" : "produced material that was {additional:additionally} sampled in",
               "gid" : "7ddb04ae-6c8a-41bd-95c2-392994d663db"
            }
         ],
         "cardinality0" : 1,
         "reversePhrase" : "remixes and compilations",
         "childOrder" : 1,
         "cardinality1" : 0,
         "deprecated" : false,
         "id" : 50,
         "orderableDirection" : 0,
         "phrase" : "remixes and compilations",
         "gid" : "d6b8f1d2-5431-4c97-9688-44f73213ee5b"
      },
      {
         "type1" : "release",
         "hasDates" : false,
         "type0" : "artist",
         "children" : [
            {
               "type1" : "release",
               "hasDates" : true,
               "type0" : "artist",
               "children" : [
                  {
                     "type1" : "release",
                     "hasDates" : true,
                     "type0" : "artist",
                     "description" : "Indicates the composer for this release, i.e. the artist who wrote the music (not necessarily the lyrics).",
                     "cardinality0" : 1,
                     "reversePhrase" : "{additional} composer",
                     "childOrder" : 0,
                     "cardinality1" : 0,
                     "deprecated" : false,
                     "id" : 55,
                     "attributes" : {
                        "1" : {
                           "min" : 0,
                           "max" : 1
                        }
                     },
                     "orderableDirection" : 0,
                     "phrase" : "{additional:additionally} composed",
                     "gid" : "01ce32b0-d873-4baa-8025-714b45c0c754"
                  },
                  {
                     "type1" : "release",
                     "hasDates" : true,
                     "type0" : "artist",
                     "description" : "Indicates the lyricist for this release.",
                     "cardinality0" : 1,
                     "reversePhrase" : "{additional} {translated:translator|lyricist}",
                     "childOrder" : 1,
                     "cardinality1" : 0,
                     "deprecated" : false,
                     "id" : 56,
                     "attributes" : {
                        "1" : {
                           "min" : 0,
                           "max" : 1
                        },
                        "517" : {
                           "min" : 0,
                           "max" : 1
                        }
                     },
                     "orderableDirection" : 0,
                     "phrase" : "{additional} {translated} lyrics",
                     "gid" : "a2af367a-b040-46f8-af21-310f92dfe97b"
                  },
                  {
                     "type1" : "release",
                     "hasDates" : true,
                     "type0" : "artist",
                     "description" : "Indicates the librettist for this release.",
                     "cardinality0" : 1,
                     "reversePhrase" : "{additional} {translated:libretto translation|librettist}",
                     "childOrder" : 2,
                     "cardinality1" : 0,
                     "deprecated" : false,
                     "id" : 57,
                     "attributes" : {
                        "1" : {
                           "min" : 0,
                           "max" : 1
                        },
                        "517" : {
                           "min" : 0,
                           "max" : 1
                        }
                     },
                     "orderableDirection" : 0,
                     "phrase" : "{additional} {translated:libretto translation|librettist}",
                     "gid" : "dd182715-ca2b-4e4b-80b1-d21742fda0dc"
                  }
               ],
               "description" : "This relationship is used to link a release to the artist responsible for writing the music and/or the words (lyrics, libretto, etc.), when no more specific information is available. If possible, the more specific composer, lyricist and/or librettist types should be used, rather than this relationship type.",
               "cardinality0" : 1,
               "reversePhrase" : "{additional} writer",
               "childOrder" : 0,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 54,
               "attributes" : {
                  "1" : {
                     "min" : 0,
                     "max" : 1
                  }
               },
               "orderableDirection" : 0,
               "phrase" : "{additional:additionally} wrote",
               "gid" : "ca7a474a-a1cd-4431-9230-56a17f553090"
            },
            {
               "type1" : "release",
               "hasDates" : true,
               "type0" : "artist",
               "children" : [
                  {
                     "type1" : "release",
                     "hasDates" : true,
                     "type0" : "artist",
                     "children" : [
                        {
                           "type1" : "release",
                           "hasDates" : true,
                           "type0" : "artist",
                           "description" : "This indicates the person who orchestrated the release. Orchestration is a special type of arrangement. It means the adaptation of a composition for an orchestra, done in a way that the musical substance remains essentially unchanged. The orchestrator is also responsible for writing scores for an orchestra, band, choral group, individual instrumentalist(s) or vocalist(s). In practical terms it consists of deciding which instruments should play which notes in a piece of music.",
                           "cardinality0" : 1,
                           "reversePhrase" : "{additional:additionally} orchestrator",
                           "childOrder" : 1,
                           "cardinality1" : 0,
                           "deprecated" : false,
                           "id" : 40,
                           "attributes" : {
                              "1" : {
                                 "min" : 0,
                                 "max" : 1
                              }
                           },
                           "orderableDirection" : 0,
                           "phrase" : "{additional:additionally} orchestrated",
                           "gid" : "04e1f0b6-ef40-4168-ba25-42a87729fe09"
                        }
                     ],
                     "description" : "This indicates the artist who arranged a tune into a form suitable for performance. 'Arrangement' is used as a catch-all term for all processes that turn a composition into a form that can be played by a specific type of ensemble.",
                     "cardinality0" : 1,
                     "reversePhrase" : "{additional} {instrument:%|instruments} arranger",
                     "childOrder" : 1,
                     "cardinality1" : 0,
                     "deprecated" : false,
                     "id" : 41,
                     "attributes" : {
                        "1" : {
                           "min" : 0,
                           "max" : 1
                        },
                        "14" : {
                           "min" : 0,
                           "max" : null
                        }
                     },
                     "orderableDirection" : 0,
                     "phrase" : "{additional:additionally} {instrument:%|instruments} arranged",
                     "gid" : "18f159bb-44f0-4aef-b198-a4736ad9b659"
                  },
                  {
                     "type1" : "release",
                     "hasDates" : true,
                     "type0" : "artist",
                     "description" : "This indicates the artist who arranged a tune into a form suitable for performance. 'Arrangement' is used as a catch-all term for all processes that turn a composition into a form that can be played by a specific type of ensemble.",
                     "cardinality0" : 1,
                     "reversePhrase" : "{additional} {vocal:%|vocals} arranger",
                     "childOrder" : 2,
                     "cardinality1" : 0,
                     "deprecated" : false,
                     "id" : 296,
                     "attributes" : {
                        "1" : {
                           "min" : 0,
                           "max" : 1
                        },
                        "3" : {
                           "min" : 0,
                           "max" : null
                        }
                     },
                     "orderableDirection" : 0,
                     "phrase" : "{additional:additionally} {vocal:%|vocals} arranged",
                     "gid" : "d7d9128d-e676-4d8f-a353-f48a55a98501"
                  }
               ],
               "description" : "This indicates the artist who arranged a tune into a form suitable for performance. 'Arrangement' is used as a catch-all term for all processes that turn a composition into a form that can be played by a specific type of ensemble.",
               "cardinality0" : 1,
               "reversePhrase" : "{additional} arranger",
               "childOrder" : 1,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 295,
               "attributes" : {
                  "1" : {
                     "min" : 0,
                     "max" : 1
                  }
               },
               "orderableDirection" : 0,
               "phrase" : "{additional:additionally} arranged",
               "gid" : "34d5334e-a4c8-4b65-a5f8-bbcc9c81d13d"
            }
         ],
         "cardinality0" : 1,
         "reversePhrase" : "composition",
         "childOrder" : 2,
         "cardinality1" : 0,
         "deprecated" : false,
         "id" : 58,
         "orderableDirection" : 0,
         "phrase" : "composition",
         "gid" : "800a8a16-5426-4f4e-8dd6-9371d8bc8398"
      },
      {
         "type1" : "release",
         "hasDates" : false,
         "type0" : "artist",
         "children" : [
            {
               "type1" : "release",
               "hasDates" : true,
               "type0" : "artist",
               "description" : "This indicates an artist who is responsible for the creative and practical day-to-day aspects involved with making a musical recording.",
               "cardinality0" : 1,
               "reversePhrase" : "{additional} {assistant} {associate} {co:co-}{executive:executive }producer",
               "childOrder" : 0,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 30,
               "attributes" : {
                  "527" : {
                     "min" : 0,
                     "max" : 1
                  },
                  "1" : {
                     "min" : 0,
                     "max" : 1
                  },
                  "526" : {
                     "min" : 0,
                     "max" : 1
                  },
                  "424" : {
                     "min" : 0,
                     "max" : 1
                  },
                  "425" : {
                     "min" : 0,
                     "max" : 1
                  }
               },
               "orderableDirection" : 0,
               "phrase" : "{additional:additionally} {assistant} {associate} {co:co-}{executive:executive }produced",
               "gid" : "8bf377ba-8d71-4ecc-97f2-7bb2d8a2a75f"
            },
            {
               "type1" : "release",
               "hasDates" : true,
               "type0" : "artist",
               "children" : [
                  {
                     "type1" : "release",
                     "hasDates" : true,
                     "type0" : "artist",
                     "description" : "This describes an engineer involved with the machines used to generate sound, such as effects processors and digital audio equipment used to modify or manipulate sound in either an analogue or digital form.",
                     "cardinality0" : 1,
                     "reversePhrase" : "{additional} {assistant} {associate} {co:co-}audio engineer",
                     "childOrder" : 0,
                     "cardinality1" : 0,
                     "deprecated" : false,
                     "id" : 31,
                     "attributes" : {
                        "527" : {
                           "min" : 0,
                           "max" : 1
                        },
                        "1" : {
                           "min" : 0,
                           "max" : 1
                        },
                        "526" : {
                           "min" : 0,
                           "max" : 1
                        },
                        "424" : {
                           "min" : 0,
                           "max" : 1
                        }
                     },
                     "orderableDirection" : 0,
                     "phrase" : "{additional:additionally} {assistant} {associate} {co:co-}audio engineered",
                     "gid" : "b04848d7-dbd9-4be0-9d8c-13df6d6e40db"
                  },
                  {
                     "type1" : "release",
                     "hasDates" : true,
                     "type0" : "artist",
                     "description" : "Indicates the mastering engineer for this work.",
                     "cardinality0" : 1,
                     "reversePhrase" : "{additional} {assistant} {associate} {co:co-}mastering",
                     "childOrder" : 0,
                     "cardinality1" : 0,
                     "deprecated" : false,
                     "id" : 42,
                     "attributes" : {
                        "527" : {
                           "min" : 0,
                           "max" : 1
                        },
                        "1" : {
                           "min" : 0,
                           "max" : 1
                        },
                        "526" : {
                           "min" : 0,
                           "max" : 1
                        },
                        "424" : {
                           "min" : 0,
                           "max" : 1
                        }
                     },
                     "orderableDirection" : 0,
                     "phrase" : "{additional} {assistant} {associate} {co:co-}mastering",
                     "gid" : "84453d28-c3e8-4864-9aae-25aa968bcf9e"
                  },
                  {
                     "type1" : "release",
                     "hasDates" : true,
                     "type0" : "artist",
                     "description" : "This describes an engineer responsible for ensuring that the sounds that the artists make reach the microphones sounding pleasant, without unwanted resonance or noise. Sometimes known as acoustical engineering.",
                     "cardinality0" : 1,
                     "reversePhrase" : "{additional} {assistant} {associate} {co:co-}sound engineer",
                     "childOrder" : 1,
                     "cardinality1" : 0,
                     "deprecated" : false,
                     "id" : 29,
                     "attributes" : {
                        "527" : {
                           "min" : 0,
                           "max" : 1
                        },
                        "1" : {
                           "min" : 0,
                           "max" : 1
                        },
                        "526" : {
                           "min" : 0,
                           "max" : 1
                        },
                        "424" : {
                           "min" : 0,
                           "max" : 1
                        }
                     },
                     "orderableDirection" : 0,
                     "phrase" : "{additional:additionally} {assistant} {associate} {co:co-}sound engineered",
                     "gid" : "271306ca-c77f-4fe0-94bc-dd4b87ae0205"
                  },
                  {
                     "type1" : "release",
                     "hasDates" : true,
                     "type0" : "artist",
                     "description" : "This describes an engineer responsible for using a mixing console to mix a recorded track into a single piece of music suitable for release.​ For remixing, see <a href=\"/relationship/ac6a86db-f757-4815-a07e-744428d2382b\">remixer</a>.",
                     "cardinality0" : 1,
                     "reversePhrase" : "{additional} {assistant} {associate} {co:co-}mixer",
                     "childOrder" : 3,
                     "cardinality1" : 0,
                     "deprecated" : false,
                     "id" : 26,
                     "attributes" : {
                        "527" : {
                           "min" : 0,
                           "max" : 1
                        },
                        "1" : {
                           "min" : 0,
                           "max" : 1
                        },
                        "526" : {
                           "min" : 0,
                           "max" : 1
                        },
                        "424" : {
                           "min" : 0,
                           "max" : 1
                        }
                     },
                     "orderableDirection" : 0,
                     "phrase" : "{additional:additionally} {assistant} {associate} {co:co-}mixed",
                     "gid" : "6cc958c0-533b-4540-a281-058fbb941890"
                  },
                  {
                     "type1" : "release",
                     "hasDates" : true,
                     "type0" : "artist",
                     "description" : "This describes an engineer responsible for committing the performance to tape. This can be as complex as setting up the microphones, amplifiers, and recording devices, or as simple as pressing the 'record' button on a 4-track.",
                     "cardinality0" : 1,
                     "reversePhrase" : "{additional:additionally} {assistant} {associate} {co:co-}recorded by",
                     "childOrder" : 4,
                     "cardinality1" : 0,
                     "deprecated" : false,
                     "id" : 36,
                     "attributes" : {
                        "527" : {
                           "min" : 0,
                           "max" : 1
                        },
                        "1" : {
                           "min" : 0,
                           "max" : 1
                        },
                        "526" : {
                           "min" : 0,
                           "max" : 1
                        },
                        "424" : {
                           "min" : 0,
                           "max" : 1
                        }
                     },
                     "orderableDirection" : 0,
                     "phrase" : "{additional:additionally} {assistant} {associate} {co:co-}recorded",
                     "gid" : "023a6c6d-80af-4f88-ae69-f5f6213f9bf4"
                  },
                  {
                     "type1" : "release",
                     "hasDates" : true,
                     "type0" : "artist",
                     "description" : "This links a release to the artist who did the programming for electronic instruments used on the release.​ In the most cases, the 'electronic instrument' is either a synthesizer or a drum machine.",
                     "cardinality0" : 1,
                     "reversePhrase" : "{additional} {assistant} {associate} {instrument} programming",
                     "childOrder" : 5,
                     "cardinality1" : 0,
                     "deprecated" : false,
                     "id" : 37,
                     "attributes" : {
                        "527" : {
                           "min" : 0,
                           "max" : 1
                        },
                        "1" : {
                           "min" : 0,
                           "max" : 1
                        },
                        "526" : {
                           "min" : 0,
                           "max" : 1
                        },
                        "14" : {
                           "min" : 0,
                           "max" : null
                        }
                     },
                     "orderableDirection" : 0,
                     "phrase" : "{additional} {assistant} {associate} {instrument} programming",
                     "gid" : "617063ad-dbb5-4877-9ba0-ba2b9198d5a7"
                  },
                  {
                     "type1" : "release",
                     "hasDates" : true,
                     "type0" : "artist",
                     "description" : "This describes an engineer responsible for either connecting disparate elements of the audio recording, or otherwise redistributing material recorded in the sessions.​ This is usually secondary, or additional to the work done by the mix engineer. It can also involve streamlining a longer track to around the 3 minute mark in order to make it suitable for radio play (a \"radio edit\").",
                     "cardinality0" : 1,
                     "reversePhrase" : "{additional} {assistant} {associate} {co:co-}editor",
                     "childOrder" : 6,
                     "cardinality1" : 0,
                     "deprecated" : false,
                     "id" : 38,
                     "attributes" : {
                        "527" : {
                           "min" : 0,
                           "max" : 1
                        },
                        "1" : {
                           "min" : 0,
                           "max" : 1
                        },
                        "526" : {
                           "min" : 0,
                           "max" : 1
                        },
                        "424" : {
                           "min" : 0,
                           "max" : 1
                        }
                     },
                     "orderableDirection" : 0,
                     "phrase" : "{additional:additionally} {assistant} {associate} {co:co-}edited",
                     "gid" : "f30c29d3-a3f1-420d-9b6c-a750fd6bc2aa"
                  },
                  {
                     "type1" : "release",
                     "hasDates" : true,
                     "type0" : "artist",
                     "description" : "This links a release to the balance engineer who engineered it.",
                     "cardinality0" : 1,
                     "reversePhrase" : "{additional} {assistant} {associate} {co:co-}balance engineer",
                     "childOrder" : 7,
                     "cardinality1" : 0,
                     "deprecated" : false,
                     "id" : 727,
                     "attributes" : {
                        "527" : {
                           "min" : 0,
                           "max" : 1
                        },
                        "1" : {
                           "min" : 0,
                           "max" : 1
                        },
                        "526" : {
                           "min" : 0,
                           "max" : 1
                        },
                        "3" : {
                           "min" : 0,
                           "max" : null
                        },
                        "424" : {
                           "min" : 0,
                           "max" : 1
                        },
                        "14" : {
                           "min" : 0,
                           "max" : null
                        }
                     },
                     "orderableDirection" : 0,
                     "phrase" : "{additional:additionally} {assistant} {associate} {co:co-}balance engineered",
                     "gid" : "97169e5e-c978-486e-a5ea-da353ca9ea42"
                  }
               ],
               "description" : "This describes an engineer who performed a general engineering role.​",
               "cardinality0" : 1,
               "reversePhrase" : "{additional} {assistant} {associate} {co:co-}{executive:executive }engineer",
               "childOrder" : 1,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 28,
               "attributes" : {
                  "527" : {
                     "min" : 0,
                     "max" : 1
                  },
                  "1" : {
                     "min" : 0,
                     "max" : 1
                  },
                  "526" : {
                     "min" : 0,
                     "max" : 1
                  },
                  "424" : {
                     "min" : 0,
                     "max" : 1
                  },
                  "425" : {
                     "min" : 0,
                     "max" : 1
                  }
               },
               "orderableDirection" : 0,
               "phrase" : "{additional:additionally} {assistant} {associate} {co:co-}{executive:executive }engineered",
               "gid" : "87e922ba-872e-418a-9f41-0a63aa3c30cc"
            },
            {
               "type1" : "release",
               "hasDates" : true,
               "type0" : "artist",
               "children" : [
                  {
                     "type1" : "release",
                     "hasDates" : true,
                     "type0" : "artist",
                     "description" : "This indicates that a person or firm provided legal representation for the release.",
                     "cardinality0" : 1,
                     "reversePhrase" : "legal representation",
                     "childOrder" : 0,
                     "cardinality1" : 0,
                     "deprecated" : false,
                     "id" : 22,
                     "orderableDirection" : 0,
                     "phrase" : "legal representation",
                     "gid" : "1a900189-53ba-442a-9406-49c43ddecb3f"
                  },
                  {
                     "type1" : "release",
                     "hasDates" : true,
                     "type0" : "artist",
                     "children" : [
                        {
                           "type1" : "release",
                           "hasDates" : true,
                           "type0" : "artist",
                           "description" : "This relationship indicates the artist is the <a href=\"//en.wikipedia.org/wiki/Sound_recording_copyright_symbol\">phonographic copyright</a> holder for this release. ​",
                           "cardinality0" : 1,
                           "reversePhrase" : "phonographic copyright by",
                           "childOrder" : 0,
                           "cardinality1" : 0,
                           "deprecated" : false,
                           "id" : 710,
                           "orderableDirection" : 0,
                           "phrase" : "holds phonographic copyright for",
                           "gid" : "01d3488d-8d2a-4cff-9226-5250404db4dc"
                        }
                     ],
                     "description" : "This relationship indicates the artist is the copyright holder for this release.",
                     "cardinality0" : 1,
                     "reversePhrase" : "copyrighted by",
                     "childOrder" : 0,
                     "cardinality1" : 0,
                     "deprecated" : false,
                     "id" : 709,
                     "orderableDirection" : 0,
                     "phrase" : "holds copyright for",
                     "gid" : "730b5251-7432-4896-8fc6-e1cba943bfe1"
                  },
                  {
                     "type1" : "release",
                     "hasDates" : true,
                     "type0" : "artist",
                     "description" : "This credits a person who was responsible for booking the studio or performance venue where the release was recorded.",
                     "cardinality0" : 1,
                     "reversePhrase" : "booking",
                     "childOrder" : 1,
                     "cardinality1" : 0,
                     "deprecated" : false,
                     "id" : 23,
                     "orderableDirection" : 0,
                     "phrase" : "booking",
                     "gid" : "b0f98226-7121-4db5-a69c-552e6d061da2"
                  },
                  {
                     "type1" : "release",
                     "hasDates" : true,
                     "type0" : "artist",
                     "description" : "This indicates that a person or agency did the art direction for the release.",
                     "cardinality0" : 1,
                     "reversePhrase" : "{additional} art direction",
                     "childOrder" : 4,
                     "cardinality1" : 0,
                     "deprecated" : false,
                     "id" : 18,
                     "attributes" : {
                        "1" : {
                           "min" : 0,
                           "max" : 1
                        }
                     },
                     "orderableDirection" : 0,
                     "phrase" : "{additional} art direction",
                     "gid" : "f3b80a09-5ebf-4ad2-9c46-3e6bce971d1b"
                  },
                  {
                     "type1" : "release",
                     "hasDates" : true,
                     "type0" : "artist",
                     "description" : "This indicates a person or agency who did design or illustration for the release.",
                     "cardinality0" : 1,
                     "reversePhrase" : "{additional} design/illustration",
                     "childOrder" : 5,
                     "cardinality1" : 0,
                     "deprecated" : false,
                     "id" : 19,
                     "attributes" : {
                        "1" : {
                           "min" : 0,
                           "max" : 1
                        }
                     },
                     "orderableDirection" : 0,
                     "phrase" : "{additional} design/illustration",
                     "gid" : "307e95dd-88b5-419b-8223-b146d4a0d439"
                  },
                  {
                     "type1" : "release",
                     "hasDates" : true,
                     "type0" : "artist",
                     "description" : "This credits the people or agency who did the graphic design, arranging pieces of content into a coherent and aesthetically-pleasing sleeve design.",
                     "cardinality0" : 1,
                     "reversePhrase" : "{additional} graphic design",
                     "childOrder" : 6,
                     "cardinality1" : 0,
                     "deprecated" : false,
                     "id" : 27,
                     "attributes" : {
                        "1" : {
                           "min" : 0,
                           "max" : 1
                        }
                     },
                     "orderableDirection" : 0,
                     "phrase" : "{additional} graphic design",
                     "gid" : "cf43b79e-3299-4b0c-9244-59ea06337107"
                  },
                  {
                     "type1" : "release",
                     "hasDates" : true,
                     "type0" : "artist",
                     "description" : "This credits a person or agency whose photographs are included as part of a release.",
                     "cardinality0" : 1,
                     "reversePhrase" : "{additional} photography",
                     "childOrder" : 7,
                     "cardinality1" : 0,
                     "deprecated" : false,
                     "id" : 20,
                     "attributes" : {
                        "1" : {
                           "min" : 0,
                           "max" : 1
                        }
                     },
                     "orderableDirection" : 0,
                     "phrase" : "{additional} photography",
                     "gid" : "0b58dc9b-9c49-4b19-bb58-9c06d41c8fbf"
                  },
                  {
                     "type1" : "release",
                     "hasDates" : true,
                     "type0" : "artist",
                     "description" : "Indicates the publisher of this release. This is <strong>not</strong> the same concept as the <a href=\"/doc/Label\">record label</a>.",
                     "cardinality0" : 1,
                     "reversePhrase" : "publisher",
                     "childOrder" : 9,
                     "cardinality1" : 0,
                     "deprecated" : false,
                     "id" : 32,
                     "orderableDirection" : 0,
                     "phrase" : "published",
                     "gid" : "7a573a01-8815-44db-8e30-693faa83fbfa"
                  },
                  {
                     "type1" : "release",
                     "hasDates" : true,
                     "type0" : "artist",
                     "description" : "This credits the author of liner notes provided with the release (usually on the sleeve). While most time liner notes are just personnel information and production data, in some cases they consist of a blurb of text (article). This relationship type should be used in this last case.",
                     "cardinality0" : 1,
                     "reversePhrase" : "{additional} liner notes",
                     "childOrder" : 11,
                     "cardinality1" : 0,
                     "deprecated" : false,
                     "id" : 24,
                     "attributes" : {
                        "1" : {
                           "min" : 0,
                           "max" : 1
                        }
                     },
                     "orderableDirection" : 0,
                     "phrase" : "{additional} liner notes",
                     "gid" : "01323b4f-7aba-410c-8c91-cb224b963a40"
                  }
               ],
               "description" : "This indicates that the artist performed a role not covered by other relationship types.",
               "cardinality0" : 1,
               "reversePhrase" : "miscellaneous support",
               "childOrder" : 2,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 25,
               "orderableDirection" : 0,
               "phrase" : "miscellaneous roles",
               "gid" : "0b63af5e-85b2-4891-8234-bddab251399d"
            }
         ],
         "cardinality0" : 1,
         "reversePhrase" : "production",
         "childOrder" : 3,
         "cardinality1" : 0,
         "deprecated" : false,
         "id" : 59,
         "orderableDirection" : 0,
         "phrase" : "production",
         "gid" : "3172a175-7c9d-44ce-a8b7-9a9187b33762"
      }
   ],
   "release-release" : [
      {
         "type1" : "release",
         "hasDates" : false,
         "type0" : "release",
         "children" : [
            {
               "type1" : "release",
               "hasDates" : true,
               "type0" : "release",
               "description" : "This links two releases, where one is a <a href=\"/doc/Mix_Terminology#remaster\">remaster</a> of the other.​ This is usually done to improve the audio quality or to adjust for more modern playback equipment. The process generally doesn't involve changing the music in any artistically important way. It may, however, result in recordings that differ in length by a few seconds.",
               "cardinality0" : 0,
               "reversePhrase" : "remastered versions",
               "childOrder" : 1,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 6,
               "orderableDirection" : 0,
               "phrase" : "remaster of",
               "gid" : "48e327b5-2d04-4518-93f1-fed5f0f0fa3c"
            },
            {
               "type1" : "release",
               "hasDates" : false,
               "type0" : "release",
               "description" : "This indicates that one release is identical to another release, but that the release title and track titles have been either translated (into another language) or transliterated (into another script).​",
               "cardinality0" : 0,
               "reversePhrase" : "transl{transliterated:iter}ated track listing of",
               "childOrder" : 5,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 2,
               "attributes" : {
                  "477" : {
                     "min" : 0,
                     "max" : 1
                  }
               },
               "orderableDirection" : 0,
               "phrase" : "transl{transliterated:iter}ated track listings",
               "gid" : "fc399d47-23a7-4c28-bfcf-0607a562b644"
            }
         ],
         "cardinality0" : 0,
         "reversePhrase" : "covers or other versions",
         "childOrder" : 0,
         "cardinality1" : 0,
         "deprecated" : false,
         "id" : 4,
         "orderableDirection" : 0,
         "phrase" : "covers or other versions",
         "gid" : "3676d4aa-2fa7-435f-b83f-cdbbe4740938"
      },
      {
         "type1" : "release",
         "hasDates" : true,
         "type0" : "release",
         "description" : "This relationship type is <strong>deprecated</strong>! Please enter a release with multiple discs as a single release containing multiple discs.",
         "cardinality0" : 0,
         "reversePhrase" : "previous disc",
         "childOrder" : 2,
         "cardinality1" : 0,
         "deprecated" : true,
         "id" : 1,
         "attributes" : {
            "516" : {
               "min" : 0,
               "max" : 1
            }
         },
         "orderableDirection" : 0,
         "phrase" : "{bonus:bonus|next} disc",
         "gid" : "6d08ec1e-a292-4dac-90f3-c398a39defd5"
      },
      {
         "type1" : "release",
         "hasDates" : false,
         "type0" : "release",
         "description" : "This indicates that a release was released in support of another release.​This allows a release to be linked to its supporting singles, EPs, and remix releases. A 'supporting release' is one which is released to increase sales of an album or to create publicity for an album.",
         "cardinality0" : 0,
         "reversePhrase" : "supporting releases",
         "childOrder" : 4,
         "cardinality1" : 0,
         "deprecated" : false,
         "id" : 3,
         "orderableDirection" : 0,
         "phrase" : "released in support of",
         "gid" : "7ad3c97e-e524-4d9a-a384-2b1407f4939b"
      }
   ],
   "artist-place" : [
      {
         "type1" : "place",
         "hasDates" : true,
         "type0" : "artist",
         "description" : "Links an artist to a place where they held a concert. Please include as detailed a date as possible.",
         "cardinality0" : 0,
         "reversePhrase" : "hosted concerts by",
         "childOrder" : 0,
         "cardinality1" : 0,
         "deprecated" : false,
         "id" : 700,
         "orderableDirection" : 0,
         "phrase" : "held concerts at",
         "gid" : "46191a34-84d4-48ff-9c2a-c86d614bc0e3"
      },
      {
         "type1" : "place",
         "hasDates" : true,
         "type0" : "artist",
         "children" : [
            {
               "type1" : "place",
               "hasDates" : true,
               "type0" : "artist",
               "description" : "Describes the fact a person was contracted by a place as a recording engineer.",
               "cardinality0" : 0,
               "reversePhrase" : "recording engineers",
               "childOrder" : 0,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 702,
               "orderableDirection" : 0,
               "phrase" : "recording engineer position at",
               "gid" : "350f7ab7-c2d9-4f00-98e0-e1973bf4a2bf"
            },
            {
               "type1" : "place",
               "hasDates" : true,
               "type0" : "artist",
               "description" : "Describes the fact a person was contracted by a place as a mixing engineer.",
               "cardinality0" : 0,
               "reversePhrase" : "mixing engineers",
               "childOrder" : 1,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 703,
               "orderableDirection" : 0,
               "phrase" : "mixing engineer position at",
               "gid" : "67ed1d31-8993-442c-aa59-afdb6a89d2c2"
            },
            {
               "type1" : "place",
               "hasDates" : true,
               "type0" : "artist",
               "description" : "Describes the fact a person was contracted by a place as a mastering engineer.",
               "cardinality0" : 0,
               "reversePhrase" : "mastering engineers",
               "childOrder" : 2,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 704,
               "orderableDirection" : 0,
               "phrase" : "mastering engineer position at",
               "gid" : "98e2ad89-6641-4336-913d-db1515aaabcb"
            }
         ],
         "description" : "Describes the fact a person was contracted by a place as an engineer.",
         "cardinality0" : 0,
         "reversePhrase" : "engineers",
         "childOrder" : 1,
         "cardinality1" : 0,
         "deprecated" : false,
         "id" : 701,
         "orderableDirection" : 0,
         "phrase" : "engineer position at",
         "gid" : "666c5ee3-b763-4b74-8f71-3456dfd3e755"
      },
      {
         "type1" : "place",
         "hasDates" : true,
         "type0" : "artist",
         "description" : "This is used to link an artist to its primary concert venue.",
         "cardinality0" : 0,
         "reversePhrase" : "primary concert venue of",
         "childOrder" : 1,
         "cardinality1" : 0,
         "deprecated" : false,
         "id" : 714,
         "orderableDirection" : 0,
         "phrase" : "primary concert venue",
         "gid" : "fff4640a-0819-49e9-92c5-1e3b5134fd95"
      }
   ],
   "url-work" : [
      {
         "type1" : "work",
         "hasDates" : false,
         "type0" : "url",
         "description" : "This relationship describes a URL where lyrics for the work can be found. Only sites on the <a href=\"/doc/Style/Relationships/URLs/Lyrics_whitelist\">whitelist</a> are permitted.",
         "cardinality0" : 0,
         "reversePhrase" : "lyrics page",
         "childOrder" : 0,
         "cardinality1" : 0,
         "deprecated" : false,
         "id" : 271,
         "orderableDirection" : 0,
         "phrase" : "lyrics page for",
         "gid" : "e38e65aa-75e0-42ba-ace0-072aeb91a538"
      },
      {
         "type1" : "work",
         "hasDates" : false,
         "type0" : "url",
         "description" : "This describes a URL where a score / sheet music for the work can be found.",
         "cardinality0" : 0,
         "reversePhrase" : "score",
         "childOrder" : 0,
         "cardinality1" : 0,
         "deprecated" : false,
         "id" : 274,
         "orderableDirection" : 0,
         "phrase" : "score for",
         "gid" : "0cc8527e-ea40-40dd-b144-3b7588e759bf"
      },
      {
         "type1" : "work",
         "hasDates" : false,
         "type0" : "url",
         "description" : "This relationship type is <strong>deprecated</strong>.",
         "cardinality0" : 0,
         "reversePhrase" : "miscellaneous support",
         "childOrder" : 1,
         "cardinality1" : 0,
         "deprecated" : true,
         "id" : 270,
         "orderableDirection" : 0,
         "phrase" : "miscellaneous roles",
         "gid" : "00687ce8-17e1-3343-b6e5-0a91b919fe24"
      },
      {
         "type1" : "work",
         "hasDates" : false,
         "type0" : "url",
         "children" : [
            {
               "type1" : "work",
               "hasDates" : false,
               "type0" : "url",
               "description" : "Points to the Wikipedia page for this work.",
               "cardinality0" : 0,
               "reversePhrase" : "Wikipedia",
               "childOrder" : 0,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 279,
               "orderableDirection" : 0,
               "phrase" : "Wikipedia page for",
               "gid" : "b45a88d6-851e-4a6e-9ec8-9a5f4ebe76ab"
            },
            {
               "type1" : "work",
               "hasDates" : false,
               "type0" : "url",
               "description" : "This is used to link a work to its corresponding page in SecondHandSongs database.",
               "cardinality0" : 0,
               "reversePhrase" : "SecondHandSongs",
               "childOrder" : 0,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 280,
               "orderableDirection" : 0,
               "phrase" : "SecondHandSongs page for",
               "gid" : "b80dff64-9560-445a-b824-c8b432d77a52"
            },
            {
               "type1" : "work",
               "hasDates" : false,
               "type0" : "url",
               "description" : "This is used to link a work to its corresponding page on Allmusic.",
               "cardinality0" : 0,
               "reversePhrase" : "Allmusic",
               "childOrder" : 0,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 286,
               "orderableDirection" : 0,
               "phrase" : "Allmusic page for",
               "gid" : "ca9c9f46-11bd-423a-b134-9109cbebe9d7"
            },
            {
               "type1" : "work",
               "hasDates" : false,
               "type0" : "url",
               "description" : "This links an entity to the appropriate listing in the Songfacts database, a user contributed database concerned with the stories behind the songs.",
               "cardinality0" : 0,
               "reversePhrase" : "Songfacts",
               "childOrder" : 0,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 289,
               "orderableDirection" : 0,
               "phrase" : "Songfacts page for",
               "gid" : "80402bbc-1aec-41d1-a5be-b599b89bc3c3"
            },
            {
               "type1" : "work",
               "hasDates" : false,
               "type0" : "url",
               "description" : "This points to the <a href=\"//viaf.org/\">VIAF</a> page for this work. VIAF is an international project to make a common authority file available to libraries across the world. An authority file is similar to an MBID for libraries. (<a href=\"//en.wikipedia.org/wiki/Virtual_International_Authority_File\">more information on Wikipedia</a>) <br/><br/> <strong>Note:</strong> Works in VIAF aren't very detailed. Only add links to MusicBrainz works if you're absolutely sure it's the same work.",
               "cardinality0" : 0,
               "reversePhrase" : "VIAF ID",
               "childOrder" : 0,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 312,
               "orderableDirection" : 0,
               "phrase" : "VIAF ID for",
               "gid" : "b6eaef52-68a0-4b50-b875-8acd7d9212ba"
            },
            {
               "type1" : "work",
               "hasDates" : false,
               "type0" : "url",
               "description" : "Points to the Wikidata page for this work.",
               "cardinality0" : 0,
               "reversePhrase" : "Wikidata",
               "childOrder" : 0,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 351,
               "orderableDirection" : 0,
               "phrase" : "Wikidata page for",
               "gid" : "587fdd8f-080e-46a9-97af-6425ebbcb3a2"
            }
         ],
         "description" : "This links an entity to the equivalent entry in another database. Please respect the <a href=\"/doc/Other_Databases_Relationship_Type/Whitelist\">whitelist</a>.",
         "cardinality0" : 0,
         "reversePhrase" : "other databases",
         "childOrder" : 99,
         "cardinality1" : 0,
         "deprecated" : false,
         "id" : 273,
         "orderableDirection" : 0,
         "phrase" : "other databases",
         "gid" : "190ea031-4355-405d-a43e-53eb4c5c4ada"
      }
   ],
   "area-recording" : [
      {
         "type1" : "recording",
         "hasDates" : true,
         "type0" : "area",
         "description" : "Links a recording to the area it was recorded in. Use only when the place is unknown!",
         "cardinality0" : 0,
         "reversePhrase" : "recorded in",
         "childOrder" : 0,
         "cardinality1" : 0,
         "deprecated" : false,
         "id" : 698,
         "orderableDirection" : 0,
         "phrase" : "recording location for",
         "gid" : "37ef3a0c-cac3-4172-b09b-4ca98d2857fc"
      }
   ],
   "artist-recording" : [
      {
         "type1" : "recording",
         "hasDates" : false,
         "type0" : "artist",
         "children" : [
            {
               "type1" : "recording",
               "hasDates" : true,
               "type0" : "artist",
               "children" : [
                  {
                     "type1" : "recording",
                     "hasDates" : true,
                     "type0" : "artist",
                     "description" : "Indicates an artist that performed one or more instruments on this recording.",
                     "cardinality0" : 1,
                     "reversePhrase" : "{additional} {guest} {solo} {instrument:%|instruments}",
                     "childOrder" : 0,
                     "cardinality1" : 0,
                     "deprecated" : false,
                     "id" : 148,
                     "attributes" : {
                        "596" : {
                           "min" : 0,
                           "max" : 1
                        },
                        "1" : {
                           "min" : 0,
                           "max" : 1
                        },
                        "194" : {
                           "min" : 0,
                           "max" : 1
                        },
                        "14" : {
                           "min" : 0,
                           "max" : null
                        }
                     },
                     "orderableDirection" : 0,
                     "phrase" : "{additional} {guest} {solo} {instrument:%|instruments}",
                     "gid" : "59054b12-01ac-43ee-a618-285fd397e461"
                  },
                  {
                     "type1" : "recording",
                     "hasDates" : true,
                     "type0" : "artist",
                     "description" : "Indicates an artist that performed vocals on this recording.",
                     "cardinality0" : 1,
                     "reversePhrase" : "{additional} {guest} {solo} {vocal} {vocal:|vocals}",
                     "childOrder" : 1,
                     "cardinality1" : 0,
                     "deprecated" : false,
                     "id" : 149,
                     "attributes" : {
                        "596" : {
                           "min" : 0,
                           "max" : 1
                        },
                        "1" : {
                           "min" : 0,
                           "max" : 1
                        },
                        "194" : {
                           "min" : 0,
                           "max" : 1
                        },
                        "3" : {
                           "min" : 0,
                           "max" : null
                        }
                     },
                     "orderableDirection" : 0,
                     "phrase" : "{additional} {guest} {solo} {vocal} {vocal:|vocals}",
                     "gid" : "0fdbe3c6-7700-4a31-ae54-b53f06ae1cfa"
                  }
               ],
               "description" : "Indicates an artist that performed on this recording.",
               "cardinality0" : 1,
               "reversePhrase" : "{additional} {guest} {solo} performer",
               "childOrder" : 0,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 156,
               "attributes" : {
                  "596" : {
                     "min" : 0,
                     "max" : 1
                  },
                  "1" : {
                     "min" : 0,
                     "max" : 1
                  },
                  "194" : {
                     "min" : 0,
                     "max" : 1
                  }
               },
               "orderableDirection" : 0,
               "phrase" : "{additional:additionally} {guest} {solo} performed",
               "gid" : "628a9658-f54c-4142-b0c0-95f031b544da"
            },
            {
               "type1" : "recording",
               "hasDates" : true,
               "type0" : "artist",
               "description" : "Indicates an orchestra that performed on this recording.",
               "cardinality0" : 1,
               "reversePhrase" : "{additional} orchestra",
               "childOrder" : 1,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 150,
               "attributes" : {
                  "1" : {
                     "min" : 0,
                     "max" : 1
                  }
               },
               "orderableDirection" : 0,
               "phrase" : "{additional} orchestra",
               "gid" : "3b6616c5-88ba-4341-b4ee-81ce1e6d7ebb"
            },
            {
               "type1" : "recording",
               "hasDates" : true,
               "type0" : "artist",
               "description" : "This indicates an artist who conducted an orchestra, band or choir on this recording.",
               "cardinality0" : 1,
               "reversePhrase" : "{additional} conductor",
               "childOrder" : 2,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 151,
               "attributes" : {
                  "1" : {
                     "min" : 0,
                     "max" : 1
                  }
               },
               "orderableDirection" : 0,
               "phrase" : "{additional:additionally} conducted",
               "gid" : "234670ce-5f22-4fd0-921b-ef1662695c5d"
            },
            {
               "type1" : "recording",
               "hasDates" : true,
               "type0" : "artist",
               "description" : "This indicates the chorus master of a choir which performed on this recording.",
               "cardinality0" : 1,
               "reversePhrase" : "{additional} chorus master",
               "childOrder" : 3,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 152,
               "attributes" : {
                  "1" : {
                     "min" : 0,
                     "max" : 1
                  }
               },
               "orderableDirection" : 0,
               "phrase" : "{additional} chorus master",
               "gid" : "45115945-597e-4cb9-852f-4e6ba583fcc8"
            }
         ],
         "cardinality0" : 1,
         "reversePhrase" : "performance",
         "childOrder" : 0,
         "cardinality1" : 0,
         "deprecated" : false,
         "id" : 122,
         "orderableDirection" : 0,
         "phrase" : "performance",
         "gid" : "f8673e29-02a5-47b7-af61-dd4519328dd0"
      },
      {
         "type1" : "recording",
         "hasDates" : false,
         "type0" : "artist",
         "children" : [
            {
               "type1" : "recording",
               "hasDates" : true,
               "type0" : "artist",
               "description" : "This indicates the person who selected the tracks and the sequence for a compilation. This applies to one long recording which contains multiple songs, one after the other. If the tracks are pitched or blended into each other, it is more appropriate to credit this person as a <a href=\"/relationship/28338ee6-d578-485a-bb53-61dbfd7c6545\">DJ-mixer</a>.",
               "cardinality0" : 1,
               "reversePhrase" : "compiler",
               "childOrder" : 0,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 147,
               "orderableDirection" : 0,
               "phrase" : "compiled",
               "gid" : "35ba2b3b-aaeb-4db1-bc5f-f42154e785d8"
            },
            {
               "type1" : "recording",
               "hasDates" : true,
               "type0" : "artist",
               "description" : "This links a recording to the person who remixed it by taking one or more other tracks, substantially altering them and mixing them together with other material. Note that this includes the artist who created a mash-up or used samples as well.",
               "cardinality0" : 1,
               "reversePhrase" : "{additional} remixer",
               "childOrder" : 0,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 153,
               "attributes" : {
                  "1" : {
                     "min" : 0,
                     "max" : 1
                  }
               },
               "orderableDirection" : 0,
               "phrase" : "{additional:additionally} remixed",
               "gid" : "7950be4d-13a3-48e7-906b-5af562e39544"
            },
            {
               "type1" : "recording",
               "hasDates" : true,
               "type0" : "artist",
               "description" : "This links a <a href=\"/doc/Mix_Terminology#DJ_mix\">DJ-mix</a> to the artist who mixed it.",
               "cardinality0" : 1,
               "reversePhrase" : "DJ-mixer",
               "childOrder" : 0,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 155,
               "orderableDirection" : 0,
               "phrase" : "DJ-mixed",
               "gid" : "28338ee6-d578-485a-bb53-61dbfd7c6545"
            },
            {
               "type1" : "recording",
               "hasDates" : true,
               "type0" : "artist",
               "description" : "Indicates that the recording contains samples from material by the indicated artist. Use this only if you really cannot figure out the particular recording that has been sampled.",
               "cardinality0" : 1,
               "reversePhrase" : "contains {additional} samples by",
               "childOrder" : 1,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 154,
               "attributes" : {
                  "1" : {
                     "min" : 0,
                     "max" : 1
                  },
                  "3" : {
                     "min" : 0,
                     "max" : null
                  },
                  "14" : {
                     "min" : 0,
                     "max" : null
                  }
               },
               "orderableDirection" : 0,
               "phrase" : "produced material that was {additional:additionally} sampled in",
               "gid" : "83f72956-2007-4bca-8a97-0ae539cca99d"
            }
         ],
         "cardinality0" : 0,
         "reversePhrase" : "remixes and compilations",
         "childOrder" : 1,
         "cardinality1" : 0,
         "deprecated" : false,
         "id" : 157,
         "orderableDirection" : 0,
         "phrase" : "remixes and compilations",
         "gid" : "91109adb-a5a3-47b1-99bf-06f88130e875"
      },
      {
         "type1" : "recording",
         "hasDates" : true,
         "type0" : "artist",
         "children" : [
            {
               "type1" : "recording",
               "hasDates" : true,
               "type0" : "artist",
               "children" : [
                  {
                     "type1" : "recording",
                     "hasDates" : true,
                     "type0" : "artist",
                     "description" : "This indicates the person who orchestrated the recording. Orchestration is a special type of arrangement. It means the adaptation of a composition for an orchestra, done in a way that the musical substance remains essentially unchanged. The orchestrator is also responsible for writing scores for an orchestra, band, choral group, individual instrumentalist(s) or vocalist(s). In practical terms it consists of deciding which instruments should play which notes in a piece of music.",
                     "cardinality0" : 1,
                     "reversePhrase" : "{additional} orchestrator",
                     "childOrder" : 0,
                     "cardinality1" : 0,
                     "deprecated" : false,
                     "id" : 300,
                     "attributes" : {
                        "1" : {
                           "min" : 0,
                           "max" : 1
                        }
                     },
                     "orderableDirection" : 0,
                     "phrase" : "{additional:additionally} orchestrated",
                     "gid" : "38fa7405-f9a5-48cb-827a-8ac601933ba0"
                  }
               ],
               "description" : "This indicates the artist who arranged a tune into a form suitable for performance. 'Arrangement' is used as a catch-all term for all processes that turn a composition into a form that can be played by a specific type of ensemble.",
               "cardinality0" : 1,
               "reversePhrase" : "{additional} {instrument:%|instruments} arranger",
               "childOrder" : 1,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 158,
               "attributes" : {
                  "1" : {
                     "min" : 0,
                     "max" : 1
                  },
                  "14" : {
                     "min" : 0,
                     "max" : null
                  }
               },
               "orderableDirection" : 0,
               "phrase" : "{additional:additionally} {instrument:%|instruments} arranged",
               "gid" : "4820daa1-98d6-4f8b-aa4b-6895c5b79b27"
            },
            {
               "type1" : "recording",
               "hasDates" : true,
               "type0" : "artist",
               "description" : "This indicates the artist who arranged a tune into a form suitable for performance. 'Arrangement' is used as a catch-all term for all processes that turn a composition into a form that can be played by a specific type of ensemble.",
               "cardinality0" : 1,
               "reversePhrase" : "{additional} {vocal:%|vocals} arranger",
               "childOrder" : 2,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 298,
               "attributes" : {
                  "1" : {
                     "min" : 0,
                     "max" : 1
                  },
                  "3" : {
                     "min" : 0,
                     "max" : null
                  }
               },
               "orderableDirection" : 0,
               "phrase" : "{additional:additionally} {vocal:%|vocals} arranged",
               "gid" : "8a2799e8-a7e2-41ce-a7da-b5f520687216"
            }
         ],
         "description" : "This indicates the artist who arranged a tune into a form suitable for performance. 'Arrangement' is used as a catch-all term for all processes that turn a composition into a form that can be played by a specific type of ensemble.",
         "cardinality0" : 1,
         "reversePhrase" : "{additional} arranger",
         "childOrder" : 1,
         "cardinality1" : 0,
         "deprecated" : false,
         "id" : 297,
         "attributes" : {
            "1" : {
               "min" : 0,
               "max" : 1
            }
         },
         "orderableDirection" : 0,
         "phrase" : "{additional:additionally} arranged",
         "gid" : "22661fb8-cdb7-4f67-8385-b2a8be6c9f0d"
      },
      {
         "type1" : "recording",
         "hasDates" : false,
         "type0" : "artist",
         "children" : [
            {
               "type1" : "recording",
               "hasDates" : true,
               "type0" : "artist",
               "description" : "This indicates an artist who is responsible for the creative and practical day-to-day aspects involved with making a musical recording.",
               "cardinality0" : 1,
               "reversePhrase" : "{additional} {assistant} {associate} {co:co-}{executive:executive }producer",
               "childOrder" : 0,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 141,
               "attributes" : {
                  "527" : {
                     "min" : 0,
                     "max" : 1
                  },
                  "1" : {
                     "min" : 0,
                     "max" : 1
                  },
                  "526" : {
                     "min" : 0,
                     "max" : 1
                  },
                  "424" : {
                     "min" : 0,
                     "max" : 1
                  },
                  "425" : {
                     "min" : 0,
                     "max" : 1
                  }
               },
               "orderableDirection" : 0,
               "phrase" : "{additional:additionally} {assistant} {associate} {co:co-}{executive:executive }produced",
               "gid" : "5c0ceac3-feb4-41f0-868d-dc06f6e27fc0"
            },
            {
               "type1" : "recording",
               "hasDates" : true,
               "type0" : "artist",
               "children" : [
                  {
                     "type1" : "recording",
                     "hasDates" : true,
                     "type0" : "artist",
                     "description" : "This relationship type is <strong>deprecated</strong>! Please add mastering engineers at the release level.",
                     "cardinality0" : 1,
                     "reversePhrase" : "{additional} {assistant} {associate} {co:co-}mastering",
                     "childOrder" : 0,
                     "cardinality1" : 0,
                     "deprecated" : true,
                     "id" : 136,
                     "attributes" : {
                        "527" : {
                           "min" : 0,
                           "max" : 1
                        },
                        "1" : {
                           "min" : 0,
                           "max" : 1
                        },
                        "526" : {
                           "min" : 0,
                           "max" : 1
                        },
                        "424" : {
                           "min" : 0,
                           "max" : 1
                        }
                     },
                     "orderableDirection" : 0,
                     "phrase" : "{additional} {assistant} {associate} {co:co-}mastering",
                     "gid" : "30adb2d7-dbcc-4393-9230-2098510ce3c1"
                  },
                  {
                     "type1" : "recording",
                     "hasDates" : true,
                     "type0" : "artist",
                     "description" : "This describes an engineer involved with the machines used to generate sound, such as effects processors and digital audio equipment used to modify or manipulate sound in either an analogue or digital form.",
                     "cardinality0" : 1,
                     "reversePhrase" : "{additional} {assistant} {associate} {co:co-}audio engineer",
                     "childOrder" : 0,
                     "cardinality1" : 0,
                     "deprecated" : false,
                     "id" : 140,
                     "attributes" : {
                        "527" : {
                           "min" : 0,
                           "max" : 1
                        },
                        "1" : {
                           "min" : 0,
                           "max" : 1
                        },
                        "526" : {
                           "min" : 0,
                           "max" : 1
                        },
                        "424" : {
                           "min" : 0,
                           "max" : 1
                        }
                     },
                     "orderableDirection" : 0,
                     "phrase" : "{additional:additionally} {assistant} {associate} {co:co-}audio engineered",
                     "gid" : "ca8d6d99-b847-439c-b0ec-33d8a1b942bc"
                  },
                  {
                     "type1" : "recording",
                     "hasDates" : true,
                     "type0" : "artist",
                     "description" : "This describes an engineer responsible for ensuring that the sounds that the artists make reach the microphones sounding pleasant, without unwanted resonance or noise. Sometimes known as acoustical engineering.",
                     "cardinality0" : 1,
                     "reversePhrase" : "{additional} {assistant} {associate} {co:co-}sound engineer",
                     "childOrder" : 1,
                     "cardinality1" : 0,
                     "deprecated" : false,
                     "id" : 133,
                     "attributes" : {
                        "527" : {
                           "min" : 0,
                           "max" : 1
                        },
                        "1" : {
                           "min" : 0,
                           "max" : 1
                        },
                        "526" : {
                           "min" : 0,
                           "max" : 1
                        },
                        "424" : {
                           "min" : 0,
                           "max" : 1
                        }
                     },
                     "orderableDirection" : 0,
                     "phrase" : "{additional:additionally} {assistant} {associate} {co:co-}sound engineered",
                     "gid" : "0cd6aa63-c297-42ed-8725-c16d31913a98"
                  },
                  {
                     "type1" : "recording",
                     "hasDates" : true,
                     "type0" : "artist",
                     "description" : "This describes an engineer responsible for using a mixing console to mix a recorded track into a single piece of music suitable for release.​ For remixing, see <a href=\"/relationship/7950be4d-13a3-48e7-906b-5af562e39544\">remixer</a>.",
                     "cardinality0" : 1,
                     "reversePhrase" : "{additional} {assistant} {associate} {co:co-}mixer",
                     "childOrder" : 3,
                     "cardinality1" : 0,
                     "deprecated" : false,
                     "id" : 143,
                     "attributes" : {
                        "527" : {
                           "min" : 0,
                           "max" : 1
                        },
                        "1" : {
                           "min" : 0,
                           "max" : 1
                        },
                        "526" : {
                           "min" : 0,
                           "max" : 1
                        },
                        "424" : {
                           "min" : 0,
                           "max" : 1
                        }
                     },
                     "orderableDirection" : 0,
                     "phrase" : "{additional:additionally} {assistant} {associate} {co:co-}mixed",
                     "gid" : "3e3102e1-1896-4f50-b5b2-dd9824e46efe"
                  },
                  {
                     "type1" : "recording",
                     "hasDates" : true,
                     "type0" : "artist",
                     "description" : "This describes an engineer responsible for committing the performance to tape. This can be as complex as setting up the microphones, amplifiers, and recording devices, or as simple as pressing the 'record' button on a 4-track.",
                     "cardinality0" : 1,
                     "reversePhrase" : "{additional:additionally} {assistant} {associate} {co:co-}recorded by",
                     "childOrder" : 4,
                     "cardinality1" : 0,
                     "deprecated" : false,
                     "id" : 128,
                     "attributes" : {
                        "527" : {
                           "min" : 0,
                           "max" : 1
                        },
                        "1" : {
                           "min" : 0,
                           "max" : 1
                        },
                        "526" : {
                           "min" : 0,
                           "max" : 1
                        },
                        "424" : {
                           "min" : 0,
                           "max" : 1
                        }
                     },
                     "orderableDirection" : 0,
                     "phrase" : "{additional:additionally} {assistant} {associate} {co:co-}recorded",
                     "gid" : "a01ee869-80a8-45ef-9447-c59e91aa7926"
                  },
                  {
                     "type1" : "recording",
                     "hasDates" : true,
                     "type0" : "artist",
                     "description" : "This links a recording to the artist who did the programming for electronic instruments used on the recording.​ In the most cases, the 'electronic instrument' is either a synthesizer or a drum machine.",
                     "cardinality0" : 1,
                     "reversePhrase" : "{additional} {assistant} {associate} {instrument} programming",
                     "childOrder" : 5,
                     "cardinality1" : 0,
                     "deprecated" : false,
                     "id" : 132,
                     "attributes" : {
                        "527" : {
                           "min" : 0,
                           "max" : 1
                        },
                        "1" : {
                           "min" : 0,
                           "max" : 1
                        },
                        "526" : {
                           "min" : 0,
                           "max" : 1
                        },
                        "14" : {
                           "min" : 0,
                           "max" : null
                        }
                     },
                     "orderableDirection" : 0,
                     "phrase" : "{additional} {assistant} {associate} {instrument} programming",
                     "gid" : "36c50022-44e0-488d-994b-33f11d20301e"
                  },
                  {
                     "type1" : "recording",
                     "hasDates" : true,
                     "type0" : "artist",
                     "description" : "This describes an engineer responsible for either connecting disparate elements of the audio recording, or otherwise redistributing material recorded in the sessions.​ This is usually secondary, or additional to the work done by the mix engineer. It can also involve streamlining a longer track to around the 3 minute mark in order to make it suitable for radio play (a \"radio edit\").",
                     "cardinality0" : 1,
                     "reversePhrase" : "{additional} {assistant} {associate} {co:co-}editor",
                     "childOrder" : 6,
                     "cardinality1" : 0,
                     "deprecated" : false,
                     "id" : 144,
                     "attributes" : {
                        "527" : {
                           "min" : 0,
                           "max" : 1
                        },
                        "1" : {
                           "min" : 0,
                           "max" : 1
                        },
                        "526" : {
                           "min" : 0,
                           "max" : 1
                        },
                        "424" : {
                           "min" : 0,
                           "max" : 1
                        }
                     },
                     "orderableDirection" : 0,
                     "phrase" : "{additional:additionally} {assistant} {associate} {co:co-}edited",
                     "gid" : "40dff87a-e475-4aa6-b615-9935b564d756"
                  },
                  {
                     "type1" : "recording",
                     "hasDates" : true,
                     "type0" : "artist",
                     "description" : "This links a recording to the balance engineer who engineered it.",
                     "cardinality0" : 1,
                     "reversePhrase" : "{additional} {assistant} {associate} {co:co-}balance engineer",
                     "childOrder" : 7,
                     "cardinality1" : 0,
                     "deprecated" : false,
                     "id" : 726,
                     "attributes" : {
                        "527" : {
                           "min" : 0,
                           "max" : 1
                        },
                        "1" : {
                           "min" : 0,
                           "max" : 1
                        },
                        "526" : {
                           "min" : 0,
                           "max" : 1
                        },
                        "3" : {
                           "min" : 0,
                           "max" : null
                        },
                        "424" : {
                           "min" : 0,
                           "max" : 1
                        },
                        "14" : {
                           "min" : 0,
                           "max" : null
                        }
                     },
                     "orderableDirection" : 0,
                     "phrase" : "{additional:additionally} {assistant} {associate} {co:co-}balance engineered",
                     "gid" : "0748fa55-56b5-4ad5-8ce8-15b97f82a0c2"
                  }
               ],
               "description" : "This describes an engineer who performed a general engineering role.​",
               "cardinality0" : 1,
               "reversePhrase" : "{additional} {assistant} {associate} {co:co-}{executive:executive }engineer",
               "childOrder" : 1,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 138,
               "attributes" : {
                  "527" : {
                     "min" : 0,
                     "max" : 1
                  },
                  "1" : {
                     "min" : 0,
                     "max" : 1
                  },
                  "526" : {
                     "min" : 0,
                     "max" : 1
                  },
                  "424" : {
                     "min" : 0,
                     "max" : 1
                  },
                  "425" : {
                     "min" : 0,
                     "max" : 1
                  }
               },
               "orderableDirection" : 0,
               "phrase" : "{additional:additionally} {assistant} {associate} {co:co-}{executive:executive }engineered",
               "gid" : "5dcc52af-7064-4051-8d62-7d80f4c3c907"
            },
            {
               "type1" : "recording",
               "hasDates" : true,
               "type0" : "artist",
               "children" : [
                  {
                     "type1" : "recording",
                     "hasDates" : true,
                     "type0" : "artist",
                     "description" : "This indicates that a person or firm provided legal representation for the recording.",
                     "cardinality0" : 1,
                     "reversePhrase" : "legal representation",
                     "childOrder" : 0,
                     "cardinality1" : 0,
                     "deprecated" : false,
                     "id" : 142,
                     "orderableDirection" : 0,
                     "phrase" : "legal representation",
                     "gid" : "75e37b65-7b50-4080-bf04-8c59c66b5f65"
                  },
                  {
                     "type1" : "recording",
                     "hasDates" : true,
                     "type0" : "artist",
                     "description" : "This credits a person who was responsible for booking the studio or performance venue where the recording was recorded.",
                     "cardinality0" : 1,
                     "reversePhrase" : "booking",
                     "childOrder" : 1,
                     "cardinality1" : 0,
                     "deprecated" : false,
                     "id" : 134,
                     "orderableDirection" : 0,
                     "phrase" : "booking",
                     "gid" : "b1edc6f6-283d-4e32-b625-b96cfb192056"
                  },
                  {
                     "type1" : "recording",
                     "hasDates" : true,
                     "type0" : "artist",
                     "description" : "This indicates a person or agency which is responsible for talent scouting, overseeing the artistic development of an artist, and acting as liaison between artists and the labels.",
                     "cardinality0" : 1,
                     "reversePhrase" : "artist & repertoire support",
                     "childOrder" : 2,
                     "cardinality1" : 0,
                     "deprecated" : false,
                     "id" : 135,
                     "orderableDirection" : 0,
                     "phrase" : "artist & repertoire support",
                     "gid" : "8dc10cef-3116-4b3d-8e3e-33ffb84a97df"
                  },
                  {
                     "type1" : "recording",
                     "hasDates" : true,
                     "type0" : "artist",
                     "description" : "This credits a person or agency who provided some kind of general creative inspiration during the recording of this recording, without actually contributing to the writing or performance.",
                     "cardinality0" : 1,
                     "reversePhrase" : "{additional} creative direction",
                     "childOrder" : 3,
                     "cardinality1" : 0,
                     "deprecated" : false,
                     "id" : 146,
                     "attributes" : {
                        "1" : {
                           "min" : 0,
                           "max" : 1
                        }
                     },
                     "orderableDirection" : 0,
                     "phrase" : "{additional} creative direction",
                     "gid" : "0eb67a3e-796b-4394-ab6e-1224f43236b6"
                  },
                  {
                     "type1" : "recording",
                     "hasDates" : true,
                     "type0" : "artist",
                     "description" : "This indicates that a person or agency did the art direction for the recording.",
                     "cardinality0" : 1,
                     "reversePhrase" : "{additional} art direction",
                     "childOrder" : 4,
                     "cardinality1" : 0,
                     "deprecated" : false,
                     "id" : 137,
                     "attributes" : {
                        "1" : {
                           "min" : 0,
                           "max" : 1
                        }
                     },
                     "orderableDirection" : 0,
                     "phrase" : "{additional} art direction",
                     "gid" : "9aae9a3d-7cc2-4eee-881d-b8b73d0ceef3"
                  },
                  {
                     "type1" : "recording",
                     "hasDates" : true,
                     "type0" : "artist",
                     "description" : "This indicates a person or agency who did design or illustration for the track.",
                     "cardinality0" : 1,
                     "reversePhrase" : "{additional} design/illustration",
                     "childOrder" : 5,
                     "cardinality1" : 0,
                     "deprecated" : false,
                     "id" : 130,
                     "attributes" : {
                        "1" : {
                           "min" : 0,
                           "max" : 1
                        }
                     },
                     "orderableDirection" : 0,
                     "phrase" : "{additional} design/illustration",
                     "gid" : "4af8e696-2690-486f-87db-bc8ec2bfe859"
                  },
                  {
                     "type1" : "recording",
                     "hasDates" : true,
                     "type0" : "artist",
                     "description" : "This credits the people or agency who did the graphic design, arranging pieces of content into a coherent and aesthetically-pleasing sleeve design.",
                     "cardinality0" : 1,
                     "reversePhrase" : "{additional} graphic design",
                     "childOrder" : 6,
                     "cardinality1" : 0,
                     "deprecated" : false,
                     "id" : 125,
                     "attributes" : {
                        "1" : {
                           "min" : 0,
                           "max" : 1
                        }
                     },
                     "orderableDirection" : 0,
                     "phrase" : "{additional} graphic design",
                     "gid" : "38751410-ee52-435b-af75-957cb4c34149"
                  },
                  {
                     "type1" : "recording",
                     "hasDates" : true,
                     "type0" : "artist",
                     "description" : "This credits a person or agency whose photographs are included as part of a recording.",
                     "cardinality0" : 1,
                     "reversePhrase" : "{additional} photography",
                     "childOrder" : 7,
                     "cardinality1" : 0,
                     "deprecated" : false,
                     "id" : 123,
                     "attributes" : {
                        "1" : {
                           "min" : 0,
                           "max" : 1
                        }
                     },
                     "orderableDirection" : 0,
                     "phrase" : "{additional} photography",
                     "gid" : "a7e408a1-8c64-4122-9ec2-906068955187"
                  },
                  {
                     "type1" : "recording",
                     "hasDates" : true,
                     "type0" : "artist",
                     "description" : "Indicates the publisher of this recording. This is <strong>not</strong> the same concept as the <a href=\"/doc/Label\">record label</a>.",
                     "cardinality0" : 1,
                     "reversePhrase" : "publisher",
                     "childOrder" : 9,
                     "cardinality1" : 0,
                     "deprecated" : false,
                     "id" : 127,
                     "orderableDirection" : 0,
                     "phrase" : "published",
                     "gid" : "9ef2ba0d-953c-43a9-b1b5-cf2ba5986406"
                  },
                  {
                     "type1" : "recording",
                     "hasDates" : true,
                     "type0" : "artist",
                     "description" : "This relationship type is <strong>deprecated</strong>. Add liner notes info on the release level.",
                     "cardinality0" : 1,
                     "reversePhrase" : "{additional} liner notes",
                     "childOrder" : 11,
                     "cardinality1" : 0,
                     "deprecated" : true,
                     "id" : 131,
                     "attributes" : {
                        "1" : {
                           "min" : 0,
                           "max" : 1
                        }
                     },
                     "orderableDirection" : 0,
                     "phrase" : "{additional} liner notes",
                     "gid" : "b64b96e6-7535-4ee8-9840-6ecf43959050"
                  }
               ],
               "description" : "This indicates that the artist performed a role not covered by other relationship types.",
               "cardinality0" : 1,
               "reversePhrase" : "miscellaneous support",
               "childOrder" : 2,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 129,
               "orderableDirection" : 0,
               "phrase" : "miscellaneous roles",
               "gid" : "68330a36-44cf-4fa2-84e8-533c6fe3fc23"
            }
         ],
         "cardinality0" : 1,
         "reversePhrase" : "production",
         "childOrder" : 3,
         "cardinality1" : 0,
         "deprecated" : false,
         "id" : 160,
         "orderableDirection" : 0,
         "phrase" : "production",
         "gid" : "b367fae0-c4b0-48b9-a40c-f3ae4c02cffc"
      }
   ],
   "place-work" : [
      {
         "type1" : "work",
         "hasDates" : true,
         "type0" : "place",
         "description" : "Indicates the place where the work had its first performance",
         "cardinality0" : 0,
         "reversePhrase" : "premiered at",
         "childOrder" : 0,
         "cardinality1" : 0,
         "deprecated" : false,
         "id" : 716,
         "orderableDirection" : 0,
         "phrase" : "premieres hosted",
         "gid" : "a4d2a7cb-365b-4b90-b52f-29469edf8ac0"
      }
   ],
   "release-url" : [
      {
         "type1" : "url",
         "hasDates" : false,
         "type0" : "release",
         "children" : [
            {
               "type1" : "url",
               "hasDates" : false,
               "type0" : "release",
               "description" : "This relationship type describes that the release contains samples taken from a movie, show or game, which has an IMDB page at the given URL. <br/><br/> To say that the release is a soundtrack, please use the <a href=\"/relationship/85b0a010-3237-47c7-8476-6fcefd4761af\">IMDB relationship type for release groups</a>.",
               "cardinality0" : 0,
               "reversePhrase" : "IMDb entry sampled in",
               "childOrder" : 0,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 83,
               "orderableDirection" : 0,
               "phrase" : "samples IMDb entry",
               "gid" : "7387c5a2-9abe-4515-b667-9eb5ed4dd4ce"
            }
         ],
         "cardinality0" : 0,
         "reversePhrase" : "production",
         "childOrder" : 0,
         "cardinality1" : 0,
         "deprecated" : false,
         "id" : 72,
         "orderableDirection" : 0,
         "phrase" : "production",
         "gid" : "ee1c7888-99c7-4c22-aaee-6a34a907fa24"
      },
      {
         "type1" : "url",
         "hasDates" : true,
         "type0" : "release",
         "description" : "This links a MusicBrainz release to the equivalent entry at Amazon and will often provide cover art if there is no cover art in the <a href=\"/doc/Cover_Art_Archive\">Cover Art Archive</a>.",
         "cardinality0" : 0,
         "reversePhrase" : "ASIN",
         "childOrder" : 0,
         "cardinality1" : 0,
         "deprecated" : false,
         "id" : 77,
         "orderableDirection" : 0,
         "phrase" : "ASIN",
         "gid" : "4f2e710d-166c-480c-a293-2e2c8d658d87"
      },
      {
         "type1" : "url",
         "hasDates" : true,
         "type0" : "release",
         "description" : "This link points to a page for a particular release within a discography for an artist or label.",
         "cardinality0" : 0,
         "reversePhrase" : "discography entry for",
         "childOrder" : 0,
         "cardinality1" : 0,
         "deprecated" : false,
         "id" : 288,
         "orderableDirection" : 0,
         "phrase" : "discography entry",
         "gid" : "823656dd-0309-4247-b282-b92d287d59c5"
      },
      {
         "type1" : "url",
         "hasDates" : false,
         "type0" : "release",
         "description" : "This links a release to a license under which it is available.",
         "cardinality0" : 0,
         "reversePhrase" : "license for",
         "childOrder" : 0,
         "cardinality1" : 0,
         "deprecated" : false,
         "id" : 301,
         "orderableDirection" : 0,
         "phrase" : "license",
         "gid" : "004bd0c3-8a45-4309-ba52-fa99f3aa3d50"
      },
      {
         "type1" : "url",
         "hasDates" : false,
         "type0" : "release",
         "children" : [
            {
               "type1" : "url",
               "hasDates" : true,
               "type0" : "release",
               "description" : "This relationship type is used to link to a page where the release can be purchased for mail order.",
               "cardinality0" : 0,
               "reversePhrase" : "mail-order purchase page for",
               "childOrder" : 0,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 79,
               "orderableDirection" : 0,
               "phrase" : "purchase for mail-order",
               "gid" : "3ee51e05-a06a-415e-b40c-b3f740dedfd7"
            },
            {
               "type1" : "url",
               "hasDates" : true,
               "type0" : "release",
               "description" : "This is used to link to a page where the release can be purchased for download.",
               "cardinality0" : 0,
               "reversePhrase" : "download purchase page for",
               "childOrder" : 1,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 74,
               "orderableDirection" : 0,
               "phrase" : "purchase for download",
               "gid" : "98e08c20-8402-4163-8970-53504bb6a1e4"
            },
            {
               "type1" : "url",
               "hasDates" : true,
               "type0" : "release",
               "description" : "This links a release to a page where it can be legally downloaded for free.",
               "cardinality0" : 0,
               "reversePhrase" : "free download page for",
               "childOrder" : 2,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 75,
               "orderableDirection" : 0,
               "phrase" : "download for free",
               "gid" : "9896ecd0-6d29-482d-a21e-bd5d1b5e3425"
            },
            {
               "type1" : "url",
               "hasDates" : true,
               "type0" : "release",
               "description" : "This relationship type is used to link a release to a site where the tracks can be legally streamed for free, e.g. Spotify.",
               "cardinality0" : 0,
               "reversePhrase" : "free music {video} streaming page for",
               "childOrder" : 3,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 85,
               "attributes" : {
                  "582" : {
                     "min" : 0,
                     "max" : 1
                  }
               },
               "orderableDirection" : 0,
               "phrase" : "stream {video} for free",
               "gid" : "08445ccf-7b99-4438-9f9a-fb9ac18099ee"
            }
         ],
         "cardinality0" : 0,
         "reversePhrase" : "get the music",
         "childOrder" : 2,
         "cardinality1" : 0,
         "deprecated" : false,
         "id" : 73,
         "orderableDirection" : 0,
         "phrase" : "get the music",
         "gid" : "759935d6-c9c6-4362-8978-2f0d46d67deb"
      },
      {
         "type1" : "url",
         "hasDates" : false,
         "type0" : "release",
         "description" : "This relationship links the release of a show's episode (for example a podcast) to the show notes for this episode.",
         "cardinality0" : 0,
         "reversePhrase" : "show notes for",
         "childOrder" : 4,
         "cardinality1" : 0,
         "deprecated" : false,
         "id" : 729,
         "orderableDirection" : 0,
         "phrase" : "show notes",
         "gid" : "2d24d075-9943-4c4d-a659-8ce52e6e6b57"
      },
      {
         "type1" : "url",
         "hasDates" : false,
         "type0" : "release",
         "description" : "This relationship type is <strong>deprecated</strong>! Please upload covers on the cover art tab for the release and/or add an ASIN relationship. Note about CD Baby: Many CD Baby releases are also available (usually with bigger covers) on Amazon.com.",
         "cardinality0" : 0,
         "reversePhrase" : "cover art for",
         "childOrder" : 9,
         "cardinality1" : 0,
         "deprecated" : true,
         "id" : 78,
         "orderableDirection" : 0,
         "phrase" : "cover art",
         "gid" : "2476be45-3090-43b3-a948-a8f972b4065c"
      },
      {
         "type1" : "url",
         "hasDates" : false,
         "type0" : "release",
         "children" : [
            {
               "type1" : "url",
               "hasDates" : false,
               "type0" : "release",
               "description" : "This is used to link the Discogs page for this release.",
               "cardinality0" : 0,
               "reversePhrase" : "Discogs page for",
               "childOrder" : 0,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 76,
               "orderableDirection" : 0,
               "phrase" : "Discogs",
               "gid" : "4a78823c-1c53-4176-a5f3-58026c76f2bc"
            },
            {
               "type1" : "url",
               "hasDates" : false,
               "type0" : "release",
               "description" : "This relationship type links a release to its corresponding page <a href=\"http://vgmdb.net/\">VGMdb</a>. VGMdb is a community project dedicated to cataloguing the music of video games and anime.",
               "cardinality0" : 0,
               "reversePhrase" : "VGMdb page for",
               "childOrder" : 0,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 86,
               "orderableDirection" : 0,
               "phrase" : "VGMdb",
               "gid" : "6af0134a-df6a-425a-96e2-895f9cd342ba"
            },
            {
               "type1" : "url",
               "hasDates" : false,
               "type0" : "release",
               "description" : "This is used to link a release to its corresponding page in SecondHandSongs database.",
               "cardinality0" : 0,
               "reversePhrase" : "SecondHandSongs page for",
               "childOrder" : 0,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 308,
               "orderableDirection" : 0,
               "phrase" : "SecondHandSongs",
               "gid" : "0e555925-1b7d-475c-9b25-b9c349dcc3f3"
            }
         ],
         "description" : "This links an entity to the equivalent entry in another database. Please respect the <a href=\"/doc/Other_Databases_Relationship_Type/Whitelist\">whitelist</a>.",
         "cardinality0" : 0,
         "reversePhrase" : "other databases",
         "childOrder" : 99,
         "cardinality1" : 0,
         "deprecated" : false,
         "id" : 82,
         "orderableDirection" : 0,
         "phrase" : "other databases",
         "gid" : "c74dee45-3c85-41e9-a804-92ab1c654446"
      }
   ],
   "area-area" : [
      {
         "type1" : "area",
         "hasDates" : true,
         "type0" : "area",
         "description" : "Designates that one area is contained by another.",
         "cardinality0" : 0,
         "reversePhrase" : "part of",
         "childOrder" : 0,
         "cardinality1" : 0,
         "deprecated" : false,
         "id" : 356,
         "orderableDirection" : 0,
         "phrase" : "parts",
         "gid" : "de7cc874-8b1b-3a05-8272-f3834c968fb7"
      }
   ],
   "recording-url" : [
      {
         "type1" : "url",
         "hasDates" : false,
         "type0" : "recording",
         "children" : [
            {
               "type1" : "url",
               "hasDates" : false,
               "type0" : "recording",
               "description" : "This relationship type describes that the recording contains samples taken from a movie, show or game, which has an IMDB page at the given URL. <br/><br/> To say that the recording is part of a soundtrack, please use the <a href=\"/relationship/85b0a010-3237-47c7-8476-6fcefd4761af\">IMDB relationship type for release groups</a>.",
               "cardinality0" : 0,
               "reversePhrase" : "IMDb entry sampled in",
               "childOrder" : 0,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 258,
               "orderableDirection" : 0,
               "phrase" : "samples IMDb entry",
               "gid" : "dad34b86-5a1a-4628-acf5-a48ccb0785f2"
            }
         ],
         "cardinality0" : 0,
         "reversePhrase" : "production",
         "childOrder" : 0,
         "cardinality1" : 0,
         "deprecated" : false,
         "id" : 256,
         "orderableDirection" : 0,
         "phrase" : "production",
         "gid" : "c0b9cc44-ea3b-4312-94f9-577c2605d305"
      },
      {
         "type1" : "url",
         "hasDates" : false,
         "type0" : "recording",
         "description" : "This links a recording to a license under which it is available.",
         "cardinality0" : 0,
         "reversePhrase" : "license for",
         "childOrder" : 0,
         "cardinality1" : 0,
         "deprecated" : false,
         "id" : 302,
         "orderableDirection" : 0,
         "phrase" : "license",
         "gid" : "f25e301d-b87b-4561-86a0-5d2df6d26c0a"
      },
      {
         "type1" : "url",
         "hasDates" : false,
         "type0" : "recording",
         "children" : [
            {
               "type1" : "url",
               "hasDates" : false,
               "type0" : "recording",
               "description" : "This is used to link to a page where the recording can be purchased for download.",
               "cardinality0" : 0,
               "reversePhrase" : "download purchase page for",
               "childOrder" : 0,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 254,
               "orderableDirection" : 0,
               "phrase" : "purchase for download",
               "gid" : "92777657-504c-4acb-bd33-51a201bd57e1"
            },
            {
               "type1" : "url",
               "hasDates" : true,
               "type0" : "recording",
               "description" : "This links a recording to a page where it can be legally downloaded for free.",
               "cardinality0" : 0,
               "reversePhrase" : "free download page for",
               "childOrder" : 1,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 255,
               "orderableDirection" : 0,
               "phrase" : "download for free",
               "gid" : "45d0cbc5-d65b-4e77-bdfd-8a75207cb5c5"
            },
            {
               "type1" : "url",
               "hasDates" : true,
               "type0" : "recording",
               "description" : "This relationship type is used to link a track to a site where the track can be legally streamed for free, such as Spotify for audio tracks or YouTube for videos.",
               "cardinality0" : 0,
               "reversePhrase" : "free music {video} streaming page for",
               "childOrder" : 2,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 268,
               "attributes" : {
                  "582" : {
                     "min" : 0,
                     "max" : 1
                  }
               },
               "orderableDirection" : 0,
               "phrase" : "stream {video} for free",
               "gid" : "7e41ef12-a124-4324-afdb-fdbae687a89c"
            }
         ],
         "cardinality0" : 0,
         "reversePhrase" : "get the music",
         "childOrder" : 1,
         "cardinality1" : 0,
         "deprecated" : false,
         "id" : 257,
         "orderableDirection" : 0,
         "phrase" : "get the music",
         "gid" : "44598c7e-01f9-438b-950a-183720a2cbbe"
      },
      {
         "type1" : "url",
         "hasDates" : false,
         "type0" : "recording",
         "children" : [
            {
               "type1" : "url",
               "hasDates" : false,
               "type0" : "recording",
               "description" : "This is used to link a recording to its corresponding page on Allmusic.",
               "cardinality0" : 0,
               "reversePhrase" : "Allmusic page for",
               "childOrder" : 0,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 285,
               "orderableDirection" : 0,
               "phrase" : "Allmusic",
               "gid" : "54482490-5ff1-4b1c-9382-b4d0ef8e0eac"
            }
         ],
         "description" : "This links an entity to the equivalent entry in another database. Please respect the <a href=\"/doc/Other_Databases_Relationship_Type/Whitelist\">whitelist</a>.",
         "cardinality0" : 0,
         "reversePhrase" : "other databases",
         "childOrder" : 99,
         "cardinality1" : 0,
         "deprecated" : false,
         "id" : 306,
         "orderableDirection" : 0,
         "phrase" : "other databases",
         "gid" : "bc21877b-e993-42ed-a7ce-9187ec9b638f"
      }
   ],
   "series-work" : [
      {
         "type1" : "work",
         "hasDates" : false,
         "type0" : "series",
         "description" : "Indicates that the work is part of a series.",
         "cardinality0" : 0,
         "reversePhrase" : "part of",
         "childOrder" : 0,
         "cardinality1" : 0,
         "deprecated" : false,
         "id" : 743,
         "attributes" : {
            "788" : {
               "min" : 0,
               "max" : 1
            }
         },
         "orderableDirection" : 1,
         "phrase" : "has parts",
         "gid" : "b0d44366-cdf0-3acb-bee6-0f65a77a6ef0"
      }
   ],
   "artist-release_group" : [
      {
         "type1" : "release_group",
         "hasDates" : true,
         "type0" : "artist",
         "description" : "This links a release group to an artist, to indicate that it is a tribute album.​ Tribute albums often have a title in the form \"A Tribute to Artistname\". They normally consist of covers of songs by the target artist, played by other (sometimes very unknown) bands, to honor the target artist. Often they are various artist compilations, but a single artist can perform the entire tribute album.",
         "cardinality0" : 1,
         "reversePhrase" : "tribute to",
         "childOrder" : 0,
         "cardinality1" : 0,
         "deprecated" : false,
         "id" : 65,
         "orderableDirection" : 0,
         "phrase" : "tribute albums",
         "gid" : "5e2907db-49ec-4a48-9f11-dfb99d2603ff"
      },
      {
         "type1" : "release_group",
         "hasDates" : true,
         "type0" : "artist",
         "description" : "This indicates a person or agency which is responsible for talent scouting, overseeing the artistic development of an artist, and acting as liaison between artists and the labels.",
         "cardinality0" : 1,
         "reversePhrase" : "artist & repertoire support",
         "childOrder" : 2,
         "cardinality1" : 0,
         "deprecated" : false,
         "id" : 62,
         "orderableDirection" : 0,
         "phrase" : "artist & repertoire support",
         "gid" : "25dd0db4-189f-436c-a610-aacb979f13e2"
      },
      {
         "type1" : "release_group",
         "hasDates" : true,
         "type0" : "artist",
         "description" : "This credits a person or agency who provided some kind of general creative inspiration during the recording of this release group, without actually contributing to the writing or performance.",
         "cardinality0" : 1,
         "reversePhrase" : "{additional} creative direction",
         "childOrder" : 3,
         "cardinality1" : 0,
         "deprecated" : false,
         "id" : 63,
         "attributes" : {
            "1" : {
               "min" : 0,
               "max" : 1
            }
         },
         "orderableDirection" : 0,
         "phrase" : "{additional} creative direction",
         "gid" : "e035ac25-a2ff-48a6-9fb6-077692c67241"
      }
   ],
   "artist-artist" : [
      {
         "type1" : "artist",
         "hasDates" : false,
         "type0" : "artist",
         "children" : [
            {
               "type1" : "artist",
               "hasDates" : true,
               "type0" : "artist",
               "description" : "This is used to specify that an <a href=\"/doc/Artist\" title=\"Artist\">artist</a> collaborated on a short-term project, for cases where artist credits can't be used.",
               "cardinality0" : 0,
               "reversePhrase" : "{additional} {minor} collaborators",
               "childOrder" : 0,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 102,
               "attributes" : {
                  "1" : {
                     "min" : 0,
                     "max" : 1
                  },
                  "2" : {
                     "min" : 0,
                     "max" : 1
                  }
               },
               "orderableDirection" : 0,
               "phrase" : "{additional} {minor} collaborator on",
               "gid" : "75c09861-6857-4ec0-9729-84eefde7fc86"
            },
            {
               "type1" : "artist",
               "hasDates" : true,
               "type0" : "artist",
               "description" : "This indicates a person is a member of a group.",
               "cardinality0" : 0,
               "reversePhrase" : "{additional} {founder:founding} members",
               "childOrder" : 0,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 103,
               "attributes" : {
                  "1" : {
                     "min" : 0,
                     "max" : 1
                  },
                  "3" : {
                     "min" : 0,
                     "max" : null
                  },
                  "525" : {
                     "min" : 0,
                     "max" : 1
                  },
                  "14" : {
                     "min" : 0,
                     "max" : null
                  }
               },
               "orderableDirection" : 0,
               "phrase" : "{additional} {founder:founding} member of",
               "gid" : "5be4c609-9afa-4ea0-910b-12ffb71e3821"
            },
            {
               "type1" : "artist",
               "hasDates" : true,
               "type0" : "artist",
               "description" : "This links a subgroup to the group from which it was created. This relationship type is the functional equivalent of the <a href=\"/relationship/5be4c609-9afa-4ea0-910b-12ffb71e3821\">member of band type</a> for group-group relationships.",
               "cardinality0" : 0,
               "reversePhrase" : "subgroups",
               "childOrder" : 0,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 722,
               "orderableDirection" : 0,
               "phrase" : "subgroup of",
               "gid" : "7802f96b-d995-4ce9-8f70-6366faad758e"
            },
            {
               "type1" : "artist",
               "hasDates" : true,
               "type0" : "artist",
               "children" : [
                  {
                     "type1" : "artist",
                     "hasDates" : true,
                     "type0" : "artist",
                     "description" : "Indicates a musician doing long-time vocal support for another one on albums and/or at concerts. This is a person-to-artist relationship that normally applies to well-known solo artists, although it can sometimes apply to groups.",
                     "cardinality0" : 0,
                     "reversePhrase" : "{vocal:%|vocals} support by",
                     "childOrder" : 0,
                     "cardinality1" : 0,
                     "deprecated" : false,
                     "id" : 107,
                     "attributes" : {
                        "3" : {
                           "min" : 0,
                           "max" : null
                        }
                     },
                     "orderableDirection" : 0,
                     "phrase" : "{vocal:%|vocals} support for",
                     "gid" : "610d39a4-3fa0-4848-a8c9-f46d7b5cc02e"
                  },
                  {
                     "type1" : "artist",
                     "hasDates" : true,
                     "type0" : "artist",
                     "description" : "Indicates a musician doing long-time instrumental support for another one on albums and/or at concerts. This is a person-to-artist relationship that normally applies to well-known solo artists, although it can sometimes apply to groups.",
                     "cardinality0" : 0,
                     "reversePhrase" : "supporting {instrument} by",
                     "childOrder" : 1,
                     "cardinality1" : 0,
                     "deprecated" : false,
                     "id" : 105,
                     "attributes" : {
                        "14" : {
                           "min" : 1,
                           "max" : null
                        }
                     },
                     "orderableDirection" : 0,
                     "phrase" : "supporting {instrument} for",
                     "gid" : "ed6a7891-ce70-4e08-9839-1f2f62270497"
                  }
               ],
               "description" : "Indicates an artist doing long-time instrumental or vocal support for another one on albums and/or at concerts. This is a person-to-artist relationship that normally applies to well-known solo artists, although it can sometimes apply to groups.",
               "cardinality0" : 0,
               "reversePhrase" : "supporting artists",
               "childOrder" : 1,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 104,
               "orderableDirection" : 0,
               "phrase" : "supporting artist for",
               "gid" : "88562a60-2550-48f0-8e8e-f54d95c7369a"
            },
            {
               "type1" : "artist",
               "hasDates" : true,
               "type0" : "artist",
               "description" : "This links an (fictional) artist to the person that voice acted it.",
               "cardinality0" : 0,
               "reversePhrase" : "voiced by",
               "childOrder" : 1,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 292,
               "orderableDirection" : 0,
               "phrase" : "voice of",
               "gid" : "e259a3f5-ce8e-45c1-9ef7-90ff7d0c7589"
            },
            {
               "type1" : "artist",
               "hasDates" : true,
               "type0" : "artist",
               "description" : "This indicates that a person is, or was, a conductor for a group.​",
               "cardinality0" : 0,
               "reversePhrase" : "{assistant} {principal} {guest} conductor {emeritus}",
               "childOrder" : 1,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 305,
               "attributes" : {
                  "526" : {
                     "min" : 0,
                     "max" : 1
                  },
                  "194" : {
                     "min" : 0,
                     "max" : 1
                  },
                  "618" : {
                     "min" : 0,
                     "max" : 1
                  },
                  "617" : {
                     "min" : 0,
                     "max" : 1
                  }
               },
               "orderableDirection" : 0,
               "phrase" : "{assistant} {principal} {guest} conductor {emeritus} for",
               "gid" : "cac01ac7-4159-42fd-9f2b-c5a7a5624079"
            },
            {
               "type1" : "artist",
               "hasDates" : true,
               "type0" : "artist",
               "description" : "This relationship specifies that an artist is a <a href=\"http://en.wikipedia.org/wiki/Tribute_act\">tribute</a> to another specific artist/band; that is, it primarily performs covers of that artist.​ They may also be referred to as cover bands. Some tribute artists may name themselves, dress, and/or act similarly to the artists they pay tribute to.",
               "cardinality0" : 0,
               "reversePhrase" : "tribute artists",
               "childOrder" : 1,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 728,
               "orderableDirection" : 0,
               "phrase" : "tribute to",
               "gid" : "a6f62641-2f58-470e-b02b-88d7b984dc9f"
            },
            {
               "type1" : "artist",
               "hasDates" : true,
               "type0" : "artist",
               "description" : "This links an artist's performance name (a stage name or alias) with their legal name.",
               "cardinality0" : 0,
               "reversePhrase" : "legal name",
               "childOrder" : 2,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 108,
               "orderableDirection" : 0,
               "phrase" : "performs as",
               "gid" : "dd9886f2-1dfe-4270-97db-283f6839a666"
            },
            {
               "type1" : "artist",
               "hasDates" : true,
               "type0" : "artist",
               "description" : "This relationship is used to link an artist to a person who has compiled a catalogue of that artist's works.",
               "cardinality0" : 0,
               "reversePhrase" : "{additional:additionally} catalogued",
               "childOrder" : 3,
               "cardinality1" : 0,
               "deprecated" : true,
               "id" : 101,
               "attributes" : {
                  "1" : {
                     "min" : 0,
                     "max" : 1
                  }
               },
               "orderableDirection" : 0,
               "phrase" : "{additional:additionally} catalogued by",
               "gid" : "47200337-edd6-43d1-88b4-86f979a427bc"
            }
         ],
         "cardinality0" : 0,
         "reversePhrase" : "musical relationship",
         "childOrder" : 0,
         "cardinality1" : 0,
         "deprecated" : false,
         "id" : 106,
         "orderableDirection" : 0,
         "phrase" : "musical relationship",
         "gid" : "92859e2a-f2e5-45fa-a680-3f62ba0beccc"
      },
      {
         "type1" : "artist",
         "hasDates" : false,
         "type0" : "artist",
         "children" : [
            {
               "type1" : "artist",
               "hasDates" : true,
               "type0" : "artist",
               "description" : "Indicates a parent-child relationship.",
               "cardinality0" : 0,
               "reversePhrase" : "parents",
               "childOrder" : 0,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 109,
               "orderableDirection" : 0,
               "phrase" : "children",
               "gid" : "9421ca84-934f-49fe-9e66-dea242430406"
            },
            {
               "type1" : "artist",
               "hasDates" : true,
               "type0" : "artist",
               "description" : "This links two siblings (brothers or sisters).",
               "cardinality0" : 0,
               "reversePhrase" : "siblings",
               "childOrder" : 1,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 110,
               "orderableDirection" : 0,
               "phrase" : "siblings",
               "gid" : "b42b7966-b904-449e-b8f9-8c7297b863d0"
            },
            {
               "type1" : "artist",
               "hasDates" : true,
               "type0" : "artist",
               "description" : "This links artists who were married.",
               "cardinality0" : 0,
               "reversePhrase" : "married",
               "childOrder" : 2,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 111,
               "orderableDirection" : 0,
               "phrase" : "married",
               "gid" : "b2bf7a5d-2da6-4742-baf4-e38d8a7ad029"
            },
            {
               "type1" : "artist",
               "hasDates" : true,
               "type0" : "artist",
               "description" : "Indicates that two persons were romantically involved with each other without being married.",
               "cardinality0" : 0,
               "reversePhrase" : "involved with",
               "childOrder" : 3,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 112,
               "orderableDirection" : 0,
               "phrase" : "involved with",
               "gid" : "fd3927ba-fd51-4fa9-bcc2-e83637896fe8"
            }
         ],
         "cardinality0" : 0,
         "reversePhrase" : "personal relationship",
         "childOrder" : 1,
         "cardinality1" : 0,
         "deprecated" : false,
         "id" : 113,
         "orderableDirection" : 0,
         "phrase" : "personal relationship",
         "gid" : "e794f8ff-b77b-4dfe-86ca-83197146ef10"
      }
   ],
   "work-work" : [
      {
         "type1" : "work",
         "hasDates" : false,
         "type0" : "work",
         "description" : "This is used to indicate that a work is a medley of several other songs. This means that the original songs were rearranged to create a new work in the form of a medley. See <a href=\"/relationship/d3fd781c-5894-47e2-8c12-86cc0e2c8d08\">arranger</a> for crediting the person who arranges songs into a medley.",
         "cardinality0" : 0,
         "reversePhrase" : "referred to in medleys",
         "childOrder" : 0,
         "cardinality1" : 0,
         "deprecated" : false,
         "id" : 239,
         "orderableDirection" : 0,
         "phrase" : "medley of",
         "gid" : "c1dca2cd-194c-36dd-93f8-6a359167e992"
      },
      {
         "type1" : "work",
         "hasDates" : true,
         "type0" : "work",
         "children" : [
            {
               "type1" : "work",
               "hasDates" : true,
               "type0" : "work",
               "description" : "This links two <a href=\"/doc/Work\" title=\"Work\">works</a>, where the second work is based on music or text from the first, but isn't directly a revision or an arrangement of it.",
               "cardinality0" : 0,
               "reversePhrase" : "is based on",
               "childOrder" : 0,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 314,
               "orderableDirection" : 0,
               "phrase" : "is the basis for",
               "gid" : "6bb1df6b-57f3-434d-8a39-5dc363d2eb78"
            },
            {
               "type1" : "work",
               "hasDates" : true,
               "type0" : "work",
               "description" : "This links different revisions of the same <a href=\"/doc/Work\" title=\"Work\">work</a>.",
               "cardinality0" : 0,
               "reversePhrase" : "revision of",
               "childOrder" : 0,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 315,
               "orderableDirection" : 0,
               "phrase" : "has revision",
               "gid" : "4d0d6491-3c41-42c6-883f-d6c7e825b052"
            },
            {
               "type1" : "work",
               "hasDates" : true,
               "type0" : "work",
               "children" : [
                  {
                     "type1" : "work",
                     "hasDates" : true,
                     "type0" : "work",
                     "description" : "This links two <a href=\"/doc/Work\" title=\"Work\">works</a> where one work is an orchestration of the other.",
                     "cardinality0" : 0,
                     "reversePhrase" : "orchestration of",
                     "childOrder" : 0,
                     "cardinality1" : 0,
                     "deprecated" : false,
                     "id" : 316,
                     "orderableDirection" : 0,
                     "phrase" : "orchestrations",
                     "gid" : "dd372cb2-5f4d-4dcd-868e-7564782f460b"
                  }
               ],
               "description" : "This links two <a href=\"/doc/Work\" title=\"Work\">works</a> where one work is an arrangement of the other.",
               "cardinality0" : 0,
               "reversePhrase" : "arrangement of",
               "childOrder" : 0,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 350,
               "attributes" : {
                  "517" : {
                     "min" : 0,
                     "max" : 1
                  }
               },
               "orderableDirection" : 0,
               "phrase" : "arrangements",
               "gid" : "51975ed8-bbfa-486b-9f28-5947f4370299"
            }
         ],
         "description" : "This links two versions of a <a href=\"/doc/Work\" title=\"Work\">work</a>.",
         "cardinality0" : 0,
         "reversePhrase" : "{translated} {parody} version of",
         "childOrder" : 0,
         "cardinality1" : 0,
         "deprecated" : false,
         "id" : 241,
         "attributes" : {
            "517" : {
               "min" : 0,
               "max" : 1
            },
            "511" : {
               "min" : 0,
               "max" : 1
            }
         },
         "orderableDirection" : 0,
         "phrase" : "later {translated} {parody} versions",
         "gid" : "7440b539-19ab-4243-8c03-4f5942ca2218"
      },
      {
         "type1" : "work",
         "hasDates" : true,
         "type0" : "work",
         "description" : "This indicates that a work is made up of multiple parts (e.g. an orchestral suite broken into movements)",
         "cardinality0" : 0,
         "reversePhrase" : "part of",
         "childOrder" : 0,
         "cardinality1" : 0,
         "deprecated" : false,
         "id" : 281,
         "orderableDirection" : 1,
         "phrase" : "parts",
         "gid" : "ca8d3642-ce5f-49f8-91f2-125d72524e6a"
      }
   ],
   "release_group-series" : [
      {
         "type1" : "series",
         "hasDates" : false,
         "type0" : "release_group",
         "description" : "Indicates that the release group is part of a series.",
         "cardinality0" : 0,
         "reversePhrase" : "has parts",
         "childOrder" : 0,
         "cardinality1" : 0,
         "deprecated" : false,
         "id" : 742,
         "attributes" : {
            "788" : {
               "min" : 0,
               "max" : 1
            }
         },
         "orderableDirection" : 2,
         "phrase" : "part of",
         "gid" : "01018437-91d8-36b9-bf89-3f885d53b5bd"
      }
   ],
   "area-release" : [
      {
         "type1" : "release",
         "hasDates" : true,
         "type0" : "area",
         "description" : "Links a release to the area it was recorded in. Use only when the place is unknown!",
         "cardinality0" : 0,
         "reversePhrase" : "recorded in",
         "childOrder" : 0,
         "cardinality1" : 0,
         "deprecated" : false,
         "id" : 699,
         "orderableDirection" : 0,
         "phrase" : "recording location for",
         "gid" : "354043e1-bdc2-4c7f-b338-2bf9c1d56e88"
      }
   ],
   "release-series" : [
      {
         "type1" : "series",
         "hasDates" : false,
         "type0" : "release",
         "description" : "Indicates that the release is part of a series.",
         "cardinality0" : 0,
         "reversePhrase" : "has parts",
         "childOrder" : 0,
         "cardinality1" : 0,
         "deprecated" : false,
         "id" : 741,
         "attributes" : {
            "788" : {
               "min" : 0,
               "max" : 1
            }
         },
         "orderableDirection" : 2,
         "phrase" : "part of",
         "gid" : "3fa29f01-8e13-3e49-9b0a-ad212aa2f81d"
      }
   ],
   "artist-label" : [
      {
         "type1" : "label",
         "hasDates" : false,
         "type0" : "artist",
         "children" : [
            {
               "type1" : "label",
               "hasDates" : true,
               "type0" : "artist",
               "description" : "This relationship type can be used to link a label to the person(s) who founded it.",
               "cardinality0" : 0,
               "reversePhrase" : "founders",
               "childOrder" : 0,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 116,
               "orderableDirection" : 0,
               "phrase" : "founded",
               "gid" : "577996f3-7ff9-45cf-877e-740fb1267a63"
            },
            {
               "type1" : "label",
               "hasDates" : true,
               "type0" : "artist",
               "description" : "This indicates that an artist was officially employed by a label as a producer.",
               "cardinality0" : 0,
               "reversePhrase" : "producers",
               "childOrder" : 0,
               "cardinality1" : 1,
               "deprecated" : false,
               "id" : 117,
               "orderableDirection" : 0,
               "phrase" : "producer position",
               "gid" : "46981330-d73c-4ba5-845f-47f467072cf8"
            },
            {
               "type1" : "label",
               "hasDates" : true,
               "type0" : "artist",
               "description" : "This indicates that an artist was officially employed by a label as an engineer.",
               "cardinality0" : 0,
               "reversePhrase" : "engineers",
               "childOrder" : 1,
               "cardinality1" : 1,
               "deprecated" : false,
               "id" : 120,
               "orderableDirection" : 0,
               "phrase" : "engineer position",
               "gid" : "5f9374d2-a0fa-4958-8a6f-80ca67e4aaa5"
            },
            {
               "type1" : "label",
               "hasDates" : true,
               "type0" : "artist",
               "description" : "This indicates that an artist was officially employed by a label in a creative position, such as photographer or graphic designer.",
               "cardinality0" : 0,
               "reversePhrase" : "creative persons",
               "childOrder" : 2,
               "cardinality1" : 1,
               "deprecated" : false,
               "id" : 115,
               "orderableDirection" : 0,
               "phrase" : "creative position",
               "gid" : "85d1947c-1986-42f0-947c-80aab72a548f"
            },
            {
               "type1" : "label",
               "hasDates" : true,
               "type0" : "artist",
               "description" : "This indicates that an artist had a recording contract with a label.",
               "cardinality0" : 0,
               "reversePhrase" : "signed",
               "childOrder" : 3,
               "cardinality1" : 1,
               "deprecated" : false,
               "id" : 121,
               "orderableDirection" : 0,
               "phrase" : "signed by",
               "gid" : "b336d682-592f-4486-9f45-3d5d59895bdc"
            },
            {
               "type1" : "label",
               "hasDates" : true,
               "type0" : "artist",
               "description" : "This indicates a personal production label for an artist. A personal label is a small label (usually a subdivision of a larger one) that exclusively handles releases by that artist.",
               "cardinality0" : 0,
               "reversePhrase" : "personal label for",
               "childOrder" : 4,
               "cardinality1" : 1,
               "deprecated" : false,
               "id" : 723,
               "orderableDirection" : 0,
               "phrase" : "has personal label",
               "gid" : "fe16f2bd-d324-435a-8076-bcf43b805bd9"
            },
            {
               "type1" : "label",
               "hasDates" : true,
               "type0" : "artist",
               "description" : "This indicates a personal publishing label for an artist. A personal publishing label is a small label (usually a subdivision of a larger one) that exclusively handles the rights to works by that artist.",
               "cardinality0" : 0,
               "reversePhrase" : "personal publisher for",
               "childOrder" : 5,
               "cardinality1" : 1,
               "deprecated" : false,
               "id" : 724,
               "orderableDirection" : 0,
               "phrase" : "has personal publisher",
               "gid" : "8fecc8a7-0df7-4637-9152-f12a07f0e9cd"
            }
         ],
         "cardinality0" : 0,
         "reversePhrase" : "contract",
         "childOrder" : 0,
         "cardinality1" : 1,
         "deprecated" : false,
         "id" : 119,
         "orderableDirection" : 0,
         "phrase" : "contract",
         "gid" : "e74a40e7-0f27-4e05-bdbd-eb10f5309472"
      }
   ],
   "artist-url" : [
      {
         "type1" : "url",
         "hasDates" : true,
         "type0" : "artist",
         "description" : "Indicates the official homepage for an artist.",
         "cardinality0" : 0,
         "reversePhrase" : "official homepage for",
         "childOrder" : 0,
         "cardinality1" : 0,
         "deprecated" : false,
         "id" : 183,
         "orderableDirection" : 0,
         "phrase" : "official homepages",
         "gid" : "fe33d22f-c3b0-4d68-bd53-a856badf2b15"
      },
      {
         "type1" : "url",
         "hasDates" : false,
         "type0" : "artist",
         "children" : [
            {
               "type1" : "url",
               "hasDates" : true,
               "type0" : "artist",
               "description" : "This links an artist to a fan-created website.",
               "cardinality0" : 0,
               "reversePhrase" : "fan page for",
               "childOrder" : 1,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 172,
               "orderableDirection" : 0,
               "phrase" : "fan pages",
               "gid" : "f484f897-81cc-406e-96f9-cd799a04ee24"
            },
            {
               "type1" : "url",
               "hasDates" : true,
               "type0" : "artist",
               "description" : "This links an artist to an online biography for that artist.",
               "cardinality0" : 0,
               "reversePhrase" : "biography of",
               "childOrder" : 2,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 182,
               "orderableDirection" : 0,
               "phrase" : "biographies",
               "gid" : "78f75830-94e1-4138-8f8a-643e3bb21ce5"
            },
            {
               "type1" : "url",
               "hasDates" : true,
               "type0" : "artist",
               "description" : "This links an artist to an online discography of their works.​ The discography should provide a summary of most, if not all, releases by the artist, and be as comprehensive as possible.",
               "cardinality0" : 0,
               "reversePhrase" : "discography page for",
               "childOrder" : 3,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 184,
               "orderableDirection" : 0,
               "phrase" : "discography pages",
               "gid" : "4fb0eeec-a6eb-4ae3-ad52-b55765b94e8f"
            },
            {
               "type1" : "url",
               "hasDates" : false,
               "type0" : "artist",
               "description" : "This links an artist to that artist's page at <a href=\"http://www.bbc.co.uk/music\">BBC Music</a>.",
               "cardinality0" : 0,
               "reversePhrase" : "BBC Music page for",
               "childOrder" : 4,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 190,
               "orderableDirection" : 0,
               "phrase" : "BBC Music",
               "gid" : "d028a975-000c-4525-9333-d3c8425e4b54"
            },
            {
               "type1" : "url",
               "hasDates" : true,
               "type0" : "artist",
               "description" : "This links an artist to an URL containing an interview with that artist.",
               "cardinality0" : 0,
               "reversePhrase" : "interview with",
               "childOrder" : 5,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 707,
               "orderableDirection" : 0,
               "phrase" : "has interview at",
               "gid" : "1f171391-1f98-4f45-b191-038ec3b12395"
            },
            {
               "type1" : "url",
               "hasDates" : true,
               "type0" : "artist",
               "description" : "Indicates a pictorial image (JPEG, GIF, PNG) of an artist.",
               "cardinality0" : 0,
               "reversePhrase" : "picture of",
               "childOrder" : 6,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 173,
               "orderableDirection" : 0,
               "phrase" : "pictures",
               "gid" : "221132e9-e30e-43f2-a741-15afc4c5fa7c"
            }
         ],
         "cardinality0" : 0,
         "reversePhrase" : "discography",
         "childOrder" : 1,
         "cardinality1" : 0,
         "deprecated" : false,
         "id" : 171,
         "orderableDirection" : 0,
         "phrase" : "discography",
         "gid" : "d0c5cf3a-8afb-4d24-ad47-00f43dc509fe"
      },
      {
         "type1" : "url",
         "hasDates" : true,
         "type0" : "artist",
         "children" : [
            {
               "type1" : "url",
               "hasDates" : true,
               "type0" : "artist",
               "children" : [
                  {
                     "type1" : "url",
                     "hasDates" : true,
                     "type0" : "artist",
                     "description" : "This relationship type links an artist to their Myspace page.",
                     "cardinality0" : 0,
                     "reversePhrase" : "Myspace page for",
                     "childOrder" : 0,
                     "cardinality1" : 0,
                     "deprecated" : false,
                     "id" : 189,
                     "orderableDirection" : 0,
                     "phrase" : "Myspace",
                     "gid" : "bac47923-ecde-4b59-822e-d08f0cd10156"
                  },
                  {
                     "type1" : "url",
                     "hasDates" : true,
                     "type0" : "artist",
                     "description" : "This links an artist to its profile at SoundCloud.",
                     "cardinality0" : 0,
                     "reversePhrase" : "SoundCloud page for",
                     "childOrder" : 0,
                     "cardinality1" : 0,
                     "deprecated" : false,
                     "id" : 291,
                     "orderableDirection" : 0,
                     "phrase" : "SoundCloud",
                     "gid" : "89e4a949-0976-440d-bda1-5f772c1e5710"
                  },
                  {
                     "type1" : "url",
                     "hasDates" : false,
                     "type0" : "artist",
                     "description" : "This links an artist to the equivalent entry at PureVolume.",
                     "cardinality0" : 0,
                     "reversePhrase" : "PureVolume page for",
                     "childOrder" : 1,
                     "cardinality1" : 0,
                     "deprecated" : false,
                     "id" : 174,
                     "orderableDirection" : 0,
                     "phrase" : "PureVolume",
                     "gid" : "b6f02157-a9d3-4f24-9057-0675b2dbc581"
                  }
               ],
               "description" : "This is used to link an artist to their page on a social networking site such as Facebook or Last.fm.",
               "cardinality0" : 0,
               "reversePhrase" : "social networking page for",
               "childOrder" : 0,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 192,
               "orderableDirection" : 0,
               "phrase" : "social networking",
               "gid" : "99429741-f3f6-484b-84f8-23af51991770"
            },
            {
               "type1" : "url",
               "hasDates" : true,
               "type0" : "artist",
               "description" : "This relationship type is used to link an artist to their blog.",
               "cardinality0" : 0,
               "reversePhrase" : "blog of",
               "childOrder" : 3,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 199,
               "orderableDirection" : 0,
               "phrase" : "blogs",
               "gid" : "eb535226-f8ca-499d-9b18-6a144df4ae6f"
            },
            {
               "type1" : "url",
               "hasDates" : true,
               "type0" : "artist",
               "children" : [
                  {
                     "type1" : "url",
                     "hasDates" : true,
                     "type0" : "artist",
                     "description" : "This links an artist to the equivalent entry at YouTube.",
                     "cardinality0" : 0,
                     "reversePhrase" : "YouTube channel for",
                     "childOrder" : 0,
                     "cardinality1" : 0,
                     "deprecated" : false,
                     "id" : 193,
                     "orderableDirection" : 0,
                     "phrase" : "YouTube channels",
                     "gid" : "6a540e5b-58c6-4192-b6ba-dbc71ec8fcf0"
                  }
               ],
               "description" : "This links an artist to a channel, playlist, or user page on a video sharing site containing videos curated by it.",
               "cardinality0" : 0,
               "reversePhrase" : "video channel for",
               "childOrder" : 4,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 303,
               "orderableDirection" : 0,
               "phrase" : "video channel",
               "gid" : "d86c9450-b6d0-4760-a275-e7547495b48b"
            }
         ],
         "description" : "This relationship type links an artist to their online community pages. An online community is a web site providing information, music, and/or news, and may act as an unofficial homepage for an entity.",
         "cardinality0" : 0,
         "reversePhrase" : "online community page for",
         "childOrder" : 1,
         "cardinality1" : 0,
         "deprecated" : false,
         "id" : 185,
         "orderableDirection" : 0,
         "phrase" : "online communities",
         "gid" : "35b3a50f-bf0e-4309-a3b4-58eeed8cee6a"
      },
      {
         "type1" : "url",
         "hasDates" : false,
         "type0" : "artist",
         "description" : "This relationship describes a URL where lyrics for the artist can be found. Only sites on the <a href=\"/doc/Style/Relationships/URLs/Lyrics_whitelist\">whitelist</a> are permitted.",
         "cardinality0" : 0,
         "reversePhrase" : "lyrics page for",
         "childOrder" : 1,
         "cardinality1" : 0,
         "deprecated" : false,
         "id" : 197,
         "orderableDirection" : 0,
         "phrase" : "lyrics page",
         "gid" : "e4d73442-3762-45a8-905c-401da65544ed"
      },
      {
         "type1" : "url",
         "hasDates" : false,
         "type0" : "artist",
         "children" : [
            {
               "type1" : "url",
               "hasDates" : false,
               "type0" : "artist",
               "description" : "This relationship type is used to link to a page where the artist's releases can be purchased for mail order.",
               "cardinality0" : 0,
               "reversePhrase" : "mail-order purchase page for",
               "childOrder" : 0,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 175,
               "orderableDirection" : 0,
               "phrase" : "purchase music for mail-order",
               "gid" : "611b1862-67af-4253-a64f-34adba305d1d"
            },
            {
               "type1" : "url",
               "hasDates" : true,
               "type0" : "artist",
               "description" : "This is used to link to a page where the artist's releases can be purchased for download.",
               "cardinality0" : 0,
               "reversePhrase" : "download purchase page for",
               "childOrder" : 1,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 176,
               "orderableDirection" : 0,
               "phrase" : "purchase music for download",
               "gid" : "f8319a2f-f824-4617-81c8-be6560b3b203"
            },
            {
               "type1" : "url",
               "hasDates" : true,
               "type0" : "artist",
               "description" : "Indicates a webpage where you can download an artist's work for free.",
               "cardinality0" : 0,
               "reversePhrase" : "free download page for",
               "childOrder" : 2,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 177,
               "orderableDirection" : 0,
               "phrase" : "download music for free",
               "gid" : "34ae77fe-defb-43ea-95d4-63c7540bac78"
            },
            {
               "type1" : "url",
               "hasDates" : false,
               "type0" : "artist",
               "description" : "This relationship type is used to link an artist to a site where music can be legally streamed for free, e.g. Spotify.",
               "cardinality0" : 0,
               "reversePhrase" : "free music streaming page for",
               "childOrder" : 3,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 194,
               "orderableDirection" : 0,
               "phrase" : "stream for free",
               "gid" : "769085a1-c2f7-4c24-a532-2375a77693bd"
            },
            {
               "type1" : "url",
               "hasDates" : false,
               "type0" : "artist",
               "description" : "This links an artist to its page at Bandcamp.",
               "cardinality0" : 0,
               "reversePhrase" : "Bandcamp page for",
               "childOrder" : 4,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 718,
               "orderableDirection" : 0,
               "phrase" : "Bandcamp",
               "gid" : "c550166e-0548-4a18-b1d4-e2ae423a3e88"
            }
         ],
         "cardinality0" : 0,
         "reversePhrase" : "get the music",
         "childOrder" : 2,
         "cardinality1" : 0,
         "deprecated" : false,
         "id" : 187,
         "orderableDirection" : 0,
         "phrase" : "get the music",
         "gid" : "919db454-212f-495a-a9bb-f69631729953"
      },
      {
         "type1" : "url",
         "hasDates" : false,
         "type0" : "artist",
         "children" : [
            {
               "type1" : "url",
               "hasDates" : false,
               "type0" : "artist",
               "description" : "This links an artist to its page in <a href=\"http://www.imdb.com/\">IMDb</a>.",
               "cardinality0" : 0,
               "reversePhrase" : "IMDb page for",
               "childOrder" : 0,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 178,
               "orderableDirection" : 0,
               "phrase" : "IMDb",
               "gid" : "94c8b0cc-4477-4106-932c-da60e63de61c"
            },
            {
               "type1" : "url",
               "hasDates" : true,
               "type0" : "artist",
               "description" : "Points to the Wikipedia page for this artist.",
               "cardinality0" : 0,
               "reversePhrase" : "Wikipedia page for",
               "childOrder" : 0,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 179,
               "orderableDirection" : 0,
               "phrase" : "Wikipedia",
               "gid" : "29651736-fa6d-48e4-aadc-a557c6add1cb"
            },
            {
               "type1" : "url",
               "hasDates" : false,
               "type0" : "artist",
               "description" : "This is used to link the Discogs page for this artist.",
               "cardinality0" : 0,
               "reversePhrase" : "Discogs page for",
               "childOrder" : 0,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 180,
               "orderableDirection" : 0,
               "phrase" : "Discogs",
               "gid" : "04a5b104-a4c2-4bac-99a1-7b837c37d9e4"
            },
            {
               "type1" : "url",
               "hasDates" : false,
               "type0" : "artist",
               "description" : "This relationship type links an artist to its corresponding page <a href=\"http://vgmdb.net/\">VGMdb</a>. VGMdb is a community project dedicated to cataloguing the music of video games and anime.",
               "cardinality0" : 0,
               "reversePhrase" : "VGMdb page for",
               "childOrder" : 0,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 191,
               "orderableDirection" : 0,
               "phrase" : "VGMdb",
               "gid" : "0af15ab3-c615-46d6-b95b-a5fcd2a92ed9"
            },
            {
               "type1" : "url",
               "hasDates" : false,
               "type0" : "artist",
               "description" : "This is used to link an artist to its corresponding page on Allmusic.",
               "cardinality0" : 0,
               "reversePhrase" : "Allmusic page for",
               "childOrder" : 0,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 283,
               "orderableDirection" : 0,
               "phrase" : "Allmusic",
               "gid" : "6b3e3c85-0002-4f34-aca6-80ace0d7e846"
            },
            {
               "type1" : "url",
               "hasDates" : false,
               "type0" : "artist",
               "description" : "This is used to link an artist to its corresponding page in SecondHandSongs database.",
               "cardinality0" : 0,
               "reversePhrase" : "SecondHandSongs page for",
               "childOrder" : 0,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 307,
               "orderableDirection" : 0,
               "phrase" : "SecondHandSongs",
               "gid" : "79c5b84d-a206-4f4c-9832-78c028c312c3"
            },
            {
               "type1" : "url",
               "hasDates" : false,
               "type0" : "artist",
               "description" : "This points to the <a href=\"//viaf.org/\">VIAF</a> page for this artist. VIAF is an international project to make a common authority file available to libraries across the world. An authority file is similar to an MBID for libraries. (<a href=\"//en.wikipedia.org/wiki/Virtual_International_Authority_File\">more information on Wikipedia</a>)",
               "cardinality0" : 0,
               "reversePhrase" : "VIAF ID for",
               "childOrder" : 0,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 310,
               "orderableDirection" : 0,
               "phrase" : "VIAF ID",
               "gid" : "e8571dcc-35d4-4e91-a577-a3382fd84460"
            },
            {
               "type1" : "url",
               "hasDates" : false,
               "type0" : "artist",
               "description" : "Points to the Wikidata page for this artist.",
               "cardinality0" : 0,
               "reversePhrase" : "Wikidata page for",
               "childOrder" : 0,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 352,
               "orderableDirection" : 0,
               "phrase" : "Wikidata",
               "gid" : "689870a4-a1e4-4912-b17f-7b2664215698"
            }
         ],
         "description" : "This links an entity to the equivalent entry in another database. Please respect the <a href=\"/doc/Other_Databases_Relationship_Type/Whitelist\">whitelist</a>.",
         "cardinality0" : 0,
         "reversePhrase" : "other databases",
         "childOrder" : 99,
         "cardinality1" : 0,
         "deprecated" : false,
         "id" : 188,
         "orderableDirection" : 0,
         "phrase" : "other databases",
         "gid" : "d94fb61c-fa20-4e3c-a19a-71a949fb2c55"
      }
   ],
   "release_group-url" : [
      {
         "type1" : "url",
         "hasDates" : false,
         "type0" : "release_group",
         "children" : [
            {
               "type1" : "url",
               "hasDates" : true,
               "type0" : "release_group",
               "description" : "This indicates the recording studio where at least part of this release group was recorded.",
               "cardinality0" : 0,
               "reversePhrase" : "recording studio",
               "childOrder" : 0,
               "cardinality1" : 0,
               "deprecated" : true,
               "id" : 98,
               "orderableDirection" : 0,
               "phrase" : "recording studio",
               "gid" : "b17e54df-dcff-4ce3-9ab6-83f4bc0ec50b"
            }
         ],
         "cardinality0" : 0,
         "reversePhrase" : "production",
         "childOrder" : 0,
         "cardinality1" : 0,
         "deprecated" : false,
         "id" : 87,
         "orderableDirection" : 0,
         "phrase" : "production",
         "gid" : "292599e7-be3b-34a2-8d92-bd4507a3f7ad"
      },
      {
         "type1" : "url",
         "hasDates" : false,
         "type0" : "release_group",
         "description" : "This relationship describes a URL where lyrics for the release group can be found. Only sites on the <a href=\"/doc/Style/Relationships/URLs/Lyrics_whitelist\">whitelist</a> are permitted.",
         "cardinality0" : 0,
         "reversePhrase" : "lyrics page for",
         "childOrder" : 0,
         "cardinality1" : 0,
         "deprecated" : false,
         "id" : 93,
         "orderableDirection" : 0,
         "phrase" : "lyrics page",
         "gid" : "156344d3-da8b-40c6-8b10-7b1c22727124"
      },
      {
         "type1" : "url",
         "hasDates" : false,
         "type0" : "release_group",
         "children" : [
            {
               "type1" : "url",
               "hasDates" : true,
               "type0" : "release_group",
               "description" : "Indicates a webpage that reviews the release (group) in question.",
               "cardinality0" : 0,
               "reversePhrase" : "review page for",
               "childOrder" : 0,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 94,
               "orderableDirection" : 0,
               "phrase" : "reviews",
               "gid" : "c3ac9c3b-f546-4d15-873f-b294d2c1b708"
            },
            {
               "type1" : "url",
               "hasDates" : true,
               "type0" : "release_group",
               "description" : "This relationship type is used to link a release group to an official website created specifically for the release group.",
               "cardinality0" : 0,
               "reversePhrase" : "official homepage for",
               "childOrder" : 0,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 287,
               "orderableDirection" : 0,
               "phrase" : "official homepages",
               "gid" : "87d97dfc-3206-42fd-89d5-99593d5f1297"
            }
         ],
         "cardinality0" : 0,
         "reversePhrase" : "discography",
         "childOrder" : 1,
         "cardinality1" : 0,
         "deprecated" : false,
         "id" : 88,
         "orderableDirection" : 0,
         "phrase" : "discography",
         "gid" : "89fe4da2-ced3-4fd0-8739-fd22d823acdb"
      },
      {
         "type1" : "url",
         "hasDates" : false,
         "type0" : "release_group",
         "children" : [
            {
               "type1" : "url",
               "hasDates" : false,
               "type0" : "release_group",
               "description" : "Points to the Wikipedia page for this album.",
               "cardinality0" : 0,
               "reversePhrase" : "Wikipedia page for",
               "childOrder" : 0,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 89,
               "orderableDirection" : 0,
               "phrase" : "Wikipedia",
               "gid" : "6578f0e9-1ace-4095-9de8-6e517ddb1ceb"
            },
            {
               "type1" : "url",
               "hasDates" : false,
               "type0" : "release_group",
               "description" : "This is used to link the Discogs page for this release group.",
               "cardinality0" : 0,
               "reversePhrase" : "Discogs page for",
               "childOrder" : 0,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 90,
               "orderableDirection" : 0,
               "phrase" : "Discogs",
               "gid" : "99e550f3-5ab4-3110-b5b9-fe01d970b126"
            },
            {
               "type1" : "url",
               "hasDates" : false,
               "type0" : "release_group",
               "description" : "This links a soundtrack release to the <a href=\"http://www.imdb.com/\">IMDb</a> page for the movie, show or game of which it is a soundtrack.",
               "cardinality0" : 0,
               "reversePhrase" : "IMDb page for",
               "childOrder" : 0,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 97,
               "orderableDirection" : 0,
               "phrase" : "IMDb",
               "gid" : "85b0a010-3237-47c7-8476-6fcefd4761af"
            },
            {
               "type1" : "url",
               "hasDates" : false,
               "type0" : "release_group",
               "description" : "This is used to link a release group to its corresponding page on Allmusic.",
               "cardinality0" : 0,
               "reversePhrase" : "Allmusic page for",
               "childOrder" : 0,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 284,
               "orderableDirection" : 0,
               "phrase" : "Allmusic",
               "gid" : "a50a1d20-2b20-4d2c-9a29-eb771dd78386"
            },
            {
               "type1" : "url",
               "hasDates" : false,
               "type0" : "release_group",
               "description" : "Points to the Wikidata page for this release group.",
               "cardinality0" : 0,
               "reversePhrase" : "Wikidata page for",
               "childOrder" : 0,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 353,
               "orderableDirection" : 0,
               "phrase" : "Wikidata",
               "gid" : "b988d08c-5d86-4a57-9557-c83b399e3580"
            }
         ],
         "description" : "This links an entity to the equivalent entry in another database. Please respect the <a href=\"/doc/Other_Databases_Relationship_Type/Whitelist\">whitelist</a>.",
         "cardinality0" : 0,
         "reversePhrase" : "other databases",
         "childOrder" : 99,
         "cardinality1" : 0,
         "deprecated" : false,
         "id" : 96,
         "orderableDirection" : 0,
         "phrase" : "other databases",
         "gid" : "38320e40-9f4a-3ae7-8cb2-3f3c9c5d856d"
      }
   ],
   "label-url" : [
      {
         "type1" : "url",
         "hasDates" : true,
         "type0" : "label",
         "description" : "Indicates the official homepage for a label.",
         "cardinality0" : 0,
         "reversePhrase" : "official homepage for",
         "childOrder" : 0,
         "cardinality1" : 0,
         "deprecated" : false,
         "id" : 219,
         "orderableDirection" : 0,
         "phrase" : "official homepages",
         "gid" : "fe108f43-acb9-4ad1-8be3-57e6ec5b17b6"
      },
      {
         "type1" : "url",
         "hasDates" : false,
         "type0" : "label",
         "children" : [
            {
               "type1" : "url",
               "hasDates" : true,
               "type0" : "label",
               "description" : "This relationship type is used to link a label to its blog.",
               "cardinality0" : 0,
               "reversePhrase" : "blog of",
               "childOrder" : 0,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 224,
               "orderableDirection" : 0,
               "phrase" : "blogs",
               "gid" : "1b431eba-0d25-4f27-9151-1bb607f5c8f8"
            },
            {
               "type1" : "url",
               "hasDates" : false,
               "type0" : "label",
               "description" : "This links a label to its page at Bandcamp.",
               "cardinality0" : 0,
               "reversePhrase" : "Bandcamp page for",
               "childOrder" : 0,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 719,
               "orderableDirection" : 0,
               "phrase" : "Bandcamp",
               "gid" : "c535de4c-a112-4974-b138-5e0daa56eab5"
            },
            {
               "type1" : "url",
               "hasDates" : false,
               "type0" : "label",
               "description" : "This links to a site describing relevant details about a label's history.",
               "cardinality0" : 0,
               "reversePhrase" : "history page for",
               "childOrder" : 1,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 211,
               "orderableDirection" : 0,
               "phrase" : "history page",
               "gid" : "5261835c-0c23-4a63-94db-ad3a86bda846"
            },
            {
               "type1" : "url",
               "hasDates" : true,
               "type0" : "label",
               "description" : "This links to a catalog or list of records published by the label.",
               "cardinality0" : 0,
               "reversePhrase" : "catalog of records",
               "childOrder" : 2,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 212,
               "orderableDirection" : 0,
               "phrase" : "catalog of records",
               "gid" : "5ac35a29-d29b-4390-b279-587bcd42fc73"
            },
            {
               "type1" : "url",
               "hasDates" : true,
               "type0" : "label",
               "description" : "This is used to link a label to an image of its logo.",
               "cardinality0" : 0,
               "reversePhrase" : "logo of",
               "childOrder" : 3,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 213,
               "orderableDirection" : 0,
               "phrase" : "logos",
               "gid" : "b35f7822-bf3c-4148-b306-fb723c63ee8b"
            },
            {
               "type1" : "url",
               "hasDates" : false,
               "type0" : "label",
               "description" : "This links a label to a fan-created website.",
               "cardinality0" : 0,
               "reversePhrase" : "fan page for",
               "childOrder" : 4,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 214,
               "orderableDirection" : 0,
               "phrase" : "fan pages",
               "gid" : "6b91b233-a68c-4854-ba33-3b9ae27f86ae"
            },
            {
               "type1" : "url",
               "hasDates" : true,
               "type0" : "label",
               "children" : [
                  {
                     "type1" : "url",
                     "hasDates" : false,
                     "type0" : "label",
                     "description" : "This links a label to its profile at SoundCloud.",
                     "cardinality0" : 0,
                     "reversePhrase" : "SoundCloud page for",
                     "childOrder" : 0,
                     "cardinality1" : 0,
                     "deprecated" : false,
                     "id" : 290,
                     "orderableDirection" : 0,
                     "phrase" : "SoundCloud",
                     "gid" : "a31d05ba-3b82-47b2-ab8b-1fe73b5459e2"
                  },
                  {
                     "type1" : "url",
                     "hasDates" : true,
                     "type0" : "label",
                     "description" : "This relationship type links a label to its Myspace page.",
                     "cardinality0" : 0,
                     "reversePhrase" : "Myspace page for",
                     "childOrder" : 5,
                     "cardinality1" : 0,
                     "deprecated" : false,
                     "id" : 215,
                     "orderableDirection" : 0,
                     "phrase" : "Myspace",
                     "gid" : "240ba9dc-9898-4505-9bf7-32a53a695612"
                  }
               ],
               "description" : "This is used to link a label to their page on a social networking site such as Facebook or Last.fm.",
               "cardinality0" : 0,
               "reversePhrase" : "social networking page for",
               "childOrder" : 6,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 218,
               "orderableDirection" : 0,
               "phrase" : "social networking",
               "gid" : "5d217d99-bc05-4a76-836d-c91eec4ba818"
            },
            {
               "type1" : "url",
               "hasDates" : true,
               "type0" : "label",
               "children" : [
                  {
                     "type1" : "url",
                     "hasDates" : true,
                     "type0" : "label",
                     "description" : "This links a label to the equivalent entry at YouTube.",
                     "cardinality0" : 0,
                     "reversePhrase" : "YouTube channel for",
                     "childOrder" : 0,
                     "cardinality1" : 0,
                     "deprecated" : false,
                     "id" : 225,
                     "orderableDirection" : 0,
                     "phrase" : "YouTube channels",
                     "gid" : "d9c71059-ba9d-4135-b909-481d12cf84e3"
                  }
               ],
               "description" : "This links a label to a channel, playlist, or user page on a video sharing site containing videos curated by it.",
               "cardinality0" : 0,
               "reversePhrase" : "video channel for",
               "childOrder" : 7,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 304,
               "orderableDirection" : 0,
               "phrase" : "video channel",
               "gid" : "20ad367c-cba0-4c02-bd61-2df3ae8cc799"
            }
         ],
         "cardinality0" : 0,
         "reversePhrase" : "online data",
         "childOrder" : 1,
         "cardinality1" : 0,
         "deprecated" : false,
         "id" : 221,
         "orderableDirection" : 0,
         "phrase" : "online data",
         "gid" : "5f82afae-0473-458d-9f17-8a2fa1ce7918"
      },
      {
         "type1" : "url",
         "hasDates" : false,
         "type0" : "label",
         "children" : [
            {
               "type1" : "url",
               "hasDates" : false,
               "type0" : "label",
               "description" : "This relationship type links a label to its corresponding page at <a href=\"http://vgmdb.net/\">VGMdb</a>. VGMdb is a community project dedicated to cataloguing the music of video games and anime.",
               "cardinality0" : 0,
               "reversePhrase" : "VGMdb page for",
               "childOrder" : 0,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 210,
               "orderableDirection" : 0,
               "phrase" : "VGMdb",
               "gid" : "8a2d3e55-d291-4b99-87a0-c59c6b121762"
            },
            {
               "type1" : "url",
               "hasDates" : false,
               "type0" : "label",
               "description" : "This is used to link a label to its corresponding Wikipedia page.",
               "cardinality0" : 0,
               "reversePhrase" : "Wikipedia page for",
               "childOrder" : 0,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 216,
               "orderableDirection" : 0,
               "phrase" : "Wikipedia",
               "gid" : "51e9db21-8864-49b3-aa58-470d7b81fa50"
            },
            {
               "type1" : "url",
               "hasDates" : true,
               "type0" : "label",
               "description" : "This is used to link the Discogs page for this label.",
               "cardinality0" : 0,
               "reversePhrase" : "Discogs page for",
               "childOrder" : 0,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 217,
               "orderableDirection" : 0,
               "phrase" : "Discogs",
               "gid" : "5b987f87-25bc-4a2d-b3f1-3618795b8207"
            },
            {
               "type1" : "url",
               "hasDates" : false,
               "type0" : "label",
               "description" : "This points to the <a href=\"//viaf.org/\">VIAF</a> page for this label. VIAF is an international project to make a common authority file available to libraries across the world. An authority file is similar to an MBID for libraries. (<a href=\"//en.wikipedia.org/wiki/Virtual_International_Authority_File\">more information on Wikipedia</a>)",
               "cardinality0" : 0,
               "reversePhrase" : "VIAF ID for",
               "childOrder" : 0,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 311,
               "orderableDirection" : 0,
               "phrase" : "VIAF ID",
               "gid" : "c4bee4f4-e622-4c74-b80b-585989de27f4"
            },
            {
               "type1" : "url",
               "hasDates" : false,
               "type0" : "label",
               "description" : "This links a label to its page in <a href=\"http://www.imdb.com/\">IMDb</a>.",
               "cardinality0" : 0,
               "reversePhrase" : "IMDb page for",
               "childOrder" : 0,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 313,
               "orderableDirection" : 0,
               "phrase" : "IMDb",
               "gid" : "dfd36bc7-0c06-49fa-8b79-96978778c716"
            },
            {
               "type1" : "url",
               "hasDates" : false,
               "type0" : "label",
               "description" : "Points to the Wikidata page for this label.",
               "cardinality0" : 0,
               "reversePhrase" : "Wikidata page for",
               "childOrder" : 0,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 354,
               "orderableDirection" : 0,
               "phrase" : "Wikidata",
               "gid" : "75d87e83-d927-4580-ba63-44dc76256f98"
            }
         ],
         "description" : "This links an entity to the equivalent entry in another database. Please respect the <a href=\"/doc/Other_Databases_Relationship_Type/Whitelist\">whitelist</a>.",
         "cardinality0" : 0,
         "reversePhrase" : "other databases",
         "childOrder" : 99,
         "cardinality1" : 0,
         "deprecated" : false,
         "id" : 222,
         "orderableDirection" : 0,
         "phrase" : "other databases",
         "gid" : "83eca2b3-5ae1-43f5-a732-56fa9a8591b1"
      }
   ],
   "place-recording" : [
      {
         "type1" : "recording",
         "hasDates" : true,
         "type0" : "place",
         "description" : "Links a recording to the place it was recorded at.",
         "cardinality0" : 1,
         "reversePhrase" : "recorded at",
         "childOrder" : 0,
         "cardinality1" : 0,
         "deprecated" : false,
         "id" : 693,
         "orderableDirection" : 0,
         "phrase" : "recording location for",
         "gid" : "ad462279-14b0-4180-9b58-571d0eef7c51"
      },
      {
         "type1" : "recording",
         "hasDates" : true,
         "type0" : "place",
         "description" : "Links a recording to the place it was mixed at.",
         "cardinality0" : 1,
         "reversePhrase" : "mixed at",
         "childOrder" : 1,
         "cardinality1" : 0,
         "deprecated" : false,
         "id" : 694,
         "orderableDirection" : 0,
         "phrase" : "mixing location for",
         "gid" : "11d74801-1493-4a5d-bc0f-4ddc537acddb"
      }
   ],
   "series-url" : [
      {
         "type1" : "url",
         "hasDates" : false,
         "type0" : "series",
         "description" : "Indicates the official homepage for a series.",
         "cardinality0" : 0,
         "reversePhrase" : "official homepage for",
         "childOrder" : 0,
         "cardinality1" : 0,
         "deprecated" : false,
         "id" : 745,
         "orderableDirection" : 0,
         "phrase" : "official homepages",
         "gid" : "b79eb9a5-46df-492d-b107-1f1fea71b0eb"
      },
      {
         "type1" : "url",
         "hasDates" : false,
         "type0" : "series",
         "children" : [
            {
               "type1" : "url",
               "hasDates" : false,
               "type0" : "series",
               "description" : "Points to the Wikipedia page for this series.",
               "cardinality0" : 0,
               "reversePhrase" : "Wikipedia page for",
               "childOrder" : 0,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 744,
               "orderableDirection" : 0,
               "phrase" : "Wikipedia",
               "gid" : "b2b9407a-dd32-30f4-aa48-b2fd2077d1d2"
            },
            {
               "type1" : "url",
               "hasDates" : false,
               "type0" : "series",
               "description" : "This is used to link a series to the equivalent entry in Discogs.",
               "cardinality0" : 0,
               "reversePhrase" : "Discogs page for",
               "childOrder" : 0,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 747,
               "orderableDirection" : 0,
               "phrase" : "Discogs",
               "gid" : "338811ef-b1a9-449d-954e-115846f33a44"
            },
            {
               "type1" : "url",
               "hasDates" : false,
               "type0" : "series",
               "description" : "Points to the Wikidata page for this series.",
               "cardinality0" : 0,
               "reversePhrase" : "Wikidata page for",
               "childOrder" : 0,
               "cardinality1" : 0,
               "deprecated" : false,
               "id" : 749,
               "orderableDirection" : 0,
               "phrase" : "Wikidata",
               "gid" : "a1eecd98-f2f2-420b-ba8e-e5bc61697869"
            }
         ],
         "description" : "This links an entity to the equivalent entry in another database. Please respect the <a href=\"/doc/Other_Databases_Relationship_Type/Whitelist\">whitelist</a>.",
         "cardinality0" : 0,
         "reversePhrase" : "other databases",
         "childOrder" : 99,
         "cardinality1" : 0,
         "deprecated" : false,
         "id" : 746,
         "orderableDirection" : 0,
         "phrase" : "other databases",
         "gid" : "8a08d0f5-c7c4-4572-9d22-cee92693d820"
      }
   ],
   "recording-series" : [
      {
         "type1" : "series",
         "hasDates" : false,
         "type0" : "recording",
         "description" : "Indicates that the recording is part of a series.",
         "cardinality0" : 0,
         "reversePhrase" : "has parts",
         "childOrder" : 0,
         "cardinality1" : 0,
         "deprecated" : false,
         "id" : 740,
         "attributes" : {
            "788" : {
               "min" : 0,
               "max" : 1
            }
         },
         "orderableDirection" : 2,
         "phrase" : "part of",
         "gid" : "ea6f0698-6782-30d6-b16d-293081b66774"
      }
   ]
}, {
   "transliterated" : {
      "l_name" : "transliterated",
      "name" : "transliterated",
      "description" : "Transliterated track listings don't change the language, just the script or spelling.",
      "freeText" : false,
      "rootID" : 477,
      "id" : 477,
      "creditable" : false,
      "gid" : "a74533a5-ed6c-4b30-9519-43a449872f9d"
   },
   "number" : {
      "l_name" : "number",
      "name" : "number",
      "description" : "This attribute indicates the number of a work in a series.",
      "freeText" : true,
      "rootID" : 788,
      "id" : 788,
      "creditable" : false,
      "gid" : "a59c5830-5ec7-38fe-9a21-c7ea54f6650a"
   },
   "emeritus" : {
      "l_name" : "emeritus",
      "name" : "emeritus",
      "description" : "This title indicates that a conductor has at least partially retired, and no longer plays an active role with the group.",
      "freeText" : false,
      "rootID" : 617,
      "id" : 617,
      "creditable" : false,
      "gid" : "65969e82-5ee5-4035-a211-00e6bf8a0f75"
   },
   "principal" : {
      "l_name" : "principal",
      "name" : "principal",
      "description" : "This indicates that the group had multiple conductors who were led by this conductor. This may be indicated by either the title of \"principal conductor\" or \"first conductor\".",
      "freeText" : false,
      "rootID" : 618,
      "id" : 618,
      "creditable" : false,
      "gid" : "d3362ce5-ea76-4cb4-854b-9540fc716078"
   },
   "partial" : {
      "l_name" : "partial",
      "name" : "partial",
      "description" : "This indicates that the recording is not of the entire work, e.g. excerpts from, conclusion of, etc.",
      "freeText" : false,
      "rootID" : 579,
      "id" : 579,
      "creditable" : false,
      "gid" : "d2b63be6-91ec-426a-987a-30b47f8aae2d"
   },
   "executive" : {
      "l_name" : "executive",
      "name" : "executive",
      "description" : "This attribute is to be used if the role was fulfilled in an executive capacity.",
      "freeText" : false,
      "rootID" : 425,
      "id" : 425,
      "creditable" : false,
      "gid" : "e0039285-6667-4f94-80d6-aa6520c6d359"
   },
   "cover" : {
      "l_name" : "cover",
      "name" : "cover",
      "description" : "Indicates that one entity is a cover of another entity",
      "freeText" : false,
      "rootID" : 567,
      "id" : 567,
      "creditable" : false,
      "gid" : "1e8536bd-6eda-3822-8e78-1c0f4d3d2113"
   },
   "medium" : {
      "l_name" : "medium",
      "name" : "medium",
      "children" : [
         {
            "freeText" : false,
            "rootID" : 568,
            "l_name" : "medium 1",
            "name" : "medium 1",
            "id" : 570,
            "creditable" : false,
            "gid" : "50352e25-05f8-3e62-b311-2c4b1be12937"
         },
         {
            "freeText" : false,
            "rootID" : 568,
            "l_name" : "medium 2",
            "name" : "medium 2",
            "id" : 569,
            "creditable" : false,
            "gid" : "5a2cd122-6104-3fae-a4c1-56f0b3ad07bc"
         },
         {
            "freeText" : false,
            "rootID" : 568,
            "l_name" : "medium 3",
            "name" : "medium 3",
            "id" : 571,
            "creditable" : false,
            "gid" : "161dcdb0-bb27-36ef-bf06-e980938a9dea"
         },
         {
            "freeText" : false,
            "rootID" : 568,
            "l_name" : "medium 4",
            "name" : "medium 4",
            "id" : 577,
            "creditable" : false,
            "gid" : "dc8950e8-f632-3a8e-9e8e-561aa470cc38"
         },
         {
            "freeText" : false,
            "rootID" : 568,
            "l_name" : "medium 5",
            "name" : "medium 5",
            "id" : 576,
            "creditable" : false,
            "gid" : "c196dec2-c2e5-3b5b-ac2b-4b3d151f69ab"
         },
         {
            "freeText" : false,
            "rootID" : 568,
            "l_name" : "medium 6",
            "name" : "medium 6",
            "id" : 575,
            "creditable" : false,
            "gid" : "679e4211-0ff4-32f3-ab48-2029bca4f827"
         },
         {
            "freeText" : false,
            "rootID" : 568,
            "l_name" : "medium 7",
            "name" : "medium 7",
            "id" : 574,
            "creditable" : false,
            "gid" : "f82a59ec-6904-3225-8ce7-986042f40a1d"
         },
         {
            "freeText" : false,
            "rootID" : 568,
            "l_name" : "medium 8",
            "name" : "medium 8",
            "id" : 573,
            "creditable" : false,
            "gid" : "9d1c49a8-5148-35d9-a2b1-51fa8ecf5b37"
         },
         {
            "freeText" : false,
            "rootID" : 568,
            "l_name" : "medium 9",
            "name" : "medium 9",
            "id" : 572,
            "creditable" : false,
            "gid" : "14b0cd02-4cfc-3fc2-9ac9-6982529e5b8a"
         }
      ],
      "freeText" : false,
      "rootID" : 568,
      "id" : 568,
      "creditable" : false,
      "gid" : "1f0299ce-dc34-30f1-b374-4749b30606e6"
   },
   "founder" : {
      "l_name" : "founder",
      "name" : "founder",
      "description" : "This attribute indicates that an artist was a founding member of a group artist.",
      "freeText" : false,
      "rootID" : 525,
      "id" : 525,
      "creditable" : false,
      "gid" : "4fd3b255-a7d7-4424-9a63-40fa543b601c"
   },
   "vocal" : {
      "l_name" : "vocal",
      "name" : "vocal",
      "children" : [
         {
            "l_name" : "lead vocals",
            "name" : "lead vocals",
            "children" : [
               {
                  "l_name" : "alto vocals",
                  "name" : "alto vocals",
                  "description" : "alto vocals",
                  "freeText" : false,
                  "rootID" : 3,
                  "id" : 5,
                  "creditable" : true,
                  "gid" : "9f63c4ba-b76f-40d5-9e99-2fb08bd4c286"
               },
               {
                  "l_name" : "contralto vocals",
                  "name" : "contralto vocals",
                  "description" : "contralto vocals",
                  "freeText" : false,
                  "rootID" : 3,
                  "id" : 230,
                  "creditable" : true,
                  "gid" : "80d94f2e-e38f-4561-add2-c866f083d276"
               },
               {
                  "l_name" : "bass-baritone vocals",
                  "name" : "bass-baritone vocals",
                  "description" : "bass-baritone vocals",
                  "freeText" : false,
                  "rootID" : 3,
                  "id" : 231,
                  "creditable" : true,
                  "gid" : "629763ee-3dc7-4225-b209-0ebb6d49bfab"
               },
               {
                  "l_name" : "baritone vocals",
                  "name" : "baritone vocals",
                  "description" : "baritone vocals",
                  "freeText" : false,
                  "rootID" : 3,
                  "id" : 6,
                  "creditable" : true,
                  "gid" : "a40b43ed-2722-4b4a-98a5-478283cdf8df"
               },
               {
                  "l_name" : "bass vocals",
                  "name" : "bass vocals",
                  "description" : "bass vocals",
                  "freeText" : false,
                  "rootID" : 3,
                  "id" : 7,
                  "creditable" : true,
                  "gid" : "1bfdb77e-f339-4e8e-9627-331ca9d9e920"
               },
               {
                  "l_name" : "countertenor vocals",
                  "name" : "countertenor vocals",
                  "description" : "countertenor vocals",
                  "freeText" : false,
                  "rootID" : 3,
                  "id" : 8,
                  "creditable" : true,
                  "gid" : "435a19f5-55dc-4a08-8c59-4257680b4217"
               },
               {
                  "l_name" : "mezzo-soprano vocals",
                  "name" : "mezzo-soprano vocals",
                  "description" : "mezzo-soprano vocals",
                  "freeText" : false,
                  "rootID" : 3,
                  "id" : 9,
                  "creditable" : true,
                  "gid" : "f81325d7-593c-4197-b776-4f8a62c67a8e"
               },
               {
                  "l_name" : "soprano vocals",
                  "name" : "soprano vocals",
                  "description" : "soprano vocals",
                  "freeText" : false,
                  "rootID" : 3,
                  "id" : 10,
                  "creditable" : true,
                  "gid" : "e88f0be8-a07e-4c0d-bd06-e938eea4d5f6"
               },
               {
                  "l_name" : "tenor vocals",
                  "name" : "tenor vocals",
                  "description" : "tenor vocals",
                  "freeText" : false,
                  "rootID" : 3,
                  "id" : 11,
                  "creditable" : true,
                  "gid" : "122c11da-651f-46cc-9118-c523a14afa1d"
               }
            ],
            "description" : "Lead or solo vocal",
            "freeText" : false,
            "rootID" : 3,
            "id" : 4,
            "creditable" : true,
            "gid" : "8e2a3255-87c2-4809-a174-98cb3704f1a5"
         },
         {
            "l_name" : "choir vocals",
            "name" : "choir vocals",
            "description" : "choir vocals",
            "freeText" : false,
            "rootID" : 3,
            "id" : 13,
            "creditable" : true,
            "gid" : "43427f08-837b-46b8-bc77-483453af6a7b"
         },
         {
            "l_name" : "background vocals",
            "name" : "background vocals",
            "description" : "background vocals",
            "freeText" : false,
            "rootID" : 3,
            "id" : 12,
            "creditable" : true,
            "gid" : "75052401-7340-4e5b-a71d-ea024a128849"
         },
         {
            "l_name" : "other vocals",
            "name" : "other vocals",
            "children" : [
               {
                  "l_name" : "spoken vocals",
                  "name" : "spoken vocals",
                  "description" : "Spoken vocals (speech)",
                  "freeText" : false,
                  "rootID" : 3,
                  "id" : 561,
                  "creditable" : true,
                  "gid" : "d3a36e62-a7c4-4eb9-839f-adfebe87ac12"
               }
            ],
            "description" : "Other vocalizations",
            "freeText" : false,
            "rootID" : 3,
            "id" : 461,
            "creditable" : true,
            "gid" : "c359be96-620a-435c-bd25-2eb0ce81a22e"
         }
      ],
      "description" : "This attribute describes a type of vocal performance.",
      "freeText" : false,
      "rootID" : 3,
      "id" : 3,
      "creditable" : true,
      "gid" : "d92884b7-ee0c-46d5-96f3-918196ba8c5b"
   },
   "EP" : {
      "l_name" : "EP",
      "name" : "EP",
      "description" : "This indicates that the release group which is from the other release group is an EP rather than a single.",
      "freeText" : false,
      "rootID" : 545,
      "id" : 545,
      "creditable" : false,
      "gid" : "1751ab9c-88d5-4570-956d-f2aec1429b09"
   },
   "co" : {
      "l_name" : "co",
      "name" : "co",
      "description" : "co-[role]",
      "freeText" : false,
      "rootID" : 424,
      "id" : 424,
      "creditable" : false,
      "gid" : "ac6f6b4c-a4ec-4483-a04e-9f425a914573"
   },
   "medley" : {
      "l_name" : "medley",
      "name" : "medley",
      "description" : "This indicates that the recording is of a medley, of which the work is one part.",
      "freeText" : false,
      "rootID" : 750,
      "id" : 750,
      "creditable" : false,
      "gid" : "37da3398-5d1b-4acb-be25-df95e33e423c"
   },
   "solo" : {
      "l_name" : "solo",
      "name" : "solo",
      "description" : "This should be used when an artist is credited in liner notes or a similar source as performing a solo part.",
      "freeText" : false,
      "rootID" : 596,
      "id" : 596,
      "creditable" : false,
      "gid" : "63daa0d3-9b63-4434-acff-4977c07808ca"
   },
   "instrumental" : {
      "l_name" : "instrumental",
      "name" : "instrumental",
      "description" : "For works that have lyrics, this indicates that those lyrics are not relevant to this recording. Examples include instrumental arrangements, or \"beats\" from hip-hop songs which may be reused with different lyrics.",
      "freeText" : false,
      "rootID" : 580,
      "id" : 580,
      "creditable" : false,
      "gid" : "c031ed4f-c9bb-4394-8cf5-e8ce4db512ae"
   },
   "video" : {
      "l_name" : "video",
      "name" : "video",
      "description" : "This attribute indicates that the streamable content is not audio but video.",
      "freeText" : false,
      "rootID" : 582,
      "id" : 582,
      "creditable" : false,
      "gid" : "112054d5-e706-4dd8-99ea-09aabee36cd6"
   },
   "minor" : {
      "l_name" : "minor",
      "name" : "minor",
      "description" : "This attribute describes if a particular collaboration was considered equal or minor.",
      "freeText" : false,
      "rootID" : 2,
      "id" : 2,
      "creditable" : false,
      "gid" : "5b66c85d-6963-4d4b-86e5-18d2caccb349"
   },
   "instrument" : {
      "l_name" : "instrument",
      "name" : "instrument",
      "children" : [
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "wind instruments",
            "name" : "wind instruments",
            "id" : 15,
            "creditable" : true,
            "gid" : "77a0f1d3-f9ec-4055-a6e7-24d7258c21f7"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "woodwind",
            "name" : "woodwind",
            "id" : 16,
            "creditable" : true,
            "gid" : "35df3318-7a89-4601-bccc-4cd27ba062f7"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "double reed",
            "name" : "double reed",
            "id" : 17,
            "creditable" : true,
            "gid" : "ee570715-6ded-4cff-ad7e-feef6a5bca44"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "bagpipe",
            "name" : "bagpipe",
            "id" : 18,
            "creditable" : true,
            "gid" : "1d865ced-d86a-4277-8914-009740e37887"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "bassoon",
            "name" : "bassoon",
            "id" : 19,
            "creditable" : true,
            "gid" : "5318ae3e-fb33-4187-a1a1-1df9a59930f8"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "contrabassoon",
            "name" : "contrabassoon",
            "id" : 20,
            "creditable" : true,
            "gid" : "5c14a2d9-0906-4a09-b5ab-0020293e430e"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "English horn",
            "name" : "English horn",
            "id" : 21,
            "creditable" : true,
            "gid" : "3590521b-8c97-4f4b-b1bb-5f68d3663d8a"
         },
         {
            "l_name" : "oboe",
            "name" : "oboe",
            "description" : "Oboe (soprano)",
            "freeText" : false,
            "rootID" : 14,
            "id" : 22,
            "creditable" : true,
            "gid" : "1b97909a-6db7-4829-91fd-414338ce28cf"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "clarinet",
            "name" : "clarinet",
            "id" : 23,
            "creditable" : true,
            "gid" : "08028095-6dae-4fe0-9f34-284fde19f29b"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "alto clarinet",
            "name" : "alto clarinet",
            "id" : 24,
            "creditable" : true,
            "gid" : "eaa3713d-162a-42ed-bcd8-4185a68defbf"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "bass clarinet",
            "name" : "bass clarinet",
            "id" : 25,
            "creditable" : true,
            "gid" : "b7d71e02-e76c-4483-b394-b29057888131"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "contrabass clarinet",
            "name" : "contrabass clarinet",
            "id" : 26,
            "creditable" : true,
            "gid" : "3f501227-b481-4336-9eee-f24f3414ba61"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "flute",
            "name" : "flute",
            "id" : 27,
            "creditable" : true,
            "gid" : "540280f1-d6cf-46bf-968b-695e99e216d7"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "end-blown flute",
            "name" : "end-blown flute",
            "id" : 28,
            "creditable" : true,
            "gid" : "3a4d70ed-7c34-4d50-b6a3-b8ce63a8c234"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "ocarina",
            "name" : "ocarina",
            "id" : 29,
            "creditable" : true,
            "gid" : "e93eda0f-9475-45c1-9194-29020d9b83e9"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "pan flute",
            "name" : "pan flute",
            "id" : 30,
            "creditable" : true,
            "gid" : "6b5b72d8-6e9c-4e31-bd21-062d10bcf661"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "piccolo",
            "name" : "piccolo",
            "id" : 31,
            "creditable" : true,
            "gid" : "d01ae816-0567-4520-8fcb-8d3b71ef4bdf"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "recorder",
            "name" : "recorder",
            "id" : 32,
            "creditable" : true,
            "gid" : "3cf4c0c9-160a-4d73-9243-7d0e0df17050"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "saxophone",
            "name" : "saxophone",
            "id" : 33,
            "creditable" : true,
            "gid" : "a9ed16cd-b8cb-4256-9c41-93f5f0458c49"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "soprano saxophone",
            "name" : "soprano saxophone",
            "id" : 34,
            "creditable" : true,
            "gid" : "4a32d2f2-2ac7-423d-9820-2c0b7ff37f60"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "alto saxophone",
            "name" : "alto saxophone",
            "id" : 35,
            "creditable" : true,
            "gid" : "9c977091-b27a-4a0e-b54e-b5ab89420e22"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "tenor saxophone",
            "name" : "tenor saxophone",
            "id" : 36,
            "creditable" : true,
            "gid" : "ef7382cf-d5b4-4923-8b9e-3c482ed84b5e"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "baritone saxophone",
            "name" : "baritone saxophone",
            "id" : 37,
            "creditable" : true,
            "gid" : "d3a04358-70f8-4c43-b722-c3cf6cc218ae"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "brass",
            "name" : "brass",
            "id" : 38,
            "creditable" : true,
            "gid" : "82157c40-112f-4e4a-a3c0-5388ebb12931"
         },
         {
            "l_name" : "cornet",
            "name" : "cornet",
            "description" : "The cornet is a brass instrument very similar to the trumpet.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 39,
            "creditable" : true,
            "gid" : "257dad59-02e6-47d9-958a-659843737827"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "horn",
            "name" : "horn",
            "id" : 40,
            "creditable" : true,
            "gid" : "e798a2bd-a578-4c28-8eea-6eca2d8b2c5d"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "alphorn",
            "name" : "alphorn",
            "id" : 41,
            "creditable" : true,
            "gid" : "2d8ec312-6373-4c11-acc5-18e9a9b788b0"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "baritone horn",
            "name" : "baritone horn",
            "id" : 42,
            "creditable" : true,
            "gid" : "f28d6657-bc51-494f-84d0-553ef1ad0376"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "flugelhorn",
            "name" : "flugelhorn",
            "id" : 43,
            "creditable" : true,
            "gid" : "fd016966-658e-40db-8fe1-f2235fe1e9a3"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "French horn",
            "name" : "French horn",
            "id" : 44,
            "creditable" : true,
            "gid" : "f9abcd44-52d6-4424-b3a0-67f003bbbf3d"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "tenor horn / alto horn",
            "name" : "tenor horn / alto horn",
            "id" : 45,
            "creditable" : true,
            "gid" : "2d5bfd00-f0ef-41e5-aa33-fd706b1d0da0"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "trombone",
            "name" : "trombone",
            "id" : 46,
            "creditable" : true,
            "gid" : "f6100277-c7b8-4c8d-aa26-d8cd014b6761"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "trumpet",
            "name" : "trumpet",
            "id" : 47,
            "creditable" : true,
            "gid" : "1c8f9780-2f16-4891-b66d-bb7aa0820dbd"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "tuba",
            "name" : "tuba",
            "id" : 48,
            "creditable" : true,
            "gid" : "e297fcf6-29a7-4673-a15d-a6f54819b2d1"
         },
         {
            "l_name" : "natural brass instruments",
            "name" : "natural brass instruments",
            "description" : "Natural brass instruments only play notes in the instrument's harmonic series.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 49,
            "creditable" : true,
            "gid" : "e5781903-d6ef-4480-a158-60300265577c"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "bugle",
            "name" : "bugle",
            "id" : 51,
            "creditable" : true,
            "gid" : "d8afa42b-9287-41a2-82b2-2a96cb6b6fca"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "mellophone",
            "name" : "mellophone",
            "id" : 56,
            "creditable" : true,
            "gid" : "6a539558-5585-4803-a705-a4520f23189d"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "ophicleide",
            "name" : "ophicleide",
            "id" : 57,
            "creditable" : true,
            "gid" : "18fb4427-58c5-4ab6-88a3-2b67a6afd718"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "shofar",
            "name" : "shofar",
            "id" : 60,
            "creditable" : true,
            "gid" : "7cb02b35-2fea-4d24-88d4-92413f090e3f"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "free reed",
            "name" : "free reed",
            "id" : 63,
            "creditable" : true,
            "gid" : "3016babb-461a-4dfe-aa20-75a01cb0b2a3"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "accordion",
            "name" : "accordion",
            "id" : 64,
            "creditable" : true,
            "gid" : "bdf08ac2-b9c2-4391-85e5-9a7716bdd690"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "concertina",
            "name" : "concertina",
            "id" : 65,
            "creditable" : true,
            "gid" : "b4aab04d-64b6-47c1-91bd-6a3541d7903a"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "harmonica",
            "name" : "harmonica",
            "id" : 66,
            "creditable" : true,
            "gid" : "63e37f1a-30b6-4746-8a49-dfb55be3cdd1"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "melodica",
            "name" : "melodica",
            "id" : 67,
            "creditable" : true,
            "gid" : "8ab40df2-106b-4b9b-a50c-0798ee95da8f"
         },
         {
            "l_name" : "sheng",
            "name" : "sheng",
            "description" : "The sheng is a Chinese free reed instrument consisting of a number of vertical pipes.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 68,
            "creditable" : true,
            "gid" : "e9f3db08-5360-4dfc-a5f4-0951f39d2be0"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "strings",
            "name" : "strings",
            "id" : 69,
            "creditable" : true,
            "gid" : "32eca297-dde6-45d0-9305-ae479947c2a8"
         },
         {
            "l_name" : "bass",
            "name" : "bass",
            "description" : "Bass is a common but generic credit which refers to more than one instrument, the most common being the bass guitar and the double bass (a.k.a. contrabass, acoustic upright bass, wood bass). Please use the correct instrument if you know which one is intended.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 70,
            "creditable" : true,
            "gid" : "6505f98c-f698-4406-8bf4-8ca43d05c36f"
         },
         {
            "l_name" : "double bass / contrabass / acoustic upright bass",
            "name" : "double bass / contrabass / acoustic upright bass",
            "description" : "The double bass, also known as contrabass or upright bass as well as many other names, is the largest and lowest-pitched bowed string instrument of the violin family in the modern symphony orchestra.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 71,
            "creditable" : true,
            "gid" : "7bd32b95-416f-4244-a98b-1311ec69c7db"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "electric upright bass",
            "name" : "electric upright bass",
            "id" : 72,
            "creditable" : true,
            "gid" : "6ba5268f-766e-48b4-9d23-f378a7559f99"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "acoustic bass guitar",
            "name" : "acoustic bass guitar",
            "id" : 73,
            "creditable" : true,
            "gid" : "15861569-249d-4b24-8ce4-d0b001b1f978"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "electric bass guitar",
            "name" : "electric bass guitar",
            "id" : 74,
            "creditable" : true,
            "gid" : "0b9d87fa-93fa-4956-8b6a-a419566cc915"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "guitars",
            "name" : "guitars",
            "id" : 75,
            "creditable" : true,
            "gid" : "f68936f2-194c-4bcd-94a9-81e1dd947b8d"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "acoustic guitar",
            "name" : "acoustic guitar",
            "id" : 76,
            "creditable" : true,
            "gid" : "00beaf8e-a781-431c-8130-7c2871696b7d"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "classical guitar",
            "name" : "classical guitar",
            "id" : 77,
            "creditable" : true,
            "gid" : "43f378cf-b099-46da-8ec3-a39b6f5e5258"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "electric guitar",
            "name" : "electric guitar",
            "id" : 78,
            "creditable" : true,
            "gid" : "7ee8ebf5-3aed-4fc8-8004-49f4a8c45a87"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "slide guitar",
            "name" : "slide guitar",
            "id" : 79,
            "creditable" : true,
            "gid" : "41d2c709-81e2-415c-9456-a0a3d14f48bd"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "steel guitar",
            "name" : "steel guitar",
            "id" : 80,
            "creditable" : true,
            "gid" : "921330d6-eb1b-4e59-b4b6-824ebcdb89c2"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "harp",
            "name" : "harp",
            "id" : 81,
            "creditable" : true,
            "gid" : "f0a6e89d-b828-4b73-885d-8c1560e5e49a"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "violins",
            "name" : "violins",
            "id" : 82,
            "creditable" : true,
            "gid" : "39354e17-ab05-4aa5-b503-3092a6b4622c"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "cello",
            "name" : "cello",
            "id" : 84,
            "creditable" : true,
            "gid" : "0db03a60-1142-4b25-ab1b-72027d0dc357"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "fiddle",
            "name" : "fiddle",
            "id" : 85,
            "creditable" : true,
            "gid" : "04a21d03-535a-4ace-9098-12013867b8e5"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "violin",
            "name" : "violin",
            "id" : 86,
            "creditable" : true,
            "gid" : "089f123c-0f7d-4105-a64e-49de81ca8fa4"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "viola",
            "name" : "viola",
            "id" : 87,
            "creditable" : true,
            "gid" : "377e007a-33fe-4825-9bef-136cf5cf581a"
         },
         {
            "l_name" : "other string instruments",
            "name" : "other string instruments",
            "description" : "Other string instruments. If you can't find an instrument, please request it at http://wiki.musicbrainz.org/Talk:Advanced_Instrument_Tree",
            "freeText" : false,
            "rootID" : 14,
            "id" : 88,
            "creditable" : true,
            "gid" : "47765c7c-2d9b-40a9-b3be-8d88d29fcfd1"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "aeolian harp",
            "name" : "aeolian harp",
            "id" : 89,
            "creditable" : true,
            "gid" : "9c48582f-f54f-4d08-ac3a-bb3520d3df09"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "Appalachian dulcimer",
            "name" : "Appalachian dulcimer",
            "id" : 90,
            "creditable" : true,
            "gid" : "e618d02c-41c0-475c-be70-7ef0f92da7d0"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "balalaika",
            "name" : "balalaika",
            "id" : 91,
            "creditable" : true,
            "gid" : "f6b51493-c7bd-41be-901b-245380ec96ce"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "banjo",
            "name" : "banjo",
            "id" : 92,
            "creditable" : true,
            "gid" : "6bf88fc7-a235-4d95-a910-a4ce4a4853c6"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "berimbau",
            "name" : "berimbau",
            "id" : 93,
            "creditable" : true,
            "gid" : "c7651f8a-ce7e-494a-9764-cbdd2d9817c3"
         },
         {
            "l_name" : "biwa",
            "name" : "biwa",
            "description" : "The biwa is a short-necked Japanese fretted lute which is played with a large triangular-shaped plectrum.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 94,
            "creditable" : true,
            "gid" : "1b165fa4-8510-4a3e-a2b5-2d38baf55176"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "bouzouki",
            "name" : "bouzouki",
            "id" : 95,
            "creditable" : true,
            "gid" : "2091cdd2-7953-453f-a29e-cfcbf5140d44"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "mandolin",
            "name" : "mandolin",
            "id" : 96,
            "creditable" : true,
            "gid" : "37fa9bb5-d5d7-4b0f-aa4d-531339ba9c32"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "musical bow",
            "name" : "musical bow",
            "id" : 97,
            "creditable" : true,
            "gid" : "89e04164-5c7b-45df-94f4-e979b21da9bc"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "crwth",
            "name" : "crwth",
            "id" : 98,
            "creditable" : true,
            "gid" : "f12c315c-317c-45d3-9dc0-c703d6486e40"
         },
         {
            "l_name" : "gayageum",
            "name" : "gayageum",
            "description" : "The gayageum is a traditional Korean zither-like string instrument which normally has 12 strings.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 99,
            "creditable" : true,
            "gid" : "73ab72a3-039d-422a-8ce8-a0f8211bd022"
         },
         {
            "l_name" : "geomungo",
            "name" : "geomungo",
            "description" : "The geomungo is a traditional Korean zither, based on the Chinese guqin, which typically has 6 strings.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 100,
            "creditable" : true,
            "gid" : "8158f0e5-94ab-4c8f-b3ed-15b1b14b7d63"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "hammered dulcimer",
            "name" : "hammered dulcimer",
            "id" : 101,
            "creditable" : true,
            "gid" : "9cbe04a2-0014-474c-b530-b0d4f4b73413"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "hardingfele",
            "name" : "hardingfele",
            "id" : 102,
            "creditable" : true,
            "gid" : "13300a83-2776-481a-80fb-cd68f7be4051"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "hurdy gurdy",
            "name" : "hurdy gurdy",
            "id" : 103,
            "creditable" : true,
            "gid" : "303d4f1a-f799-4c42-9bac-dbedd9139e91"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "jew's harp",
            "name" : "jew's harp",
            "id" : 104,
            "creditable" : true,
            "gid" : "ffaf7204-92f1-4c03-846a-748218ebf2a5"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "kora",
            "name" : "kora",
            "id" : 106,
            "creditable" : true,
            "gid" : "32de8d17-6ea8-4c46-8c95-c02b77883c50"
         },
         {
            "l_name" : "koto",
            "name" : "koto",
            "description" : "The koto is a traditional Japanese string instrument with 13 strings that are strung over 13 movable bridges along the width of the instrument.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 107,
            "creditable" : true,
            "gid" : "274717c1-b2d8-4a6a-8eaf-eb0c1e11b757"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "lute",
            "name" : "lute",
            "id" : 108,
            "creditable" : true,
            "gid" : "38237fcc-b833-4cd6-8dc1-e5fe2f308a2b"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "lyre",
            "name" : "lyre",
            "id" : 109,
            "creditable" : true,
            "gid" : "21bd4d63-a75a-4022-abd3-52ba7487c2de"
         },
         {
            "l_name" : "mbira",
            "name" : "mbira",
            "description" : "The mbira or kalimba (also known by many other names) is an African thumb piano.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 110,
            "creditable" : true,
            "gid" : "4dc550d6-973f-42bd-8c9b-7dfd09bd3f6e"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "psaltery",
            "name" : "psaltery",
            "id" : 111,
            "creditable" : true,
            "gid" : "2f5aa3e2-993e-42ab-85a9-97cad29c430c"
         },
         {
            "l_name" : "shamisen",
            "name" : "shamisen",
            "description" : "The shamisen, samisen or sangen is a three-stringed instrument from Japan which is played with a large triangular-shaped plectrum called a bachi. The body traditionally uses cat or dog skin, unlike the Chinese sanxian and Okinawan sanshin.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 112,
            "creditable" : true,
            "gid" : "c03753c7-1735-4e24-9c9a-8cb5994d6bc5"
         },
         {
            "l_name" : "sitar",
            "name" : "sitar",
            "description" : "The sitar is a plucked stringed instrument used mainly in Hindustani music and Indian classical music which is descended from a similar but simpler Persian instrument called the setar.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 113,
            "creditable" : true,
            "gid" : "9290b2c1-97c3-4355-a26f-c6dba89cf8ff"
         },
         {
            "l_name" : "ukulele",
            "name" : "ukulele",
            "description" : "The ukulele is a small guitar-like instrument commonly associated with Hawaiian music. It generally has four nylon or gut strings.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 114,
            "creditable" : true,
            "gid" : "af1341bb-f62c-4e9b-af62-c3ea19fa54c6"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "tres",
            "name" : "tres",
            "id" : 115,
            "creditable" : true,
            "gid" : "65b8bd3c-c194-415b-b075-1f3cd9d031bd"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "vielle",
            "name" : "vielle",
            "id" : 116,
            "creditable" : true,
            "gid" : "69de43e4-1d92-4b65-8c63-2f9daf485f81"
         },
         {
            "l_name" : "Mexican vihuela",
            "name" : "Mexican vihuela",
            "description" : "Mexican vihuela, used by mariachi bands",
            "freeText" : false,
            "rootID" : 14,
            "id" : 117,
            "creditable" : true,
            "gid" : "a11f1ba4-f2e1-4498-860e-f1b22b17f75b"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "viola da gamba",
            "name" : "viola da gamba",
            "id" : 118,
            "creditable" : true,
            "gid" : "be34e4e5-6e77-46f5-ab56-c9641d3da213"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "viola d'amore",
            "name" : "viola d'amore",
            "id" : 119,
            "creditable" : true,
            "gid" : "b47bdb4e-59ee-42d3-96ef-a1f0fdd61148"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "violotta",
            "name" : "violotta",
            "id" : 120,
            "creditable" : true,
            "gid" : "8be32b8c-7845-4b6f-94dd-ff4d83169c26"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "washtub bass",
            "name" : "washtub bass",
            "id" : 121,
            "creditable" : true,
            "gid" : "b8471d2e-9b9d-4f52-822e-b19a37cd30ac"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "xalam / khalam",
            "name" : "xalam / khalam",
            "id" : 122,
            "creditable" : true,
            "gid" : "e7c17460-e42d-4ffc-8167-4bd6d7e4f2c5"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "zither",
            "name" : "zither",
            "id" : 123,
            "creditable" : true,
            "gid" : "c6a133d5-c1e0-47d6-bc30-30d102a78893"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "percussion",
            "name" : "percussion",
            "id" : 124,
            "creditable" : true,
            "gid" : "8e9abdf1-0afc-4544-b201-c6fa768d01f4"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "drums",
            "name" : "drums",
            "id" : 125,
            "creditable" : true,
            "gid" : "3bccb7eb-cbca-42cd-b0ac-a5e959df7221"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "drumset",
            "name" : "drumset",
            "id" : 126,
            "creditable" : true,
            "gid" : "12092505-6ee1-46af-a15a-b5b468b6b155"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "congas",
            "name" : "congas",
            "id" : 127,
            "creditable" : true,
            "gid" : "f3bd3292-1a33-4259-974d-b7375158d95d"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "bongos",
            "name" : "bongos",
            "id" : 128,
            "creditable" : true,
            "gid" : "af593522-6dc8-45b3-8419-35f22adb5c03"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "snare drum",
            "name" : "snare drum",
            "id" : 129,
            "creditable" : true,
            "gid" : "947cca7d-74c6-4044-b6cc-71a1180d0b28"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "timbales",
            "name" : "timbales",
            "id" : 132,
            "creditable" : true,
            "gid" : "e79fd941-dcdf-4a07-bafb-61ef5c47d7b2"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "triangle",
            "name" : "triangle",
            "id" : 133,
            "creditable" : true,
            "gid" : "63cfd648-2022-4390-8740-1ea86259574f"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "whip",
            "name" : "whip",
            "id" : 134,
            "creditable" : true,
            "gid" : "0b9887d6-e05d-42b0-bdfc-02c36b930642"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "afuche / cabasa",
            "name" : "afuche / cabasa",
            "id" : 136,
            "creditable" : true,
            "gid" : "33b6ba89-8265-4d8f-bbdc-ecff41e29e8c"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "castanets",
            "name" : "castanets",
            "id" : 137,
            "creditable" : true,
            "gid" : "dd53d958-d4dd-43df-bf61-2e62d4772109"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "claves",
            "name" : "claves",
            "id" : 138,
            "creditable" : true,
            "gid" : "4846eef6-2901-41cf-bae1-a27ff708fc54"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "doyra",
            "name" : "doyra",
            "id" : 140,
            "creditable" : true,
            "gid" : "81c58ce0-65fa-4bab-8484-f8d68ae91c63"
         },
         {
            "l_name" : "güiro",
            "name" : "güiro",
            "unaccented" : "guiro",
            "freeText" : false,
            "rootID" : 14,
            "id" : 141,
            "creditable" : true,
            "gid" : "f297a140-d442-446d-9a2e-a7f1923f7df6"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "maracas",
            "name" : "maracas",
            "id" : 142,
            "creditable" : true,
            "gid" : "67e43590-f3c4-486c-9b86-f1dfe338c5e9"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "mendoza",
            "name" : "mendoza",
            "id" : 143,
            "creditable" : true,
            "gid" : "a5479f69-0c46-4bd3-8170-add906b9e688"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "tuned percussion",
            "name" : "tuned percussion",
            "id" : 150,
            "creditable" : true,
            "gid" : "a1f626fa-0912-4ebf-adeb-06f9c0dcdf70"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "bells",
            "name" : "bells",
            "id" : 151,
            "creditable" : true,
            "gid" : "c95c7129-d180-4218-afea-4b74ef70e2be"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "electronic instruments",
            "name" : "electronic instruments",
            "id" : 159,
            "creditable" : true,
            "gid" : "a51219e5-fc36-4427-93a9-743e616c6f0c"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "Denis d'or",
            "name" : "Denis d'or",
            "id" : 160,
            "creditable" : true,
            "gid" : "8dd115ee-f066-4d68-95ca-6a70d6a44b93"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "Dubreq Stylophone",
            "name" : "Dubreq Stylophone",
            "id" : 161,
            "creditable" : true,
            "gid" : "515da853-78ae-49ac-9b02-471a4eb0a9df"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "drum machine",
            "name" : "drum machine",
            "id" : 162,
            "creditable" : true,
            "gid" : "ce0eed13-58d8-4744-8ad0-b7d6182a2d0f"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "ondes Martenot",
            "name" : "ondes Martenot",
            "id" : 163,
            "creditable" : true,
            "gid" : "51b6b587-43bb-4944-8b98-7fb04404b28a"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "sampler",
            "name" : "sampler",
            "id" : 164,
            "creditable" : true,
            "gid" : "fb6f5426-b6ec-4ffa-9bb1-d9fdf9b453ad"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "synclavier",
            "name" : "synclavier",
            "id" : 165,
            "creditable" : true,
            "gid" : "6b18e468-2ae1-4b4c-ad1f-5296894e956f"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "synthesizer",
            "name" : "synthesizer",
            "id" : 166,
            "creditable" : true,
            "gid" : "4a29230c-5ab5-4eff-ac59-4a253f3561a0"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "teleharmonium",
            "name" : "teleharmonium",
            "id" : 167,
            "creditable" : true,
            "gid" : "4573bc1b-9388-47d6-b184-ed8a4d1fb47e"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "theremin",
            "name" : "theremin",
            "id" : 168,
            "creditable" : true,
            "gid" : "96c9c681-ee2f-42a7-894b-c50d983b9e7f"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "calliope",
            "name" : "calliope",
            "id" : 170,
            "creditable" : true,
            "gid" : "9f860a2b-e38f-4699-94a9-f9f5730afc02"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "carillon",
            "name" : "carillon",
            "id" : 171,
            "creditable" : true,
            "gid" : "0d14d4e0-9ac9-4a96-a595-4145d7794082"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "celesta",
            "name" : "celesta",
            "id" : 172,
            "creditable" : true,
            "gid" : "a1464d63-4f9d-4aaa-9513-a15d12baa408"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "clavichord",
            "name" : "clavichord",
            "id" : 173,
            "creditable" : true,
            "gid" : "eacc32ac-8ff4-4ebd-b9ef-148986524761"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "harpsichord",
            "name" : "harpsichord",
            "id" : 174,
            "creditable" : true,
            "gid" : "bfe379dc-1d65-4862-acd8-60d53bb963a2"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "Mellotron",
            "name" : "Mellotron",
            "id" : 175,
            "creditable" : true,
            "gid" : "3715ab17-124b-4011-b324-d2bb2cd46f6b"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "organ",
            "name" : "organ",
            "id" : 176,
            "creditable" : true,
            "gid" : "55a37f4f-39a4-45a7-851d-586569985519"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "Hammond organ",
            "name" : "Hammond organ",
            "id" : 177,
            "creditable" : true,
            "gid" : "0fa6ef90-4c92-4456-9965-ad3f96c51db3"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "harmonium",
            "name" : "harmonium",
            "id" : 178,
            "creditable" : true,
            "gid" : "c43c7647-077d-4d60-a01b-769de71b82f2"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "pipe organ",
            "name" : "pipe organ",
            "id" : 179,
            "creditable" : true,
            "gid" : "39d85868-3476-45cc-94d0-3d43e3135921"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "piano",
            "name" : "piano",
            "id" : 180,
            "creditable" : true,
            "gid" : "b3eac5f9-7859-4416-ac39-7154e2e8d348"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "grand piano",
            "name" : "grand piano",
            "id" : 181,
            "creditable" : true,
            "gid" : "e8694e08-43c7-4658-b39d-bfe8f85d573e"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "Rhodes piano",
            "name" : "Rhodes piano",
            "id" : 182,
            "creditable" : true,
            "gid" : "aa3b54ec-9cc8-409c-a2d9-f960e65bf5f5"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "upright piano",
            "name" : "upright piano",
            "id" : 184,
            "creditable" : true,
            "gid" : "b236d895-ffc1-4be0-bdcb-8979ce50c2a5"
         },
         {
            "l_name" : "other instruments",
            "name" : "other instruments",
            "description" : "Other instruments. If you can't find an instrument, please request it at http://wiki.musicbrainz.org/Instrument_Tree/Requests",
            "freeText" : false,
            "rootID" : 14,
            "id" : 185,
            "creditable" : true,
            "gid" : "0a06dd9a-92d6-4891-a699-2b116a3d3f37"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "hardart",
            "name" : "hardart",
            "id" : 187,
            "creditable" : true,
            "gid" : "491e1a15-ad7a-4701-811d-8fe7711249a9"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "kazoo",
            "name" : "kazoo",
            "id" : 188,
            "creditable" : true,
            "gid" : "9ea49871-d5db-45b0-983f-f1cbae748d9a"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "lasso d'amore",
            "name" : "lasso d'amore",
            "id" : 189,
            "creditable" : true,
            "gid" : "159aa813-ee34-4a1d-a6c6-7db20afb182e"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "musical saw",
            "name" : "musical saw",
            "id" : 190,
            "creditable" : true,
            "gid" : "23171239-1d9d-4482-b057-1ba884bcfda6"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "singing bowl",
            "name" : "singing bowl",
            "id" : 191,
            "creditable" : true,
            "gid" : "01571d2e-c4a0-4544-86d2-b289ef837498"
         },
         {
            "l_name" : "suikinkutsu",
            "name" : "suikinkutsu",
            "description" : "A suikinkutsu is a type of Japanese garden ornament which uses dripping water to create music. Although it is also known as a Japanese water zither, it is named after the sound the koto (a Japanese zither) makes and is not actually a string instrument.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 192,
            "creditable" : true,
            "gid" : "e47f81f3-bc5c-489d-aedc-de967ee1e0d1"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "serpent",
            "name" : "serpent",
            "id" : 197,
            "creditable" : true,
            "gid" : "443c51d5-44ca-4ed5-bda8-d405e9d43270"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "sackbut",
            "name" : "sackbut",
            "id" : 198,
            "creditable" : true,
            "gid" : "0d012882-abbf-4c93-8fa8-494a192dcca0"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "euphonium",
            "name" : "euphonium",
            "id" : 199,
            "creditable" : true,
            "gid" : "6c73e2b6-76bc-40b1-ae7d-2768d23a9a79"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "sousaphone",
            "name" : "sousaphone",
            "id" : 200,
            "creditable" : true,
            "gid" : "53e090c3-4376-470f-be04-09483324b668"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "Wagner tuba",
            "name" : "Wagner tuba",
            "id" : 201,
            "creditable" : true,
            "gid" : "5dd9c3cb-f206-4248-8c35-35314b739652"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "bull-roarer",
            "name" : "bull-roarer",
            "id" : 202,
            "creditable" : true,
            "gid" : "d00cec5f-f9bc-4235-a54f-6639a02d4e4c"
         },
         {
            "l_name" : "keyed brass instruments",
            "name" : "keyed brass instruments",
            "description" : "Keyed brass instruments use holes along the body of the instrument in a similar way to a woodwind instrument.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 203,
            "creditable" : true,
            "gid" : "371dd55f-5251-4905-a8b2-2d2acf352376"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "didgeridoo",
            "name" : "didgeridoo",
            "id" : 204,
            "creditable" : true,
            "gid" : "8a0f37bb-65f1-48f9-a58f-95227d28470c"
         },
         {
            "l_name" : "conch",
            "name" : "conch",
            "description" : "Conch shell",
            "freeText" : false,
            "rootID" : 14,
            "id" : 205,
            "creditable" : true,
            "gid" : "8eb9019f-36ec-4fed-be43-e4f22cf87fb7"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "Spanish acoustic guitar",
            "name" : "Spanish acoustic guitar",
            "id" : 206,
            "creditable" : true,
            "gid" : "117dacfc-0ad0-4e90-81a4-a28b4c03929b"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "cowbell",
            "name" : "cowbell",
            "id" : 208,
            "creditable" : true,
            "gid" : "2b75a5bc-f9ce-49e8-ace8-35e5925fff4a"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "washboard",
            "name" : "washboard",
            "id" : 209,
            "creditable" : true,
            "gid" : "2e899f30-ac87-4ea9-88bf-9b4b573bab63"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "spoons",
            "name" : "spoons",
            "id" : 210,
            "creditable" : true,
            "gid" : "8dfbf2ce-239d-4e6e-90c1-4467a8c853ba"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "ratchet",
            "name" : "ratchet",
            "id" : 211,
            "creditable" : true,
            "gid" : "a140a41d-16eb-487d-ba31-d82fd16e14b3"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "vibraslap",
            "name" : "vibraslap",
            "id" : 212,
            "creditable" : true,
            "gid" : "9c79b6a1-89bb-4603-9b52-e7b0b639d317"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "wood block",
            "name" : "wood block",
            "id" : 213,
            "creditable" : true,
            "gid" : "ec7a5fbf-f374-4bdb-8c1d-fabc7a8424c0"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "crotales",
            "name" : "crotales",
            "id" : 214,
            "creditable" : true,
            "gid" : "e599d391-7a7c-491d-9843-2cdd140b23d4"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "glockenspiel",
            "name" : "glockenspiel",
            "id" : 215,
            "creditable" : true,
            "gid" : "340b8043-e3c4-443e-afb8-7fce24fe0ce4"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "marimba",
            "name" : "marimba",
            "id" : 216,
            "creditable" : true,
            "gid" : "c436b34a-3017-472d-a003-49a2b24d55da"
         },
         {
            "l_name" : "timpani",
            "name" : "timpani",
            "description" : "Timpani (Kettle drum)",
            "freeText" : false,
            "rootID" : 14,
            "id" : 217,
            "creditable" : true,
            "gid" : "7d86c75c-bccd-4c9d-a73d-4bb443e5110b"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "tubular bells",
            "name" : "tubular bells",
            "id" : 218,
            "creditable" : true,
            "gid" : "7d6964ff-b1f5-472b-bdd7-b53de3739ad3"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "vibraphone",
            "name" : "vibraphone",
            "id" : 219,
            "creditable" : true,
            "gid" : "799af440-c0e7-4d8f-83d5-ecfee8b25787"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "xylophone",
            "name" : "xylophone",
            "id" : 220,
            "creditable" : true,
            "gid" : "db95a035-6a3d-44b4-8694-74ff71b61768"
         },
         {
            "l_name" : "other percussion",
            "name" : "other percussion",
            "description" : "Other percussion. If you can't find an instrument, please request it at http://wiki.musicbrainz.org/Talk:Advanced_Instrument_Tree",
            "freeText" : false,
            "rootID" : 14,
            "id" : 221,
            "creditable" : true,
            "gid" : "bea78dfc-eab4-48be-a082-1d65c146a999"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "temple blocks",
            "name" : "temple blocks",
            "id" : 222,
            "creditable" : true,
            "gid" : "c49f1425-946e-43d4-8890-41d226a1ec69"
         },
         {
            "l_name" : "shakuhachi",
            "name" : "shakuhachi",
            "description" : "The shakuhachi is a Japanese end-blown flute.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 224,
            "creditable" : true,
            "gid" : "d3bdf855-7161-40f5-945b-f261f7c0d6ba"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "alto violin",
            "name" : "alto violin",
            "id" : 226,
            "creditable" : true,
            "gid" : "72ef1be2-d348-4d95-ad39-ff00a4636bd6"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "clavinet",
            "name" : "clavinet",
            "id" : 227,
            "creditable" : true,
            "gid" : "563a9f16-e84b-409a-bda5-2e4ce09d5573"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "bass trombone",
            "name" : "bass trombone",
            "id" : 228,
            "creditable" : true,
            "gid" : "e659d40f-50b4-4726-b8d5-a3e254e8008b"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "guitar",
            "name" : "guitar",
            "id" : 229,
            "creditable" : true,
            "gid" : "63021302-86cd-4aee-80df-2270d54f4978"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "keyboard",
            "name" : "keyboard",
            "id" : 232,
            "creditable" : true,
            "gid" : "95b0c3d2-9606-4ef5-a019-9b7437f3adda"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "reeds",
            "name" : "reeds",
            "id" : 233,
            "creditable" : true,
            "gid" : "1313dfa6-2073-4a55-b60e-904d47c704fa"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "singular reed",
            "name" : "singular reed",
            "id" : 234,
            "creditable" : true,
            "gid" : "6d46f715-b23f-4a1d-a716-fbce01916329"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "turntable(s)",
            "name" : "turntable(s)",
            "id" : 236,
            "creditable" : true,
            "gid" : "ae92e4be-1e62-40d8-85a8-2e56290a95fa"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "valve trombone",
            "name" : "valve trombone",
            "id" : 237,
            "creditable" : true,
            "gid" : "fe2e16fc-81b7-44e7-a96a-c3afac308a04"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "Chapman stick",
            "name" : "Chapman stick",
            "id" : 238,
            "creditable" : true,
            "gid" : "f5f66443-cb91-4845-a02e-207b33bf67f2"
         },
         {
            "l_name" : "dobro",
            "name" : "dobro",
            "description" : "Dobro, resonator guitar",
            "freeText" : false,
            "rootID" : 14,
            "id" : 240,
            "creditable" : true,
            "gid" : "566b5377-1dc9-4745-80eb-3fb03f67c85e"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "tabla",
            "name" : "tabla",
            "id" : 241,
            "creditable" : true,
            "gid" : "18e6998b-e53b-415b-b484-d3ac286da99d"
         },
         {
            "l_name" : "madal",
            "name" : "madal",
            "description" : "Madal, hand drum originating from Nepal",
            "freeText" : false,
            "rootID" : 14,
            "id" : 242,
            "creditable" : true,
            "gid" : "ddc4d5c6-8b2e-4c92-8cab-d430e0ce6258"
         },
         {
            "l_name" : "uilleann pipes",
            "name" : "uilleann pipes",
            "description" : "Uilleann/Union/Irish pipes",
            "freeText" : false,
            "rootID" : 14,
            "id" : 248,
            "creditable" : true,
            "gid" : "d307828e-e4e4-42ee-bce9-e1cd15ad3ec1"
         },
         {
            "l_name" : "bodhrán",
            "name" : "bodhrán",
            "unaccented" : "bodhran",
            "freeText" : false,
            "rootID" : 14,
            "id" : 249,
            "creditable" : true,
            "gid" : "1759833f-e25d-41a1-9133-780b9c9ee506"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "sarod",
            "name" : "sarod",
            "id" : 250,
            "creditable" : true,
            "gid" : "97d2aa1e-b5e6-4930-ab0e-f2cfe508b253"
         },
         {
            "l_name" : "bansuri",
            "name" : "bansuri",
            "description" : "The bansuri is a transverse alto flute, which is the North Indian counterpart to the venu.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 251,
            "creditable" : true,
            "gid" : "1ebfe130-b68c-452a-8ee3-81b430d13ca3"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "heckelphone",
            "name" : "heckelphone",
            "id" : 261,
            "creditable" : true,
            "gid" : "ede795b9-6bf8-4cc7-95c9-2bc9c5d5b858"
         },
         {
            "l_name" : "sho",
            "name" : "sho",
            "description" : "The shō is a Japanese free reed instrument modelled on the Chinese sheng, although the shō tends to be smaller in size.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 262,
            "creditable" : true,
            "gid" : "58a2fe57-147c-4a48-a2af-cf87305fcaab"
         },
         {
            "l_name" : "bandoneón",
            "name" : "bandoneón",
            "unaccented" : "bandoneon",
            "freeText" : false,
            "rootID" : 14,
            "id" : 263,
            "creditable" : true,
            "gid" : "007d6c88-c6fd-4fe7-9af7-8a0cac0d2526"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "duct flutes",
            "name" : "duct flutes",
            "id" : 264,
            "creditable" : true,
            "gid" : "218218d4-50fe-431d-bbca-55f4158beae0"
         },
         {
            "l_name" : "other flutes",
            "name" : "other flutes",
            "description" : "Other flutes. If you can't find an instrument, please request it at http://wiki.musicbrainz.org/Talk:Advanced_Instrument_Tree",
            "freeText" : false,
            "rootID" : 14,
            "id" : 265,
            "creditable" : true,
            "gid" : "dd91b67e-014f-4f12-b995-463bc7f54609"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "willow flute",
            "name" : "willow flute",
            "id" : 266,
            "creditable" : true,
            "gid" : "987da87e-c5d3-42eb-805d-27b8c3f3ebde"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "tin whistle",
            "name" : "tin whistle",
            "id" : 267,
            "creditable" : true,
            "gid" : "c1b42be7-f713-449b-a3a4-925351b5acbc"
         },
         {
            "l_name" : "slide whistle",
            "name" : "slide whistle",
            "description" : "Slide whistle (infamous 'Clangers' sound)",
            "freeText" : false,
            "rootID" : 14,
            "id" : 268,
            "creditable" : true,
            "gid" : "712646f2-7776-4ec5-975f-189c79bcc9dd"
         },
         {
            "l_name" : "sáo trúc",
            "name" : "sáo trúc",
            "unaccented" : "sao truc",
            "description" : "The sáo trúc is a Vietnamese transverse flute made of bamboo.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 269,
            "creditable" : true,
            "gid" : "3fd7b592-fddd-4d46-a7c6-cac6b1fcba41"
         },
         {
            "l_name" : "nose flute",
            "name" : "nose flute",
            "description" : "The nose flute is a flute played by the nose commonly found in countries in and around the Pacific.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 270,
            "creditable" : true,
            "gid" : "e2e7de25-20d5-4c3f-8a23-2b99d3e44730"
         },
         {
            "l_name" : "valved brass instruments",
            "name" : "valved brass instruments",
            "description" : "Valved brass instruments use a set of valves which introduce additional tubing into the instrument.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 271,
            "creditable" : true,
            "gid" : "d2f041b9-b6a6-4973-badd-1b07a37192c9"
         },
         {
            "l_name" : "slide brass instruments",
            "name" : "slide brass instruments",
            "description" : "Slide brass instruments use a slide to change the length of tubing.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 272,
            "creditable" : true,
            "gid" : "4a5da835-0f0d-4010-b013-76d0a48f8578"
         },
         {
            "l_name" : "cornett",
            "name" : "cornett",
            "description" : "The cornett (not to be confused with the cornet) is an early wind instrument.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 273,
            "creditable" : true,
            "gid" : "29b024c3-f6cd-4415-83ec-2b6765856881"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "reed organ",
            "name" : "reed organ",
            "id" : 274,
            "creditable" : true,
            "gid" : "20443ce3-cde1-4968-b7cc-65e45bb9714f"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "bowed string instruments",
            "name" : "bowed string instruments",
            "id" : 275,
            "creditable" : true,
            "gid" : "4c1916f0-4643-45ce-afaf-c9c5dabbb4f7"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "rebec",
            "name" : "rebec",
            "id" : 276,
            "creditable" : true,
            "gid" : "3f7302e4-f10f-4905-8d71-ef61141da383"
         },
         {
            "l_name" : "bass guitar",
            "name" : "bass guitar",
            "description" : "Bass (modern, typically electrical, but not always)",
            "freeText" : false,
            "rootID" : 14,
            "id" : 277,
            "creditable" : true,
            "gid" : "17f9f065-2312-4a24-8309-6f6dd63e2e33"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "electric cello",
            "name" : "electric cello",
            "id" : 278,
            "creditable" : true,
            "gid" : "5e36c381-11c0-47ec-ac74-df63e9e24af7"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "treble violin",
            "name" : "treble violin",
            "id" : 279,
            "creditable" : true,
            "gid" : "837c7244-ece8-47ff-b215-78f4aa4f227d"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "soprano violin",
            "name" : "soprano violin",
            "id" : 280,
            "creditable" : true,
            "gid" : "ba6af31f-8b2f-4c5e-903e-882f88f6d3a6"
         },
         {
            "l_name" : "kemenche",
            "name" : "kemenche",
            "description" : "Turkish three-stringed bowed instrument",
            "freeText" : false,
            "rootID" : 14,
            "id" : 281,
            "creditable" : true,
            "gid" : "01ba56a2-4306-493d-8088-c7e9b671c74e"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "electric violin",
            "name" : "electric violin",
            "id" : 282,
            "creditable" : true,
            "gid" : "5f4d4cf9-40fb-494d-8266-747b0289a84d"
         },
         {
            "l_name" : "huqin",
            "name" : "huqin",
            "description" : "Huqin is a Chinese family of bowed string instruments.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 283,
            "creditable" : true,
            "gid" : "90086448-eb94-4ee1-a3a6-1412398088b9"
         },
         {
            "l_name" : "jinghu",
            "name" : "jinghu",
            "description" : "The jinghu is a Chinese bowed string instrument with two strings used primarily in Beijing opera.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 284,
            "creditable" : true,
            "gid" : "89e4a2ef-172f-4f50-a507-316917a9b98a"
         },
         {
            "l_name" : "erhu",
            "name" : "erhu",
            "description" : "The erhu is a bowed Chinese instrument with two strings.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 285,
            "creditable" : true,
            "gid" : "988026a0-2cb7-42bb-9407-9110874fa401"
         },
         {
            "l_name" : "gaohu",
            "name" : "gaohu",
            "description" : "The gaohu is a Chinese bowed string instrument developed from the erhu and tuned a fourth higher.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 286,
            "creditable" : true,
            "gid" : "e2cd6f0c-fb6b-444e-96ea-0a4ec0ea66f3"
         },
         {
            "l_name" : "zhonghu",
            "name" : "zhonghu",
            "description" : "The zhonghu is a Chinese bowed string instrument developed from the erhu and tuned a fourth or a fifth lower.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 287,
            "creditable" : true,
            "gid" : "e2be1d64-66ff-438e-8433-66ba7b99715d"
         },
         {
            "l_name" : "cizhonghu",
            "name" : "cizhonghu",
            "description" : "The dahu, also known as cizhonghu or xiaodihu, is a large Chinese bowed string instrument in the huqin family.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 288,
            "creditable" : true,
            "gid" : "c95361dd-f093-44bf-84a2-9067af7b1b12"
         },
         {
            "l_name" : "gehu",
            "name" : "gehu",
            "description" : "The gehu is a Chinese bowed string instrument, with four strings and tuned like the cello.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 289,
            "creditable" : true,
            "gid" : "fdcced38-d8ca-403f-b5cf-1e0c8e5b980e"
         },
         {
            "l_name" : "diyingehu",
            "name" : "diyingehu",
            "description" : "The diyingehu is a Chinese bowed string instrument, with four strings and tuned like the double bass.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 290,
            "creditable" : true,
            "gid" : "fa6e1499-d64f-4ff1-aa7b-e2c535d30416"
         },
         {
            "l_name" : "banhu",
            "name" : "banhu",
            "description" : "The banhu is a Chinese bowed string instrument in the huqin family. It is also called banghu for its use in bangzi opera.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 291,
            "creditable" : true,
            "gid" : "7254d816-5cb5-4399-bbe9-4b7e14e67462"
         },
         {
            "l_name" : "yehu",
            "name" : "yehu",
            "description" : "The yehu is a Chinese bowed string instrument in the huqin family, made from a coconut shell.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 292,
            "creditable" : true,
            "gid" : "8c10a781-2414-4dbb-9a33-d8a156ac12f1"
         },
         {
            "l_name" : "kokyu",
            "name" : "kokyu",
            "description" : "The kokyu is a Japanese bowed string instrument.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 293,
            "creditable" : true,
            "gid" : "b1a367a1-6dde-4357-b7bb-0395dfb6c2dd"
         },
         {
            "l_name" : "morin khuur / matouqin",
            "name" : "morin khuur / matouqin",
            "description" : "The morin khuur or matouqin is a Mongolian bowed string instrument which has two strings. The scroll is normally carved in the shape of a horse's head.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 294,
            "creditable" : true,
            "gid" : "1bf9e39f-5ffc-4588-990b-d48609613f8f"
         },
         {
            "l_name" : "đàn nhị",
            "name" : "đàn nhị",
            "unaccented" : "dan nhi",
            "description" : "The đàn nhị is a Vietnamese stringed instrument with a small, cylindrical body, covered at one end with snakeskin. The bow passes between the two strings and the instrument has no frets. This instrument is of Chinese descent but has relatives all over Asia.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 295,
            "creditable" : true,
            "gid" : "327938f3-0931-4dc9-bd64-5959089978e0"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "archaic and other bowed string-instruments",
            "name" : "archaic and other bowed string-instruments",
            "id" : 296,
            "creditable" : true,
            "gid" : "4c8eff90-b3cf-4a8f-be1f-2aeb1ddc3fad"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "viola organista",
            "name" : "viola organista",
            "id" : 297,
            "creditable" : true,
            "gid" : "83f85adc-472c-45ea-ba5e-22e5a825d49f"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "nyckelharpa",
            "name" : "nyckelharpa",
            "id" : 298,
            "creditable" : true,
            "gid" : "3be28a98-61eb-403d-a9fb-62e04f9b79ac"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "bowed psaltery",
            "name" : "bowed psaltery",
            "id" : 299,
            "creditable" : true,
            "gid" : "a0185c49-36b3-445b-8949-474c0a7fdafb"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "gudok",
            "name" : "gudok",
            "id" : 300,
            "creditable" : true,
            "gid" : "0bcc6b50-1f8b-4c6b-86f3-f2cd61ae5f85"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "gadulka",
            "name" : "gadulka",
            "id" : 301,
            "creditable" : true,
            "gid" : "280ae6d4-03ad-4009-ba8d-de793e4c87c0"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "plucked string instruments",
            "name" : "plucked string instruments",
            "id" : 302,
            "creditable" : true,
            "gid" : "b879ca9a-bf4b-41f8-b1a3-aa109f2e3bea"
         },
         {
            "l_name" : "đàn tứ dây",
            "name" : "đàn tứ dây",
            "unaccented" : "dan tu day",
            "description" : "A latter-day construction in the form of a four-stringed, square-bodied bass guitar",
            "freeText" : false,
            "rootID" : 14,
            "id" : 303,
            "creditable" : true,
            "gid" : "2c27736b-e774-4f8e-8290-604d3c468870"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "oud",
            "name" : "oud",
            "id" : 304,
            "creditable" : true,
            "gid" : "758c62c1-39c9-4fe9-8cb0-07398f3cb15a"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "Turkish baglama",
            "name" : "Turkish baglama",
            "id" : 305,
            "creditable" : true,
            "gid" : "2dd967cd-104e-4696-8a70-0f6fd37779e7"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "Greek baglama",
            "name" : "Greek baglama",
            "id" : 306,
            "creditable" : true,
            "gid" : "d4d5309f-166e-4e14-9887-06692f2c1027"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "cittern",
            "name" : "cittern",
            "id" : 307,
            "creditable" : true,
            "gid" : "7b935bb5-798b-43bd-92ad-85511a132e44"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "mandola",
            "name" : "mandola",
            "id" : 308,
            "creditable" : true,
            "gid" : "6bfa53af-7c17-47d2-9778-f31a4ab5fb91"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "rebab",
            "name" : "rebab",
            "id" : 309,
            "creditable" : true,
            "gid" : "30cb46c6-2694-4348-a7c6-3fb12666d7e5"
         },
         {
            "l_name" : "yueqin",
            "name" : "yueqin",
            "description" : "The yueqin is a Chinese \"moon-shaped\" plucked lute.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 310,
            "creditable" : true,
            "gid" : "d16da325-4ae5-45fd-a0ec-338766795391"
         },
         {
            "l_name" : "zhongruan",
            "name" : "zhongruan",
            "description" : "The zhongruan is a Chinese plucked lute, the tenor-ranged size in the ruan family.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 311,
            "creditable" : true,
            "gid" : "d096e1f9-6664-4c64-b793-842072e917ac"
         },
         {
            "l_name" : "đàn nguyệt",
            "name" : "đàn nguyệt",
            "unaccented" : "dan nguyet",
            "description" : "The đàn nguyệt or đàn kìm is a two-stringed Vietnamese lute with a long neck and a circular, flat body.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 312,
            "creditable" : true,
            "gid" : "f427a934-2c14-49bc-a0fd-aee758821157"
         },
         {
            "l_name" : "đàn tỳ bà",
            "name" : "đàn tỳ bà",
            "unaccented" : "dan ty ba",
            "description" : "The đàn tỳ bà is a four-stringed Vietnamese lute with a pear-shaped body. Like the Chinese pipa from which is derived, it has greatly elevated frets at the neck.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 313,
            "creditable" : true,
            "gid" : "8fcc9dea-8978-4dc9-8feb-acb35f8dca2c"
         },
         {
            "l_name" : "sanxian",
            "name" : "sanxian",
            "description" : "The sanxian is a Chinese lute with three strings.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 314,
            "creditable" : true,
            "gid" : "ce8d4fc7-08cd-4d13-a84f-297f799e672f"
         },
         {
            "l_name" : "sanshin",
            "name" : "sanshin",
            "description" : "The sanshin is an Okinawan string instrument which consists of a snakeskin-covered body, neck and three strings. It is traditionally played with a plectrum made of horn worn on the index finger.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 315,
            "creditable" : true,
            "gid" : "68c66335-c83e-49b9-8400-831788d792ff"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "electric sitar",
            "name" : "electric sitar",
            "id" : 316,
            "creditable" : true,
            "gid" : "d7977da9-ed10-441a-b4e3-a64277db2cb6"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "kinnor",
            "name" : "kinnor",
            "id" : 317,
            "creditable" : true,
            "gid" : "c0727528-4b67-4e8f-9494-22ecf9816fd7"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "kithara",
            "name" : "kithara",
            "id" : 318,
            "creditable" : true,
            "gid" : "dbf82b8f-1bc5-4a7d-9811-48e743546442"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "langeleik",
            "name" : "langeleik",
            "id" : 319,
            "creditable" : true,
            "gid" : "fd687fde-bb99-4bcd-8676-4ae4aa2fdfac"
         },
         {
            "l_name" : "đàn tranh",
            "name" : "đàn tranh",
            "unaccented" : "dan tranh",
            "description" : "The đàn tranh is a a long Vietnamese zither with sixteen strings and high, movable bridges. The strings are plucked with plectrums, while the left hand is used for ornamenting the notes by pressing the strings.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 320,
            "creditable" : true,
            "gid" : "b95fb59c-cb20-4bb7-bc11-8ab782d480f0"
         },
         {
            "l_name" : "đàn bầu",
            "name" : "đàn bầu",
            "unaccented" : "dan bau",
            "description" : "The đàn bầu is a one-stringed Vietnamese zither.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 321,
            "creditable" : true,
            "gid" : "75ef0f2e-0ca2-48ef-9a1c-56f23a900652"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "struck string instruments",
            "name" : "struck string instruments",
            "id" : 322,
            "creditable" : true,
            "gid" : "8f59848c-c7f4-458f-8fc6-d3b7fc252c3f"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "Warr guitar",
            "name" : "Warr guitar",
            "id" : 323,
            "creditable" : true,
            "gid" : "1e49948d-7522-4444-aa5d-633dfbeffb1f"
         },
         {
            "l_name" : "yangqin",
            "name" : "yangqin",
            "description" : "The yangqin is a Chinese hammered dulcimer.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 324,
            "creditable" : true,
            "gid" : "154ef6da-72e7-4c28-bf98-cf260f145a43"
         },
         {
            "l_name" : "santur",
            "name" : "santur",
            "description" : "Santur, Middle Eastern",
            "freeText" : false,
            "rootID" : 14,
            "id" : 325,
            "creditable" : true,
            "gid" : "29480d87-363a-467b-9950-058c0fe86fe6"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "cymbalum",
            "name" : "cymbalum",
            "id" : 326,
            "creditable" : true,
            "gid" : "65194192-8cc9-48c2-ae47-7da3bb934e30"
         },
         {
            "l_name" : "đàn tam thập lục",
            "name" : "đàn tam thập lục",
            "unaccented" : "dan tam thap luc",
            "description" : "The đàn tam thập lục is a relatively recent imported addition to Vietnamese instruments. A dulcimer with thirty-six strings, struck with two small rubber-clad dubs. It has many counterparts in various countries, such as the \"santoor\" in India and also the \"cimbalon\" in Hungary.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 327,
            "creditable" : true,
            "gid" : "27cb4a0f-bdfa-4b1d-8b78-3768063154e3"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "toy piano",
            "name" : "toy piano",
            "id" : 328,
            "creditable" : true,
            "gid" : "bbd63209-8a4e-46b7-9527-1dd80629a8e0"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "electric piano",
            "name" : "electric piano",
            "id" : 329,
            "creditable" : true,
            "gid" : "75b8297f-d9fe-455d-85cf-d62843f14da5"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "Chamberlin",
            "name" : "Chamberlin",
            "id" : 330,
            "creditable" : true,
            "gid" : "0ec79cfa-0ace-491a-8ba4-8ef7843c6ef5"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "tiple",
            "name" : "tiple",
            "id" : 331,
            "creditable" : true,
            "gid" : "5a671386-5e8f-4381-8b0e-b9b0a9e56e60"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "Spanish vihuela",
            "name" : "Spanish vihuela",
            "id" : 332,
            "creditable" : true,
            "gid" : "298ee599-e2b1-4cc1-b579-5e1c90153004"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "tambourine",
            "name" : "tambourine",
            "id" : 333,
            "creditable" : true,
            "gid" : "4431f7b0-69a4-49ee-b84f-15dda19fb70c"
         },
         {
            "l_name" : "kortholt",
            "name" : "kortholt",
            "description" : "The kortholt ia a woodwind instrument that was popular in the Renaissance period.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 334,
            "creditable" : true,
            "gid" : "1224a91c-5ba1-4f86-baf2-0a5b809f41e8"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "djembe",
            "name" : "djembe",
            "id" : 335,
            "creditable" : true,
            "gid" : "f4e6ad5f-a0c2-4974-8607-df65e7e2c11b"
         },
         {
            "l_name" : "đại cô/tiểu cô",
            "name" : "đại cô/tiểu cô",
            "unaccented" : "dai co/tieu co",
            "description" : "variously sized drums",
            "freeText" : false,
            "rootID" : 14,
            "id" : 336,
            "creditable" : true,
            "gid" : "0adb2d21-a131-4dfd-b8f0-23a8cad8d6a6"
         },
         {
            "l_name" : "mõ",
            "name" : "mõ",
            "unaccented" : "mo",
            "description" : "The mõ is a Vietnamese idiophone consisting of a hollow piece of wood with slits which is played with drumsticks.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 337,
            "creditable" : true,
            "gid" : "22fc02a8-0f6e-4b69-895b-b4db47cc8eac"
         },
         {
            "l_name" : "goblet drum",
            "name" : "goblet drum",
            "description" : "Goblet drums are single-headed drums with a goblet shaped body.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 338,
            "creditable" : true,
            "gid" : "909f7bde-b162-450f-9252-6fb81cc85b9b"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "gongs",
            "name" : "gongs",
            "id" : 339,
            "creditable" : true,
            "gid" : "bf833d87-2ec0-4a2f-a6e1-324bfb2f2505"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "gong",
            "name" : "gong",
            "id" : 340,
            "creditable" : true,
            "gid" : "21e8f13c-aca2-4a34-83a3-951cc347c14a"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "cymbals",
            "name" : "cymbals",
            "id" : 342,
            "creditable" : true,
            "gid" : "0fe1a768-45ba-49e4-8363-14db8e73ca85"
         },
         {
            "l_name" : "não bạt / chập chõa",
            "name" : "não bạt / chập chõa",
            "unaccented" : "nao bat / chap choa",
            "description" : "Various types of cymbal. Also called chũm chọe",
            "freeText" : false,
            "rootID" : 14,
            "id" : 343,
            "creditable" : true,
            "gid" : "8ea17c05-096a-4d51-a4c1-67819bdfa0cc"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "steelpan",
            "name" : "steelpan",
            "id" : 344,
            "creditable" : true,
            "gid" : "2bf75d8e-68f0-4e58-8042-3835265034c1"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "whistle",
            "name" : "whistle",
            "id" : 345,
            "creditable" : true,
            "gid" : "3d7aca42-f7a7-46d8-9531-d39841a8aa6d"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "handbells",
            "name" : "handbells",
            "id" : 346,
            "creditable" : true,
            "gid" : "ee376c6e-128d-45be-b060-35e9655a612f"
         },
         {
            "l_name" : "sênh tiền",
            "name" : "sênh tiền",
            "unaccented" : "senh tien",
            "description" : "The sênh tiền is a Vietnamese instrument which is a combination of clappers, a rasp and a jingle, made from three pieces of wood with old Chinese coins attached.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 347,
            "creditable" : true,
            "gid" : "67115113-23f7-4080-a454-c4575b101c70"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "Moog",
            "name" : "Moog",
            "id" : 348,
            "creditable" : true,
            "gid" : "c2c3a433-dc4b-4107-9d39-1f605ebedbaa"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "Minimoog",
            "name" : "Minimoog",
            "id" : 349,
            "creditable" : true,
            "gid" : "44b6cb78-ac8c-4caa-bde1-747802a3b130"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "Tibetan water drum",
            "name" : "Tibetan water drum",
            "id" : 350,
            "creditable" : true,
            "gid" : "310cb712-c512-419f-9b61-ab77325b6636"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "waterphone",
            "name" : "waterphone",
            "id" : 351,
            "creditable" : true,
            "gid" : "4cdeebe9-aaa5-4f13-9842-77a387d890ce"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "omnichord",
            "name" : "omnichord",
            "id" : 352,
            "creditable" : true,
            "gid" : "a40f824f-8489-4bb1-b21c-dd5d1a914b35"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "vocoder",
            "name" : "vocoder",
            "id" : 354,
            "creditable" : true,
            "gid" : "1d04494c-a06b-409e-9a95-bde7a94860dd"
         },
         {
            "l_name" : "k'lông pút",
            "name" : "k'lông pút",
            "unaccented" : "k'long put",
            "description" : "The k'lông pút is an instrument from the central highlands of Vietnam played by ethnic groups such as the Xơ Đăng and the Bahnar. It consists of a number of different sized bamboo tubes laid horizontally which are played by the musician clapping their slightly cupped hands in front of the tubes in order to push air into the tubes.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 355,
            "creditable" : true,
            "gid" : "40a1d1d3-ecba-4bb2-b35f-7424541f8887"
         },
         {
            "l_name" : "song loan",
            "name" : "song loan",
            "description" : "The song loan is a traditional Vietnamese instrument consisting of a hollow wooden body (about 7 cm in diameter) attached to a flexible spring with a wooden ball on the other end and played with the foot.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 356,
            "creditable" : true,
            "gid" : "147b8ca4-462b-4301-98a2-5df86700d30e"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "glass (h)armonica",
            "name" : "glass (h)armonica",
            "id" : 357,
            "creditable" : true,
            "gid" : "10ee2ae4-d9b6-46af-9250-6d853af7051e"
         },
         {
            "l_name" : "santoor",
            "name" : "santoor",
            "description" : "Santoor, Indian dulcimer",
            "freeText" : false,
            "rootID" : 14,
            "id" : 358,
            "creditable" : true,
            "gid" : "9ace3b20-ff09-4a53-b737-79f9dc1ca90b"
         },
         {
            "l_name" : "khim",
            "name" : "khim",
            "description" : "The khim is a hammered dulcimer from Thailand and Cambodia.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 359,
            "creditable" : true,
            "gid" : "9c2b7d88-b301-4dca-9f7c-014a210d0da5"
         },
         {
            "l_name" : "kanun",
            "name" : "kanun",
            "description" : "Kanun, Arabic plucked strings",
            "freeText" : false,
            "rootID" : 14,
            "id" : 360,
            "creditable" : true,
            "gid" : "896a4fc8-d9c2-4e02-9c34-9b6fb135c739"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "garklein recorder",
            "name" : "garklein recorder",
            "id" : 361,
            "creditable" : true,
            "gid" : "0de793bc-e676-4b26-bb55-ae5979cd6bfc"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "sopranino recorder",
            "name" : "sopranino recorder",
            "id" : 362,
            "creditable" : true,
            "gid" : "db7a69ea-4cae-44ed-94ab-a112b6bd7a3c"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "treble recorder / alto recorder",
            "name" : "treble recorder / alto recorder",
            "id" : 363,
            "creditable" : true,
            "gid" : "1a625158-8e67-49b4-9dd5-fa6a0208bdcf"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "tenor recorder",
            "name" : "tenor recorder",
            "id" : 364,
            "creditable" : true,
            "gid" : "4a6559f5-cbd3-4f72-8386-af028547ff30"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "bass recorder / f-bass recorder",
            "name" : "bass recorder / f-bass recorder",
            "id" : 365,
            "creditable" : true,
            "gid" : "1787a64f-f495-4829-96c6-39b000cbe6b0"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "great bass recorder / c-bass recorder",
            "name" : "great bass recorder / c-bass recorder",
            "id" : 366,
            "creditable" : true,
            "gid" : "27dfceab-1f17-4e62-a300-834836f77ae7"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "contrabass recorder",
            "name" : "contrabass recorder",
            "id" : 367,
            "creditable" : true,
            "gid" : "f91f2462-7227-4897-9dcf-495febbc05aa"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "subcontrabass recorder",
            "name" : "subcontrabass recorder",
            "id" : 368,
            "creditable" : true,
            "gid" : "0385a06d-dbed-4112-bfab-31b78590dd8f"
         },
         {
            "l_name" : "nai",
            "name" : "nai",
            "description" : "Nai, Romanian Panflute",
            "freeText" : false,
            "rootID" : 14,
            "id" : 369,
            "creditable" : true,
            "gid" : "423760ab-c428-41c9-8dcc-986302448889"
         },
         {
            "l_name" : "syrinx",
            "name" : "syrinx",
            "description" : "Greek Panflute",
            "freeText" : false,
            "rootID" : 14,
            "id" : 370,
            "creditable" : true,
            "gid" : "ca17a349-e0e3-4b9b-b74d-898a2b54b43e"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "vacuum cleaner",
            "name" : "vacuum cleaner",
            "id" : 375,
            "creditable" : true,
            "gid" : "a2d87653-559a-4c8e-9cb0-f72effb8df8f"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "chromatic harmonica",
            "name" : "chromatic harmonica",
            "id" : 376,
            "creditable" : true,
            "gid" : "70230603-783c-4665-b518-94f427164c29"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "baritone guitar",
            "name" : "baritone guitar",
            "id" : 377,
            "creditable" : true,
            "gid" : "31c3f6cc-d49c-4d63-8b85-576a545d33f2"
         },
         {
            "l_name" : "phách",
            "name" : "phách",
            "unaccented" : "phach",
            "description" : "Phách are small wooden sticks beaten on a small piece of bamboo or a wooden block. The sound produced is used to keep time.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 379,
            "creditable" : true,
            "gid" : "8e3196e6-2720-4562-8877-3cced6cdb063"
         },
         {
            "l_name" : "kèn bầu",
            "name" : "kèn bầu",
            "unaccented" : "ken bau",
            "description" : "The kèn bầu is a double reed instrument from Vietnam.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 380,
            "creditable" : true,
            "gid" : "93edb5e2-d047-486f-90f3-809708f7ba2d"
         },
         {
            "l_name" : "t'rưng",
            "name" : "t'rưng",
            "unaccented" : "t'rung",
            "description" : "The t'rưng is a bamboo xylophone from the central highlands of Vietnam which is played by ethnic groups such as the Bahnar and the Ê Đê.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 381,
            "creditable" : true,
            "gid" : "4c44a7c0-6b80-4ea8-bf6c-dda8b10d6c96"
         },
         {
            "l_name" : "trống bông",
            "name" : "trống bông",
            "unaccented" : "trong bong",
            "description" : "The trống bông is a wooden Vietnamese drum with a single drumhead which is played with both hands.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 382,
            "creditable" : true,
            "gid" : "ffe6c3f3-12a2-42e7-8cde-7ae24ff83fc5"
         },
         {
            "l_name" : "đing buốt",
            "name" : "đing buốt",
            "unaccented" : "ding buot",
            "description" : "edo village traditional flute, four finger holes, blowing reed",
            "freeText" : false,
            "rootID" : 14,
            "id" : 383,
            "creditable" : true,
            "gid" : "ce8bf63e-ffb2-44e9-a886-16ca6522525f"
         },
         {
            "l_name" : "ki pah",
            "name" : "ki pah",
            "description" : "cow horns without fingerholes. with mouthpiece and free reed",
            "freeText" : false,
            "rootID" : 14,
            "id" : 384,
            "creditable" : true,
            "gid" : "bd5a399f-c18e-41ad-af23-a01353c51d7c"
         },
         {
            "l_name" : "tràm plè",
            "name" : "tràm plè",
            "unaccented" : "tram ple",
            "description" : "a variant of the \"Hmông flute\". flute blowers lips enclose the blowing hole with the vibrating \"free reed\" inside",
            "freeText" : false,
            "rootID" : 14,
            "id" : 385,
            "creditable" : true,
            "gid" : "44c74dce-8a26-4837-9c19-918b412c6a6a"
         },
         {
            "l_name" : "cò ke",
            "name" : "cò ke",
            "unaccented" : "co ke",
            "description" : "The cò ke is an instrument used by the Mường ethnic minority in Vietnam. It is similar to the đàn nhị, consisting of a cylindrical wooden soundbox covered in snakeskin and two strings which are played with a horsehair bow.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 386,
            "creditable" : true,
            "gid" : "1c70cc38-deee-4a84-9b16-7a81c0f43aed"
         },
         {
            "l_name" : "saó ôi flute",
            "name" : "saó ôi flute",
            "unaccented" : "sao oi flute",
            "description" : "saó ôi (flute of the Muong)",
            "freeText" : false,
            "rootID" : 14,
            "id" : 387,
            "creditable" : true,
            "gid" : "478acc37-ae3e-4307-bf64-276bc4705448"
         },
         {
            "l_name" : "kèn lá",
            "name" : "kèn lá",
            "unaccented" : "ken la",
            "description" : "The kèn lá is an instrument used by the Hmong minority of Vietnam which consists of a leaf which is curled up and positioned in the mouth so it vibrates when it is blown.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 388,
            "creditable" : true,
            "gid" : "953e5114-95f3-4415-bff5-38b1b8df0472"
         },
         {
            "l_name" : "hmông flute",
            "name" : "hmông flute",
            "unaccented" : "hmong flute",
            "description" : "family of Hmông flutes",
            "freeText" : false,
            "rootID" : 14,
            "id" : 389,
            "creditable" : true,
            "gid" : "7a5b3204-0200-426c-88d5-3f26a225b757"
         },
         {
            "l_name" : "trắng lu",
            "name" : "trắng lu",
            "unaccented" : "trang lu",
            "freeText" : false,
            "rootID" : 14,
            "id" : 390,
            "creditable" : true,
            "gid" : "fd5caadd-efab-487a-8954-cd243396fbe2"
         },
         {
            "l_name" : "trắng jâu",
            "name" : "trắng jâu",
            "unaccented" : "trang jau",
            "description" : "trắng jâu bass form of trắng lu",
            "freeText" : false,
            "rootID" : 14,
            "id" : 391,
            "creditable" : true,
            "gid" : "8045f4a3-7f12-4de4-957d-26908a2714eb"
         },
         {
            "l_name" : "pang gu ly hu hmông",
            "name" : "pang gu ly hu hmông",
            "unaccented" : "pang gu ly hu hmong",
            "description" : "a kind of a \"slide whistle\" form. Hmông flute",
            "freeText" : false,
            "rootID" : 14,
            "id" : 392,
            "creditable" : true,
            "gid" : "92ec69b8-c35c-4d44-9e99-953d229d6e87"
         },
         {
            "l_name" : "sáo meò",
            "name" : "sáo meò",
            "unaccented" : "sao meo",
            "freeText" : false,
            "rootID" : 14,
            "id" : 393,
            "creditable" : true,
            "gid" : "29872747-b9cf-43f5-a258-0997728ed058"
         },
         {
            "l_name" : "ding tac ta",
            "name" : "ding tac ta",
            "description" : "The ding tac ta is a free reed wind instrument played by the Ê Đê minority in Vietnam. It is made of a bamboo tube with three holes and a gourd wind chamber.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 394,
            "creditable" : true,
            "gid" : "44055718-26b6-4a25-9e76-5067ae5b9862"
         },
         {
            "l_name" : "khèn Mèo",
            "name" : "khèn Mèo",
            "unaccented" : "khen Meo",
            "description" : "The khèn Mèo is a mouth organ used by the Hmong people. It has bamboo pipes (typically six) which each have a free reed.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 395,
            "creditable" : true,
            "gid" : "c4c5d67b-0b98-4865-9d52-1bbdcec74c0e"
         },
         {
            "l_name" : "đing năm",
            "name" : "đing năm",
            "unaccented" : "ding nam",
            "description" : "The đing năm is a <a href=\"https://en.wikipedia.org/wiki/Gourd_mouth_organ\">gourd mouth organ</a> used by minority ethnic groups in the central highlands of Vietnam.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 396,
            "creditable" : true,
            "gid" : "39f40186-44a6-41a3-8c1d-4fd746e663bb"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "brushes",
            "name" : "brushes",
            "id" : 397,
            "creditable" : true,
            "gid" : "8a4a2afb-609e-4316-b7fa-4a687aada9ee"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "handclaps",
            "name" : "handclaps",
            "id" : 398,
            "creditable" : true,
            "gid" : "b8d84cec-ef49-47ec-b754-c1e48146e255"
         },
         {
            "l_name" : "Vietnamese guitar",
            "name" : "Vietnamese guitar",
            "description" : "The Vietnamese guitar is similar to a normal guitar, but with scalloped fingerboard resulting in elevated frets similar to the đàn nguyệt.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 399,
            "creditable" : true,
            "gid" : "4a5a2a59-f5a8-4dc1-95b8-f3b3fb3cf2b6"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "Hawaiian guitar",
            "name" : "Hawaiian guitar",
            "id" : 400,
            "creditable" : true,
            "gid" : "c0ea0405-ae3f-4851-bf85-277fadff80e2"
         },
         {
            "l_name" : "tiêu",
            "name" : "tiêu",
            "unaccented" : "tieu",
            "description" : "The tiêu is a Vietnamese end-blown flute related to the Chinese xiao.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 401,
            "creditable" : true,
            "gid" : "8882d96e-1efc-41b7-811a-b28f269adce0"
         },
         {
            "l_name" : "gumbri",
            "name" : "gumbri",
            "description" : "This is a three-stringed skin-covered bass plucked lute from North-Africa.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 402,
            "creditable" : true,
            "gid" : "39d6fb0f-35a4-4c0a-b6c8-ca210c43f4a7"
         },
         {
            "l_name" : "daf",
            "name" : "daf",
            "description" : "The daf is a large Persian frame drum used in popular and classical music. The frame is usually made of hardwood with many metal ringlets attached and the membrane is usually goatskin.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 403,
            "creditable" : true,
            "gid" : "182121b7-ecec-4a56-a480-563c895225f9"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "ebow",
            "name" : "ebow",
            "id" : 404,
            "creditable" : true,
            "gid" : "bd9789d9-f270-4352-87f6-fc7cc3383b6d"
         },
         {
            "l_name" : "zarb",
            "name" : "zarb",
            "description" : "The zarb is a goblet drum from Persia.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 405,
            "creditable" : true,
            "gid" : "fb2ea66c-ac2e-4ffc-acb3-2ad78a6c515f"
         },
         {
            "l_name" : "riq",
            "name" : "riq",
            "description" : "The riq is a type of tambourine used as a traditional instrument in Arabic music.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 406,
            "creditable" : true,
            "gid" : "0cebfc41-374f-4860-9340-90e4b6515cbe"
         },
         {
            "l_name" : "udu",
            "name" : "udu",
            "description" : "The udu is a Nigerian idiophone consisting of a water jug with an additional hole.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 407,
            "creditable" : true,
            "gid" : "ccb8a525-85e0-4d20-ba76-5730a086cfc1"
         },
         {
            "l_name" : "ghatam",
            "name" : "ghatam",
            "description" : "Ghatam, a South Indian Carnatic music percussion instrument",
            "freeText" : false,
            "rootID" : 14,
            "id" : 408,
            "creditable" : true,
            "gid" : "c5aa7d98-c14d-4ff1-8afb-f8743c62496c"
         },
         {
            "l_name" : "ti bwa",
            "name" : "ti bwa",
            "description" : "ti bwa, percussion instrument made of a piece of bamboo laid horizontally and beaten with sticks",
            "freeText" : false,
            "rootID" : 14,
            "id" : 409,
            "creditable" : true,
            "gid" : "76e5cc5f-aa37-4be3-a035-9e7518250ee5"
         },
         {
            "l_name" : "tanbou ka",
            "name" : "tanbou ka",
            "description" : "Tanbou ka or Tambu ka (a small high-pitched drum)",
            "freeText" : false,
            "rootID" : 14,
            "id" : 410,
            "creditable" : true,
            "gid" : "5f0a32fa-82b2-49da-a9ee-78cad9cf756d"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "rattle",
            "name" : "rattle",
            "id" : 411,
            "creditable" : true,
            "gid" : "ac1e05c2-b4c2-4b0b-a5a8-87b902cefa06"
         },
         {
            "l_name" : "chacha",
            "name" : "chacha",
            "description" : "Chacha, west Indian rattle",
            "freeText" : false,
            "rootID" : 14,
            "id" : 412,
            "creditable" : true,
            "gid" : "27a9b513-5218-404f-a285-02d89aa358df"
         },
         {
            "l_name" : "cajón",
            "name" : "cajón",
            "unaccented" : "cajon",
            "description" : "Cajón, Peruvian box drum",
            "freeText" : false,
            "rootID" : 14,
            "id" : 413,
            "creditable" : true,
            "gid" : "537a8fb2-a92e-420f-b0a8-22a6ed2f038e"
         },
         {
            "l_name" : "đàn tam",
            "name" : "đàn tam",
            "unaccented" : "dan tam",
            "description" : "The đàn tam is a three-stringed fretless lute from Vietnam.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 414,
            "creditable" : true,
            "gid" : "2c8e50c2-f089-45b2-9e3e-7ca795039a7f"
         },
         {
            "l_name" : "chimes",
            "name" : "chimes",
            "description" : "Chime or chimes can refer to multiple different instruments, including tubular bells, wind chime, chime bar and mark tree. Please use the correct instrument if you know which one is intended.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 415,
            "creditable" : true,
            "gid" : "3b8cd68b-aadc-4e43-a13f-e575202d67ea"
         },
         {
            "l_name" : "pí thiu",
            "name" : "pí thiu",
            "unaccented" : "pi thiu",
            "description" : "Pí thiu or Pí khui vertical flute",
            "freeText" : false,
            "rootID" : 14,
            "id" : 416,
            "creditable" : true,
            "gid" : "63f030d8-f116-4f11-9dee-0cb1cfeb8445"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "shakers",
            "name" : "shakers",
            "id" : 417,
            "creditable" : true,
            "gid" : "0d2ef84f-197b-405b-9a7c-293bbe331e30"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "sapek clappers",
            "name" : "sapek clappers",
            "id" : 418,
            "creditable" : true,
            "gid" : "6fad31ea-dca7-4639-a879-062f87c10dfe"
         },
         {
            "l_name" : "darbuka",
            "name" : "darbuka",
            "description" : "The darbuka is an hourglass-shaped goblet drum from Greece, the Middle East and India.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 419,
            "creditable" : true,
            "gid" : "c1002eda-e0b7-48e4-a181-05abddb9b872"
         },
         {
            "l_name" : "bendir",
            "name" : "bendir",
            "description" : "Bendir, frame drum from North Africa, doesn't have jingles",
            "freeText" : false,
            "rootID" : 14,
            "id" : 420,
            "creditable" : true,
            "gid" : "e9bb7775-e8a7-4daa-8c0f-6ef364f105ee"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "frame drum",
            "name" : "frame drum",
            "id" : 421,
            "creditable" : true,
            "gid" : "f7d3dd06-721b-4258-8c5e-cf3b5085b45c"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "transverse flute",
            "name" : "transverse flute",
            "id" : 422,
            "creditable" : true,
            "gid" : "ebc071ab-24b6-4b2f-8981-340f1f76f2bd"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "alto flute",
            "name" : "alto flute",
            "id" : 423,
            "creditable" : true,
            "gid" : "c6e576de-0091-48f3-8d61-b846c4b0da69"
         },
         {
            "l_name" : "theatre organ",
            "name" : "theatre organ",
            "description" : "Theatre organ, such as the Wurlitzer",
            "freeText" : false,
            "rootID" : 14,
            "id" : 426,
            "creditable" : true,
            "gid" : "e632d6e3-23ec-41f5-bcce-79b8e231ce1e"
         },
         {
            "l_name" : "crumhorn",
            "name" : "crumhorn",
            "description" : "Crumhorn used in the 14th to 17th centuries in Europe",
            "freeText" : false,
            "rootID" : 14,
            "id" : 427,
            "creditable" : true,
            "gid" : "e1b9fc01-a349-444f-b798-9893b5af83f4"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "metallophone",
            "name" : "metallophone",
            "id" : 428,
            "creditable" : true,
            "gid" : "906e1945-bfcb-4952-bba5-f43296d7aff6"
         },
         {
            "l_name" : "pipa",
            "name" : "pipa",
            "description" : "The pipa is a four-stringed plucked Chinese instrument with a pear-shaped body.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 429,
            "creditable" : true,
            "gid" : "4ddf3737-9ef2-49c4-9de2-697a19884463"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "concert harp",
            "name" : "concert harp",
            "id" : 431,
            "creditable" : true,
            "gid" : "82ffe485-7729-479e-bf7e-afc5e6db60eb"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "electric harp",
            "name" : "electric harp",
            "id" : 432,
            "creditable" : true,
            "gid" : "0326482a-37a4-40b1-bb06-06643865968e"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "folk harp",
            "name" : "folk harp",
            "id" : 433,
            "creditable" : true,
            "gid" : "34c1af71-f7fc-4e34-a46a-5c29ee4c019b"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "wire-strung harp",
            "name" : "wire-strung harp",
            "id" : 434,
            "creditable" : true,
            "gid" : "65116580-10f5-4123-9d86-5e379cd9ab83"
         },
         {
            "l_name" : "Irish harp / clàrsach",
            "name" : "Irish harp / clàrsach",
            "unaccented" : "Irish harp / clarsach",
            "description" : "An Irish/Scottish harp.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 435,
            "creditable" : true,
            "gid" : "e9b4bcb7-4731-42c3-9464-9d58fb12ec2d"
         },
         {
            "l_name" : "German harp",
            "name" : "German harp",
            "description" : "German/Bohemian harp",
            "freeText" : false,
            "rootID" : 14,
            "id" : 436,
            "creditable" : true,
            "gid" : "bc542c3c-5cf6-4c31-b75f-a03d660cad75"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "bones",
            "name" : "bones",
            "id" : 437,
            "creditable" : true,
            "gid" : "4710ed73-78e7-4ba4-8c02-5bc2da1f611b"
         },
         {
            "l_name" : "Northumbrian pipes",
            "name" : "Northumbrian pipes",
            "description" : "Northumbrian (small)pipes",
            "freeText" : false,
            "rootID" : 14,
            "id" : 438,
            "creditable" : true,
            "gid" : "356efa34-ceb1-4476-ba03-42d4bcd4e0e7"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "piano accordion",
            "name" : "piano accordion",
            "id" : 439,
            "creditable" : true,
            "gid" : "ba4550e2-5bf1-4778-a3b7-1e5552d6dba9"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "button accordion",
            "name" : "button accordion",
            "id" : 440,
            "creditable" : true,
            "gid" : "36f5262c-2761-4de7-9733-f0b89deeaed6"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "diatonic accordion / melodeon",
            "name" : "diatonic accordion / melodeon",
            "id" : 441,
            "creditable" : true,
            "gid" : "842d3d24-f638-47e6-a239-8578723db09c"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "keyboard bass",
            "name" : "keyboard bass",
            "id" : 442,
            "creditable" : true,
            "gid" : "3ac17d91-feb7-4c2e-9b74-5aa7c73c8e16"
         },
         {
            "l_name" : "amadinda",
            "name" : "amadinda",
            "description" : "Amadinda, southern Uganda giant xylophone, made on with resonating hardwood bars",
            "freeText" : false,
            "rootID" : 14,
            "id" : 443,
            "creditable" : true,
            "gid" : "73332fb8-bbf5-4094-a3ae-e636ae5cfcf6"
         },
         {
            "l_name" : "balafon",
            "name" : "balafon",
            "description" : "Balafon, Malian 'gourd xylophone'",
            "freeText" : false,
            "rootID" : 14,
            "id" : 444,
            "creditable" : true,
            "gid" : "a48d42b3-0fa9-45f2-933d-2770f4ca273f"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "gamelan",
            "name" : "gamelan",
            "id" : 445,
            "creditable" : true,
            "gid" : "a26a663e-3add-42e1-ac07-ce289d5f330a"
         },
         {
            "l_name" : "slit drum",
            "name" : "slit drum",
            "description" : "Slit drum, hollowed out tree with slits",
            "freeText" : false,
            "rootID" : 14,
            "id" : 446,
            "creditable" : true,
            "gid" : "1a03e9a1-f81f-40ce-9d57-65d6c1b9dcb3"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "vessel drum",
            "name" : "vessel drum",
            "id" : 447,
            "creditable" : true,
            "gid" : "1fc7aaea-f808-4f37-9429-a85dd89d1764"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "frottoir",
            "name" : "frottoir",
            "id" : 448,
            "creditable" : true,
            "gid" : "c6842ddb-3226-49c0-b7af-37ebc607dc85"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "rhythm sticks",
            "name" : "rhythm sticks",
            "id" : 449,
            "creditable" : true,
            "gid" : "f1e042f5-2a09-47b1-9cdf-1018d239d330"
         },
         {
            "l_name" : "sistrum",
            "name" : "sistrum",
            "description" : "The sistrum is a metal rattle associated with ancient Iraq and Egypt.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 450,
            "creditable" : true,
            "gid" : "760558ba-a02a-4692-9046-b819cf75836f"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "bamboo angklung",
            "name" : "bamboo angklung",
            "id" : 451,
            "creditable" : true,
            "gid" : "ebf4cb51-93b1-44ec-8e68-c92098b3e8d4"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "metal angklung",
            "name" : "metal angklung",
            "id" : 452,
            "creditable" : true,
            "gid" : "219a4468-1e33-4718-987d-85102dccf544"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "ankle rattlers",
            "name" : "ankle rattlers",
            "id" : 453,
            "creditable" : true,
            "gid" : "7aed0189-ff99-4b43-8ff0-52ca5626d0b7"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "wavedrum",
            "name" : "wavedrum",
            "id" : 454,
            "creditable" : true,
            "gid" : "53174999-953d-482b-9240-23acf2452fc9"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "rainstick",
            "name" : "rainstick",
            "id" : 455,
            "creditable" : true,
            "gid" : "2b2fa61b-2eae-4bf1-a0c0-37c5638b0660"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "ocean drum",
            "name" : "ocean drum",
            "id" : 456,
            "creditable" : true,
            "gid" : "1a994b2a-c93e-4543-81f4-c5924c4ed9be"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "talking drum",
            "name" : "talking drum",
            "id" : 457,
            "creditable" : true,
            "gid" : "3b6d0bdc-2e39-424f-81d9-098be2efa707"
         },
         {
            "l_name" : "taiko",
            "name" : "taiko",
            "description" : "Japanese traditional drum beaten with sticks called bachi.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 458,
            "creditable" : true,
            "gid" : "69e695d1-e4e0-4c18-9b9a-134b189ca2bc"
         },
         {
            "l_name" : "surdo",
            "name" : "surdo",
            "description" : "The surdo is a large bass drum used in Brazilian music, most notably samba.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 459,
            "creditable" : true,
            "gid" : "a7e6594b-d952-4732-9410-3eb41a60605c"
         },
         {
            "l_name" : "bin-sasara",
            "name" : "bin-sasara",
            "description" : "The binzasara is a Japanese percussion instrument made of many small slats of wood connected by a spine of string with handles at each end.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 460,
            "creditable" : true,
            "gid" : "b4304bab-60a9-41b8-9b00-8da222fa4206"
         },
         {
            "l_name" : "shekere",
            "name" : "shekere",
            "description" : "The shekere is a shaker from West Africa consisting of a gourd with beads woven into a net which covers the gourd.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 462,
            "creditable" : true,
            "gid" : "e23fb2a1-69bf-4c6e-baef-cf51f19a1b24"
         },
         {
            "l_name" : "dholak",
            "name" : "dholak",
            "description" : "dholak, classical North Indian hand drum",
            "freeText" : false,
            "rootID" : 14,
            "id" : 463,
            "creditable" : true,
            "gid" : "96c87e0e-4a33-4abe-b6fb-e7a3a3f67229"
         },
         {
            "l_name" : "gankogui",
            "name" : "gankogui",
            "description" : "Gankogui, iron bell",
            "freeText" : false,
            "rootID" : 14,
            "id" : 464,
            "creditable" : true,
            "gid" : "04e048dc-6aa6-4f6b-8d17-8180f7216003"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "fortepiano",
            "name" : "fortepiano",
            "id" : 465,
            "creditable" : true,
            "gid" : "814b1c15-1f5c-470d-ab8f-5e7615ff8586"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "lap steel guitar",
            "name" : "lap steel guitar",
            "id" : 466,
            "creditable" : true,
            "gid" : "857ff05c-5367-4ba2-9b49-98eefa2badcc"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "resonator guitar",
            "name" : "resonator guitar",
            "id" : 467,
            "creditable" : true,
            "gid" : "4ffe5341-4d63-4b1f-8b00-b008954bc7a4"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "table steel guitar",
            "name" : "table steel guitar",
            "id" : 468,
            "creditable" : true,
            "gid" : "8ecb065e-fa6a-4009-98bd-bd742307d0e8"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "pedal steel guitar",
            "name" : "pedal steel guitar",
            "id" : 469,
            "creditable" : true,
            "gid" : "4a10b219-65ac-4b6c-950d-acc8461266c7"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "electric lap steel guitar",
            "name" : "electric lap steel guitar",
            "id" : 470,
            "creditable" : true,
            "gid" : "3c5349ca-cf82-4537-851f-1957ac88bced"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "continuum",
            "name" : "continuum",
            "id" : 471,
            "creditable" : true,
            "gid" : "295ac276-dd44-4d96-96ff-e2ba104ba00c"
         },
         {
            "l_name" : "tambura",
            "name" : "tambura",
            "description" : "Tambura, Tanbura or Tamboura",
            "freeText" : false,
            "rootID" : 14,
            "id" : 473,
            "creditable" : true,
            "gid" : "b9362496-01a3-4298-b369-84313cec5ee1"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "tamburitza",
            "name" : "tamburitza",
            "id" : 474,
            "creditable" : true,
            "gid" : "4568d593-e1d5-4516-bbe9-391adc016155"
         },
         {
            "l_name" : "bandura",
            "name" : "bandura",
            "description" : "Bandura, ukrainian 14th century lute",
            "freeText" : false,
            "rootID" : 14,
            "id" : 475,
            "creditable" : true,
            "gid" : "5175556a-ac06-4d29-b8fd-61fa0b707e36"
         },
         {
            "l_name" : "bandura",
            "name" : "bandura",
            "description" : "Bandura, modern day Ukraininan zither",
            "freeText" : false,
            "rootID" : 14,
            "id" : 476,
            "creditable" : true,
            "gid" : "3c84f7d8-c8c1-4ec5-8e71-4bc9a1625e10"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "theorbo",
            "name" : "theorbo",
            "id" : 478,
            "creditable" : true,
            "gid" : "1a9bc5e0-b9f4-46df-8b64-4000b2253211"
         },
         {
            "l_name" : "banjitar",
            "name" : "banjitar",
            "description" : "The banjitar is a six-string banjo with the neck of a guitar.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 479,
            "creditable" : true,
            "gid" : "b62ace3b-47e7-4319-8a3e-1b035ccd20b2"
         },
         {
            "l_name" : "duduk",
            "name" : "duduk",
            "description" : "The duduk is a traditional Armenian double reed woodwind instrument.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 480,
            "creditable" : true,
            "gid" : "e5e6de9d-bde7-4340-a591-f1c55c658c2c"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "low whistle",
            "name" : "low whistle",
            "id" : 482,
            "creditable" : true,
            "gid" : "862730d6-83bb-4e75-a686-6b0ca576005c"
         },
         {
            "l_name" : "dohol",
            "name" : "dohol",
            "description" : "Dohol, traditional Iranian drum",
            "freeText" : false,
            "rootID" : 14,
            "id" : 483,
            "creditable" : true,
            "gid" : "8637075b-7d48-4093-ac36-a39e58636048"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "bass pedals",
            "name" : "bass pedals",
            "id" : 484,
            "creditable" : true,
            "gid" : "bc826dde-9200-43ad-81af-6ef2c52ca37b"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "piccolo trumpet",
            "name" : "piccolo trumpet",
            "id" : 486,
            "creditable" : true,
            "gid" : "9d718374-101c-495b-9402-7e3a5f2a3d0e"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "electronic drum set",
            "name" : "electronic drum set",
            "id" : 487,
            "creditable" : true,
            "gid" : "174d408c-2e3c-4dd6-aeee-3583ea9b206e"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "soprano clarinet",
            "name" : "soprano clarinet",
            "id" : 488,
            "creditable" : true,
            "gid" : "7a102d81-9c6c-446d-8560-4876cbe7a70a"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "basset clarinet",
            "name" : "basset clarinet",
            "id" : 489,
            "creditable" : true,
            "gid" : "2c4d2aa6-594f-4312-a317-7c201ae12de6"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "basset horn",
            "name" : "basset horn",
            "id" : 490,
            "creditable" : true,
            "gid" : "f93d6f87-6447-4d10-8bfd-08500dfcdb33"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "Irish bouzouki",
            "name" : "Irish bouzouki",
            "id" : 491,
            "creditable" : true,
            "gid" : "c0cffc5c-4473-4c11-a236-242462ab13f4"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "zurna",
            "name" : "zurna",
            "id" : 492,
            "creditable" : true,
            "gid" : "0666c718-137e-4cc6-881d-fc6430d7dea4"
         },
         {
            "l_name" : "shawm",
            "name" : "shawm",
            "description" : "Shawm, Medieval and Renaissance instrument, predecessor to the oboe",
            "freeText" : false,
            "rootID" : 14,
            "id" : 493,
            "creditable" : true,
            "gid" : "b4f112c3-d666-47f2-bb85-bae28572ca13"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "autoharp",
            "name" : "autoharp",
            "id" : 494,
            "creditable" : true,
            "gid" : "dc17c2a5-a7be-4b78-a0c1-4aceee0875e1"
         },
         {
            "l_name" : "cümbüş",
            "name" : "cümbüş",
            "unaccented" : "cumbus",
            "freeText" : false,
            "rootID" : 14,
            "id" : 495,
            "creditable" : true,
            "gid" : "3b0b9c99-ea82-4716-8c11-c86c8dd99218"
         },
         {
            "l_name" : "davul",
            "name" : "davul",
            "description" : "Davul, turkish drum",
            "freeText" : false,
            "rootID" : 14,
            "id" : 496,
            "creditable" : true,
            "gid" : "681639fb-9112-4b94-88b1-f78ef36465c0"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "treble flute",
            "name" : "treble flute",
            "id" : 497,
            "creditable" : true,
            "gid" : "1456509e-1a34-469d-a899-e195a0afe183"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "soprano flute",
            "name" : "soprano flute",
            "id" : 498,
            "creditable" : true,
            "gid" : "b524b7a7-2d87-43a7-9977-8a9081ff6e0f"
         },
         {
            "l_name" : "concert flute",
            "name" : "concert flute",
            "description" : "The concert flute is the most common variant of the flute and is commonly referred to as just \"flute\".",
            "freeText" : false,
            "rootID" : 14,
            "id" : 499,
            "creditable" : true,
            "gid" : "3274e7ce-8487-4258-8706-4447c65c34e5"
         },
         {
            "l_name" : "flûte d'amour",
            "name" : "flûte d'amour",
            "unaccented" : "flute d'amour",
            "description" : "The flûte d'amour is the mezzo-soprano instrument of the flute family.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 500,
            "creditable" : true,
            "gid" : "3decd8ad-623a-482f-a8e5-27e2450e75c7"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "bass flute",
            "name" : "bass flute",
            "id" : 501,
            "creditable" : true,
            "gid" : "c3fddfb8-100a-4e25-897f-9129d5a6c39f"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "Indian bamboo flutes",
            "name" : "Indian bamboo flutes",
            "id" : 502,
            "creditable" : true,
            "gid" : "8abe1fd0-f17b-4c91-ab29-bc23d164bb95"
         },
         {
            "l_name" : "venu",
            "name" : "venu",
            "description" : "The venu is a bamboo transverse flute used in the Carnatic music of South India.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 503,
            "creditable" : true,
            "gid" : "ee71289c-5a64-4dbc-b623-af1c7d2ff7bd"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "boatswain's pipe",
            "name" : "boatswain's pipe",
            "id" : 504,
            "creditable" : true,
            "gid" : "ae8e7fca-0be6-4cbc-9f53-7b2263e910ef"
         },
         {
            "l_name" : "violone",
            "name" : "violone",
            "description" : "Violone, The largest/deepest member of the Viol family",
            "freeText" : false,
            "rootID" : 14,
            "id" : 505,
            "creditable" : true,
            "gid" : "cb2793f8-cbab-4eec-b54c-b5ee77956caf"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "Baltic psalteries",
            "name" : "Baltic psalteries",
            "id" : 506,
            "creditable" : true,
            "gid" : "5bf8e03f-990c-4c9b-b648-ba4a0d2fa524"
         },
         {
            "l_name" : "kanklės",
            "name" : "kanklės",
            "unaccented" : "kankles",
            "description" : "Kanklės, Lithuanian plucked string",
            "freeText" : false,
            "rootID" : 14,
            "id" : 507,
            "creditable" : true,
            "gid" : "e21ce008-8744-407b-ad7c-5caa3f69e610"
         },
         {
            "l_name" : "gusli",
            "name" : "gusli",
            "description" : "Gusli, an ancient Slavic musical instrument, Russian",
            "freeText" : false,
            "rootID" : 14,
            "id" : 508,
            "creditable" : true,
            "gid" : "bb08cebd-ff6c-49e8-8f8f-914cc2d68c27"
         },
         {
            "l_name" : "kantele",
            "name" : "kantele",
            "description" : "Kantele, Finnish traditional plucked string",
            "freeText" : false,
            "rootID" : 14,
            "id" : 509,
            "creditable" : true,
            "gid" : "d96160fe-57f5-4dc0-a6ae-bc05314f9743"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "tangent piano",
            "name" : "tangent piano",
            "id" : 510,
            "creditable" : true,
            "gid" : "34be09ba-f2e4-47c7-82b3-c9c43108d510"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "baglama",
            "name" : "baglama",
            "id" : 512,
            "creditable" : true,
            "gid" : "f83c4b45-3584-401a-90bf-4ec80e7add78"
         },
         {
            "l_name" : "Scottish smallpipes",
            "name" : "Scottish smallpipes",
            "description" : "Like (and developed from) the Northumbrian smallpipes, but with Great Highland Bagpipe fingering.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 513,
            "creditable" : true,
            "gid" : "c8ea4d81-ec45-489e-8f68-1616f36966e3"
         },
         {
            "l_name" : "bellow-blown bagpipes",
            "name" : "bellow-blown bagpipes",
            "description" : "Bagpipes played by pumping air into a bellow and then from the bellow into the chanter(s).",
            "freeText" : false,
            "rootID" : 14,
            "id" : 514,
            "creditable" : true,
            "gid" : "d4cbc6fd-5e68-4cf4-afeb-dd2fb4df3c2d"
         },
         {
            "l_name" : "practice chanter",
            "name" : "practice chanter",
            "description" : "Looks like a recorder, but with double reeds and bagpipe fingering system. Mostly used to learn how to play the pipes, but are occasionally played in their own right.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 515,
            "creditable" : true,
            "gid" : "7d401fc3-21ae-4299-abf9-075152446368"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "bass drum",
            "name" : "bass drum",
            "id" : 518,
            "creditable" : true,
            "gid" : "e78b40c0-acc8-4db8-911a-adf991e0c73d"
         },
         {
            "l_name" : "bombarde",
            "name" : "bombarde",
            "description" : "conical bore double-reed musical instrument from Brittany",
            "freeText" : false,
            "rootID" : 14,
            "id" : 519,
            "creditable" : true,
            "gid" : "07ef7707-ab79-4a23-b2e3-260a46b26ec7"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "bayan",
            "name" : "bayan",
            "id" : 520,
            "creditable" : true,
            "gid" : "087fd82c-cbf6-4e46-8f7c-11ef3a63cbd9"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "chromatic button accordion",
            "name" : "chromatic button accordion",
            "id" : 521,
            "creditable" : true,
            "gid" : "e5cab458-2079-4eb3-bd0e-e63aba7d9162"
         },
         {
            "l_name" : "tenor guitar",
            "name" : "tenor guitar",
            "description" : "Slightly smaller, four-string version of the steel-string acoustic guitar or electric guitar",
            "freeText" : false,
            "rootID" : 14,
            "id" : 522,
            "creditable" : true,
            "gid" : "a1baa57d-6ab4-461e-89df-448d6fd2c597"
         },
         {
            "l_name" : "fretless bass",
            "name" : "fretless bass",
            "description" : "variety of bass guitars without frets",
            "freeText" : false,
            "rootID" : 14,
            "id" : 523,
            "creditable" : true,
            "gid" : "96bec768-bee7-4b67-816e-3b4743df98ec"
         },
         {
            "l_name" : "chalumeau",
            "name" : "chalumeau",
            "description" : "The chalumeau is a single-reed woodwind instrument of the late baroque and early classical era.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 524,
            "creditable" : true,
            "gid" : "e3511ed1-3d73-4340-880f-c8ccc8eda11c"
         },
         {
            "l_name" : "quena",
            "name" : "quena",
            "description" : "The quena is a traditional bamboo flute from the Andes.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 528,
            "creditable" : true,
            "gid" : "52009a6c-156b-40d4-abf5-c46084a7a69b"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "12 string guitar",
            "name" : "12 string guitar",
            "id" : 529,
            "creditable" : true,
            "gid" : "d5cc3c69-218e-449a-b80d-8bd7a61311a1"
         },
         {
            "l_name" : "cuatro",
            "name" : "cuatro",
            "description" : "A class of South-American guitars",
            "freeText" : false,
            "rootID" : 14,
            "id" : 531,
            "creditable" : true,
            "gid" : "38c897e8-c2ca-46e5-8e85-7aa3f826e93c"
         },
         {
            "l_name" : "taragot",
            "name" : "taragot",
            "description" : "The taragot is a Turkish/Hungarian/Romanian reed instrument related to the saxophone and clarinet.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 532,
            "creditable" : true,
            "gid" : "018753b1-f9d2-4d14-b66e-c348aa49a89c"
         },
         {
            "l_name" : "EWI",
            "name" : "EWI",
            "description" : "EWI (an acronym for electric wind instrument) is the name of Akai's wind controller.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 533,
            "creditable" : true,
            "gid" : "7061c07c-e87a-4f5f-b45f-fb1138733e32"
         },
         {
            "l_name" : "marxophone",
            "name" : "marxophone",
            "description" : "A type of fretless zither.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 534,
            "creditable" : true,
            "gid" : "25cb4a8d-9928-4102-8933-1cc3b0998efe"
         },
         {
            "l_name" : "shruti box",
            "name" : "shruti box",
            "description" : "The shruti box is similar to a harmonium and is used to provide a drone accompaniment.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 535,
            "creditable" : true,
            "gid" : "e6b016f0-61bf-4c5b-99c4-8f8724ad12b5"
         },
         {
            "l_name" : "bass saxophone",
            "name" : "bass saxophone",
            "description" : "The bass saxophone is the second largest existing member of the saxophone family (not counting the subcontrabass tubax). It is similar in design to a baritone saxophone, but it is larger, with a longer loop near the mouthpiece.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 536,
            "creditable" : true,
            "gid" : "9447c0af-5569-48f2-b4c5-241105d58c91"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "sopranino saxophone",
            "name" : "sopranino saxophone",
            "id" : 537,
            "creditable" : true,
            "gid" : "d069369c-cc96-43c9-bfa7-e2074f8949a6"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "contrabass saxophone",
            "name" : "contrabass saxophone",
            "id" : 538,
            "creditable" : true,
            "gid" : "be8d7e28-4f6b-4c0f-b2d0-9694eb4779cc"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "electronic organ",
            "name" : "electronic organ",
            "id" : 539,
            "creditable" : true,
            "gid" : "63d0f29f-37df-4c3e-bb3c-6a7c8f1b4c3d"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "farfisa",
            "name" : "farfisa",
            "id" : 540,
            "creditable" : true,
            "gid" : "40243f27-1011-491b-8b06-28c48749b960"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "finger snaps",
            "name" : "finger snaps",
            "id" : 541,
            "creditable" : true,
            "gid" : "34787aa3-1027-498b-af38-4385665cc34c"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "voice synthesizer",
            "name" : "voice synthesizer",
            "id" : 542,
            "creditable" : true,
            "gid" : "b0f83029-6d38-4f6f-bd30-db44e427f497"
         },
         {
            "l_name" : "Stroh violin",
            "name" : "Stroh violin",
            "description" : "The Stroh violin is a violin with a metal resonator and horn rather than a wooden body.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 543,
            "creditable" : true,
            "gid" : "984e4a24-7d34-4661-a6e4-0a28374ff89f"
         },
         {
            "l_name" : "guzheng",
            "name" : "guzheng",
            "description" : "The guzheng or zheng is a Chinese plucked zither, with 18 to 23 or more strings and movable bridges.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 544,
            "creditable" : true,
            "gid" : "2a01b8d1-7abd-466d-be5f-435263bdd76a"
         },
         {
            "l_name" : "talkbox",
            "name" : "talkbox",
            "description" : "A talkbox is an effects device which enables a musician to modify the sound of an instrument.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 546,
            "creditable" : true,
            "gid" : "9eecc5ee-d625-4330-85dd-a338d80ea433"
         },
         {
            "l_name" : "hi-hat",
            "name" : "hi-hat",
            "description" : "A hi-hat is a typical part of a drum kit, consisting of a pair of cymbals mounted on a stand.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 547,
            "creditable" : true,
            "gid" : "6d328aab-3bee-4d9d-b400-e1e71ff96f37"
         },
         {
            "l_name" : "zill",
            "name" : "zill",
            "description" : "Zills are tiny metallic finger cymbals used in belly dancing and other similar performances.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 548,
            "creditable" : true,
            "gid" : "8fb042f2-32d1-4ab2-9417-e13c6c78f960"
         },
         {
            "l_name" : "bass synthesizer",
            "name" : "bass synthesizer",
            "description" : "A bass synthesizer is used to create sounds in the bass range.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 549,
            "creditable" : true,
            "gid" : "e6571d23-5d79-4216-99d6-06e14e737da1"
         },
         {
            "l_name" : "Batá drum",
            "name" : "Batá drum",
            "unaccented" : "Bata drum",
            "description" : "A Batá drum is a double-headed drum originating from Nigeria.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 550,
            "creditable" : true,
            "gid" : "768fdb8c-494e-4dcd-9400-7345b7c3e399"
         },
         {
            "l_name" : "kaval",
            "name" : "kaval",
            "description" : "The kaval is a chromatic end-blown flute from the Balkans and Anatolia.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 551,
            "creditable" : true,
            "gid" : "e6c0f0f4-9e03-4177-8ccc-c4c99c8a9d83"
         },
         {
            "l_name" : "sarangi",
            "name" : "sarangi",
            "description" : "The sarangi is a short-necked, bowed string instrument from India, Nepal and Pakistan.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 552,
            "creditable" : true,
            "gid" : "79f5331d-d17c-4c2e-8ad0-44144432a754"
         },
         {
            "l_name" : "dizi",
            "name" : "dizi",
            "description" : "The dizi is a Chinese transverse flute typically made of bamboo. In Chinese, it is sometimes just called 笛 (di), but in Japanese 笛 (fue) is a more generic word referring to a whole class of flutes rather than this specific instrument.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 553,
            "creditable" : true,
            "gid" : "d6fa07a5-0060-4288-a974-156905cebcc3"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "finger cymbals",
            "name" : "finger cymbals",
            "id" : 554,
            "creditable" : true,
            "gid" : "74e8088e-d5b0-44bc-853a-74aa8c8aa5aa"
         },
         {
            "l_name" : "tom-tom",
            "name" : "tom-tom",
            "description" : "A tom-tom (or just tom) is a cylindrical drum with no snare, commonly found in a standard drum set.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 555,
            "creditable" : true,
            "gid" : "80eb5b78-b3eb-401a-b774-6a922cfee238"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "tzoura",
            "name" : "tzoura",
            "id" : 556,
            "creditable" : true,
            "gid" : "8bb9074d-5964-48bf-8d62-d8e6e4785e9c"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "musical box",
            "name" : "musical box",
            "id" : 557,
            "creditable" : true,
            "gid" : "2f5f6a67-2b2b-4857-92b0-5b25d485f632"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "bass harmonica",
            "name" : "bass harmonica",
            "id" : 558,
            "creditable" : true,
            "gid" : "a9658be0-ffeb-4b64-ba96-bbe4e3c6db84"
         },
         {
            "l_name" : "charango",
            "name" : "charango",
            "description" : "The charango is a small South American lute.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 559,
            "creditable" : true,
            "gid" : "557e7397-5878-4fc6-9d81-26f542a9f280"
         },
         {
            "l_name" : "tar (lute)",
            "name" : "tar (lute)",
            "description" : "The tar is a long-necked, waisted lute found in Azerbaijan, Iran, Armenia, Georgia, and other areas near the Caucasus region. Not to be confused with the drum of the same name.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 560,
            "creditable" : true,
            "gid" : "dabdeb41-560f-4d84-aa6a-cf22349326fe"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "Wurlitzer electric piano",
            "name" : "Wurlitzer electric piano",
            "id" : 562,
            "creditable" : true,
            "gid" : "faf35fe4-cbd2-497b-a5a3-40bc2c59c446"
         },
         {
            "l_name" : "descant recorder / soprano recorder",
            "name" : "descant recorder / soprano recorder",
            "description" : "A descant or soprano recorder is the most common size of recorder and is often learnt by children.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 563,
            "creditable" : true,
            "gid" : "0d6efd24-2fe8-4a46-b34d-46633e30f642"
         },
         {
            "l_name" : "shinobue",
            "name" : "shinobue",
            "description" : "The shinobue is a high-pitched transverse bamboo flute from Japan.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 564,
            "creditable" : true,
            "gid" : "9880f5b8-bbe9-4415-9dc6-3ec65342de6a"
         },
         {
            "l_name" : "chamber organ",
            "name" : "chamber organ",
            "description" : "A chamber organ is a small pipe organ.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 565,
            "creditable" : true,
            "gid" : "023adf58-6aa2-4659-8760-3b36f81d0352"
         },
         {
            "l_name" : "saz",
            "name" : "saz",
            "description" : "The saz is a long-necked fretted lute",
            "freeText" : false,
            "rootID" : 14,
            "id" : 566,
            "creditable" : true,
            "gid" : "ce9452ac-917f-4cab-ab13-75996816202b"
         },
         {
            "l_name" : "oboe d'amore",
            "name" : "oboe d'amore",
            "description" : "Oboe d'amore / Oboe d'amour (mezzo-soprano)",
            "freeText" : false,
            "rootID" : 14,
            "id" : 581,
            "creditable" : true,
            "gid" : "d43cf2e2-cc1f-4448-97f6-7d291c8ebc87"
         },
         {
            "l_name" : "kanjira",
            "name" : "kanjira",
            "description" : "The kanjira is a South Indian frame drum.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 583,
            "creditable" : true,
            "gid" : "f7306552-f9fc-44f0-8d62-0b48f4c4c278"
         },
         {
            "l_name" : "mridangam",
            "name" : "mridangam",
            "description" : "The mridangam is a double-sided drum from India.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 584,
            "creditable" : true,
            "gid" : "f689271c-37bc-4c49-92a3-a14b15ee5d0e"
         },
         {
            "l_name" : "Saraswati veena",
            "name" : "Saraswati veena",
            "description" : "The Saraswati veena is an Indian plucked stringed instrument used in Carnatic music.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 585,
            "creditable" : true,
            "gid" : "41761936-5dbc-433f-b558-a7ef14fe9b08"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "tanbur",
            "name" : "tanbur",
            "id" : 586,
            "creditable" : true,
            "gid" : "16f816ec-9ecf-4236-8006-19a4b27797f1"
         },
         {
            "l_name" : "foot percussion",
            "name" : "foot percussion",
            "description" : "Percussion performed with the feet, such as <a href=\"http://en.wikipedia.org/wiki/Foot-tapping\">foot tapping</a> and <a href=\"http://en.wikipedia.org/wiki/Clogging\">clogging</a>.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 587,
            "creditable" : true,
            "gid" : "91eb1744-96d8-4c54-8aa2-f97ed7d88950"
         },
         {
            "l_name" : "bell tree",
            "name" : "bell tree",
            "description" : "A bell tree is a percussion instrument, consisting of vertically nested inverted metal bowls.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 588,
            "creditable" : true,
            "gid" : "def0ce61-3d8f-4644-bbee-7c2824fb2787"
         },
         {
            "l_name" : "thavil",
            "name" : "thavil",
            "description" : "The thavil is a barrel shaped drum from South India.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 589,
            "creditable" : true,
            "gid" : "f8cbf484-c96d-4261-a06d-5a097a403956"
         },
         {
            "l_name" : "prepared piano",
            "name" : "prepared piano",
            "description" : "A prepared piano is a piano that has had its sound altered by placing objects (preparations) between or on the strings or on the hammers or dampers.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 590,
            "creditable" : true,
            "gid" : "4d256d61-4f35-49c4-a054-9cb78b417583"
         },
         {
            "l_name" : "Cretan lyra",
            "name" : "Cretan lyra",
            "description" : "The Cretan lyra is a Greek pear-shaped, three-stringed bowed musical instrument, central to the traditional music of Crete and parts of Greece.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 591,
            "creditable" : true,
            "gid" : "4fe225a3-6939-4fab-a416-d0cd38c96cb9"
         },
         {
            "l_name" : "bawu",
            "name" : "bawu",
            "description" : "The bawu is a Chinese wind instrument. Although shaped like a flute, it is actually a free reed instrument, with a single metal reed. It is played in a transverse (horizontal) manner.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 592,
            "creditable" : true,
            "gid" : "2c82a2d3-bead-4acd-8b8a-6ae3c87bd2bb"
         },
         {
            "l_name" : "xiao",
            "name" : "xiao",
            "description" : "The xiao is a Chinese end-blown flute.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 593,
            "creditable" : true,
            "gid" : "649c0df6-18d1-47dd-a96f-6713e7fd9496"
         },
         {
            "l_name" : "domra",
            "name" : "domra",
            "description" : "The domra is a long-necked Russian string instrument of the lute family with a round body and three or four metal strings.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 594,
            "creditable" : true,
            "gid" : "961a2c0d-5ca6-476f-85d2-af19e0559f89"
         },
         {
            "l_name" : "haegeum",
            "name" : "haegeum",
            "description" : "The haegeum is a traditional Korean string instrument.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 595,
            "creditable" : true,
            "gid" : "8721ee8b-de77-4e38-a8ce-61bba705807b"
         },
         {
            "l_name" : "agogô",
            "name" : "agogô",
            "unaccented" : "agogo",
            "description" : "The agogô is a single or multiple bell used in samba music with origins in traditional Yoruba music.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 597,
            "creditable" : true,
            "gid" : "f341241c-6a19-4ed9-acb0-0b89fe0bfdef"
         },
         {
            "l_name" : "bandora",
            "name" : "bandora",
            "description" : "The bandora is a large long-necked plucked string instrument that has been described as a kind of bass cittern.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 598,
            "creditable" : true,
            "gid" : "41c3e01f-1449-4e60-984e-cb1c75db449d"
         },
         {
            "l_name" : "caxixi",
            "name" : "caxixi",
            "description" : "The caxixi is a shaker originating in Brazil which is made of a small wicker basket containing seeds or other small particles.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 599,
            "creditable" : true,
            "gid" : "b2cc0011-1bd1-4906-a77f-f15c7a5bae12"
         },
         {
            "l_name" : "barrel organ",
            "name" : "barrel organ",
            "description" : "A barrel organ is a mechanical musical instrument typically operated by a person turning a crank which turns a barrel which has music encoded onto it.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 600,
            "creditable" : true,
            "gid" : "e6fa08fe-bcc3-4715-9486-9d642ec38726"
         },
         {
            "l_name" : "cuíca",
            "name" : "cuíca",
            "unaccented" : "cuica",
            "description" : "The cuíca is a Brazilian friction drum often used in samba music.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 601,
            "creditable" : true,
            "gid" : "fa174c32-b348-4939-89b2-bde85af4ee02"
         },
         {
            "l_name" : "daegeum",
            "name" : "daegeum",
            "description" : "The daegeum is a large transverse flute from Korea which is made of bamboo.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 602,
            "creditable" : true,
            "gid" : "a089e86d-2e55-41e0-9d3a-3f71564eba8e"
         },
         {
            "l_name" : "nohkan",
            "name" : "nohkan",
            "description" : "The nohkan is a high-pitched bamboo transverse flute from Japan.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 603,
            "creditable" : true,
            "gid" : "e5b5ed95-f855-4493-a054-0fc4f39bc3e3"
         },
         {
            "l_name" : "shehnai",
            "name" : "shehnai",
            "description" : "The shehnai is a double reed conical oboe, common in North India, West India and Pakistan, made out of wood, with a metal flare bell at the end.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 604,
            "creditable" : true,
            "gid" : "5e17d5f8-65b1-464d-9f90-47259d832507"
         },
         {
            "l_name" : "janggu",
            "name" : "janggu",
            "description" : "The janggu or janggo is a double-headed hourglass shaped drum which is the most widely used drum used in the traditional music of Korea.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 605,
            "creditable" : true,
            "gid" : "0a050b86-ba63-4a5e-a384-1650996073d1"
         },
         {
            "l_name" : "dulcian",
            "name" : "dulcian",
            "description" : "The dulcian is a double reed bass woodwind instrument which is a 16th century ancestor of the bassoon.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 606,
            "creditable" : true,
            "gid" : "a0b1ba6b-6ea7-4489-a4af-c9e23d6e24da"
         },
         {
            "l_name" : "wind chime",
            "name" : "wind chime",
            "description" : "Wind chimes are chimes constructed from suspended tubes, rods, bells or other objects, designed to be hung outside and played by the wind.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 607,
            "creditable" : true,
            "gid" : "43c68c41-8b93-4330-b1af-524705ec289e"
         },
         {
            "l_name" : "kkwaenggwari",
            "name" : "kkwaenggwari",
            "description" : "The kkwaenggwari is a small flat brass gong, typically about 20cm in diameter, which is used primarily in the folk music of Korea.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 608,
            "creditable" : true,
            "gid" : "e7494c7f-0c68-42c0-a37a-6e4fea80a062"
         },
         {
            "l_name" : "piri",
            "name" : "piri",
            "description" : "The piri is a Korean double reed instrument made of bamboo, used in both the folk and classical (court) music of Korea. Related to the Chinese guan and Japanese hichiriki.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 609,
            "creditable" : true,
            "gid" : "ad6477fe-3586-4d75-9914-de24900d148f"
         },
         {
            "l_name" : "body percussion",
            "name" : "body percussion",
            "description" : "Percussion performed by parts of the body.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 610,
            "creditable" : true,
            "gid" : "6a0a53ab-1e66-45c4-af0d-2ec1e145b84e"
         },
         {
            "l_name" : "rudra veena",
            "name" : "rudra veena",
            "description" : "The rudra veena is a large plucked string instrument used in Hindustani classical music.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 611,
            "creditable" : true,
            "gid" : "aea9661c-cbda-4bf3-a61d-d78697472f29"
         },
         {
            "l_name" : "pakhavaj",
            "name" : "pakhavaj",
            "description" : "The pakhavaj is an Indian barrel-shaped, two-headed drum used in Hindustani music.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 612,
            "creditable" : true,
            "gid" : "cf1343bf-0893-4a62-9c72-e25ee5be0309"
         },
         {
            "l_name" : "kamancheh",
            "name" : "kamancheh",
            "description" : "The kamānche is a Persian bowed string instrument.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 613,
            "creditable" : true,
            "gid" : "a9f76c33-1eaa-48c0-a43c-ee12754eb7bf"
         },
         {
            "l_name" : "bowed piano",
            "name" : "bowed piano",
            "description" : "A piano whose strings are bowed, using nylon filament or other materials",
            "freeText" : false,
            "rootID" : 14,
            "id" : 614,
            "creditable" : true,
            "gid" : "2fb619eb-c5b3-495a-967a-b747b976a7d9"
         },
         {
            "l_name" : "jug",
            "name" : "jug",
            "description" : "an empty jug (usually made of glass or stoneware) played with the mouth",
            "freeText" : false,
            "rootID" : 14,
            "id" : 615,
            "creditable" : true,
            "gid" : "d5b9c401-a32e-4d4c-951d-2e9d76d6e078"
         },
         {
            "l_name" : "guqin",
            "name" : "guqin",
            "description" : "The guqin is a plucked seven-string Chinese musical instrument of the zither family.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 616,
            "creditable" : true,
            "gid" : "6e6329ed-27c0-4ace-a6fd-bfc03ae68a40"
         },
         {
            "l_name" : "archlute",
            "name" : "archlute",
            "description" : "The archlute is a European plucked string instrument developed around 1600 as a compromise between the very large theorbo and the Renaissance tenor lute",
            "freeText" : false,
            "rootID" : 14,
            "id" : 619,
            "creditable" : true,
            "gid" : "b4804589-9529-482e-86c9-4a288aae193f"
         },
         {
            "l_name" : "algozey",
            "name" : "algozey",
            "description" : "A wooden, beaked double-flute traditionally played by goat herders in the Punjab region of India and Pakistan.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 620,
            "creditable" : true,
            "gid" : "430c0de2-e2fb-4f81-8889-69a4b71f9bc2"
         },
         {
            "l_name" : "virginal",
            "name" : "virginal",
            "description" : "The virginals is a smaller and simpler rectangular form of the harpsichord with only one string per note",
            "freeText" : false,
            "rootID" : 14,
            "id" : 621,
            "creditable" : true,
            "gid" : "635db582-10ba-4488-8574-0a616090b599"
         },
         {
            "l_name" : "cornamuse",
            "name" : "cornamuse",
            "description" : "The cornamuse is a double reed instrument from the Renaissance, similar to the crumhorn but with a closed bell.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 622,
            "creditable" : true,
            "gid" : "28527011-9cf4-4dcd-a70c-22042a92a52c"
         },
         {
            "l_name" : "tumbi",
            "name" : "tumbi",
            "description" : "The tumbi is a high pitched, single string plucking instrument associated with folk music of Punjab.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 623,
            "creditable" : true,
            "gid" : "b0edfd1a-e728-4b93-802e-96c1c2f9d84a"
         },
         {
            "l_name" : "hang",
            "name" : "hang",
            "description" : "Percussion instrument made from two steel sheets that are attached together creating a recognizable 'UFO shape'.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 624,
            "creditable" : true,
            "gid" : "d5b46baa-37fc-46cc-b99f-c455ce6e6a9c"
         },
         {
            "l_name" : "spilåpipa",
            "name" : "spilåpipa",
            "unaccented" : "spilapipa",
            "description" : "The spilåpipa is a Swedish fipple flute with eight finger-holes on the top, but no thumb-holes. It has a modal tuning.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 625,
            "creditable" : true,
            "gid" : "59705bd6-e257-41ce-92b6-6593fc2e9b39"
         },
         {
            "l_name" : "fife",
            "name" : "fife",
            "description" : "A fife is a small, high-pitched, transverse flute that is similar to the piccolo, but louder and shriller due to its narrower bore.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 626,
            "creditable" : true,
            "gid" : "996e6514-37a4-4b22-af71-e968f30913fd"
         },
         {
            "l_name" : "laser harp",
            "name" : "laser harp",
            "description" : "A laser harp is an electronic musical instrument consisting of several laser beams to be blocked, in analogy with the plucking of the strings of a harp, in order to produce sounds.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 627,
            "creditable" : true,
            "gid" : "e5d0ff68-3005-4c5f-8cf1-61eaa3bbb332"
         },
         {
            "l_name" : "17-string koto",
            "name" : "17-string koto",
            "description" : "A koto with 17 rather than 13 strings, sometimes described as a bass koto.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 628,
            "creditable" : true,
            "gid" : "21468ce3-bad3-4f48-a2ff-01e6b0bc9ca2"
         },
         {
            "l_name" : "valiha",
            "name" : "valiha",
            "description" : "The valiha is a bamboo tube zither from Madagascar",
            "freeText" : false,
            "rootID" : 14,
            "id" : 629,
            "creditable" : true,
            "gid" : "a6a6d1b0-5d8a-4f8b-a89d-a6b6c5f8a1b0"
         },
         {
            "l_name" : "launeddas",
            "name" : "launeddas",
            "description" : "The launeddas is a typical Sardinian woodwind instrument, consisting of three pipes.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 630,
            "creditable" : true,
            "gid" : "571baf30-f258-419a-a4ec-fe2e8be478e1"
         },
         {
            "l_name" : "orpharion",
            "name" : "orpharion",
            "description" : "A plucked instrument from the Renaissance.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 631,
            "creditable" : true,
            "gid" : "73064eb8-ecd8-4fa2-b79f-06094da5b119"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "tape",
            "name" : "tape",
            "id" : 632,
            "creditable" : true,
            "gid" : "672c19ec-0ca3-4ece-9f6b-7f1c0018a0e6"
         },
         {
            "l_name" : "baroque trumpet",
            "name" : "baroque trumpet",
            "description" : "A valveless trumpet, in the model of the ones from the 16th to 18th centuries",
            "freeText" : false,
            "rootID" : 14,
            "id" : 633,
            "creditable" : true,
            "gid" : "a6e9129c-63d3-4e38-bcc3-8f4662a8f247"
         },
         {
            "l_name" : "natural horn",
            "name" : "natural horn",
            "description" : "Valveless ancestor of the modern (French) horn.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 634,
            "creditable" : true,
            "gid" : "218d072b-474a-4a9c-9d0f-c5b39891a4be"
         },
         {
            "l_name" : "five-string banjo",
            "name" : "five-string banjo",
            "description" : "A five-string banjo is a banjo with five strings.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 635,
            "creditable" : true,
            "gid" : "3933adfe-f55b-47fd-b085-c9983d15cc9d"
         },
         {
            "l_name" : "cavaquinho",
            "name" : "cavaquinho",
            "description" : "The cavaquinho is a small plucked string instrument of Portuguese origin with four wire or gut strings",
            "freeText" : false,
            "rootID" : 14,
            "id" : 636,
            "creditable" : true,
            "gid" : "aa129b27-d572-4eb7-9def-4a6869f21cda"
         },
         {
            "l_name" : "kudüm",
            "name" : "kudüm",
            "unaccented" : "kudum",
            "description" : "Turkish pair of small, hemispherical drums",
            "freeText" : false,
            "rootID" : 14,
            "id" : 637,
            "creditable" : true,
            "gid" : "44715139-79f9-4093-a883-dc743d8bb466"
         },
         {
            "l_name" : "typewriter",
            "name" : "typewriter",
            "description" : "A typewriter, used for percussion (either keys or bells)",
            "freeText" : false,
            "rootID" : 14,
            "id" : 638,
            "creditable" : true,
            "gid" : "af1799a2-1088-4243-a0d2-8f89e3fc515c"
         },
         {
            "l_name" : "yaylı tanbur",
            "name" : "yaylı tanbur",
            "description" : "The yaylı tanbur is a bowed lute from Turkey derived from the older plucked tanbur.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 639,
            "creditable" : true,
            "gid" : "ea37234d-a59b-4823-954f-aa499970ca94"
         },
         {
            "l_name" : "bulbul tarang",
            "name" : "bulbul tarang",
            "description" : "The bulbul tarang is a string instrument from India and Pakistan.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 640,
            "creditable" : true,
            "gid" : "0ddf2bbb-18bb-41da-b369-f145fc17fa50"
         },
         {
            "l_name" : "esraj",
            "name" : "esraj",
            "description" : "The esraj is a bowed string instrument from Eastern and Central India, mostly used as an accompanying instrument",
            "freeText" : false,
            "rootID" : 14,
            "id" : 641,
            "creditable" : true,
            "gid" : "105db479-f28e-40fb-9cbe-9305172238f9"
         },
         {
            "l_name" : "dilruba",
            "name" : "dilruba",
            "description" : "The dilruba is a bowed string instrument from Northern India, mostly used in religious music and light classical songs",
            "freeText" : false,
            "rootID" : 14,
            "id" : 642,
            "creditable" : true,
            "gid" : "57deb1b0-b7fe-4616-b9cb-bbd59bc0acd8"
         },
         {
            "l_name" : "tef",
            "name" : "tef",
            "description" : "A Turkish version of tambourine / daf, made from animal skin and played with the fingers.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 643,
            "creditable" : true,
            "gid" : "b0acbf59-ffba-4e2f-8104-31aed56fa364"
         },
         {
            "l_name" : "daire",
            "name" : "daire",
            "description" : "A larger version of tef, used to indicate the rhythmic structures (usul) in makam music.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 644,
            "creditable" : true,
            "gid" : "a3c58697-eae3-454c-90c5-5f911a24376a"
         },
         {
            "l_name" : "morsing",
            "name" : "morsing",
            "description" : "An Indian version of the jew's harp, played as a percussion instrument in Carnatic music and Rajastani folk music.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 645,
            "creditable" : true,
            "gid" : "e2f0cdf4-3651-4bb9-9153-0cdb16ce65ea"
         },
         {
            "l_name" : "kartal",
            "name" : "kartal",
            "description" : "The kartal is an Indian percussion instrument with jingles, played with the hands, mainly used in Kirtans, Bhajans and in Rajastani folk music.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 646,
            "creditable" : true,
            "gid" : "f5fe9a97-6595-4d4d-9b6b-a83c646c7143"
         },
         {
            "l_name" : "dhol",
            "name" : "dhol",
            "description" : "Double headed drum from India.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 647,
            "creditable" : true,
            "gid" : "9eda0cee-d33f-402e-b7bc-96b9e6962d5c"
         },
         {
            "l_name" : "chande",
            "name" : "chande",
            "description" : "The chande is a drum used in the traditional and classical music of South India.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 648,
            "creditable" : true,
            "gid" : "07504f21-f5b8-476a-8958-d0abe38c3748"
         },
         {
            "l_name" : "maddale",
            "name" : "maddale",
            "description" : "Maddale is a double-headed drum from Karnataka, India. It is the primary rhythmic accompaniment in Yakshagana.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 649,
            "creditable" : true,
            "gid" : "28a6a166-0df4-4d1a-aba1-70ed4265559d"
         },
         {
            "l_name" : "electric fretless guitar",
            "name" : "electric fretless guitar",
            "description" : "Electric guitar without frets.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 650,
            "creditable" : true,
            "gid" : "12f20f43-c71d-4476-8ada-b968aab50900"
         },
         {
            "l_name" : "acoustic fretless guitar",
            "name" : "acoustic fretless guitar",
            "description" : "Acoustic guitar without frets.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 651,
            "creditable" : true,
            "gid" : "5888d65d-9d65-4d13-8454-3d68be9b3e55"
         },
         {
            "l_name" : "ney",
            "name" : "ney",
            "description" : "Persian / Turkish / Arabic end-blown flute with five or six finger holes and one thumb hole.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 652,
            "creditable" : true,
            "gid" : "8460bc93-953f-4a48-9106-485d5703ec6f"
         },
         {
            "l_name" : "kemençe of the Black Sea",
            "name" : "kemençe of the Black Sea",
            "unaccented" : "kemence of the Black Sea",
            "description" : "Turkish box-shaped kemenche, mainly used for folk music.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 653,
            "creditable" : true,
            "gid" : "ad09a4ed-d1b6-47c3-ac85-acb531244a4d"
         },
         {
            "l_name" : "classical kemençe",
            "name" : "classical kemençe",
            "unaccented" : "classical kemence",
            "description" : "Turkish bowl-shaped kemenche, mainly used in classical Ottoman music",
            "freeText" : false,
            "rootID" : 14,
            "id" : 654,
            "creditable" : true,
            "gid" : "b9692581-c117-47f3-9524-3deeb69c6d3f"
         },
         {
            "l_name" : "komuz",
            "name" : "komuz",
            "description" : "The komuz is a fretless string instrument used in Central Asian music, seen as the Kyrgyz national instrument.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 655,
            "creditable" : true,
            "gid" : "822083c6-d93d-4b5e-8117-33bf763096e8"
         },
         {
            "l_name" : "talharpa / hiiu kannel",
            "name" : "talharpa / hiiu kannel",
            "description" : "The talharpa is a four-stringed bowed lyre from northern Europe, mostly played in Estonia.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 656,
            "creditable" : true,
            "gid" : "ff696aa2-629e-41ef-b68d-d8fe4b52a34a"
         },
         {
            "l_name" : "ruan",
            "name" : "ruan",
            "description" : "Ruan is a family of Chinese plucked lutes.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 657,
            "creditable" : true,
            "gid" : "c679782c-2d59-45b8-ab24-f19dd243fa03"
         },
         {
            "l_name" : "daruan",
            "name" : "daruan",
            "description" : "The daruan is a Chinese plucked lute.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 658,
            "creditable" : true,
            "gid" : "1156c575-2165-4799-be3f-023ff1fc7655"
         },
         {
            "l_name" : "hulusi",
            "name" : "hulusi",
            "description" : "The hulusi is a Chinese free reed wind instrument which has three bamboo pipes which pass through a gourd.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 659,
            "creditable" : true,
            "gid" : "da111bba-76e4-43ec-b03f-8fe8e558626e"
         },
         {
            "l_name" : "suona",
            "name" : "suona",
            "description" : "The suona is a Chinese shawm frequently used in the folk music of northern China.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 660,
            "creditable" : true,
            "gid" : "15cd573d-15a8-4f9f-a48f-f73218d85e14"
         },
         {
            "l_name" : "jing'erhu",
            "name" : "jing'erhu",
            "description" : "The jing'erhu is a Chinese bowed string instrument, similar to the erhu, so named because is played in Beijing opera.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 661,
            "creditable" : true,
            "gid" : "cecbc1f9-40b9-4f51-a357-286d622df956"
         },
         {
            "l_name" : "xiaoluo",
            "name" : "xiaoluo",
            "description" : "The xiaoluo is a Chinese small flat gong whose pitch rises when struck with the side of a flat wooden stick.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 662,
            "creditable" : true,
            "gid" : "ce0a1033-3e33-4d7f-8230-1fb53a57651d"
         },
         {
            "l_name" : "daluo",
            "name" : "daluo",
            "description" : "The daluo is a Chinese large flat gong whose pitch drops when struck with a padded mallet.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 663,
            "creditable" : true,
            "gid" : "f02ca577-d1ec-4c02-97c8-a15afff6bbfa"
         },
         {
            "l_name" : "jing",
            "name" : "jing",
            "description" : "The jing is a large gong used in traditional Korean music.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 664,
            "creditable" : true,
            "gid" : "d28125ee-4bfc-4cff-95ca-fdc52f85669c"
         },
         {
            "l_name" : "nagadou-daiko",
            "name" : "nagadou-daiko",
            "description" : "The nagadou-daiko is an elongated barrel-shaped Japanese drum.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 665,
            "creditable" : true,
            "gid" : "81aa0df3-4533-42bc-a023-13b92177ea90"
         },
         {
            "l_name" : "shime-daiko",
            "name" : "shime-daiko",
            "description" : "The shime-daiko is a small Japanese drum with a short but wide body which has a higher pitch than a normal taiko.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 666,
            "creditable" : true,
            "gid" : "e3154c4b-9da9-4ef2-abc4-58d577454e77"
         },
         {
            "l_name" : "taishogoto",
            "name" : "taishogoto",
            "description" : "The taishōgoto is a Japanese string instrument with 2-12 strings and keys which are used to fret the strings.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 667,
            "creditable" : true,
            "gid" : "1975ee04-30de-4835-9656-102ccd49c0c7"
         },
         {
            "l_name" : "kōauau",
            "name" : "kōauau",
            "unaccented" : "koauau",
            "description" : "The kōauau is a small ductless and notchless Maori flute which is four to eight inches long and has three to six fingerholes placed along the pipe.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 668,
            "creditable" : true,
            "gid" : "047cca04-5191-48b6-984c-4858db3e232e"
         },
         {
            "l_name" : "kotsuzumi",
            "name" : "kotsuzumi",
            "description" : "The kotsuzumi or simply tsuzumi is an hourglass-shaped Japanese drum with cords that can be squeezed or released to increase or decrease the tension of the heads.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 669,
            "creditable" : true,
            "gid" : "b35084cc-0e82-4047-9698-828c478f994f"
         },
         {
            "l_name" : "ōtsuzumi",
            "name" : "ōtsuzumi",
            "unaccented" : "otsuzumi",
            "description" : "The ōtsuzumi is an hourglass-shaped Japanese drum, larger than the kotsuzumi.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 670,
            "creditable" : true,
            "gid" : "6de2a79c-9658-4765-bbb2-c82dc015ca48"
         },
         {
            "l_name" : "tap dancing",
            "name" : "tap dancing",
            "description" : "Tap dancing is a type of dance in which the dancer wears special shoes that make a clicking sound as the dancer's feet strike the floor.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 671,
            "creditable" : true,
            "gid" : "57be0c41-d871-424d-a4e0-db6d5cbb6aea"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "electronic wind instrument",
            "name" : "electronic wind instrument",
            "id" : 672,
            "creditable" : true,
            "gid" : "4809de55-92ba-4bac-b1b0-a609d2d41d18"
         },
         {
            "l_name" : "Lyricon",
            "name" : "Lyricon",
            "description" : "The Lyricon is an electronic wind instrument.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 673,
            "creditable" : true,
            "gid" : "f396f3a3-d4db-449b-8ab7-1b31508b310c"
         },
         {
            "l_name" : "Vienna horn",
            "name" : "Vienna horn",
            "description" : "The Vienna horn is a type of musical horn used primarily in Vienna, Austria, for playing orchestral or classical music.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 674,
            "creditable" : true,
            "gid" : "11329bb7-5657-4a6b-ac9e-917d9f77d784"
         },
         {
            "l_name" : "Xaphoon",
            "name" : "Xaphoon",
            "description" : "The Xaphoon is a keyless chromatic single-reed woodwind instrument.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 675,
            "creditable" : true,
            "gid" : "c64428c0-bed0-4af9-8c71-d66f82117ee7"
         },
         {
            "l_name" : "yatga",
            "name" : "yatga",
            "description" : "The yatga is a traditional Mongolian plucked zither, similar to the Chinese guzheng.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 676,
            "creditable" : true,
            "gid" : "ee8fcd03-bc67-4f6b-9d55-6821c80eb751"
         },
         {
            "l_name" : "atarigane",
            "name" : "atarigane",
            "description" : "The atarigane is a Japanese gong which is struck using a deer horn mallet.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 677,
            "creditable" : true,
            "gid" : "a7d2c5cd-508e-4bc3-9d63-44c94aa9a125"
         },
         {
            "l_name" : "nylon guitar",
            "name" : "nylon guitar",
            "description" : "A classical guitar strung with nylon strings.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 678,
            "creditable" : true,
            "gid" : "87d5bd6a-8d14-4ed0-befa-b90379536634"
         },
         {
            "l_name" : "gut guitar",
            "name" : "gut guitar",
            "description" : "A classical guitar strung with gut strings.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 679,
            "creditable" : true,
            "gid" : "c2bfcf82-356c-4606-9dd7-51efd1b11bec"
         },
         {
            "l_name" : "rondador",
            "name" : "rondador",
            "description" : "The rondador is a set of chorded bamboo panpipes from Ecuador.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 680,
            "creditable" : true,
            "gid" : "75f77da4-41f2-4c64-9a5c-0528048f07e3"
         },
         {
            "l_name" : "siku",
            "name" : "siku",
            "description" : "The siku is a traditional Andean panpipe.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 681,
            "creditable" : true,
            "gid" : "448eeddf-37a3-49f3-9e46-d46ccd821aaf"
         },
         {
            "l_name" : "fourth flute",
            "name" : "fourth flute",
            "description" : "The fourth flute is a recorder with a lowest note of B♭, a fourth above the treble/alto recorder.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 682,
            "creditable" : true,
            "gid" : "f0ddf0ec-e8ac-4765-acef-0687af2b2f32"
         },
         {
            "l_name" : "fujara",
            "name" : "fujara",
            "description" : "The fujara is a large folk shepherd's fipple flute originated from central Slovakia.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 683,
            "creditable" : true,
            "gid" : "54c58a0e-cd47-436b-872a-dc5fe89bd213"
         },
         {
            "l_name" : "oboe da caccia",
            "name" : "oboe da caccia",
            "description" : "The oboe da caccia is a double reed woodwind instrument in the oboe family, pitched a fifth below the oboe and used primarily in the Baroque period of European classical music.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 684,
            "creditable" : true,
            "gid" : "de947c13-0406-4e70-badb-689d26e7d11d"
         },
         {
            "l_name" : "limbe",
            "name" : "limbe",
            "description" : "The limbe is a Mongolian transverse flute.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 685,
            "creditable" : true,
            "gid" : "f8c53ee8-da8f-4639-af9d-ea977ef8cc3b"
         },
         {
            "l_name" : "E-flat clarinet",
            "name" : "E-flat clarinet",
            "description" : "The E♭ clarinet is a member of the clarinet family.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 686,
            "creditable" : true,
            "gid" : "fd749773-a4c8-4fa9-85f9-a56eb016bcc3"
         },
         {
            "l_name" : "tonkori",
            "name" : "tonkori",
            "description" : "The tonkori is a plucked string instrument played by the Ainu of northern Japan and Sakhalin.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 687,
            "creditable" : true,
            "gid" : "642a60e9-6ea3-4153-90de-748dae23324e"
         },
         {
            "l_name" : "Reactable",
            "name" : "Reactable",
            "description" : "The Reactable is an electronic musical instrument consisting of a round translucent table on which blocks are placed.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 688,
            "creditable" : true,
            "gid" : "3f3ea4f9-5b51-4f6f-833e-e3bd17e659b8"
         },
         {
            "l_name" : "buk",
            "name" : "buk",
            "description" : "The buk is a Korean drum. While buk is a generic term for drum, it normally refers to a shallow barrel-shaped drum with a wooden body.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 689,
            "creditable" : true,
            "gid" : "acd0c109-e4dd-488a-8f7b-d7c7e5f333bf"
         },
         {
            "l_name" : "chikuzen biwa",
            "name" : "chikuzen biwa",
            "description" : "The chikuzen biwa is a biwa with either four strings and frets or five strings and frets popularised during the Meiji period.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 690,
            "creditable" : true,
            "gid" : "ac16043b-4727-40f9-bb2a-cb30ab4ce7a2"
         },
         {
            "l_name" : "heike biwa",
            "name" : "heike biwa",
            "description" : "The heike biwa is a biwa with four strings and five frets used to play Heike Monogatari.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 691,
            "creditable" : true,
            "gid" : "ec478db3-c490-4fca-a688-0bdd9fb55806"
         },
         {
            "l_name" : "satsuma biwa",
            "name" : "satsuma biwa",
            "description" : "The satsuma biwa is a biwa with four strings and frets popularised during the Edo period.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 692,
            "creditable" : true,
            "gid" : "de564c42-80db-4040-96c4-269ad9e063ac"
         },
         {
            "l_name" : "bangu",
            "name" : "bangu",
            "description" : "The bangu or danpigu is a Chinese frame drum, struck by two bamboo sticks. It is usually played along with the clappers ban (Chinese: 板, bǎn) and both instruments are known collectively as <a href=\"http://en.wikipedia.org/wiki/Guban_(instrument)\">guban</a> (Chinese: 鼓板, gǔbǎn).",
            "freeText" : false,
            "rootID" : 14,
            "id" : 693,
            "creditable" : true,
            "gid" : "42349583-c10d-4c6e-b553-28d916113856"
         },
         {
            "l_name" : "gralla",
            "name" : "gralla",
            "description" : "The gralla is a traditional Catalan double reed instrument in the oboe family.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 694,
            "creditable" : true,
            "gid" : "ad0ddf4c-05ca-4d9b-a159-8caed25e6bf4"
         },
         {
            "l_name" : "samba whistle",
            "name" : "samba whistle",
            "description" : "The samba whistle is a tri-tone whistle used in samba music and other Brazilian music styles.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 695,
            "creditable" : true,
            "gid" : "6c09e10d-7ed8-47a6-a9f2-8551b19b2d92"
         },
         {
            "l_name" : "thon",
            "name" : "thon",
            "description" : "The thon is a goblet drum with a ceramic or wooden body used in classical Thai and Cambodian music which forms one part of <a href=\"http://en.wikipedia.org/wiki/Thon_and_rammana\">thon and rammana</a>.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 696,
            "creditable" : true,
            "gid" : "30ec9a37-d7a5-41ca-942d-55f27015ff2f"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "hourglass drum",
            "name" : "hourglass drum",
            "id" : 697,
            "creditable" : true,
            "gid" : "76c83821-5b2e-41d9-b9c2-cef0dc1ddb77"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "friction drum",
            "name" : "friction drum",
            "id" : 698,
            "creditable" : true,
            "gid" : "9cb81ffe-8ae9-47c5-8b13-65d54e10be58"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "barrel drum",
            "name" : "barrel drum",
            "id" : 699,
            "creditable" : true,
            "gid" : "fdb869b9-cb9e-40d4-a7bf-f44c8d3bbac7"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "other drums",
            "name" : "other drums",
            "id" : 700,
            "creditable" : true,
            "gid" : "1da1ca18-9d70-4217-9e3c-9e67c93b834a"
         },
         {
            "l_name" : "żafżafa",
            "name" : "żafżafa",
            "unaccented" : "zafzafa",
            "description" : "The żafżafa or rabbaba is a Maltese friction drum consisting of a container (made of tin, pottery or wood) covered with animal skin with a long Arundo donax reed attached.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 701,
            "creditable" : true,
            "gid" : "741715c4-1756-43f8-b56f-a4aca1dc2cfd"
         },
         {
            "l_name" : "żaqq",
            "name" : "żaqq",
            "unaccented" : "zaqq",
            "description" : "The żaqq is a Maltese bagpipe made from the complete skin of an animal (typically a premature calf, goat or dog). The chanter consists of two side-by-side pipes and a bull's horn is normally attached to the end.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 702,
            "creditable" : true,
            "gid" : "659128ed-9e82-41ee-a872-4b6f8b32234b"
         },
         {
            "l_name" : "mirliton",
            "name" : "mirliton",
            "description" : "Mirliton is a generic term for membranophones played by a performer speaking or singing into them, and which alter the sound of the voice by means of a vibrating membrane.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 703,
            "creditable" : true,
            "gid" : "23a2775f-4bf3-4432-beb2-97be32b9ef50"
         },
         {
            "l_name" : "żummara",
            "name" : "żummara",
            "unaccented" : "zummara",
            "description" : "The żummara is a Maltese instrument similar to a kazoo. It is made out of a piece of bamboo reed covered on one end by greaseproof paper tied with string. A melody is then hummed into a hole in the reed producing a rough raspy sound. Not to be confused with the Egyptian/Iraqi zummara which is an instrument similar to a chalemeau.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 704,
            "creditable" : true,
            "gid" : "9478e40f-bab3-4fcb-a52a-f3df65770bfa"
         },
         {
            "l_name" : "shudraga",
            "name" : "shudraga",
            "description" : "The shudraga is a Mongolian fretless lute with three strings.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 705,
            "creditable" : true,
            "gid" : "e8e99279-0774-404a-9973-d4b06c759fc4"
         },
         {
            "l_name" : "nose whistle",
            "name" : "nose whistle",
            "description" : "The nose whistle (also known as the Humanatone) is a simple instrument played with the nose. The stream of air is directed over an edge in the instrument and the frequency of the notes produced is controlled by the volume of air.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 738,
            "creditable" : true,
            "gid" : "3d082a7d-e8d9-4c7b-b8d0-513883a7d586"
         },
         {
            "l_name" : "rauschpfeife",
            "name" : "rauschpfeife",
            "description" : "A wooden double-reed instrument with a conical bore from the 16th and 17th centuries",
            "freeText" : false,
            "rootID" : 14,
            "id" : 739,
            "creditable" : true,
            "gid" : "d6e67b1c-7b88-4157-9c67-aae74a163670"
         },
         {
            "l_name" : "duxianqin",
            "name" : "duxianqin",
            "description" : "The duxianqin is a one-string zither which is likely derived from the Vietnamese đàn bầu.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 740,
            "creditable" : true,
            "gid" : "4d857424-16ba-40a1-a3c3-6342aef9fde9"
         },
         {
            "l_name" : "saron",
            "name" : "saron",
            "description" : "The saron is an Indonesian musical instrument which is used in the gamelan. It normally has seven bronze bars placed on top of a resonating frame.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 741,
            "creditable" : true,
            "gid" : "7f025c8a-cfe8-4ac7-844a-346877fb2607"
         },
         {
            "l_name" : "dombra",
            "name" : "dombra",
            "description" : "The dombra is a long-necked lute from central Asia.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 742,
            "creditable" : true,
            "gid" : "115d7724-356c-4086-be40-2fef51415260"
         },
         {
            "l_name" : "naobo",
            "name" : "naobo",
            "description" : "The naobo are Chinese cymbals, specially used in Beijing opera.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 743,
            "creditable" : true,
            "gid" : "8c17c50a-c955-4cd4-b14e-87999d31e0f1"
         },
         {
            "l_name" : "mandocello",
            "name" : "mandocello",
            "description" : "The mandocello is a plucked string instrument of the mandolin family, the equivalent to the cello in the violin family",
            "freeText" : false,
            "rootID" : 14,
            "id" : 744,
            "creditable" : false,
            "gid" : "03de7e59-d275-4b21-b16a-ab363e909df6"
         },
         {
            "l_name" : "octave mandolin",
            "name" : "octave mandolin",
            "description" : "The octave mandolin is a fretted string instrument with four pairs of strings tuned in fifths, G, D, A, E (low to high), an octave below a mandolin.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 745,
            "creditable" : false,
            "gid" : "0dadbeee-4790-4730-9492-965f500c06fb"
         },
         {
            "l_name" : "Disk Drive",
            "name" : "Disk Drive",
            "description" : "as using drives for producing music, harddrives, floppy, cd or other.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 746,
            "creditable" : false,
            "gid" : "88f0d4fb-e7cc-4825-9d05-bcf974953790"
         },
         {
            "l_name" : "Harddisk",
            "name" : "Harddisk",
            "description" : "Harddisk configured to produce tones in pattern.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 747,
            "creditable" : false,
            "gid" : "ff7fe5a4-6360-469e-991d-4c1b9b7fd42a"
         },
         {
            "l_name" : "Floppy Drive",
            "name" : "Floppy Drive",
            "description" : "Floppy Drives configured to produce tones while reading, software is used.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 748,
            "creditable" : false,
            "gid" : "9bc6f6d5-db01-400b-8a59-ce455ca05921"
         },
         {
            "l_name" : "baryton",
            "name" : "baryton",
            "description" : "The baryton is a bowed string instrument which shares some characteristics with instruments of the viol family, distinguished by an extra set of plucked strings. It was in regular use in Europe up until the end of the 18th century.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 749,
            "creditable" : false,
            "gid" : "7b14c118-e243-459c-a18a-0c478a3ea6f4"
         },
         {
            "l_name" : "pedal piano",
            "name" : "pedal piano",
            "description" : "The pedal piano is a kind of piano that includes a pedalboard, enabling bass register notes to be played with the feet, as is standard on the organ.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 751,
            "creditable" : false,
            "gid" : "1487a644-3720-4ea9-8e37-3de180b5be85"
         },
         {
            "l_name" : "tar (drum)",
            "name" : "tar (drum)",
            "description" : "A tar is a single-headed frame drum from North Africa and the Middle East.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 752,
            "creditable" : false,
            "gid" : "1bf0ba6f-b062-4efe-a56f-33cc1035f6bb"
         },
         {
            "l_name" : "đàn tứ",
            "name" : "đàn tứ",
            "unaccented" : "dan tu",
            "description" : "The đàn tứ or đàn đoản is a traditional Vietnamese moon-shaped lute with a short neck.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 753,
            "creditable" : false,
            "gid" : "cbf5a4cb-7174-4eb6-8fbe-0b0b06118250"
         },
         {
            "l_name" : "liuqin",
            "name" : "liuqin",
            "description" : "The liuqin is a Chinese string instrument which has four strings and a pear-shaped body and resembles the pipa.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 754,
            "creditable" : false,
            "gid" : "6c62497a-8990-4709-86a8-78bcc4f45a06"
         },
         {
            "l_name" : "mouth organ",
            "name" : "mouth organ",
            "description" : "A mouth organ is a generic term for free reed aerophone with one or more air chambers fitted with a free reed.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 755,
            "creditable" : false,
            "gid" : "859ea9b3-00a1-4cc5-8f90-6f0e0f20539c"
         },
         {
            "l_name" : "khene",
            "name" : "khene",
            "description" : "The khene is a mouth organ from Laos and north-east Thailand which is also used by some ethnic minority groups in Vietnam. It typically consists of 14 bamboo pipes arranged into two rows which are connected to a small, hollowed-out hardwood windchest.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 756,
            "creditable" : false,
            "gid" : "5053c10b-0a2c-4298-946f-b9a608827874"
         },
         {
            "l_name" : "vichitra veena",
            "name" : "vichitra veena",
            "description" : "The vichitra veena is a plucked string instrument used in Hindustani music.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 757,
            "creditable" : false,
            "gid" : "b4d38ac1-7f12-437c-a61a-be2796ffc559"
         },
         {
            "l_name" : "qilaut",
            "name" : "qilaut",
            "description" : "The qilaut is an Inuit frame drum which has a handle and is made of caribou skin.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 758,
            "creditable" : false,
            "gid" : "7aa50be7-d31a-4e89-9fb2-a32ad290b255"
         },
         {
            "l_name" : "ranat ek",
            "name" : "ranat ek",
            "description" : "The ranat ek is a Thai xylophone which consists of 21 wooden bars suspended by cords over a boat-shaped trough resonator and struck by two mallets.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 759,
            "creditable" : false,
            "gid" : "e16bb6a7-fac3-46da-8ee4-e65c12b65388"
         },
         {
            "l_name" : "tenor violin",
            "name" : "tenor violin",
            "description" : "A tenor violin is an instrument with a range between those of the cello and the viola.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 760,
            "creditable" : false,
            "gid" : "c7a69b51-7105-4d4c-ab4a-ec118e24d1f0"
         },
         {
            "l_name" : "hichiriki",
            "name" : "hichiriki",
            "description" : "The hichiriki is a double reed Japanese flute used as one of two main melodic instruments in Japanese gagaku music.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 761,
            "creditable" : false,
            "gid" : "b3b3d5f8-d2cd-4c98-ad19-60876a0176da"
         },
         {
            "l_name" : "ryuteki",
            "name" : "ryuteki",
            "description" : "The ryuteki is a Japanese transverse flute used in gagaku.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 762,
            "creditable" : false,
            "gid" : "1878af04-5a26-46e4-9389-a1ef93030e5d"
         },
         {
            "l_name" : "ching",
            "name" : "ching",
            "description" : "Ching are a pair of small hand cymbals used in Thai and Cambodian music.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 763,
            "creditable" : false,
            "gid" : "83225061-4655-4c2b-bce2-dc2a931dd4af"
         },
         {
            "l_name" : "chap",
            "name" : "chap",
            "description" : "Chap are a pair of cymbals used in Thai and Cambodian music. They are larger, flatter and thinner than the cymbals known as ching.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 764,
            "creditable" : false,
            "gid" : "46b796c3-269e-4c64-8ec4-7b051e5740ed"
         },
         {
            "l_name" : "ranat thum",
            "name" : "ranat thum",
            "description" : "The ranat thum is a xylophone from Thailand consisting of 18 wooden bars suspended by cords over a boat-shaped trough resonator. It is similar to the ranat ek but lower in pitch.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 765,
            "creditable" : false,
            "gid" : "5af2c8f2-0153-46c0-8f79-ca03194bcab7"
         },
         {
            "l_name" : "khong wong",
            "name" : "khong wong",
            "description" : "The khong wong is a gong circle consisting of a number of gongs in a horizontal circular rattan frame. The player sits in the middle.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 766,
            "creditable" : false,
            "gid" : "b6aa8ec7-3ede-4f8b-92f1-45f4568e3261"
         },
         {
            "l_name" : "khong wong lek",
            "name" : "khong wong lek",
            "description" : "The khong wong lek is a gong circle used in Thai classical music. It has 18 tuned bossed gongs and is smaller and higher in pitch than the khong wong yai.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 767,
            "creditable" : false,
            "gid" : "936cc15c-58ce-4e3b-8d84-30143ccf05ee"
         },
         {
            "l_name" : "khong wong yai",
            "name" : "khong wong yai",
            "description" : "The khong wong yai is a gong circle used in the music of Thailand. It has 16 tuned bossed gongs and is larger and lower in pitch than the khong wong lek.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 768,
            "creditable" : false,
            "gid" : "4ed60977-fbcf-4802-bfce-cdbdc23e6dcc"
         },
         {
            "l_name" : "saw duang",
            "name" : "saw duang",
            "description" : "The saw duang is a two-stringed instrument used in traditional Thai music which has a cylindrical soundbox made of wood and a snakeskin resonator.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 769,
            "creditable" : false,
            "gid" : "28db0a69-5191-41ad-98b4-be1ff876868f"
         },
         {
            "l_name" : "saw u",
            "name" : "saw u",
            "description" : "The saw u is a Thai bowed string instrument which has a soundbox made from a coconut shell with a cowskin resonator.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 770,
            "creditable" : false,
            "gid" : "7e57165e-404c-4e11-9e3d-5273b48db40f"
         },
         {
            "l_name" : "post horn",
            "name" : "post horn",
            "description" : "The post horn is a valveless coiled brass instrument used to signal the arrival or departure of a post rider or mail coach.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 771,
            "creditable" : false,
            "gid" : "e4f188db-5bb8-4d22-ac90-a76877fb4ea6"
         },
         {
            "l_name" : "chakhe",
            "name" : "chakhe",
            "description" : "The chakhe is a three stringed crocodile shaped plucked zither from Thailand.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 772,
            "creditable" : false,
            "gid" : "faa2699d-2d3c-42e0-9e67-73239603693a"
         },
         {
            "l_name" : "rammana",
            "name" : "rammana",
            "description" : "The rammana is a frame drum used in classical Thai and Cambodian music which forms one part of <a href=\"http://en.wikipedia.org/wiki/Thon_and_rammana\">thon and rammana</a>.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 773,
            "creditable" : false,
            "gid" : "551e553a-cadd-4363-8723-f72aab5431d0"
         },
         {
            "l_name" : "dutar",
            "name" : "dutar",
            "description" : "The dutar is a long-necked two-stringed lute found in Iran and Central Asia.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 774,
            "creditable" : false,
            "gid" : "b3cf8cff-f7c7-4311-bf4e-cfc09bdb07ca"
         },
         {
            "l_name" : "setar",
            "name" : "setar",
            "description" : "The setar is a long-necked three-stringed lute found in Iran and Central asia.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 775,
            "creditable" : false,
            "gid" : "f1299271-c5d7-4f7c-8b72-d64aa152c3bb"
         },
         {
            "l_name" : "ukeke",
            "name" : "ukeke",
            "description" : "The ukeke is a Hawaiian musical bow made of koa wood, 16 to 24 inches long and about 1½ inches wide with two or three strings fastened through and around either end, tuned to an A major triad.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 776,
            "creditable" : false,
            "gid" : "751a051c-833e-46cf-91b7-9a462b8d674c"
         },
         {
            "l_name" : "lamellophone",
            "name" : "lamellophone",
            "description" : "Lamellophones are a family of musical instruments which have one or more long thin plates - \"lamella\" or \"tongues\" - which are fixed at one end and free at the other end. The free end is plucked, causing the plate to vibrate.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 777,
            "creditable" : false,
            "gid" : "56c8b6ff-b442-4adf-bd51-b2e26f28338b"
         },
         {
            "l_name" : "marímbula",
            "name" : "marímbula",
            "unaccented" : "marimbula",
            "description" : "The marímbula is a plucked box musical instrument from the Caribbean.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 778,
            "creditable" : false,
            "gid" : "1ed1ea53-0365-43ac-bdb5-1c4cd571baa6"
         },
         {
            "l_name" : "arghul",
            "name" : "arghul",
            "description" : "The arghul is a traditional Egyptian double-pipe, single-reed woodwind instrument.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 779,
            "creditable" : false,
            "gid" : "3adfcaab-611b-4117-b370-54842244dd24"
         },
         {
            "l_name" : "diddley bow",
            "name" : "diddley bow",
            "description" : "The diddley bow is a single-stringed American instrument which is typically homemade. It consists of a single string of baling wire tensioned between two nails on a board over a glass bottle, which is used both as a bridge and as a means to magnify the instrument's sound.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 780,
            "creditable" : false,
            "gid" : "927f1238-6638-4f6a-9484-404def8cdd3b"
         },
         {
            "l_name" : "tack piano",
            "name" : "tack piano",
            "description" : "The tack piano is a permanently altered version of an ordinary piano, which has tacks or nails placed on the felt-padded hammers of the instrument at the point where the hammers hit the strings, giving the instrument a tinny, more percussive sound.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 781,
            "creditable" : false,
            "gid" : "7e704071-7d7c-42f2-af03-a15eb66916d2"
         },
         {
            "l_name" : "mark tree",
            "name" : "mark tree",
            "description" : "A mark tree consists of many small chimes arranged in order of length which hang from a bar. The chimes are played by sweeping a finger or stick through the length of the hanging chimes.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 782,
            "creditable" : false,
            "gid" : "36174229-0e11-4eaf-82c8-e2502ddbbd30"
         },
         {
            "l_name" : "chime bar",
            "name" : "chime bar",
            "description" : "A chime bar is a percussion instrument consisting of a tuned metal bar similar to a glockenspiel bar which is mounted on a wooden resonator and played with a mallet.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 783,
            "creditable" : false,
            "gid" : "ddc0d7a5-cadb-4598-ac8d-83e17bde9816"
         },
         {
            "l_name" : "gong bass drum",
            "name" : "gong bass drum",
            "description" : "A gong bass drum is a large single drumhead which resembles a gong.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 784,
            "creditable" : false,
            "gid" : "af48ce3d-80de-40cb-8cc9-e8acc138d19d"
         },
         {
            "l_name" : "chau gong",
            "name" : "chau gong",
            "description" : "The chau gong is a large gong made of brass or bronze which is almost flat except for the rim.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 785,
            "creditable" : false,
            "gid" : "36163737-93f2-4794-bf67-f964bf227f23"
         },
         {
            "l_name" : "taepyeongso",
            "name" : "taepyeongso",
            "description" : "The taepyeongso is a Korean double reed wind instrument which has a conical wooden body with a metal mouthpiece and cup-shaped metal bell.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 786,
            "creditable" : false,
            "gid" : "5efb3f0e-6b8c-472a-81b1-52aa5beee1e7"
         },
         {
            "l_name" : "ajaeng",
            "name" : "ajaeng",
            "description" : "The ajaeng is a bowed Korean zither with 7 (sometimes 8 or 9) strings.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 787,
            "creditable" : false,
            "gid" : "51d4054b-b13a-47bd-9ff4-cfc42009c42c"
         },
         {
            "l_name" : "ektara",
            "name" : "ektara",
            "description" : "The ektara is a one-string instrument used in traditional music from Bangladesh, India, Egypt, and Pakistan.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 789,
            "creditable" : false,
            "gid" : "ba30c0de-373c-44e4-ac28-594c4f316ab0"
         },
         {
            "l_name" : "ganzá",
            "name" : "ganzá",
            "unaccented" : "ganza",
            "description" : "The ganzá is a cylinder-shaped Brazilian rattle used in samba music.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 790,
            "creditable" : false,
            "gid" : "b55abfb4-c40a-44e8-876b-e8de1834892a"
         },
         {
            "l_name" : "guitalele",
            "name" : "guitalele",
            "description" : "The guitalele is a guitar-ukulele hybrid, combining the small size of a guitalele with the six strings of a classical guitar.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 791,
            "creditable" : false,
            "gid" : "f156be0c-4663-463f-8202-23f7973797c2"
         },
         {
            "l_name" : "sabar",
            "name" : "sabar",
            "description" : "The sabar is a drum from Senegal which is normally played with one hand and one stick. The body is an elongated cylinder with tapered ends. The head is made of goatskin and is attached to the body using pegs.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 792,
            "creditable" : false,
            "gid" : "f37cf81c-0443-4e50-81ea-a63da88a7c4a"
         },
         {
            "l_name" : "Portuguese guitar",
            "name" : "Portuguese guitar",
            "description" : "The Portuguese guitar is a plucked string instrument associated with fado. It has twelve steel strings, strung in six courses.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 793,
            "creditable" : false,
            "gid" : "ba4705aa-ff1d-48d5-ae80-7b2046fb451e"
         },
         {
            "freeText" : false,
            "rootID" : 14,
            "l_name" : "electric viola",
            "name" : "electric viola",
            "id" : 794,
            "creditable" : false,
            "gid" : "2fe389f3-e357-4df8-9fe7-604aa6f50c01"
         },
         {
            "l_name" : "duck call",
            "name" : "duck call",
            "description" : "A duck call is a tool used to emulate the sound of a duck.",
            "freeText" : false,
            "rootID" : 14,
            "id" : 795,
            "creditable" : false,
            "gid" : "af7f5463-cda7-4503-b2f9-3ab865a2e92a"
         }
      ],
      "description" : "This attribute describes the possible instruments that can be captured as part of a performance. <br/> Can't find an instrument? <a href=\"http://wiki.musicbrainz.org/Advanced_Instrument_Tree\">Request it!</a>",
      "freeText" : false,
      "rootID" : 14,
      "id" : 14,
      "creditable" : true,
      "gid" : "0abd7f04-5e28-425b-956f-94789d9bcbe2"
   },
   "bonus" : {
      "l_name" : "bonus",
      "name" : "bonus",
      "description" : "Indicates a bonus disc",
      "freeText" : false,
      "rootID" : 516,
      "id" : 516,
      "creditable" : false,
      "gid" : "60f7b0f6-92c2-4027-81f3-63dfa6d6a64a"
   },
   "translated" : {
      "l_name" : "translated",
      "name" : "translated",
      "description" : "This attribute indicates a version with the lyrics in a different language than the original.",
      "freeText" : false,
      "rootID" : 517,
      "id" : 517,
      "creditable" : false,
      "gid" : "ed11fcb1-5a18-4e1d-b12c-633ed19c8ee1"
   },
   "parody" : {
      "l_name" : "parody",
      "name" : "parody",
      "description" : "This attribute indicates a version with satirical, ironic, or otherwise humorous intent. Parodies in most cases have altered lyrics.",
      "freeText" : false,
      "rootID" : 511,
      "id" : 511,
      "creditable" : false,
      "gid" : "d73de9d3-934b-419c-8c83-2e48a5773b14"
   },
   "assistant" : {
      "l_name" : "assistant",
      "name" : "assistant",
      "description" : "This typically indicates someone who is either a first-timer, or less experienced, and who is working under the direction of someone who is more experienced.",
      "freeText" : false,
      "rootID" : 526,
      "id" : 526,
      "creditable" : false,
      "gid" : "8c4196b1-7053-4b16-921a-f22b2898ed44"
   },
   "associate" : {
      "l_name" : "associate",
      "name" : "associate",
      "description" : "This typically indicates someone who is less experienced and who is working under the direction of someone who is more experienced.",
      "freeText" : false,
      "rootID" : 527,
      "id" : 527,
      "creditable" : false,
      "gid" : "8d23d2dd-13df-43ea-85a0-d7eb38dc32ec"
   },
   "additional" : {
      "l_name" : "additional",
      "name" : "additional",
      "description" : "This attribute describes if a particular role was considered normal or additional.",
      "freeText" : false,
      "rootID" : 1,
      "id" : 1,
      "creditable" : false,
      "gid" : "0a5341f8-3b1d-4f99-a0c6-26b7f4e42c7f"
   },
   "live" : {
      "l_name" : "live",
      "name" : "live",
      "description" : "This indicates that the recording is of a live performance.",
      "freeText" : false,
      "rootID" : 578,
      "id" : 578,
      "creditable" : false,
      "gid" : "70007db6-a8bc-46d7-a770-80e6a0bb551a"
   },
   "guest" : {
      "l_name" : "guest",
      "name" : "guest",
      "description" : "This attribute indicates a 'guest' performance where the performer is not usually part of the band.",
      "freeText" : false,
      "rootID" : 194,
      "id" : 194,
      "creditable" : false,
      "gid" : "b3045913-62ac-433e-9211-ac683cdf6b5c"
   }
});
