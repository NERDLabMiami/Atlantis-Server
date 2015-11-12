#pragma once

#include "ofMain.h"
#include "ofxNERDLab.h"
#include "ofxBox2d.h"
#include "ofxSpeech.h"
#include "ofxGui.h"
#include "ofxCenteredTrueTypeFont.h"
#include "ofxBonjour.h"
#include "pod.h"
#include "diamond.h"
#include "submarine.h"
#include "fizzle.h"
#include "evactube.h"
#include "evacuee.h"

#include "GetawayPod.h"
#include "fireball.h"

#define SERVER_PORT 9000
#define CLIENT_PORT 9001

#define STARTING_NUMBER_OF_DIAMONDS     10
#define DIAMONDS_REFILL                 20
#define DIAMONDS_TO_WIN                 100


#define GAME_INDEX_POPULATION           -1
#define GAME_INDEX_INTRODUCTION         0
#define GAME_INDEX_EVACUATION           1
#define GAME_INDEX_DIAMONDS             2
#define GAME_INDEX_SUBMARINES           3
#define GAME_INDEX_GAME_CREDITS         4

class ofApp : public ofBaseApp{

	public:
		void setup();
		void update();
		void draw();

		void keyPressed(int key);
		void keyReleased(int key);
		void mouseMoved(int x, int y );
		void mouseDragged(int x, int y, int button);
		void mousePressed(int x, int y, int button);
		void mouseReleased(int x, int y, int button);
		void windowResized(int w, int h);
		void dragEvent(ofDragInfo dragInfo);
		void gotMessage(ofMessage msg);
    
    
        void loadGenericAssets();
        void loadGui();
        void startNetworking();
        void removeAllGameObjects();
    
        void setIndexState(int idx, int state);
        ofxNERDLab *nerdlab;
    
        ofxBox2d    box2d;			  //	the box2d world
        ofxSpeechSynthesizer narrator;
        ofxBonjourPublisher publisher;
    
        ofxPanel gui;
        ofxButton startButton;
        ofxButton fakePlayerButton;
        ofxButton fullScreenButton;
        ofxButton resetButton;
        ofxToggle killPlayers;
        ofxToggle showIpAddress;
        ofxFloatSlider tapPower;
        ofxFloatSlider audioPower;
        ofxFloatSlider shakePower;
        ofxFloatSlider swipePower;
        bool showGui;
    
        void startButtonPressed();
        void fakePlayer();
        void toggleFullScreen();
        void resetGame();
        float resolutionScaling;
        int score;
        int gameState;
        int gameIndex;
        string ipAddress;
        float timeToEndRollCall;
        string highlightedPlayerName;
        ofPoint highlightedPlayerPoint;
        int highlightedId;
        vector<ofColor> colorScheme;
    
        ofxCenteredTrueTypeFont text;
        ofxCenteredTrueTypeFont smallText;
        ofxCenteredTrueTypeFont bigText;
        string bigTextMessage;
        string statusMessage;
        ofPoint statusMessagePosition;
    
        ofSoundPlayer introMusic;
        ofSoundPlayer alarm;
        ofImage introBackground;
        ofImage bgFishImage;
        float sceneCounter;
        float introTimer;
        float messageTimer;

    
        // EVACUATION
        
