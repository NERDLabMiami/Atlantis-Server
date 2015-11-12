//
//  GetawayPod.h
//  Atlantis_Server 1080
//
//  Created by Clay Ewing on 10/4/14.
//
//

#include "ofMain.h"

class GetawayPod  {
    
public:
    GetawayPod();
    void setup(ofPoint pos, ofPoint vel);
    void display(ofColor color, bool scaling);
    void reset();
    vector <ofImage> podImages;
    vector <ofImage> fireImages;
    float podAnimationCounter;
    float fireAnimationCounter;
    ofPoint position;
    ofPoint velocity;
    float scale;
};
