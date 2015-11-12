//
//  evacuee.cpp
//  IndieCade Server
//
//  Created by Clay Ewing on 9/15/14.
//
//

#include "evacuee.h"

Evacuee::Evacuee() {
    currentPod = 0;

}

void Evacuee::setup(ofPoint pos, ofImage * occupantimg) {
    position.set(pos.x, pos.y + 13);
    originalPosition = position;
    image = occupantimg;
    alpha = 0;
    safe = false;
    evacuating = false;
}

void Evacuee::evacuate() {
    evacuating = true;
}

void Evacuee::next() {
}
bool Evacuee::display() {
    bool hasBeenEvacuated = false;
    if (evacuating) {
        position.y+=10;
    }
    else {
        alpha++;
        if (alpha >= 255) {
            alpha = 255;
        }
    }

    if (position.y > ofGetHeight() - 100) {
        setup(originalPosition, image);
        hasBeenEvacuated = true;
        cout << "Setting Evac Pod to True" << endl;
    }

    ofSetColor(255, 255, 255, alpha);
    image->draw(position);
    
    return hasBeenEvacuated;
}
