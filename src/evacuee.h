//
//  evacuee.h
//  IndieCade Server
//
//  Created by Clay Ewing on 9/15/14.
//
//
#ifndef __IndieCade_Server__evacuee__
#define __IndieCade_Server__evacuee__

#include "ofMain.h"
#include "evacpod.h"


class Evacuee  {
    
public:
    Evacuee();
    bool display();
    void setup(ofPoint pos, ofImage * occupantimg);
    void evacuate();
    void next();
    ofImage *image;
    ofPoint position;
    ofPoint originalPosition;
    float alpha;
    int currentPod;
    bool evacuating;
    bool safe;
    bool waiting;
    EvacPod evacpod;
    
};

#endif