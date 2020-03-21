// var rooms = {
//     "center_start": {
//         "description": "You are in a daze with a pounding headache, unknowing\
//                         of how you got here. You are in a dimly lit room.",
//         "directions": {
//             "north": "north_start",
//             "south": "south_start",
//             "west": "west_start",
//             "east": "east_start"
//         }
//     },
//     "north_start": {
//         "description": "You are in a daze with a pounding headache, unknowing\
//                         of how you got here. You are in a dimly lit room.",
//         "directions": {
//             "south": "center_start",
//             "west": "north_west_start",
//             "east": "north_east_start"
//         }
//     },
//     "south_start": {
//         "description": "You are in a daze with a pounding headache, unknowing\
//                         of how you got here. You are in a dimly lit room.",
//         "directions": {
//             "north": "central_start",
//             "west": "south_west_start",
//             "east": "south_east_start"
//         }
//     },
//     "east_start": {
//         "description": "You are in a daze with a pounding headache, unknowing\
//                         of how you got here. You are in a dimly lit room.",
//         "directions": {
//             "north": "north_east_start",
//             "south": "south_east_start",
//             "west": "central_start",
//         }
//     },
//     "west_start": {
//         "description": "You are in a daze with a pounding headache, unknowing\
//                         of how you got here. You are in a dimly lit room.",
//         "directions": {
//             "north": "north_west_start",
//             "south": "south_west_start",
//             "east": "central_start"
//         }
//     },
//     "south_east_start": {
//         "description": "You are in a daze with a pounding headache, unknowing\
//                         of how you got here. You are in a dimly lit room.",
//         "directions": {
//             "north": "east_start",
//             "west": "south_start",
//         }
//     },
//     "south_west_start": {
//         "description": "You are in a daze with a pounding headache, unknowing\
//                         of how you got here. You are in a dimly lit room.",
//         "directions": {
//             "north": "west_start",
//             "east": "south_start"
//         }
//     },
//     "north_west_start": {
//         "description": "You are in a daze with a pounding headache, unknowing\
//                         of how you got here. You are in a dimly lit room.",
//         "directions": {
//             "south": "west_start",
//             "east": "north_start"
//         }
//     },
//     "north_east_start": {
//         "description": "You are in a daze with a pounding headache, unknowing\
//                         of how you got here. You are in a dimly lit room.",
//         "directions": {
//             "south": "east_start",
//             "west": "north_start",
//         }
//     },
// }

var rooms = {
    "start": {
        "description": "You are in a dark, cold place and you see a light to <b>north</b>\
     and you hear the sound of running water to the <b>west</b>",
        "directions": {
            "north": "clearing1",
            "west": "bridge1"
        }
    },
    "clearing1": {
        "description": "You arrive to a clearing, you see a lighthouse to the <b>north</b>\
     and there is a strange smell coming from the <b>east</b>",
        "directions": {
            "south": "start",
            "north": "lighthouse",
            "east": "trolls"
        }
    },
    "lighthouse": {
        "description": "You arrive to the lighthouse and walk up to the door. A strange old lady\
     opens the door. What do you do?",
        "directions": {
            "south": "clearing1"
        }
    },
    "trolls": {
        "description": "You arrive to another clearing, there are some trolls roasting some mysterious meat\
     They haven't seen you yet. What do you do?",
        "directions": {
            "west": "clearing1"
        }
    },
    "bridge1": {
        "description": "You see a river and there is a bridge to the <b>west</b>",
        "directions": {
            "east": "start",
            "west": "bridge2"
        }
    },
    "bridge2": {
        "description": "You try to cross the bridge but a troll jumps out and bites your leg!",
        "directions": {
            "east": "bridge1"
        }
    }
}


