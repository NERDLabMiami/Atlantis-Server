//
//  bubble.cpp
//  IndieCade Server
//
//  Created by Clay Ewing on 9/9/14.
//
//

#include "bubble.h"

void Bubble::setupCustom(int id) {
    setData(new CustomData());
    CustomData * theData = (CustomData *)getData();
    theData->type = TYPE_BUBBLE;
    theData->remove = false;
    theData->taken = false;
    theData->id = id;
    scale = 1;
    
}

void Bubble::display() {
    CustomData * theData = (CustomData *)getData();
    theData->position = getPosition();
    if (theData->taken) {
        body->SetActive(false);
        scale *= .9;
        if (scale <= .1) {
            theData->remove = true;
        }
    }

    ofPushMatrix();
    ofTranslate(getPosition());
    ofRotateZ(getRotation());
    ofSetColor(color);
    ofFill();
    if (!theData->taken) {
            image->draw(-getWidth()/2, -getHeight()/2, getWidth() * scale, getHeight() * scale);
    }
    ofPopMatrix();
    
}