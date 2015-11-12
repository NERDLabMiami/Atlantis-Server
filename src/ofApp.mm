#include "ofApp.h"
#include "LocalAddressGrabber.h"

static bool removeShape(ofPtr<ofxBox2dBaseShape> shape) {
    CustomData *custom = (CustomData *)shape->getData();
    return custom->remove;
}

static bool removeFizz(Fizzle f) {
    return (f.radius <= 0);
}
static bool removeSubmarine(ofPtr<Submarine> submarine) {
    return (submarine->armor <= 0);
}

static bool removeFireball(Fireball f) {
    return (f.alpha <= 0);
}

//--------------------------------------------------------------
void ofApp::setup(){
    resolutionScaling = ofGetWidth() / 1920;
    nerdlab = new ofxNERDLab();

    ofAddListener(nerdlab->receivedMove, this, &ofApp::move);
    ofAddListener(nerdlab->receivedAccelerometer, this, &ofApp::accelerometer);
    ofAddListener(nerdlab->receivedShake, this, &ofApp::shake);
    ofAddListener(nerdlab->receivedTap, this, &ofApp::tap);
    ofAddListener(nerdlab->receivedRelease, this, &ofApp::release);
    ofAddListener(nerdlab->receivedAudioInput, this, &ofApp::audio);
    ofAddListener(nerdlab->receivedRotate, this, &ofApp::rotate);
    ofAddListener(nerdlab->clientRequest, this, &ofApp::join);
    ofAddListener(nerdlab->clientRejoin, this, &ofApp::rejoin);
    ofAddListener(nerdlab->clientConfirm, this, &ofApp::confirm);
    ofAddListener(nerdlab->rollCallEnded, this, &ofApp::rollCalled);
    ofAddListener(nerdlab->playerCalled, this, &ofApp::playerHighlight);
    ofAddListener(nerdlab->playerQuit, this, &ofApp::playerQuit);

    loadGui();
    startNetworking();
    loadGenericAssets();
    setIndexState(GAME_INDEX_POPULATION, OFXNERDLAB_GAME_STATE_WAITING);
    getawayPod.podImages = nerdlab->loadImageSet("getaway_pod/1");
    getawayPod2.podImages = nerdlab->loadImageSet("getaway_pod/2");
    getawayPod3.podImages = nerdlab->loadImageSet("getaway_pod/3");
    getawayPod.fireImages = nerdlab->loadImageSet("getaway_pod/glow");
    getawayPod2.fireImages = nerdlab->loadImageSet("getaway_pod/glow");
    getawayPod3.fireImages = nerdlab->loadImageSet("getaway_pod/glow");
    escapingSubmarine.podImages = nerdlab->loadImageSet("getaway_pod/submarine");
    escapingSubmarine.fireImages = nerdlab->loadImageSet("pod_fire");
    repeatingSeaBackground.loadImage("backgrounds/sea_cut_1px.png");
    seaBackground.loadImage("backgrounds/sea_climbing_bg.png");
    seaClimbLeft.loadImage("backgrounds/climb_left.png");
    seaClimbRight.loadImage("backgrounds/climb_right.png");
    podEscapeCounter = 0;
    rocket.loadSound("sounds/rocket.aif");
    fireball.loadImage("fireball.png");
    getawayPod.setup(ofPoint(-ofGetWidth()/4, ofGetHeight()), ofPoint(4,-1));
    getawayPod2.setup(ofPoint(-ofGetWidth()/2, ofGetHeight()-140), ofPoint(4,-1));
    getawayPod3.setup(ofPoint(-ofGetWidth()/3, ofGetHeight()-100), ofPoint(4,-1));
    escapingSubmarine.reset();
    escapingSubmarine.setup(ofPoint(ofGetWidth()/2), ofPoint(0,-1));
    podsGetawaySound.loadSound("sounds/spaceship.wav");
}

void ofApp::setIndexState(int idx, int state) {
    gameIndex = idx;
    gameState = state;
}
void ofApp::startNetworking() {
    LocalAddressGrabber :: availableList();
    ipAddress = LocalAddressGrabber :: getIpAddress("en1");

    NSNetService *service;
    service = [[NSNetService alloc] initWithDomain:@"" type:@"_nerdlab._tcp"  name:@"" port:SERVER_PORT];
    if (service) {
        NSLog(@"Publishing Service");
        [service publish];
    }
    else {
        NSLog(@"Trouble publishing service");
    }
 
    
}
void ofApp::loadGui() {
    gui.setup(); // most of the time you don't need a name
    gui.add(startButton.setup("start"));
    gui.add(fullScreenButton.setup("full screen"));
    gui.add(showIpAddress.setup("show ip address", false));
    gui.add(fakePlayerButton.setup("add zombie"));
    gui.add(resetButton.setup("restart"));
    gui.add(killPlayers.setup("reset connections", true));
    gui.add(tapPower.setup("tapping power", 4, .1, 5));
    gui.add(audioPower.setup("yelling power", .4, .1, 1));
    gui.add(shakePower.setup("shake power", .5, .2, 1));
    gui.add(swipePower.setup("swiping power", 2, 2, 5));
    showGui = true;
    startButton.addListener(this, &ofApp::startButtonPressed);
    colorScheme = nerdlab->colors();
    fakePlayerButton.addListener(this, &ofApp::fakePlayer);
    fullScreenButton.addListener(this, &ofApp::toggleFullScreen);
    resetButton.addListener(this, &ofApp::resetGame);
    
}
//--------------------------------------------------------------

void ofApp::loadGenericAssets() {
    bigText.loadFont("joystix.ttf", 120);

    text.loadFont("joystix.ttf", 40);
    smallText.loadFont("joystix.ttf", 20);
    titleImage.loadImage("backgrounds/bg1080.png");
    titleForegroundImage.loadImage("title_foreground.png");
    statusMessagePosition.set(ofGetWidth()*2, 80);
    introMusic.loadSound("sounds/opening.mp3");
    alarm.loadSound("sounds/alarm.wav");
    alarm.setVolume(.3);
    alarm.setLoop(true);
    introMusic.setLoop(true);
    introMusic.play();
    rumble.setLoop(true);
    rumble.loadSound("sounds/rumble.wav");
    explosion.loadSound("sounds/big_explosion.wav");
    rumble.setVolume(.1);
    narrator.initSynthesizer();
    box2d.init();
    box2d.setGravity(0, 0);
    box2d.enableEvents();
    box2d.setFPS(30.0);
    introBackground.loadImage("atlantis_afar.png");
    populationSign.loadImage("backgrounds/population_sign.png");
    titleDiamond.loadImage("glowing_diamond.png");
    fishXDirection = 1;
    bubbleFx.loadSound("sounds/bubble.wav");
    collectFx.setVolume(.2);
    bubbleFx.setVolume(.9);
    bubbleImage.loadImage("ammo/bubble.png");
    narrator.setVolume(.5);

}

void ofApp::resetGame() {
    introMusic.play();
    removeAllGameObjects();
    alarm.stop();
    rocket.stop();

    diamondBackgroundMusic.stop();
    evacuationOpeningMusic.stop();
    evacuationBackgroundMusic.stop();
    submarineBackgroundMusic.stop();
    getawayPod.reset();
    getawayPod2.reset();
    getawayPod3.reset();
    getawayPod.setup(ofPoint(-ofGetWidth()/4, ofGetHeight()-140), ofPoint(4,-1));
    getawayPod2.setup(ofPoint(-ofGetWidth()/2, ofGetHeight()-100), ofPoint(4,-1));
    getawayPod3.setup(ofPoint(-ofGetWidth()/3, ofGetHeight()-80), ofPoint(4,-1));

    escapingSubmarine.reset();
    escapingSubmarine.setup(ofPoint(ofGetWidth()/2), ofPoint(0,-1));
    nerdlab->resetTeams();

    if (killPlayers) {
        nerdlab->clearClientList();
        nerdlab->players.clear();
    }
    setIndexState(GAME_INDEX_POPULATION, OFXNERDLAB_GAME_STATE_WAITING);
}
//--------------------------------------------------------------

void ofApp::move(ofxNERDLabMoveEvent &e) {
    switch (gameIndex) {
        case GAME_INDEX_EVACUATION:
            //
            break;
        case GAME_INDEX_DIAMONDS:
            if (e.id < pods.size()) {
                float xSpeed = e.x * -.08;
                float ySpeed = e.y * -.08;
                pods[e.id].get()->setVelocity(xSpeed, ySpeed);
            }
            break;
        case GAME_INDEX_SUBMARINES:
            if (submarines.size() > e.id) {
                float xSpeed = e.x * -.05;
                float ySpeed = e.y * -.05;
                submarines[e.id].get()->setVelocity(xSpeed, ySpeed);
                }
            break;
    }

}
void ofApp::rotate(ofxNERDLabRotateEvent &e) {
    switch (gameIndex) {
        case GAME_INDEX_EVACUATION:
            if (abs(e.amount) > 100) {

                if(tubes[currentTubeIndex].addPower(swipePower)) {
                    nextTube();
                }
            }


            break;
        case GAME_INDEX_DIAMONDS:
            break;
        case GAME_INDEX_SUBMARINES:
            cout << "Got Rotation from " << e.id << endl;
            if (submarines.size() > e.id) {
                cout << "Rotating " << e.amount << endl;
                submarines[e.id].get()->setRotation(e.amount);
            }
            break;
    }
}

