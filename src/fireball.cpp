//
//  fireball.cpp
//  Atlantis_Server 1080
//
//  Created by Clay Ewing on 10/8/14.
//
//

#include "fireball.h"

Fireball::Fireball(ofImage *img) {
    image = img;
    alpha = 255;
    position.set(ofRandom(ofGetWidth()), ofRandom(ofGetHeight()/2, ofGetHeight()));
    
}

void Fireball::display() {
    ofSetColor(255, 255, 255, alpha);
    image->draw(position);
    alpha-=5;
}