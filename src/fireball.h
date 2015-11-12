//
//  fireball.h
//  Atlantis_Server 1080
//
//  Created by Clay Ewing on 10/8/14.
//
//

#include "ofMain.h"

class Fireball  {
    
public:
    Fireball(ofImage *img);
    void display();
    ofImage *image;
    ofPoint position;
    float alpha;
    
};
