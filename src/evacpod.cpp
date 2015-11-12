//
//  evacpod.cpp
//  IndieCade Server
//
//  Created by Clay Ewing on 9/15/14.
//
//

#include "evacpod.h"

EvacPod::EvacPod() {
}



void EvacPod::display() {
    if (evacuating) {
        position.y+=podSpeedY;

        if (position.y >= ofGetHeight()) {
            podSpeedY = -4;
        }

        if (position.y <= originalPosition.y) {
            evacuating = false;
            podSpeedY = 4;
        }

    }
    

    
    
    ofSetColor(255, 255, 255);
    image->draw(position);
}

void EvacPod::displayFront() {
    ofSetColor(255, 255, 255);
    imageFront->draw(position);
}


void EvacPod::setup(ofPoint pos, ofImage * img, ofImage *imgFront) {
    image = img;
    imageFront = imgFront;
    podSpeedY = 4;
    position = pos;
    originalPosition = pos;
    alpha = 0;
    evacuating = false;
}
