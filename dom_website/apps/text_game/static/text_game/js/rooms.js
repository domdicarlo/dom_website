var rooms = {
    "A room": {
        "first": "You are in a daze with a pounding headache, unknowing\
                        of how you got here.",
        "description": "The room is dimly lit by some standing lamps around the room.\
                        You can see enough to not bump into things but\
                        it's dark enough to draw the foreboding sense that\
                        something may jump from the shadows\
                        at any moment. The floor is wooden and creaky, and the walls\
                        are covered with an old, tan 1960s patterned wallpaper which\
                        has seen better days. There are some mundane things in the room:\
                        a desk, a fridge, a painting, and a couch and coffetable.\
                        There is a steel door at the North end of the room, \
                        which you must have come through to get\
                        in here.",
        "spaces": {
            "Central": {
                "directions": {
                    "north": "North",
                    "south": "South",
                    "west": "West",
                    "east": "East"
                }
            },
            "North": {
                "detail": "There is a a door here. You hear a low hum from the other side of it.",
                "directions": {
                    "south": "Central",
                    "west": "North West",
                    "east": "North East"
                }
            },
            "South": {
                "detail": "There are what appear to be scratches on the wall.\
                           They look human-made.",
                "directions": {
                    "north": "Central",
                    "west": "South West",
                    "east": "South East"
                }
            },
            "East": {
                "detail": "You see a wooden desk. It has some pieces of paper on top of it,\
                           along with a pen.",
                "directions": {
                    "north": "North East",
                    "south": "South East",
                    "west": "Central",
                }
            },
            "West": {
                "detail": "A painting of a lighthouse sits on the wall.",
                "directions": {
                    "north": "North West",
                    "south": "South West",
                    "east": "Central"
                }
            },
            "South East": {
                "detail": "An old, vintage looking fridge sits in the corner. It's not plugged in.",
                "directions": {
                    "north": "East",
                    "west": "South",
                }
            },
            "South West": {
                "detail": "The floor creaks.",
                "directions": {
                    "north": "West",
                    "east": "South"
                }
            },
            "North West": {
                "detail": "You hear a low hum from the other side of the wall.\
                           There is a tattered couch with an antiquated wooden\
                           coffee table in front of it",
                "directions": {
                    "south": "West",
                    "east": "North"
                }
            },
            "North East": {
                "detail": "You hear a low hum from the other side of the wall.",
                "directions": {
                    "south": "East",
                    "west": "North",
                }
            },
        }
    },
}

// var rooms = {
//     "start": {
//         "description": "You are in a dark, cold place and you see a light to <b>north</b>\
//      and you hear the sound of running water to the <b>west</b>",
//         "directions": {
//             "north": "clearing1",
//             "west": "bridge1"
//         }
//     },
//     "clearing1": {
//         "description": "You arrive to a clearing, you see a lighthouse to the <b>north</b>\
//      and there is a strange smell coming from the <b>east</b>",
//         "directions": {
//             "south": "start",
//             "north": "lighthouse",
//             "east": "trolls"
//         }
//     },
//     "lighthouse": {
//         "description": "You arrive to the lighthouse and walk up to the door. A strange old lady\
//      opens the door. What do you do?",
//         "directions": {
//             "south": "clearing1"
//         }
//     },
//     "trolls": {
//         "description": "You arrive to another clearing, there are some trolls roasting some mysterious meat\
//      They haven't seen you yet. What do you do?",
//         "directions": {
//             "west": "clearing1"
//         }
//     },
//     "bridge1": {
//         "description": "You see a river and there is a bridge to the <b>west</b>",
//         "directions": {
//             "east": "start",
//             "west": "bridge2"
//         }
//     },
//     "bridge2": {
//         "description": "You try to cross the bridge but a troll jumps out and bites your leg!",
//         "directions": {
//             "east": "bridge1"
//         }
//     }
// }
