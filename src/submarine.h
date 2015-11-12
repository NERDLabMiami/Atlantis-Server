//
//  submarine.h
//  IndieCade Server
//
//  Created by Clay Ewing on 9/9/14.
//
//

#include "ofMain.h"
#include "ofxBox2dRect.h"
#include "custom.h"
#include "bubble.h"

#define BUBBLE_SPEED        10
#define STARTING_ARMOR      30

class Submarine : public ofxBox2dRect {
    public:
    void display();
    void setupCustom(int id);
    void shootQueue();
    void shoot(float bubbleSize);
    void addRotation(float amount);
    int armor;
    ofColor color;
    ofImage *image;
    ofImage *glow;
    ofImage *bubbleImage;
    int numberOfPassengers;
    int offset;
    float internalRotation;
    vector<float> bubbleQueue;
    vector <ofPtr<Bubble> > bubbles;
    ofEvent<ofPoint> popped;
};