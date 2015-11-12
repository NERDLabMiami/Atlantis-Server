//
//  custom.h
//  cinemaServer
//
//  Created by Clay Ewing on 2/14/14.
//
//
#ifndef __CUSTOM_DATA_H_INCLUDED__
#define __CUSTOM_DATA_H_INCLUDED__

#define POD_TYPE            1
#define DIAMOND_TYPE        2

#define TYPE_POD            1
#define TYPE_DIAMOND        2
#define TYPE_SHIP           3
#define TYPE_ATTACKER       4
#define TYPE_ZOMBIE         5
#define TYPE_SUBMARINE      6
#define TYPE_BUBBLE         7

class CustomData {
public:
    int type;
    bool remove;
    bool taken;
    bool highlight;
    int id;
    ofPoint position;
};

#endif