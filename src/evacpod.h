//
//  evacpod.h
//  IndieCade Server
//
//  Created by Clay Ewing on 9/15/14.
//
//
#ifndef __IndieCade_Server__evacpod__
#define __IndieCade_Server__evacpod__

#include "ofMain.h"

class EvacPod  {
    
public:
    EvacPod();
    void display();
    void displayFront();
    void setup(ofPoint pos, ofImage * img, ofImage * imgFront);
    ofImage *image;
    ofImage *imageFront;
    ofPoint position;
    ofPoint originalPosition;
    float podSpeedY;
    float alpha;
    bool evacuating;
};
#endif