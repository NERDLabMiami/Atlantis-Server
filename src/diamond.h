//
//  food.h
//  atlantis
//
//  Created by Clay Ewing on 3/30/14.
//
//

#include "ofMain.h"
#include "ofxBox2dRect.h"
#include "custom.h"

class Diamond : public ofxBox2dRect {
    
public:
    void display();
    void setupCustom(int id);
    ofColor color;
    ofImage *image;
    ofImage *shadowImage;
    float scale;
    
};