void ofApp::shake(ofxNERDLabAccelerometerEvent &e) {
    switch (gameIndex) {
        case GAME_INDEX_EVACUATION:
            if (nerdlab->players.size() > e.id) {
                if(tubes[currentTubeIndex].addPower(shakePower)) {
                    nextTube();
                }
            }
            
            break;
        case GAME_INDEX_DIAMONDS:
            break;
        case GAME_INDEX_SUBMARINES:
            break;
    }
    
}

void ofApp::accelerometer(ofxNERDLabAccelerometerEvent &e) {
    switch (gameIndex) {
        case GAME_INDEX_EVACUATION:
            if (nerdlab->players.size() > e.id) {
                if (ofDist(nerdlab->players[e.id].lastPoint.x, nerdlab->players[e.id].lastPoint.y, e.x, e.y) > 40) {
                    nerdlab->players[e.id].lastPoint.set(e.x, e.y);

                    if(tubes[currentTubeIndex].addPower(shakePower)) {
                        nextTube();
                    }

                }
            }
            
            break;
        case GAME_INDEX_DIAMONDS:
            break;
        case GAME_INDEX_SUBMARINES:
            break;
    }
}

void ofApp::tap(ofxNERDLabTapEvent &e) {
    switch (gameIndex) {
        case GAME_INDEX_EVACUATION:

            if(tubes[currentTubeIndex].addPower(tapPower)) {
                nextTube();
            }

            break;
        case GAME_INDEX_DIAMONDS:
            break;
        case GAME_INDEX_SUBMARINES:
            break;
    }

}

void ofApp::release(ofxNERDLabReleaseEvent &e) {
    float scale = 0;
    switch (gameIndex) {
        case GAME_INDEX_EVACUATION:

            break;
        case GAME_INDEX_DIAMONDS:
            break;
        case GAME_INDEX_SUBMARINES:
            cout << "Got Release for " << e.id << endl;
            if (submarines.size() > e.id) {
            //crashes
                cout << "Releasing " << e.time << endl;
                if (e.time >= 10) {
                    submarines[e.id].get()->bubbleQueue.push_back(e.time);
                }
                else {
                    bubblePopped(submarines[e.id].get()->getPosition(), false);
                }
            }
            break;
    }
}

void ofApp::audio(ofxNERDLabAudioInputEvent &e) {
    switch (gameIndex) {
        case GAME_INDEX_EVACUATION:
            if(tubes[currentTubeIndex].addPower(ofMap(e.amplitude, 0, 1, 0, audioPower))) {
                nextTube();
            }

            break;
        case GAME_INDEX_DIAMONDS:
            break;
        case GAME_INDEX_SUBMARINES:
            //spin + shoot bubbles
        
            //shoot same size bubble
            if (e.amplitude > .60) {
                submarines[e.id].get()->bubbleQueue.push_back(e.amplitude * 10);
            }
            
            break;
    }

}

void ofApp::nextTube() {
    doorlock.play();
    currentTubeIndex++;
    numberEvacuated++;
    for (int i = 0; i < nerdlab->players.size(); i++) {
        nerdlab->players[i].setScore(numberEvacuated);
    }
    if (currentTubeIndex >= tubes.size()) {
        evacuationChambersCleared++;
        if (evacuationChambersCleared == 3) {
            evacuationTimer = ofGetElapsedTimef() + 30;
        }
        currentTubeIndex = 0;
        string controlMessage = "";
    
        switch (evacuationControlScheme) {
            case OFXNERDLAB_GAME_CONTROL_TAP:
                evacuationControlScheme = OFXNERDLAB_GAME_CONTROL_ACCEL;
                controlMessage = "SHAKE TO RING!";
                bigTextMessage = "SHAKE!";
//                evacuationMessage = "SHAKE THE BELL TO\n SOUND THE ALARM!";
                evacuationMessage = "RING THE ALARM!";
                break;
            case OFXNERDLAB_GAME_CONTROL_ACCEL:
                evacuationControlScheme = OFXNERDLAB_GAME_CONTROL_ROTATE;
                controlMessage = "ROTATE THE VALVE!";
                bigTextMessage = "SWIPE!";
                //evacuationMessage = "    THE VALVES ARE STUCK!\nROTATE TO RELIEVE PRESSURE";
                evacuationMessage = "RELEASE THE PRESSURE!";
                break;
            case OFXNERDLAB_GAME_CONTROL_ROTATE:
                controlMessage = "CALL FOR HELP!";
                bigTextMessage = "SCREAM!";
                //evacuationMessage = "WE NEED MORE POWER!\n  CALL FOR HELP!";
                evacuationControlScheme = OFXNERDLAB_GAME_CONTROL_AUDIO;
                evacuationMessage = "CALL FOR HELP!";
                break;
            case OFXNERDLAB_GAME_CONTROL_AUDIO:
                controlMessage = "TAP TO PUMP!";
                bigTextMessage = "TAP!";
                evacuationMessage = "PUMP OUT THE WATER!";
//                evacuationMessage = "WE'RE TAKING ON WATER!\n TAP TO PUMP IT OUT!";
                evacuationControlScheme = OFXNERDLAB_GAME_CONTROL_TAP;
                break;
            default:
                break;
        }
        //change control scheme
        cout << "Sending New Control Scheme " << evacuationControlScheme << " to Players with message: " << controlMessage << endl;
       // evacuationMessage = controlMessage;
        messageTimer = ofGetElapsedTimef() + 2;
        for (int i = 0; i < nerdlab->players.size(); i++) {
            nerdlab->players[i].sendControl(evacuationControlScheme);
            nerdlab->players[i].sendOutOfGameMessage(controlMessage);
        }
    }
}

void ofApp::confirm(ofxNERDLabMessageEvent &e) {

    nerdlab->players[e.player_id].confirm_message(lastOutgoingMessage);
}
void ofApp::join(ofxNERDLabJoinEvent &e) {
    cout << "Join Event Called" <<endl;
    nerdlab->players[e.player_id].sendState(OFXNERDLAB_GAME_STATE_WAITING);
    nerdlab->players[e.player_id].sendOutOfGameMessage("Connected");
    lastOutgoingMessage = "Connected";
    
}
void ofApp::playerQuit(ofxNERDLabQuitEvent &e) {
    for (int i = 0; i < nerdlab->clients.size(); i++) {
        if(nerdlab->clients[i].ip == e.ip) {
            nerdlab->players.erase(nerdlab->players.begin()+i);
            nerdlab->clients.erase(nerdlab->clients.begin()+i);
            switch (gameIndex) {
                case GAME_INDEX_EVACUATION:
                    //
                    break;
                case GAME_INDEX_DIAMONDS:
                    if (gameState == OFXNERDLAB_GAME_STATE_PLAYING) {
                        pods.erase(pods.begin()+i);
                    }
                    break;
                case GAME_INDEX_SUBMARINES:
                    break;
            }

            

            break;
        }
    }
   
}
void ofApp::rejoin(ofxNERDLabJoinEvent &e) {
    switch (gameIndex) {
        case GAME_INDEX_EVACUATION:
            nerdlab->players[e.player_id].resend(e.player_id, e.name, gameState, ofColor(255,255,255));
            //
            break;
        case GAME_INDEX_DIAMONDS:
            cout << "SENDING GAME STATE" << gameState << endl;
            //they have quit, so they don't exist. need to create a new player, then send rejoin message.
            if (gameState == OFXNERDLAB_GAME_STATE_PLAYING) {
                nerdlab->players[e.player_id].resend(e.player_id, e.name, gameState, pods[e.player_id]->color);
                nerdlab->players[e.player_id].setScoreName("diamonds");
                nerdlab->players[e.player_id].setScore(nerdlab->players[e.player_id].score);
                cout << "Sending to IP " << e.ip << endl;
            }
                break;
        case GAME_INDEX_SUBMARINES:
            //TODO: Look up team id
            //      send controls
            if (gameState == OFXNERDLAB_GAME_STATE_PLAYING) {
            int teamId = e.player_id/3;
            cout << "assigning team #" << teamId << endl;
            nerdlab->players[e.player_id].resend(teamId, e.name, gameState, submarines[teamId]->color);
                switch (e.player_id%3) {
                    case 0:
                        cout << "sending driving controls" << endl;
                        nerdlab->players[e.player_id].sendControl(OFXNERDLAB_GAME_CONTROL_MOVE);
                        break;
                    case 1:
                        cout << "sending tap controls" << endl;
                        nerdlab->players[e.player_id].sendControl(OFXNERDLAB_GAME_CONTROL_TAP);
                        break;
                    case 2:
                        cout << "sending rotation controls" << endl;
                        nerdlab->players[e.player_id].sendControl(OFXNERDLAB_GAME_CONTROL_ROTATE);
                        break;
                    default:
                        break;
                }
                nerdlab->players[e.player_id].setScoreName("armor left");
                nerdlab->players[e.player_id].setScore(submarines[teamId]->armor);

                
            }
            break;
    }
    

}

