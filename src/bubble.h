//
//  bubble.h
//  IndieCade Server
//
//  Created by Clay Ewing on 9/9/14.
//
//

#ifndef __IndieCade_Server__bubble__
#define __IndieCade_Server__bubble__

#include "ofMain.h"
#include "ofxBox2dRect.h"
#include "custom.h"

class Bubble : public ofxBox2dRect {
public:
    void display();
    void setupCustom(int id);
    bool remove;
    
    ofColor color;
    ofImage *image;
    ofPoint velocity;
    float scale;
};
#endif