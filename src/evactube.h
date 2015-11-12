//
//  evactube.h
//  IndieCade Server
//
//  Created by Clay Ewing on 9/14/14.
//
//

#include "ofMain.h"
#include "evacuee.h"
#include "evacpod.h"

class EvacTube  {
    
public:
    EvacTube();
    void display();
    void setup(ofPoint pos, ofImage * tubeImg, ofImage * tubeBackImage, ofImage *tubeBackEvacuatingImage, ofImage *podImg, ofImage *podImgFront, ofImage *podPlatform);
    void next();
    bool addPower(float p);
    bool evacuating;
    bool destroyed;
    ofImage *tubeImage;
    ofImage *tubeBackImage;
    ofImage *tubeBackImageEvacuating;
    ofImage *podPlatformImage;
    ofSoundPlayer *airlockSound;
    vector<Evacuee> evacuees;
    ofPoint tubePosition;
    EvacPod evacpod;
    //    ofPoint podPosition;
//    float podSpeed;
    int currentEvacuee;
    float power;
    float destructionSpeed;
};