void ofApp::playerHighlight(ofxNERDLabJoinEvent &e) {
    switch (gameIndex) {
        case GAME_INDEX_EVACUATION:
            //
            break;
            
        case GAME_INDEX_DIAMONDS:
            highlightedId = e.player_id;
//            nerdlab->players[e.player_id].sendControl(OFXNERDLAB_GAME_CONTROL_MOVE);
//            nerdlab->players[e.player_id].sendInGameMessage("drag to move!");
            //TODO: Send Vibration/Pulse
            highlightedPlayerName = e.name;
            pods[e.player_id].get()->highlight = true;
            break;

        case GAME_INDEX_SUBMARINES:
            highlightedId = e.team_id;
            if (e.player_id%3 == 0) {
                //move
                highlightedPlayerName = e.name + " is captain!\n";
            }
            
            else if (e.player_id%3 == 1) {

                //shoot
                highlightedPlayerName = highlightedPlayerName + e.name + " is blowing bubbles\n";

            }
            
            else if (e.player_id%3 == 2){
                //rotate
                highlightedPlayerName = highlightedPlayerName + e.name + " is aiming the canon";
            }

            highlightedPlayerPoint = ofPoint(ofGetWidth()/2, ofGetHeight()/2);

            break;
    }
}

void ofApp::newPod(int shapeId, int colorIndex) {
    ofPtr<Pod> p = ofPtr<Pod>(new Pod);
    
    p.get()->setPhysics(15, .2, 5);
    p.get()->setup(box2d.getWorld(), ofGetWidth()/2, ofGetHeight()/2, podImages[shapeId].width/2, podImages[shapeId].height/2);
    p.get()->setVelocity(0,0);
    p.get()->setData(new CustomData());
    p.get()->setupCustom(pods.size());
    p.get()->color = colorScheme[colorIndex];
    nerdlab->players[pods.size()].useImageSet(OFXNERDLAB_IMAGE_SET_ABSTRACT);
    nerdlab->players[pods.size()].setColor(colorScheme[colorIndex]);
    nerdlab->players[pods.size()].setScoreName("Diamonds");
    cout << "Using Image # " << shapeId << endl;
    nerdlab->players[pods.size()].setImageNumber(shapeId);
    nerdlab->players[pods.size()].setControlsEnabled(true);
    nerdlab->players[pods.size()].setId();
    p.get()->image = &podImages[shapeId];
    p.get()->glow = &podGlowImages[shapeId];
    pods.push_back(p);

}
void ofApp::rollCalled(ofxNERDLabRollCalled &e) {
    cout << "Roll Call Finished" << endl;
    timeToEndRollCall = e.time + 2;
    
    for (int i = 0; i < nerdlab->players.size(); i++) {
        nerdlab->players[i].setControlsEnabled(true);
        nerdlab->players[i].sendState(OFXNERDLAB_GAME_STATE_PLAYING);
        cout << "sending player " << i << "play notice" << endl;
    }
    setIndexState(gameIndex, OFXNERDLAB_GAME_STATE_PLAYING);
    
    
    switch (gameIndex) {
        case GAME_INDEX_EVACUATION:
            //
            break;
        case GAME_INDEX_DIAMONDS:
            ofAddListener(box2d.contactStartEvents, this, &ofApp::contactDiamonds);
            //Diamond Rush
            for (int i = diamonds.size(); i < STARTING_NUMBER_OF_DIAMONDS; i++) {
                newDiamond();
            }
            
            break;
        case GAME_INDEX_SUBMARINES:
            ofAddListener(box2d.contactStartEvents, this, &ofApp::contactSubmarine);
            
            break;
    }
    
    
}


void ofApp::update(){
    //ofRemove(diamonds, removeShape);
    ofRemove(fizz, removeFizz);
    ofRemove(fireballs, removeFireball);
    if (submarines.size() > 0) {
        for (int i = 0; i < submarines.size(); i++) {
            ofRemove(submarines[i]->bubbles, removeShape);
        }
    }
    int mostDiamondsHoarded = 0;
    int highlightedHoarder = 0;

    switch (gameState) {
        case OFXNERDLAB_GAME_STATE_WAITING:
            switch (gameIndex) {
                case GAME_INDEX_INTRODUCTION:
                    if (introTimer < ofGetElapsedTimef()) {
                        startEvacuation();
                    }
                    
                        break;
                case GAME_INDEX_DIAMONDS:
                    sceneCounter += .28;
                    if (sceneCounter <= 230) {
                        bubblePopped(ofPoint(ofRandom(ofGetWidth()), ofRandom(ofGetHeight()-10, ofGetHeight())), true);

                    }
                    if (sceneCounter <= 30) {
                        fireballs.push_back(Fireball(&fireball));
                    }
                    if (sceneCounter >= 255) {
                        startDiamonds();
                        sceneCounter = 0;
                    }
                    break;
                    
                case GAME_INDEX_SUBMARINES:
                    getAwayCutSceneCounter++;
                    if (getAwayCutSceneCounter >= 1300) {
                        
                        startSubmarines();
                        unloadDiamondAssets();
                    }
                    

                    break;
                default:
                    break;
            }
            break;
        case OFXNERDLAB_GAME_STATE_ASSIGNING_CONTROLS:
            break;
        case OFXNERDLAB_GAME_STATE_ROLL_CALL:
            //push rollcall further with the timer
           // cout << "still in roll call. time to end is " << timeToEndRollCall << " and it's " << ofGetElapsedTimef() << endl;
            nerdlab->rollcall();
            switch (gameIndex) {
                case GAME_INDEX_DIAMONDS:

                    break;
                    
                default:
                    break;
            }
            break;
        case OFXNERDLAB_GAME_STATE_PLAYING:
            switch (gameIndex) {
                case GAME_INDEX_EVACUATION:
                    drawFish();
                    if(ofGetFrameNum()%200 == 0) {
                        bubblePopped(ofPoint(ofRandom(ofGetWidth()), ofRandom(ofGetHeight()+20, ofGetHeight())), true);
                    }


                    if (!evacuationOpeningMusic.getIsPlaying() && !evacuationLoopStarted) {
                        evacuationBackgroundMusic.play();
                        evacuationLoopStarted = true;
                    }
                    if (evacuationChambersCleared >= 4 && !shaking) {
                        shaking = true;
                        rumble.play();
                    }
                    if (rumble.getIsPlaying() && rumble.getVolume() < 1) {
                        rumble.setVolume(rumble.getVolume() * 1.01);
                        if (ofGetFrameNum()%550 == 0) {
                            bubblePopped(ofPoint(ofRandom(ofGetWidth()), ofRandom(ofGetHeight()+20, ofGetHeight())), true);
                        }

                    }
                    if (evacuationChambersCleared >= 4 && evacuationTimer < ofGetElapsedTimef()) {
                        shaking = false;
                        rumble.stop();
                        rumble.setVolume(.1);
                        explosion.play();
                        endOfEvacuation();
                        loadDiamondAssets();

                    }
                    break;
                case GAME_INDEX_DIAMONDS:
                    for (int i = 0; i < nerdlab->players.size(); i++) {
                        
                        if(nerdlab->players[i].score > mostDiamondsHoarded) {
                            mostDiamondsHoarded = nerdlab->players[i].score;
                            highlightedHoarder = i;
                            
                        }
                    }
                    statusMessage = "#1 Hoarder: " + nerdlab->players[highlightedHoarder].name + "(" + ofToString(mostDiamondsHoarded) + ")";

                    statusMessagePosition.x--;
                    if (statusMessagePosition.x < -(text.stringWidth(statusMessage) * 1.1)) {
                        statusMessagePosition.x = ofGetWidth();
                    }
                    if (pods.size() <= 0) {
                        setIndexState(GAME_INDEX_SUBMARINES, OFXNERDLAB_GAME_STATE_WAITING);
                        loadSubmarineAssets();
                    }
                    
                    for (int i = 0; i < nerdlab->players.size(); i++) {
                        if (nerdlab->players[i].score >= DIAMONDS_TO_WIN) {
                            //
                            ofRemoveListener(box2d.contactStartEvents, this, &ofApp::contactDiamonds);
                            
                            //continue looking at the rest of the players
                            mostDiamondsCollected = nerdlab->players[i].score;
                            playerWithMostDiamonds = nerdlab->players[i].name;
                            playerWithMostDiamondsId = i;
                            for (int j = i; j < nerdlab->players.size(); j++) {
                                if(nerdlab->players[j].score > mostDiamondsCollected) {
                                    mostDiamondsCollected = nerdlab->players[j].score;
                                    playerWithMostDiamonds = nerdlab->players[j].name;
                                    playerWithMostDiamondsId = j;
                                    
                                }
                            }
                            loadSubmarineAssets();
                            endOfDiamonds();
                            setIndexState(GAME_INDEX_SUBMARINES, OFXNERDLAB_GAME_STATE_WAITING);
                            }
                        }
                    
                        if (nextDiamondEruption < ofGetElapsedTimef()) {
                            cout << "Diamond Eruption" << endl;
                            for (int i = 0; i < DIAMONDS_REFILL; i++) {
                                newDiamond();
                            }
                            nextDiamondEruption = ofGetElapsedTimef() + ofRandom(5);
                        }
                        else {
                        }

                    break;
                case GAME_INDEX_SUBMARINES:
                    int numberAlive = 0;
                    for (int i = 0; i < submarines.size(); i++) {
                        submarines[i].get()->shootQueue();
                        //ofRemove(submarines[i]->bubbles, removeShape);
                        if (submarines[i].get()->armor > 0) {
                            numberAlive++;
                        }
                    }
                    if (numberAlive <= 1) {
                        
                        winningTeamId = -1;
                        for (int i = 0; i < submarines.size(); i++) {
                            if(submarines[i].get()->armor > 0) {
                                winningTeamId = i;
                                cout << "FOUND WINNING TEAM #" << i << endl;
                            }
                        }
                        winningTeamMembers = nerdlab->teamMembers(winningTeamId);
                        if (winningTeamId == -1) {
                            escapeSubmarineColor = ofColor::black;
                        }
                        else {
                            escapeSubmarineColor = submarines[winningTeamId].get()->color;

                        }
                        setIndexState(GAME_INDEX_SUBMARINES, OFXNERDLAB_GAME_STATE_GAME_OVER);
                    }
                    
                    
                    break;
            }
            
            
            break;
            
        case OFXNERDLAB_GAME_STATE_GAME_OVER:
            switch (gameIndex) {
                case GAME_INDEX_EVACUATION:
                    //
                    break;
                case GAME_INDEX_DIAMONDS:
                    break;
                case GAME_INDEX_SUBMARINES:
                    for (int i = 0; i < nerdlab->players.size(); i++) {
                        nerdlab->players[i].sendState(OFXNERDLAB_GAME_STATE_PAUSED);
                        nerdlab->players[i].setControlsEnabled(false);
                        lastOutgoingMessage = "Game Over";
                        nerdlab->players[i].sendOutOfGameMessage("Game Over");
                    }
                    setIndexState(GAME_INDEX_GAME_CREDITS, OFXNERDLAB_GAME_STATE_GAME_OVER);
                    submarineBackgroundMusic.stop();
                    introMusic.play();
                    rocket.play();

                    unloadSubmarineAssets();
                    break;
                case GAME_INDEX_GAME_CREDITS:
                    getAwayCutSceneCounter++;
                    if (getAwayCutSceneCounter >= 1400) {
                        resetGame();
                    }
                    break;
            }
            break;
            
        default:
            break;
    }
    box2d.update();

    
}

