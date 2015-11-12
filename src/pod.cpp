//
//  humanoid.cpp
//  atlantis
//
//  Created by Clay Ewing on 3/30/14.
//
//

#include "pod.h"

void Pod::setupCustom(int id) {
    setData(new CustomData());
    CustomData * theData = (CustomData *)getData();
    theData->type = TYPE_POD;
    theData->remove = false;
    theData->taken = false;
    highlight = false;
    theData->id = id;
    alpha = 0;

}

void Pod::display() {
    float width = getWidth();
    float height = getHeight();
    ofPushMatrix();
    ofSetRectMode(OF_RECTMODE_CENTER);
    ofTranslate(getPosition());
    ofRotateZ(getRotation());
    CustomData * theData = (CustomData *)getData();
    if (theData->taken) {
        alpha+=10;
    }
    if (highlight) {
        alpha+=5;
    }
    if (alpha >= 255) {
        theData->taken = false;
        highlight = false;
        alpha = 0;
    }
    ofSetColor(255, alpha);
    glow->draw(0, 0, width*2, height*2);
    ofSetColor(color);
    ofFill();
    image->draw(0,0, width, height);
    ofSetRectMode(OF_RECTMODE_CORNER);
    ofPopMatrix();
}