        string evacuationMessage;
        bool shaking;
        void startEvacuation();
        void drawBeams();
        void drawFrames();
        void drawFish();
        void drawRotatedFrames();
        void drawEvacuationAlert();
        int rotatedFrameMovement;
        void nextTube();
        void endOfEvacuation();
        void loadEvacuationAssets();
        void unloadEvacuationAssets();
    
    
        vector<EvacTube> tubes;
        ofSoundPlayer evacuationBackgroundMusic;
        ofSoundPlayer evacuationOpeningMusic;
        ofSoundPlayer airlock;
        ofSoundPlayer doorlock;
        ofSoundPlayer rumble;
        ofSoundPlayer explosion;
        ofImage evacuationBackgroundImage;
        ofImage evacuationPlatformImage;
        ofImage evacTubeImage;
        ofImage evacTubeBackImage;
        ofImage evacTubeBackImageEvacuating;
        vector<ofImage> evacPodImages;
        vector<ofImage> evacPodImagesFront;
        vector<ofImage> evacPlatforms;
        ofImage evacueeImage;
        ofImage beamLeftImage;
        ofImage beamRightImage;
        ofImage beamImage;
        ofImage frameBackgroundImage;
        vector<Evacuee> evacuees;
        vector<ofImage> evacueeImages;
        vector<ofImage> frameImages;
        vector<Fireball> fireballs;
        vector<int> frameIndex;
        int currentTubeIndex;
        int evacuationControlScheme;
        int evacuationChambersCleared;
        float evacuationTimer;
        int numberEvacuated;
        bool evacuationLoopStarted;
        float fishX;
        int fishXDirection;
        float fishXSpeed;
        float fishY;
        ofImage fireball;
        
    
        // DIAMOND RUSH
        void startDiamonds();
        void loadDiamondAssets();
        void unloadDiamondAssets();
        void assignShapesWithDifferentColors();
        void drawDiamondSea(float alpha, bool showWaves);
        void drawDiamondVolcanoes(float alpha);
        void drawGetaway();
        void newPod(int shapeId, int colorIndex);
        vector<ofImage> podImages;
        vector<ofImage> podGlowImages;
        vector<ofImage> topWaves;
        vector<ofImage> bottomWaves;
        vector <ofPtr<Pod> > pods;
        vector <ofPtr<Diamond> > diamonds;
        vector<ofPoint> diamondMines;
        ofImage diamondImage;
        ofImage oceanImage;
        ofImage volcanoForeground;
        ofImage volcanoBackground;
        ofImage titleImage;
        ofImage titleForegroundImage;
        ofImage populationSign;
        ofImage titleDiamond;
        ofSoundPlayer collectFx;
        ofSoundPlayer diamondBackgroundMusic;
        float lonePodStartingX;
        GetawayPod getawayPod;
    GetawayPod getawayPod2;
    GetawayPod getawayPod3;
    float waveAnimationCounter;
        ofSoundPlayer rocket;
        int getAwayCutSceneCounter;
    
        void newDiamond();
        void contactDiamonds(ofxBox2dContactArgs &e);
        void endOfDiamonds();

        string playerWithMostDiamonds;
        int mostDiamondsCollected;
        int playerWithMostDiamondsId;
        float nextDiamondEruption;
    
        int currentPod;
        int currentColor;
        ofPoint podGrid;
    
        // SUBMARINES
        vector <ofImage> submarineImages;
        ofImage submarineOutlineImage;
        ofImage bubbleImage;
        ofImage seaImage;
        ofImage seaThrobImage;
        ofImage seaEbbImage;
    
    ofImage repeatingSeaBackground;
    ofImage seaBackground;
    ofImage seaClimbLeft;
    ofImage seaClimbRight;
    int podEscapeCounter;
    GetawayPod escapingSubmarine;
    ofColor escapeSubmarineColor;
    ofSoundPlayer podsGetawaySound;
    
        ofSoundPlayer bubbleFx;
        ofSoundPlayer submarineExplode;
        ofSoundPlayer submarineBackgroundMusic;
        int winningTeamId;
        string winningTeamMembers;
        string lastOutgoingMessage;
        vector<ofPtr<Submarine> > submarines;
        void newSubmarine(int passengers);
        void assignTeamsToSubmarines();
        void loadSubmarineAssets();
        void unloadSubmarineAssets();
        void startSubmarines();
        void drawSubmarineSea();
    void drawSurvivors();
        void bubblePopped(ofPoint point, bool toTop);
        void contactSubmarine(ofxBox2dContactArgs &e);
        void submarineHit(int subId);
        vector<Fizzle> fizz;
    
    /* ofxNERDLab events */

        void move(ofxNERDLabMoveEvent &e);
        void accelerometer(ofxNERDLabAccelerometerEvent &e);
        void shake(ofxNERDLabAccelerometerEvent &e);
        void tap(ofxNERDLabTapEvent &e);
        void release(ofxNERDLabReleaseEvent &e);
        void audio(ofxNERDLabAudioInputEvent &e);
        void rotate(ofxNERDLabRotateEvent &e);
        void join(ofxNERDLabJoinEvent &e);
        void rejoin(ofxNERDLabJoinEvent &e);
        void rollCalled(ofxNERDLabRollCalled &e);
        void playerHighlight(ofxNERDLabJoinEvent &e);
        void playerQuit(ofxNERDLabQuitEvent &e);
        void confirm(ofxNERDLabMessageEvent &e);
    
    //FOR BONJOUR
    
    void onPublishedService(const void* sender, string &serviceIp);
    void onDiscoveredService(const void* sender, string &serviceIp);
    void onRemovedService(const void* sender, string &serviceIp);

    
};