//--------------------------------------------------------------
void ofApp::draw(){
    
    switch (gameState) {
        case OFXNERDLAB_GAME_STATE_WAITING:

            switch (gameIndex) {
                case GAME_INDEX_POPULATION:
                    ofBackground(0, 0, 0);
                    ofSetColor(255, 255, 255);
                    titleImage.draw(0, 0, ofGetWidth(), ofGetHeight());
                    populationSign.draw((ofGetWidth()/2) - 80, ofGetHeight()-populationSign.height - 40);
                    titleDiamond.draw(0, 0, ofGetWidth(), ofGetHeight());
                    titleForegroundImage.draw(0, 0, ofGetWidth(), ofGetHeight());
                    ofSetColor(200,200,200,200);
                    smallText.drawString("population: " + ofToString(nerdlab->players.size()), (ofGetWidth()/2), ofGetHeight()-40-(populationSign.height/2.2));

                    break;
                case GAME_INDEX_INTRODUCTION:
                    //fade in and out
                    ofSetColor(155 + (ofGetFrameNum()%100), 0, 0);
                    introBackground.draw(0, 0, ofGetWidth(), ofGetHeight());
                    drawEvacuationAlert();
                    break;
                case GAME_INDEX_GAME_CREDITS:
                    break;
                case GAME_INDEX_EVACUATION:
                    
                    
                    break;
                case GAME_INDEX_DIAMONDS:
                    ofBackground(0, 0, 0);
                    ofSetColor(255, 255, 255);
                    evacuationBackgroundImage.draw(0, 0, ofGetWidth(), ofGetHeight());
                    evacuationPlatformImage.draw(0,ofGetHeight() - evacuationPlatformImage.height + sceneCounter, ofGetWidth(), evacuationPlatformImage.height);
                    drawRotatedFrames();
                    for (int i = 0; i < tubes.size(); i++) {
                        tubes[i].display();
                    }
                    for (int i = 0; i < fizz.size(); i++) {
                        fizz[i].display();
                    }

                    
                    drawDiamondSea(sceneCounter, true);
                    drawDiamondVolcanoes(sceneCounter);

                    for (int i = 0; i < fireballs.size(); i++) {
                        fireballs[i].display();
                    }
                    ofSetColor(0);
                    text.drawStringCentered(ofToString(numberEvacuated) + " citizens evacuated!", ofGetWidth()/2-2, ofGetHeight()/3-2);

                    ofSetColor(255, 255, 255);
                    text.drawStringCentered(ofToString(numberEvacuated) + " citizens evacuated!", ofGetWidth()/2, ofGetHeight()/3);
                    
                    break;
                case GAME_INDEX_SUBMARINES:
                    drawGetaway();
                    
                    break;
            }
            break;
        case OFXNERDLAB_GAME_STATE_ASSIGNING_CONTROLS:
            switch (gameIndex) {
                case GAME_INDEX_EVACUATION:
                    //
                    break;
                case GAME_INDEX_DIAMONDS:
                    break;
                case GAME_INDEX_SUBMARINES:
                    break;
            }
            break;
        case OFXNERDLAB_GAME_STATE_ROLL_CALL:
            switch (gameIndex) {
                case GAME_INDEX_EVACUATION:
                    //
                    break;
                case GAME_INDEX_DIAMONDS:
                    ofBackground(0, 0, 0);
                    drawDiamondSea(255, true);
                    pods[highlightedId].get()->display();
/*                    for (int i = 0; i < pods.size(); i++) {
                        pods[i].get()->display();
                    }
 */
                    drawDiamondVolcanoes(255);
                    ofSetColor(0);
                    text.drawStringCentered(highlightedPlayerName, ofGetWidth()/2-2, ofGetHeight()/3-2);
                    ofSetColor(255, 255, 255);
                    text.drawStringCentered(highlightedPlayerName, ofGetWidth()/2, ofGetHeight()/3);
                    
                    break;
                case GAME_INDEX_SUBMARINES:
                    drawSubmarineSea();
                    //JUST SHOW HIGHLIGHTED SUB, NOTHING ELSE
                    submarines[highlightedId].get()->display();
                    ofSetColor(0);
                    text.drawString(highlightedPlayerName, 40, ofGetHeight()/3-2);
                    
                    ofSetColor(255, 255, 255);
                    text.drawString(highlightedPlayerName, 42, ofGetHeight()/3);

                    break;
            }
            break;
        case OFXNERDLAB_GAME_STATE_PLAYING:
            switch (gameIndex) {
                case GAME_INDEX_EVACUATION:
                    ofBackground(0, 0, 0);
                    ofSetColor(255, 255, 255);
                    evacuationBackgroundImage.draw(0, 0, ofGetWidth(), ofGetHeight());
                    bgFishImage.draw(fishX, fishY);
                    
                    for (int i = 0; i < fizz.size(); i++) {
                        fizz[i].display();
                    }
                    
                    if (shaking) {
                        
                        evacuationPlatformImage.draw(0,ofGetHeight() - evacuationPlatformImage.height + ofRandom(0,5), ofGetWidth(), evacuationPlatformImage.height);
                    }
                    else {
                        evacuationPlatformImage.draw(0,ofGetHeight() - evacuationPlatformImage.height, ofGetWidth(), evacuationPlatformImage.height);
                        
                    }


                    drawFrames();
                    for (int i = 0; i < tubes.size(); i++) {
                        tubes[i].display();
                        if (shaking) {
                            tubes[i].tubePosition.x += ofRandom(-evacuationChambersCleared*.1,evacuationChambersCleared*.1);
                            tubes[i].tubePosition.y += ofRandom(-evacuationChambersCleared*.05, evacuationChambersCleared*.05);
                        }
                    }
                    
                    drawBeams();
                    for (int i = 0; i < fireballs.size(); i++) {
                        fireballs[i].display();
                    }
                    ofSetColor(0);
                    if (evacuationChambersCleared >= 4) {
                        text.drawStringCentered(ofToString(int(evacuationTimer - ofGetElapsedTimef())), (ofGetWidth()/2)-2, (ofGetHeight()/3)-2);
                        ofSetColor(255, 255, 255);
                        text.drawStringCentered(ofToString(int(evacuationTimer - ofGetElapsedTimef())), ofGetWidth()/2, ofGetHeight()/3);
                    }
                    
                    if (messageTimer > ofGetElapsedTimef()) {
                        ofSetColor(0);
                        text.drawStringCentered(evacuationMessage, ofGetWidth()/2-2, ofGetHeight()/2-2);
                        ofSetColor(255, 255, 255);
                        text.drawStringCentered(evacuationMessage, ofGetWidth()/2, ofGetHeight()/2);
                    } else {
                        if (ofGetFrameNum()%80 < 20) {
                            ofSetColor(0);
                            bigText.drawStringCentered(bigTextMessage, ofGetWidth()/2, ofGetHeight()/2-2);
                            ofSetColor(255, 255, 255);
                            bigText.drawStringCentered(bigTextMessage, ofGetWidth()/2-2, ofGetHeight()/2);

                        }

                        //BIGTEXTMESSAGE
                    }

                    break;
                case GAME_INDEX_DIAMONDS:
                    //game
                    ofBackground(0, 0, 0);
                    drawDiamondSea(255, true);
                    drawDiamondVolcanoes(255);

                    for (int i = 0; i < pods.size(); i++) {
                        pods[i].get()->display();
                    }
                    ofSetColor(0, 0, 0);
                    text.drawStringCentered(statusMessage, ofGetWidth()/2-2, 80);
                    ofSetColor(255, 255, 255);
                    text.drawStringCentered(statusMessage, ofGetWidth()/2, 80);
                    
                    break;
                case GAME_INDEX_SUBMARINES:

                    drawSubmarineSea();
                    for (int i = 0; i < submarines.size(); i++) {
                        submarines[i].get()->display();
                    }
                    for (int i = 0; i < fizz.size(); i++) {
                        fizz[i].display();
                    }
                    
                    for (int i = 0; i < fireballs.size(); i++) {
                        fireballs[i].display();
                    }
                    
                    break;
            }

            break;
        case OFXNERDLAB_GAME_STATE_GAME_OVER:
            switch (gameIndex) {
                case GAME_INDEX_EVACUATION:
                    //
                    break;
                case GAME_INDEX_DIAMONDS:
                    ofSetColor(255, 255, 255);
                    text.drawString("GAME OVER", 0, 40);
                    text.drawString(playerWithMostDiamonds + " collected " + ofToString(mostDiamondsCollected), 0, 80);
                    //cool but causing crashes. == taking victory lap
                    // pods[playerWithMostDiamondsId]->display();

                    break;
                case GAME_INDEX_SUBMARINES:
                    ofSetColor(255, 255, 255);
                    text.drawString("GAME OVER", 0, 40);
                    text.drawString("WINNING TEAM ID " + ofToString(winningTeamId), 0, 80);

                    break;
                case GAME_INDEX_GAME_CREDITS:
                    ofBackground(0, 0, 0);
                    drawSurvivors();
            }
            break;

        default:
            break;
    }
    if( showGui ){
		gui.draw();
	}
    if ( showIpAddress) {
        ofSetColor(255,255,255);
        smallText.drawString(ipAddress + "\nSSID: SecureCanes", ofGetWidth()-populationSign.width/1.2, ofGetHeight()-(populationSign.height/3));

    }

}

