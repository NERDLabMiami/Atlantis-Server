//
//  fizzle.cpp
//  IndieCade Server
//
//  Created by Clay Ewing on 9/12/14.
//
//

#include "fizzle.h"

Fizzle::Fizzle(bool toTop) {
    if (toTop) {
        velocity.set(ofRandom(-2,2), ofRandom(-1,-10));
    }
    else {
        velocity.set(ofRandom(-2,2), ofRandom(0,-3));
        
    }
}

void Fizzle::setup(ofPoint pos, ofColor c, ofImage * img) {
    position = pos;
    color = c;
    image = img;
    radius = img->width;
}

void Fizzle::display() {
    if (radius >= 0) {
        ofSetColor(color);
        image->draw(position, radius, radius);
        radius--;
        position += velocity;
    }
}

