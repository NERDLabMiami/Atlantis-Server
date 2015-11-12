//
//  humanoid.h
//  atlantis
//
//  Created by Clay Ewing on 3/30/14.
//
//

#include "ofMain.h"
#include "ofxBox2dRect.h"
#include "custom.h"

class Pod : public ofxBox2dRect {
    
public:
    void display();
    void setupCustom(int id);
    bool highlight;
    ofColor color;
    ofImage *image;
    ofImage *glow;
    float alpha;
    int offset;
    
};
