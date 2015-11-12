//
//  submarine.cpp
//  IndieCade Server
//
//  Created by Clay Ewing on 9/9/14.
//
//

#include "submarine.h"

static bool removeBubble(Bubble b) {
    return b.remove;
}

void Submarine::setupCustom(int id) {
    setData(new CustomData());
    CustomData * theData = (CustomData *)getData();
    theData->type = TYPE_SUBMARINE;
    theData->remove = false;
    theData->id = id;
    armor = STARTING_ARMOR;
    setVelocity(ofRandom(-1,1), ofRandom(1,-1));
    offset = ofRandom(-5,10);
    internalRotation = 0;

}

void Submarine::shootQueue() {
    for (int i = 0; i < bubbleQueue.size(); i++) {
        shoot(bubbleQueue[i]);
    }
    bubbleQueue.clear();
}

void Submarine::shoot(float bubbleSize) {
    ofPtr<Bubble> bubble = ofPtr<Bubble>(new Bubble);
    float xPos = (cos((getRotation()-90) * PI/180)) * (getHeight()/2 + bubbleSize + BUBBLE_SPEED);
    float yPos = (sin((getRotation()-90) * PI/180)) * (getWidth()/2 + bubbleSize + BUBBLE_SPEED);
    bubble.get()->setPhysics(2, .1, 0);
    bubble.get()->setup(this->getWorld(), getPosition().x + xPos, getPosition().y + yPos, bubbleSize, bubbleSize);
    bubble.get()->setVelocity(cos((getRotation()-90)*PI/180) * BUBBLE_SPEED, sin((getRotation()-90)*PI/180) * BUBBLE_SPEED);
    bubble.get()->setData(new CustomData());
    bubble.get()->setupCustom(bubbles.size());
    bubble.get()->color = ofColor(color);
    bubble->image = bubbleImage;

    bubbles.push_back(bubble);
}

void Submarine::addRotation(float amount) {
    internalRotation+= amount;
    setRotation(internalRotation);
}

void Submarine::display() {
    //PLAYER 1 ALWAYS DRIVES?
    if (armor > 0) {
    switch (numberOfPassengers) {
            
        case 1:
            if (int(ofRandom(40))%40 == 1) {
                shoot(ofRandom(10,30));
            }

        case 2:
            //setRotation(ofGetElapsedTimef() * (30 + offset));
            break;
        default:
            break;
    }
    
    ofPushMatrix();
    ofTranslate(getPosition());
    ofRotateZ(getRotation());
    ofSetColor(color);
    if (armor < 5) {
        float alpha (ofMap(sin(ofGetFrameNum() * .3), -1, 1, 40,255));
        ofSetColor(255, 0, 0, alpha);
        glow->draw(-getWidth()/2, -getHeight()/2, getWidth(), getHeight());
        ofSetColor(color, ofMap(armor, STARTING_ARMOR, 0, 100, 255));
    }

    ofFill();
    image->draw(-getWidth()/2, -getHeight()/2, getWidth(), getHeight());
    ofPopMatrix();
    
        
    for (int i = 0; i < bubbles.size(); i++) {
            bubbles[i].get()->display();
        }
    }
    else {
        body->SetActive(false);
    }

}