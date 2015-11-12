//
//  diamond.cpp
//  atlantis
//
//  Created by Clay Ewing on 3/30/14.
//
//

#include "diamond.h"

void Diamond::setupCustom(int id) {
    setData(new CustomData());
    CustomData * theData = (CustomData *)getData();
    theData->type = TYPE_DIAMOND;
    theData->remove = false;
    theData->id = id;
    theData->taken = false;
    color = ofColor(255,255,255);
    scale = 1;
}
void Diamond::display() {
    float width = getWidth();
    float height = getHeight();
    CustomData * theData = (CustomData *)getData();

    if (theData->taken) {
        body->SetActive(false);
        scale *= .9;
        if (scale <= .1) {
            theData->remove = true;
        }
    }
    ofPushMatrix();
    ofSetRectMode(OF_RECTMODE_CENTER);
    ofTranslate(getPosition());
    ofRotateZ(getRotation());
//    ofSetColor(0, 200);
//    image->draw(0, 0, width*1.1*scale, height*1.1*scale);
    ofSetColor(color);
    image->draw(0,0, width*scale, height*scale);
    ofSetRectMode(OF_RECTMODE_CORNER);
    ofPopMatrix();
}