void ofApp::removeAllGameObjects() {

//STOP LISTENING FOR ANY CONTACT
    ofRemoveListener(box2d.contactStartEvents, this, &ofApp::contactDiamonds);
    ofRemoveListener(box2d.contactStartEvents, this, &ofApp::contactSubmarine);

    //DIAMONDS
    for (int i = 0; i < pods.size(); i++) {
        pods[i]->destroy();
    }
    pods.clear();
    
    for (int i = 0; i < diamonds.size(); i++) {
        diamonds[i]->destroy();
    }
    diamonds.clear();
    
//SUBMARINES
    for (int i = 0; i < submarines.size(); i++) {
        for (int j = 0; j < submarines[i]->bubbles.size(); j++) {
            submarines[i]->bubbles[j]->destroy();
        }
        submarines[i].get()->destroy();
    }
    submarines.clear();
}

void ofApp::startButtonPressed() {
    loadEvacuationAssets();
    setIndexState(GAME_INDEX_INTRODUCTION, OFXNERDLAB_GAME_STATE_WAITING);
    introTimer = ofGetElapsedTimef() + 6.5;
    narrator.speakPhrase("[[slnc]]Breach Detected! Evacuate Immediately!");
    showGui = false;
    ofHideCursor();

    for (int i = 0; i < nerdlab->players.size(); i++) {
        nerdlab->players[i].sendState(OFXNERDLAB_GAME_STATE_PAUSED);
        nerdlab->players[i].sendOutOfGameMessage("Evacuation in Progress!");
    }
    introMusic.stop();
//    for (int x = beamLeftImage.width - 10; x < ofGetWidth(); x+= evacTubeImage.width + beamImage.width - 20) {
    alarm.play();
    int columnWidth = evacTubeImage.width;
    for (int x = 20; x < ofGetWidth()-evacTubeImage.width; x+= columnWidth) {

        EvacTube tube = *new EvacTube();
        tube.setup(ofPoint(x, 0), &evacTubeImage, &evacTubeBackImage, &evacTubeBackImageEvacuating, &evacPodImages[tubes.size()%evacPodImagesFront.size()], &evacPodImagesFront[tubes.size()%evacPodImagesFront.size()], &evacPlatforms[tubes.size()%evacPlatforms.size()]);
        tube.airlockSound = &airlock;
        for (int i = 0; i < 5; i++) {
            Evacuee evacuee = *new Evacuee();
            evacuee.setup(tube.tubePosition, &evacueeImages[int(ofRandom(evacueeImages.size()))]);
            evacuee.next();
            tube.evacuees.push_back(evacuee);
        }
        tube.next();
        tubes.push_back(tube);
    }
    for (int i = 0; i < tubes.size(); i++) {
        frameIndex.push_back(ofRandom(frameImages.size()));
    }

}

void ofApp::loadEvacuationAssets() {
    evacuationBackgroundMusic.loadSound("sounds/evacuation_loop.mp3");
    evacuationOpeningMusic.loadSound("sounds/evacuation_opening.wav");
    airlock.loadSound("sounds/airlock.wav");
    doorlock.loadSound("sounds/doorlock.wav");
    evacuationBackgroundMusic.setLoop(true);
    evacuationBackgroundImage.loadImage("backgrounds/evacuation.png");
    evacuationPlatformImage.loadImage("backgrounds/evac_platform.png");
    evacTubeImage.loadImage("evac_holder.png");
    evacTubeBackImage.loadImage("evac_holder_back.png");
    evacTubeBackImageEvacuating.loadImage("evac_holder_back_evacuating.png");
    bgFishImage.loadImage("bgfish.png");
    evacPodImages = nerdlab->loadImageSet("evac_pods");
    evacPlatforms = nerdlab->loadImageSet("evac_platforms");
    evacPodImagesFront = nerdlab->loadImageSet("evac_pods_front");
    evacueeImages = nerdlab->loadImageSet("atlanteans/smaller");
    frameImages = nerdlab->loadImageSet("frames");
    
    //defaults
    doorlock.setVolume(.3);
    airlock.setVolume(.25);
    evacuationBackgroundMusic.setVolume(1);

}

void ofApp::unloadEvacuationAssets() {
    evacuationBackgroundMusic.unloadSound();
    evacuationOpeningMusic.unloadSound();
    airlock.unloadSound();
    doorlock.unloadSound();
    evacuationBackgroundImage.clear();
    evacuationPlatformImage.clear();
    evacTubeImage.clear();
    evacTubeBackImage.clear();
    evacTubeBackImageEvacuating.clear();
    bgFishImage.clear();
    evacPodImages.clear();
    frameImages.clear();
}


void ofApp::startEvacuation() {
    shaking = false;
    fishX = ofGetWidth() + 20;
    fishY = ofRandom(ofGetHeight()/2 - 50, ofGetHeight() + 50);
    fishXSpeed = ofRandom(1,3);
    currentTubeIndex = 0;
    numberEvacuated = 0;
    evacuationChambersCleared = 0;
    evacuationLoopStarted = false;
    evacuationControlScheme = OFXNERDLAB_GAME_CONTROL_TAP;
//    evacuationMessage = "TAP TO PUMP!";
    evacuationMessage = "PUMP OUT THE WATER!";
    bigTextMessage = "TAP!";

    removeAllGameObjects();
    for (int i = 0; i < nerdlab->players.size(); i++) {
        nerdlab->players[i].startWithParameters(OFXNERDLAB_IMAGE_SET_HUMANS, 0, ofColor(255,255,255), "citizens evacuated", 0, OFXNERDLAB_GAME_CONTROL_TAP);
         nerdlab->players[i].sendOutOfGameMessage(evacuationMessage);
    }
    setIndexState(GAME_INDEX_EVACUATION, OFXNERDLAB_GAME_STATE_PLAYING);
    narrator.speakPhrase("Evacuation pods engaged. Work together to charge the pods.");
    alarm.stop();
    evacuationOpeningMusic.play();
    messageTimer = ofGetElapsedTimef() + 2;
    
}

void ofApp::drawEvacuationAlert() {
    ofSetColor(0);
    if (ofGetFrameNum()%200 < 100) {
        text.drawStringCentered("breach detected!", ofGetWidth()/2-2, 48);
    }
    else {
        text.drawStringCentered("evacuate immediately!", ofGetWidth()/2, 50);
    }
    
    ofSetColor(255, 255, 255);
    
    if (ofGetFrameNum()%200 < 100) {
        text.drawStringCentered("breach detected!", ofGetWidth()/2, 50);
    }
    else {
        text.drawStringCentered("evacuate immediately!", ofGetWidth()/2, 50);
    }

}

