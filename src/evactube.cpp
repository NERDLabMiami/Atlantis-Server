//
//  evactube.cpp
//  IndieCade Server
//
//  Created by Clay Ewing on 9/14/14.
//
//

#include "evactube.h"


EvacTube::EvacTube() {
    power = 0;
    currentEvacuee = 0;
    destroyed = false;
    destructionSpeed = ofRandom(1,10);
    
//    podSpeed = 1;
    
}

void EvacTube::setup(ofPoint pos, ofImage *tube, ofImage *tubeBack, ofImage *tubeEvacuating, ofImage *podImage, ofImage * podImageFront, ofImage *podPlatform ) {
    tubePosition = pos;
    tubeImage = tube;
    tubeBackImageEvacuating = tubeEvacuating;
    tubeBackImage = tubeBack;
    podPlatformImage = podPlatform;
    evacpod.setup(ofPoint(tubePosition.x,ofGetHeight() - podImage->getHeight()), podImage, podImageFront);
    evacuating = false;
    }

void EvacTube::next() {
    currentEvacuee++;

    if (evacuees.size() > currentEvacuee) {
    }
    else {
        currentEvacuee = 0;
        
    }
}

void EvacTube::display() {
    if (evacuating) {
        tubeBackImageEvacuating->draw(tubePosition);

    }
    else {
        tubeBackImage->draw(tubePosition);
    }
    if (!destroyed) {
        evacpod.display();
        evacuees[currentEvacuee].display();
    }
    for (int i = 0; i < evacuees.size(); i++) {
        if (evacuees[i].evacuating) {
            if(evacuees[i].display()) {
                evacuees[i].position.x = tubePosition.x;
                evacpod.evacuating = true;
                airlockSound->play();
                evacuating = false;
            }
        }
    }

    if (destroyed) {
        tubePosition.y+= power + destructionSpeed;
        tubeImage->draw(tubePosition);

    }
    else {
        ofSetColor(0, 255, 0);
        float powerY = ofMap(power, 0, 100, tubeImage->getHeight()-10, 0);
        float powerHeight = ofMap(power, 0, 100, 0, tubeImage->getHeight());
        
        ofRect(tubePosition.x + tubeImage->getWidth()-40, powerY, 30, powerHeight);
        
        ofSetColor(255, 0, 0);
        ofRect(tubePosition.x + tubeImage->getWidth()-40, 10, 30, powerY);
        ofSetColor(255, 255, 255);
        tubeImage->draw(tubePosition);
        podPlatformImage->draw(tubePosition.x + tubeImage->getWidth() - 50 - podPlatformImage->getWidth(), ofGetHeight()-podPlatformImage->getHeight());
        evacpod.displayFront();

    }

}

bool EvacTube::addPower(float p) {
    power+=p;
    if (power >= 100) {
        power = 0;
        evacuees[currentEvacuee].evacuate();
        evacuating = true;
        next();
        return true;
    }
    return false;
}