//
//  fizzle.h
//  IndieCade Server
//
//  Created by Clay Ewing on 9/12/14.
//
//

#include "ofMain.h"

class Fizzle  {
    
public:
    Fizzle(bool toTopFast);
    void display();
    void setup(ofPoint pos, ofColor c, ofImage * img);
    ofColor color;
    ofImage *image;
    ofPoint position;
    ofPoint velocity;
    float radius;
    
};