void ofApp::drawFish() {
    fishX-=fishXSpeed * fishXDirection;
    fishY-=cos(ofGetElapsedTimef()) * 1.5;
    if (fishX < -bgFishImage.width*2) {
        fishX = -bgFishImage.width;
        fishXDirection *= -1;
        fishXSpeed = ofRandom(1,3);
        fishY = ofRandom(ofGetHeight()/2 - 50, ofGetHeight() + 50);
        bgFishImage.mirror(false, true);
    }
    if (fishX > ofGetWidth() + bgFishImage.width * 2) {
        fishXSpeed = ofRandom(1,3);
        fishX = ofGetWidth();
        fishXDirection *= -1;
        fishY = ofRandom(ofGetHeight()/2 - 50, ofGetHeight() + 50);
        bgFishImage.mirror(false, true);
    }
    
}
void ofApp::drawFrames() {
    ofSetColor(255, 255, 255);
    for (int i = 0; i < tubes.size(); i++) {
       frameImages[frameIndex[i]].draw(tubes[i].tubePosition.x - 10, tubes[i].tubePosition.y);
    }
}
void ofApp::drawBeams() {

//    beamLeftImage.draw(0, 0);
    for (int i = 0; i < tubes.size(); i++) {
//        beamImage.draw(tubes[i].tubePosition.x, 0);
    }
//    beamRightImage.draw(ofGetWidth()-beamRightImage.width, 0);
}

void ofApp::drawRotatedFrames() {
    rotatedFrameMovement-= 1;

    ofSetColor(255, 255, 255);
    for (int i = 0; i < tubes.size(); i++) {
        ofPushMatrix();
        ofTranslate(tubes[i].tubePosition.x, tubes[i].tubePosition.y);
        if (i%2 == 0) {
            ofRotateZ(ofGetElapsedTimef());
            
        }
        else {
            ofRotateZ(-ofGetElapsedTimef());
            
        }
        frameImages[frameIndex[i]].draw(0,rotatedFrameMovement);
        ofPopMatrix();
    }
}

void ofApp::endOfEvacuation() {
    for (int i = 0; i < nerdlab->players.size(); i++) {
        nerdlab->players[i].setControlsEnabled(false);
        lastOutgoingMessage = "The Economy Has Collapsed!";
        nerdlab->players[i].sendOutOfGameMessage("The Economy Has Collapsed!");
        //nerdlab->players[i].sendBackground(GAME_INDEX_DIAMONDS);
    }
    volcanoForeground.loadImage("volcano_front.png");
    volcanoBackground.loadImage("volcano_behind.png");
    setIndexState(GAME_INDEX_DIAMONDS, OFXNERDLAB_GAME_STATE_WAITING);
    evacuationBackgroundMusic.stop();
    lonePodStartingX = ofGetWidth()+bgFishImage.width;
    narrator.speakPhrase("[[slnc 3000]] Atlantis is gone. The economy has collapsed. Citizens are looting the erupting diamond mines to trade at the surface. It's everyone for themself.");
    for (int i = 0; i < tubes.size(); i++) {
        tubes[i].destroyed = true;
    }

}

void ofApp::loadDiamondAssets() {
    topWaves = nerdlab->loadImageSet("backgrounds/waves/top");
    bottomWaves = nerdlab->loadImageSet("backgrounds/waves/bottom");
    diamondImage.loadImage("diamond.png");
    oceanImage.loadImage("backgrounds/seabg_1080.png");
    collectFx.loadSound("sounds/collect.wav");
    diamondBackgroundMusic.loadSound("sounds/diamond_music.wav");
    diamondBackgroundMusic.setLoop(true);
    podImages = nerdlab->loadImageSet("abstract");

}

void ofApp::unloadDiamondAssets() {
    diamondImage.clear();
    oceanImage.clear();
    collectFx.unloadSound();
    diamondBackgroundMusic.unloadSound();
    podImages.clear();
}

void ofApp::startDiamonds() {
    unloadEvacuationAssets();
    tubes.clear();
    fizz.clear();
    narrator.speakPhrase("Head Count Initiated");
    diamondBackgroundMusic.play();
    diamondMines.push_back(ofPoint(ofGetWidth()/5, ofGetHeight()-20));
    diamondMines.push_back(ofPoint(ofGetWidth()/2, ofGetHeight()-20));
    diamondMines.push_back(ofPoint(ofGetWidth()-(ofGetWidth()/5), ofGetHeight()-20));
    
    nextDiamondEruption = ofGetElapsedTimef() + ofRandom(5);
    //ALL PLAYERS THAT ARE PLAYING WILL HAVE JOINED AT THIS POINT
    box2d.createBounds();
    removeAllGameObjects();
    
    //ASSIGN AVATARS (+IMAGESET) AND CONTROLS
    assignShapesWithDifferentColors();
    cout << "Starting Roll Call" << endl;

    setIndexState(GAME_INDEX_DIAMONDS, OFXNERDLAB_GAME_STATE_ROLL_CALL);
}

void ofApp::drawSurvivors() {
    seaBackground.draw(0, ofGetHeight()-seaBackground.getHeight()+podEscapeCounter);
    seaClimbLeft.draw(0, ofGetHeight()-seaClimbLeft.getHeight()+podEscapeCounter);
    seaClimbRight.draw(ofGetWidth()-seaClimbRight.width,ofGetHeight()-seaClimbRight.getHeight()+podEscapeCounter);
    escapingSubmarine.display(escapeSubmarineColor, false);
    podEscapeCounter++;
    ofSetColor(0, 0, 0);
    text.drawStringCentered("SURVIVORS", ofGetWidth()/3-2, ofGetHeight()/2-2);
    text.drawString(winningTeamMembers, ofGetWidth()/3-2, (ofGetHeight()/1.5)-2);
    
    ofSetColor(255, 255, 255);
    text.drawStringCentered("SURVIVORS", ofGetWidth()/3, ofGetHeight()/2);
    text.drawString(winningTeamMembers, ofGetWidth()/3, ofGetHeight()/1.5);
    
}

void ofApp::drawGetaway() {
   /* if (getAwayCutSceneCounter <= 255) {
        ofSetColor(getAwayCutSceneCounter,getAwayCutSceneCounter,getAwayCutSceneCounter);
    }
    else {
        ofSetColor(255,255,255);
        
    }*/
    drawDiamondSea(255, true);
    getawayPod.display(ofColor::white, true);
    getawayPod2.display(ofColor::white, true);
    getawayPod3.display(ofColor::white, true);
    podEscapeCounter++;
 
    if (getAwayCutSceneCounter >= 500) {
        ofSetColor(0);
        smallText.drawStringCentered("  Each player is grouped into\n       a team of three\n\n  The captain moves by dragging\nThe technician rotates by swiping\nThe shooter yells to blow bubbles", ofGetWidth()/2-2, 300 - 2);
        ofSetColor(255, 255, 255);
        smallText.drawStringCentered("  Each player is grouped into\n       a team of three\n\n  The captain moves by dragging\nThe technician rotates by swiping\nThe shooter yells to blow bubbles", ofGetWidth()/2, 300);

    }
    else {
        ofSetColor(0);
        text.drawStringCentered(playerWithMostDiamonds + " HOARDED THE MOST!", ofGetWidth()/2-2, text.getLineHeight() -2);
        ofSetColor(255, 255, 255);
        text.drawStringCentered(playerWithMostDiamonds + " HOARDED THE MOST!", ofGetWidth()/2, text.getLineHeight());
        
    }
    drawDiamondVolcanoes(255);

}
void ofApp::drawDiamondSea(float alpha, bool showWaves) {
    waveAnimationCounter+= .11;
    if (waveAnimationCounter > topWaves.size()) {
        waveAnimationCounter = 0;
    }
    
    ofSetColor(alpha, alpha, alpha, alpha);
    oceanImage.draw(0, 0, ofGetWidth(), ofGetHeight());
    if (showWaves) {
        for (int x = 0; x < ofGetWidth(); x+= bottomWaves[0].width/8) {
            bottomWaves[waveAnimationCounter].draw(x,0, bottomWaves[waveAnimationCounter].width/8, bottomWaves[waveAnimationCounter].height/8);
        }
        /*
        for (int x = 0; x < ofGetWidth(); x+= topWaves[0].width/2) {
            topWaves[waveAnimationCounter].draw(x, 0,topWaves[waveAnimationCounter].width/2, topWaves[waveAnimationCounter].height/2);
        }
         */
    }
    
}

void ofApp::drawDiamondVolcanoes(float alpha) {
    ofSetColor(alpha, alpha, alpha, alpha);
    volcanoBackground.draw(0, ofGetHeight()-volcanoBackground.height, ofGetWidth(), 62);
    if (diamonds.size() > 0) {
        for (int i = 0; i < diamonds.size(); i++) {
            diamonds[i].get()->display();
        }
    }
    ofSetColor(alpha, alpha, alpha, alpha);

    volcanoForeground.draw(0, ofGetHeight()-volcanoBackground.height, ofGetWidth(), 62);

}

void ofApp::loadSubmarineAssets() {
    submarineImages = nerdlab->loadImageSet("submarines");
    submarineOutlineImage.loadImage("sub_outline.png");
    submarineExplode.loadSound("sounds/explosion.wav");
    submarineBackgroundMusic.loadSound("sounds/submarine_music.wav");
    submarineBackgroundMusic.setLoop(true);
    seaImage.loadImage("backgrounds/seabackground_static.png");
    seaThrobImage.loadImage("backgrounds/seabackground_throb.png");
    seaEbbImage.loadImage("backgrounds/seabackground_ebb.png");

}

