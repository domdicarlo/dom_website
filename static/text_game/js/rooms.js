var rooms = {
    "center_start": {
        "description": "You are in a daze with a pounding headache, unknowing\
                        of how you got here. You are in a dimly lit room.",
        "directions": {
            "north": "north_start",
            "south": "south_start",
            "west": "west_start",
            "east": "east_start"
        }
    },
    "north_start": {
        "description": "You are in a daze with a pounding headache, unknowing\
                        of how you got here. You are in a dimly lit room.",
        "directions": {
            "south": "center_start",
            "west": "north_west_start",
            "east": "north_east_start"
        }
    },
    "south_start": {
        "description": "You are in a daze with a pounding headache, unknowing\
                        of how you got here. You are in a dimly lit room.",
        "directions": {
            "north": "central_start",
            "west": "south_west_start",
            "east": "south_east_start"
        }
    },
    "east_start": {
        "description": "You are in a daze with a pounding headache, unknowing\
                        of how you got here. You are in a dimly lit room.",
        "directions": {
            "north": "north_east_start",
            "south": "south_east_start",
            "west": "central_start",
        }
    },
    "west_start": {
        "description": "You are in a daze with a pounding headache, unknowing\
                        of how you got here. You are in a dimly lit room.",
        "directions": {
            "north": "north_west_start",
            "south": "south_west_start",
            "east": "central_start"
        }
    },
    "south_east_start": {
        "description": "You are in a daze with a pounding headache, unknowing\
                        of how you got here. You are in a dimly lit room.",
        "directions": {
            "north": "east_start",
            "west": "south_start",
        }
    },
    "south_west_start": {
        "description": "You are in a daze with a pounding headache, unknowing\
                        of how you got here. You are in a dimly lit room.",
        "directions": {
            "north": "west_start",
            "east": "south_start"
        }
    },
    "north_west_start": {
        "description": "You are in a daze with a pounding headache, unknowing\
                        of how you got here. You are in a dimly lit room.",
        "directions": {
            "south": "west_start",
            "east": "north_start"
        }
    },
    "north_east_start": {
        "description": "You are in a daze with a pounding headache, unknowing\
                        of how you got here. You are in a dimly lit room.",
        "directions": {
            "south": "east_start",
            "west": "north_start",
        }
    },
}
