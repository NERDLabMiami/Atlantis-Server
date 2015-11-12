//
//  GetawayPod.cpp
//  Atlantis_Server 1080
//
//  Created by Clay Ewing on 10/4/14.
//
//

#include "GetawayPod.h"

GetawayPod::GetawayPod() {
    position = ofPoint(ofRandom(-ofGetWidth()/2), ofRandom(ofGetHeight()+100, ofGetHeight()/2));
    velocity.set(3, -1);
    podAnimationCounter = 0;
    fireAnimationCounter = 0;
    scale = 1;
}
void GetawayPod::setup(ofPoint pos, ofPoint vel) {
    position = pos;
    velocity = vel;
}
void GetawayPod::reset() {
    position = ofPoint(ofRandom(-ofGetWidth()/2), ofRandom(0, ofGetHeight()/2));
    velocity.set(3, -1);
    podAnimationCounter = 0;
    scale = 1;
    fireAnimationCounter = 0;
    
}
void GetawayPod::display(ofColor color, bool scaling) {
    if (scaling) {
        scale *= .995;
    }
    ofPushMatrix();
    ofSetColor(255,255, 255, ofMap(scale, 0, 1, 100, 255));
    ofTranslate(position.x, position.y);
    fireImages[fireAnimationCounter].draw(0, 0, fireImages[0].getWidth()*scale, fireImages[0].getHeight()*scale);
    ofSetColor(color);
    podImages[podAnimationCounter].draw(0,0, podImages[podAnimationCounter].getWidth()*scale, podImages[podAnimationCounter].getHeight()*scale);

    podAnimationCounter+=.25;
    fireAnimationCounter+=.25;
    if (podAnimationCounter >= podImages.size()) {
        podAnimationCounter = 0;
    }
    if (fireAnimationCounter >= fireImages.size()) {
        fireAnimationCounter = 0;
    }
    position += velocity;
    ofPopMatrix();
}