void ofApp::unloadSubmarineAssets() {
    submarineImages.clear();
    submarineOutlineImage.clear();
    submarineExplode.unloadSound();
    submarineBackgroundMusic.unloadSound();
    seaImage.clear();
    seaThrobImage.clear();
    seaEbbImage.clear();
}

void ofApp::startSubmarines() {
    numberEvacuated = 0;
    getAwayCutSceneCounter = 0;
    podEscapeCounter = 0;
    submarineBackgroundMusic.play();
    getawayPod.reset();
    getawayPod2.reset();
    getawayPod3.reset();
    getawayPod.setup(ofPoint(-ofGetWidth()/4, ofGetHeight()-140), ofPoint(4,-1));
    getawayPod2.setup(ofPoint(-ofGetWidth()/2, ofGetHeight()-100), ofPoint(4,-1));
    getawayPod3.setup(ofPoint(-ofGetWidth()/3, ofGetHeight()-80), ofPoint(4,-1));

    box2d.createBounds();
    removeAllGameObjects();
    assignTeamsToSubmarines();
    setIndexState(GAME_INDEX_SUBMARINES, OFXNERDLAB_GAME_STATE_ROLL_CALL);
}

void ofApp::drawSubmarineSea() {
    ofBackground(0, 0, 0);
    ofSetColor(255,255,255);
    seaImage.draw(0, 0, ofGetWidth(), ofGetHeight());
    ofSetRectMode(OF_RECTMODE_CENTER);
    seaThrobImage.draw(ofGetWidth()/2, ofGetHeight()/2, ofGetWidth() + (sin(ofGetElapsedTimef()) * 200),ofGetHeight() + (sin(ofGetElapsedTimef()) * 200));
    ofPushMatrix();
    ofTranslate(ofGetWidth()/2, ofGetHeight()/2);
    ofRotateZ(sin(ofGetElapsedTimef()) * 4);
    seaEbbImage.draw(0,0, ofGetWidth() + (sin(ofGetElapsedTimef()) * 5), ofGetHeight() + (sin(ofGetElapsedTimef()) * 4));
    ofPopMatrix();
    ofSetRectMode(OF_RECTMODE_CORNER);
}

void ofApp::fakePlayer() {
    nerdlab->createFakePlayer();
}
//--------------------------------------------------------------
void ofApp::keyPressed(int key){

    
    if (key == '+' && gameIndex == GAME_INDEX_EVACUATION) {
        if(tubes[currentTubeIndex].addPower(8)) {
            nextTube();
        }
    }
    if (key == ' ') {
        showGui = !showGui;
        if (showGui) {
            ofShowCursor();
        }
        else {
            ofHideCursor();
        }
    }
    
    if (key == 'd' && gameIndex == GAME_INDEX_SUBMARINES) {
        for (int i = 0; i < submarines.size(); i++) {
            submarines[i].get()->armor--;
            fireballs.push_back(Fireball(&fireball));

        }
    }

    

    
}

//--------------------------------------------------------------
void ofApp::keyReleased(int key){

}

//--------------------------------------------------------------
void ofApp::mouseMoved(int x, int y ){

}

//--------------------------------------------------------------
void ofApp::mouseDragged(int x, int y, int button){

}

//--------------------------------------------------------------
void ofApp::mousePressed(int x, int y, int button){

}

//--------------------------------------------------------------
void ofApp::mouseReleased(int x, int y, int button){

}

//--------------------------------------------------------------
void ofApp::windowResized(int w, int h){

}

//--------------------------------------------------------------
void ofApp::gotMessage(ofMessage msg){

}

//--------------------------------------------------------------
void ofApp::dragEvent(ofDragInfo dragInfo){ 

}

void ofApp::endOfDiamonds() {
    diamondBackgroundMusic.stop();
    getAwayCutSceneCounter = 0;
    podEscapeCounter = 0;
    highlightedId = 0;
    podsGetawaySound.play();
//    lonePodStartingX = ofGetWidth()+bgFishImage.width;
    //clear pods
    for (int i = 0; i < pods.size(); i++) {
        pods[i]->destroy();
    }
    pods.clear();
    //clear diamonds
    for (int i = 0; i < diamonds.size(); i++) {
        diamonds[i]->destroy();
    }
    diamonds.clear();
    diamondMines.clear();

    //reset player scores
    for (int i = 0; i < nerdlab->players.size(); i++) {
        nerdlab->players[i].score = 0;
    }

    for (int i = 0; i < nerdlab->players.size(); i++) {
        nerdlab->players[i].setControlsEnabled(false);
        lastOutgoingMessage = "Alliances Have Formed!";
        nerdlab->players[i].sendOutOfGameMessage("Alliances Have Formed!");
        //nerdlab->players[i].sendBackground(GAME_INDEX_SUBMARINES);
    }
    narrator.speakPhrase("Citizens have become resentful and jealous of their neighbors, especially " + playerWithMostDiamonds + ", the biggest hoarder. Alliances are formed in a fight for wealth and power. War is here. Destroy your enemies. Protect your team.");
//    setIndexState(gameIndex, OFXNERDLAB_GAME_STATE_WAITING);
}

void ofApp::assignTeamsToSubmarines() {
    //assign teams
//    submarineImages = nerdlab->loadImageSet("submarines");

    for (int i = 0; i < nerdlab->players.size(); i+=3) {
//    for (int i = 0; i < nerdlab->players.size(); i+=2) {

        vector<int> team;
        //push back the player id
        team.push_back(i);
        if(i + 1 < nerdlab->players.size()) {
            team.push_back(i+1);
        }

        if(i + 2 < nerdlab->players.size()) {
            team.push_back(i+2);
        }
 
        nerdlab->newTeam(team);
        //create a new submarine for team
        newSubmarine(team.size());
    }
    
    //load team members into their submarine
    int teamPodShapeId = 0;
    //TEAMS.SIZE() should be == to submarines.size()
    for (int teamId = 0; teamId < nerdlab->teams.size(); teamId++) {
        
        // loop through individual players on team
        for (int playerPosition = 0; playerPosition < nerdlab->teams[teamId].size(); playerPosition++) {
            int playerNum = nerdlab->teams[teamId][playerPosition];
            cout << "Assigning Player " << playerNum << " to team " << teamId << endl;
            nerdlab->players[playerNum].tag = teamId;
            nerdlab->players[playerNum].startWithParameters(OFXNERDLAB_IMAGE_SET_SUBMARINES, teamPodShapeId, submarines[teamId].get()->color, "armor left", submarines[teamId].get()->armor, OFXNERDLAB_GAME_CONTROL_NOTHING);

            nerdlab->players[playerNum].setColor(submarines[teamId].get()->color);
            nerdlab->players[playerNum].useImageSet(OFXNERDLAB_IMAGE_SET_SUBMARINES);
            nerdlab->players[playerNum].setImageNumber(teamPodShapeId);
            nerdlab->players[playerNum].setId();
            nerdlab->players[playerNum].setScoreName("ARMOR LEFT");
            nerdlab->players[playerNum].setScore(submarines[teamId].get()->armor);

            if (playerPosition == 0) {
                nerdlab->players[playerNum].sendControl(OFXNERDLAB_GAME_CONTROL_MOVE);
                nerdlab->players[playerNum].sendInGameMessage("drag to drive!");

                cout << "this player will be driving" << endl;
            }
            //new for 2 player
            else if (playerPosition == 1){
                cout << "Player position " << playerPosition << endl;
                nerdlab->players[playerNum].sendControl(OFXNERDLAB_GAME_CONTROL_AUDIO);
                nerdlab->players[playerNum].sendInGameMessage("blow dangerous bubbles!");

            }
            
            else {
                nerdlab->players[playerNum].sendControl(OFXNERDLAB_GAME_CONTROL_ROTATE);
                nerdlab->players[playerNum].sendInGameMessage("swipe to aim!");
                
            }
            /*
            if (playerPosition == 1) {

                nerdlab->players[playerNum].sendControl(OFXNERDLAB_GAME_CONTROL_TAP);
                nerdlab->players[playerNum].sendInGameMessage("hold and release to fire!");

                cout << "this player will shooting" << endl;

            }
            if (playerPosition == 2) {
                nerdlab->players[playerNum].sendControl(OFXNERDLAB_GAME_CONTROL_ROTATE);
                nerdlab->players[playerNum].sendInGameMessage("swipe to rotate!");

                cout << "this player aiming" << endl;

            }
             */
            nerdlab->players[playerNum].setControlsEnabled(true);
        }
        teamPodShapeId++;
        if (teamPodShapeId > submarineImages.size()) {
            teamPodShapeId = 0;
        }

    }

    
}

void ofApp::newSubmarine(int passengers) {
    int subId = submarines.size();
    cout << "Creating New Submarine with ID " << subId << endl;
    int teamShapeId = submarines.size()%submarineImages.size();
    
    
    
    ofPtr<Submarine> s = ofPtr<Submarine>(new Submarine);
    s.get()->setPhysics(20, .1, 10);
    s.get()->setup(box2d.getWorld(), ofRandom(ofGetWidth()-100), ofGetHeight()/2, submarineImages[teamShapeId].width/3, submarineImages[teamShapeId].height/3);
    s.get()->setVelocity(0, 0);
    s.get()->setData(new CustomData());
    s.get()->setupCustom(subId);

    if (subId < colorScheme.size()) {
        s.get()->color = colorScheme[subId];
    }
    else {
        s.get()->color = ofColor(ofRandom(255), ofRandom(255), ofRandom(255));

    }
    //need to pick from set eventually
    s.get()->image = &submarineImages[teamShapeId];
    s.get()->bubbleImage = &bubbleImage;
    s.get()->glow = &submarineOutlineImage;

    
    s.get()->numberOfPassengers = passengers;
    submarines.push_back(s);
    //return subId;
    
}


void ofApp::assignShapesWithDifferentColors() {

    pods.clear();
    //5 Images
    //2 pixel padding
    podGrid.set(podImages[0].getWidth()+2, podImages[0].getHeight()+2);
    podGlowImages = nerdlab->loadImageSet("abstract_glow");
    ofxOscMessage msg;
    int playerCounter = 0;
    //5 squares
    
    if (nerdlab->players.size() > 0) {
        for (int j = 0; j < colorScheme.size(); j++) {
                for (int i = 0; i < podImages.size(); i++) {

                //20 colors
                ofPtr<Pod> p = ofPtr<Pod>(new Pod);
            
                p.get()->setPhysics(15, .2, 5);
                p.get()->setup(box2d.getWorld(), podGrid.x, podGrid.y, podImages[i].width/2, podImages[i].height/2);
                p.get()->setVelocity(0,0);
                p.get()->setData(new CustomData());
                p.get()->setupCustom(playerCounter);
                p.get()->color = colorScheme[j];
/*
                nerdlab->players[playerCounter].setColor(colorScheme[j]);
                nerdlab->players[playerCounter].setScoreName("Diamonds");

                nerdlab->players[playerCounter].useImageSet(OFXNERDLAB_IMAGE_SET_ABSTRACT);
                nerdlab->players[playerCounter].setImageNumber(i);
                nerdlab->players[playerCounter].setControlsEnabled(true);
                nerdlab->players[playerCounter].setId();
 */
                p.get()->image = &podImages[i];
                p.get()->glow = &podGlowImages[i];
                pods.push_back(p);
                nerdlab->players[playerCounter].startWithParameters(OFXNERDLAB_IMAGE_SET_ABSTRACT, i, colorScheme[j], "diamonds", 0, OFXNERDLAB_GAME_CONTROL_MOVE);

                cout << "Creating Player " << playerCounter << endl;
                playerCounter++;
                //check if we've hit the number of players
                if (playerCounter >= nerdlab->players.size()) {
                    break;
                }
                    podGrid.x += podImages[0].width + 2;
                    //new row
                    if (podGrid.x > ofGetWidth() - podImages[0].width) {
                        podGrid.x = podImages[0].getWidth()+2;
                        podGrid.y += podImages[0].getHeight()+2;
                    }
            }
            if (playerCounter >= nerdlab->players.size()) {
                break;
            }

        }
    }
}

void ofApp::newDiamond() {
    ofPtr<Diamond> d = ofPtr<Diamond>(new Diamond);
    d.get()->setPhysics(10, .1, 10);
    float dScale = ofRandom(.1, .3);
    
    float dWidth = diamondImage.width * dScale;
    float dHeight = diamondImage.height * dScale;
    int diamondMineIndex = ofRandom(diamondMines.size());
    d.get()->setup(box2d.getWorld(), ofRandom(diamondMines[diamondMineIndex].x - 20, diamondMines[diamondMineIndex].x + 20), diamondMines[diamondMineIndex].y, dWidth, dHeight);

    d.get()->setVelocity(ofRandom(-1,1), ofRandom(-5));
    d.get()->image = &diamondImage;
    d.get()->shadowImage = &diamondImage;
    
    d.get()->setData(new CustomData());
    d.get()->setupCustom(diamonds.size());
    diamonds.push_back(d);
    
}

void ofApp::contactDiamonds(ofxBox2dContactArgs &e) {
    
    if(e.a != NULL && e.b != NULL) {
        
        CustomData *data1 = (CustomData *)e.a->GetBody()->GetUserData();
        CustomData *data2 = (CustomData *)e.b->GetBody()->GetUserData();
        if (data1 != NULL && data2 != NULL) {
            if (data1->type == data2->type) {
                //colliding against each other
                if (data1->type == TYPE_POD) {
                    //PLAYERS COLLIDING WITH EACH OTHER
                }
                if (data1->type == TYPE_DIAMOND) {
                    //FOOD ON FOOD COLLISION
                }
            }
            else {
                //if more than 2 types, needs more logic
                if (data1->type == TYPE_DIAMOND) {
                    
                    if (!data1->taken) {
                        nerdlab->players[data2->id].setScore(nerdlab->players[data2->id].score + 1);
                        nerdlab->players[data2->id].sendReaction(OFXNERDLAB_REACTION_PULSE);
                        collectFx.play();
                        data1->taken = true;
                        data2->taken = true;
                    }
                }
                else {
                    if (!data2->taken) {

                        nerdlab->players[data1->id].setScore(nerdlab->players[data1->id].score + 1);
                        nerdlab->players[data1->id].sendReaction(OFXNERDLAB_REACTION_PULSE);
                        collectFx.play();
                        data2->taken = true;
                        data1->taken = true;
                    }
                }
                
            }
        }
    }
}


void ofApp::bubblePopped(ofPoint point, bool toTop) {
    bubbleFx.play();

    //should create a fizzing thing here
    int fizzAmount = ofRandom(10);
    for (int i = 0; i < fizzAmount; i++)  {
        Fizzle f = *new Fizzle(toTop);
        f.setup(point, ofColor(255,255,255), &bubbleImage);
        fizz.push_back(f);
    }
}

void ofApp::submarineHit(int subId) {
    cout << "Hit Submarine" << endl;
    if (subId < nerdlab->teams.size()) {
        submarines[subId].get()->armor--;
        if (submarines[subId].get()->armor <= 0) {
            nerdlab->setTeamControlsEnabled(subId, false);
            nerdlab->sendTeamInGameStatus(subId, "Your Submarine Blew Up!");
            nerdlab->sendTeamState(subId, OFXNERDLAB_GAME_STATE_WAITING);
        }
        else {
            cout << "Sending Armor of " << submarines[subId].get()->armor << " to Submarine " << subId << endl;
            nerdlab->setTeamScore(subId, submarines[subId].get()->armor);
        }
        
        for (int i = 0; i < nerdlab->teams[subId].size(); i++) {
            
            if (submarines[subId].get()->armor <= 0) {
                submarineExplode.play();

                cout << "Blowing Up Sub" << endl;
                cout << "Player Is Being Sent Lots of Stuff #" << nerdlab->teams[subId][i] << endl;
                bubblePopped(submarines[subId].get()->getPosition(), false);
                nerdlab->players[nerdlab->teams[subId][i]].setControlsEnabled(false);
                lastOutgoingMessage = "You Died.";
                nerdlab->players[nerdlab->teams[subId][i]].sendOutOfGameMessage("You Died.");
            }
        }
    }
}

void ofApp::contactSubmarine(ofxBox2dContactArgs &e) {
    if(e.a != NULL && e.b != NULL) {
        CustomData *data1 = (CustomData *)e.a->GetBody()->GetUserData();
        CustomData *data2 = (CustomData *)e.b->GetBody()->GetUserData();
//WALLS
        if (data1 == NULL) {
            if (data2->type == TYPE_BUBBLE) {
                bubblePopped(data2->position, false);
                data2->taken = true;
            }
        }
        if (data2 == NULL) {
            if (data1->type == TYPE_BUBBLE) {
                bubblePopped(data1->position, false);
                data1->taken = true;
            }
        }
//OBJECT ON OBJECT
        
        if (data1 != NULL && data2 != NULL) {
            //SAME OBJECTS
            if (data1->type == data2->type) {
                //colliding against each other
                if (data1->type == TYPE_BUBBLE) {
                    //BUBBLES COLLIDING WITH EACH OTHER
                    cout << "Bubbles Colliding Together" << endl;
                }
                if (data1->type == TYPE_SUBMARINE) {
                    //SUBMARINES COLLIDING
                    cout << "Submarine Colliding Together" << endl;
                }
            }
            //DIFFERENT OBJECTS
            else {
                cout << "Different Things Hitting Each Other" << endl;
                //play bubble pop
                if (data1->type == TYPE_BUBBLE) {
                    bubblePopped(data1->position, false);
                    submarineHit(data2->id);
                    data1->taken = true;
                }
                if (data2->type == TYPE_BUBBLE) {
                    data2->taken = true;
                    cout << "Attempting Armor Removal" << endl;
                    submarineHit(data1->id);
                    bubblePopped(data2->position, false);
                }
            }
        }
    }
}


void ofApp::toggleFullScreen() {
    ofToggleFullscreen();
}
/*
//--------------------------------------------------------------
void ofApp::onPublishedService(const void* sender, string &serviceIp) {
    ofLog() << "Received published service event: " << serviceIp;
}

void ofApp::onDiscoveredService(const void* sender, string &serviceIp) {
    ofLog() << "Received discovered service event: " << serviceIp;
}

void ofApp::onRemovedService(const void* sender, string &serviceIp) {
    ofLog() << "Received removed service event: " << serviceIp;
}
*/