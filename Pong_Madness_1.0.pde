/*

    Pong Madness

    Ji Minoong (JD)
    Digital Media Art Workshop (ANT3010)
    Computer Science and Engineering
    Sogang University
    2013. 6. 19
    
    
*/



// load the P5 libraries:
import oscP5.*;
import netP5.*;
Paddle paddle1;
Paddle paddle2;
int elements = 200 ;
Ball ballarray[] = new Ball[elements];
int score1 = 0;
int score2 = 0;
int speed = 3;
int a = 0;
int ballcount = elements;
int phase = 0;
int mytimer = 0;
boolean isCalled = false;
boolean isAnyKeyPressed = false;

// create the objects we need:
OscP5 oscP5;
NetAddress myRemoteLocation;

//myMessage.add(mouseX);

void setup() {

  ////////////////////////////////////////////////
  /////////////////connect to MAX/////////////////
  ////////////////////////////////////////////////

  // start oscP5:
  oscP5 = new OscP5(this, 11111);
  // set up the address we will send messages to:
  // "127.0.0.1" means 'send to the same machine this is running on'
  // 12345 is the port number Max is listening on
  myRemoteLocation = new NetAddress("127.0.0.1", 12345);
  OscMessage hitPaddleMsg = new OscMessage("/score");
  hitPaddleMsg.add(0);
  oscP5.send(hitPaddleMsg, myRemoteLocation);
  hitPaddleMsg = new OscMessage("/start");
  hitPaddleMsg.add(0);
  oscP5.send(hitPaddleMsg, myRemoteLocation);


  ////////////////////////////////////////////////
  ///////////////////init scene///////////////////
  ////////////////////////////////////////////////


  size(600, 600);
  phase = 0;
  score1 = 0;
  score2 = 0;
  isAnyKeyPressed = false;
  isCalled = false;
  mytimer = millis();

  paddle1 = new Paddle (20, height /2 );
  paddle2 = new Paddle (width - 20, height /2);

  for (int i = 0; i < elements ; i++ )
    ballarray[i] = new Ball(width / 2, height + 10, 0, 0);


  PFont myFont;
  myFont = createFont ("Courier", 40);
  textFont(myFont);
}

void someone_scored (Ball myball) {
  myball.velx = 0;
  myball.vely = 0;
  myball.nextx = width / 2;
  myball.nexty = height + 10;

  ballcount--;

  println(ballcount);
  
  
  //send max(score1,score2) to MAX/MSP
  OscMessage hitPaddleMsg = new OscMessage("/score");
  if (score1 >= score2)
    hitPaddleMsg.add(score1);
  else
    hitPaddleMsg.add(score2);
  oscP5.send(hitPaddleMsg, myRemoteLocation);
}

void player_one_scored (Ball myball) {
  score1 += 1;
  someone_scored (myball);
}

void player_two_scored (Ball myball) {
  score2 += 1;
  someone_scored (myball);
}




class Paddle {
  float x = 0;
  float y = 0;
  float pwidth = width / 60;
  float pheight = height / 10;
  int direction = 0;

  Paddle( float givenx, float giveny ) {
    x = givenx;
    y = giveny;
  }
  void draw() {
    noStroke();
    rectMode(CENTER);
    rect(x, y, pwidth, pheight);
  }
  void move() {
    y = y + direction;
    if (y < 40) {
      y = y - direction;
    }
    else if ( y > height-40) {
      y = y - direction;
    }
  }
}


class Ball {

  float x = 0, y = 0;
  float bwidth = 6, bheight = 6;
  float velx = random(-3, 3);
  float vely = random(-3, 3);
  float nextx = 0, nexty = 0;

  Ball(float givenx, float giveny, float dx, float dy) {
    x = givenx;
    y = giveny;
    velx = dx;
    vely = dy;
  }

  void draw() {
    noStroke();
    rectMode(CENTER);
    rect(x, y, bwidth, bheight);
  }

  void move() {

    nextx = x + velx;
    nexty = y + vely;


    if ( nexty < 0 || nexty > height ) {
      vely *= -1.3; // or vely *= -1;
      velx *= 1.3;
    }

    if ( nextx < 0 )
      player_two_scored(this);
    else if ( nextx > width )
      player_one_scored(this);
    else // ball is still in the court 
    {  // collision detection with paddles
      if ( x >= (paddle1.x + paddle1.pwidth/2) && nextx < (paddle1.x + paddle1.pwidth/2) ) {
        if ( nexty < paddle1.y + paddle1.pheight/2 + bwidth/2 && nexty > paddle1.y - paddle1.pheight/2 - bwidth/2 )
        {     
          velx *= -1.3;
          OscMessage hitPaddleMsg = new OscMessage("/hit1");
          hitPaddleMsg.add(y);
          oscP5.send(hitPaddleMsg, myRemoteLocation);
        }
      }

      else if ( x <= (paddle2.x - paddle2.pwidth/2) && nextx > (paddle2.x - paddle2.pwidth/2)) {
        if ( nexty < paddle2.y + paddle2.pheight/2 + bwidth/2 && nexty > paddle2.y - paddle2.pheight/2 - bwidth/2 )
        { 
          velx *= -1.3;
          OscMessage hitPaddleMsg = new OscMessage("/hit2");
          hitPaddleMsg.add(y);
          oscP5.send(hitPaddleMsg, myRemoteLocation);
        }
      }
    }
    x = nextx;
    y = nexty;
  }
}

void keyPressed() {

  if ( key == 'w' ) {
    println("player 1 up");
    paddle1.direction = 0 - speed;
  }
  else if (key == 's') {
    println ("player 1 down");
    paddle1.direction = speed;
  }
  else if (key == 'o' ) {
    println("player 2 up");
    paddle2.direction = 0 - speed;
  }
  else if (key == 'l') {
    println("player 2 down");
    paddle2.direction = speed;
  }
  else if (key == 'r' ) {
    setup();
  }

  if (!isAnyKeyPressed) {  // starts game when any key is pressed
    phase = 1;
    isAnyKeyPressed = true; 
    mytimer = millis();
    // tell MAX patcher that the game has started
    OscMessage hitPaddleMsg = new OscMessage("/start");
    hitPaddleMsg.add(1);
    oscP5.send(hitPaddleMsg, myRemoteLocation);
  }
}

void keyReleased() {

  if ( key == 'w' ) {
    println("player 1 stop");
  }
  else if (key == 's') {
    println ("player 1 stop");
  }
  else if (key == 'o' ) {
    println("player 2 stop");
  }
  else if (key == 'l') {
    println("player 2 stop");
  }
}

void drawNet() {
  for (int i = 0; i < height; i += 10) {
    rect(width/2, i, 1, 5);
  }
}

void drawScore() {
  textSize(80);
  textAlign(CENTER);
  text(score1, width/4, height / 10 + 20);
  text(score2, width*3/4, height / 10 + 20);
}




void setPhase1 () {


  if (!isCalled) {

    ballcount = 100;
    int angle = 150;
    for (int i = 0; i < ballcount / 2 ; i++ )
      ballarray[i] = new Ball(width / 2, height / 2, 2 * cos((float)i/30.0 + angle), 2 * sin((float)i/30.0 + angle));

    for (int i = ballcount/2; i < ballcount ; i++ )
      ballarray[i] = new Ball(width / 2, height / 2, 2 * cos( ( ballcount - (float) i) / 30.0 + angle), 2 * sin( ( ballcount - (float)i ) / 30.0 + angle));
  }
  isCalled = true;
}


void setPhase2 () {


  if (!isCalled) {


    ballcount = 100;
    int angle = 260;
    for (int i = 0; i < ballcount / 2; i++ )
      ballarray[i] = new Ball(width / 2, height / 2, 2 * cos((float)i/30.0 + angle), 2 * sin((float)i/30.0 + angle));

    for (int i = ballcount/2; i < ballcount ; i++ )
      ballarray[i] = new Ball(width / 2, height / 2, 2 * cos( ( ballcount - (float) i) / 30.0 + angle), 2 * sin( ( ballcount - (float)i ) / 30.0 + angle));
  }
  isCalled = true;
}


void setPhase3 () {

  if (!isCalled) {

    ballcount = 200;
    int angle = 75;
    for (int i = 0; i < ballcount ; i++ ) {

      ballarray[i] = new Ball(width / 2, height / 2, 2 * cos((float)i/10.0 + angle), 2 * sin((float)i/10.0 + angle));
    }
  }
  isCalled = true;
}

void setPhase4 () {

  if (!isCalled) {

    ballcount = 200;
    int angle = 75;
    for (int i = 0; i < ballcount ; i++ )
      ballarray[i] = new Ball(width / 2, height / 2, 2 * cos((float)(ballcount-i-1)/20.0 + angle), 2 * sin((float)(ballcount-i-1)/20.0 + angle));
  }
  isCalled = true;
}

void setPhase5 () {


  if (!isCalled) {

    ballcount = 100;
    int angle = 150;
    for (int i = 0; i < ballcount / 2 ; i++ )
      ballarray[i] = new Ball(width / 2, height / 2, 2 * cos((float)i/30.0 + angle), 2 * sin((float)i/30.0 + angle));

    for (int i = ballcount/2; i < ballcount ; i++ )
      ballarray[i] = new Ball(width / 2, height / 2, 2 * cos( ( ballcount - (float) i) / 30.0 + angle), 2 * sin( ( elements - (float)i ) / 30.0 + angle));
  }
  isCalled = true;
}


void setPhase6 () {


  if (!isCalled) {

    ballcount = 100;
    int angle = 260;
    for (int i = 0; i < ballcount / 2; i++ )
      ballarray[i] = new Ball(width / 2, height / 2, 2 * cos((float)i/30.0 + angle), 2 * sin((float)i/30.0 + angle));

    for (int i = ballcount/2; i < ballcount ; i++ )
      ballarray[i] = new Ball(width / 2, height / 2, 2 * cos( ( ballcount - (float) i) / 30.0 + angle), 2 * sin( ( elements - (float)i ) / 30.0 + angle));
  }
  isCalled = true;
}


void increaseAndSendA() {

  //Draw every balls
  for ( int i = 0; i < a; i ++ )
  {
    ballarray[i].draw();
    ballarray[i].move();
  }

  //send balls number
  if ( a < ballcount ) {
    a++;
    OscMessage hitPaddleMsg = new OscMessage("/shoot");
    hitPaddleMsg.add(a);
    oscP5.send(hitPaddleMsg, myRemoteLocation);
  }
}

void draw() {
  background(0);

  paddle1.draw();
  paddle1.move();
  paddle2.draw();
  paddle2.move();

  ///////////////////////////////////////////////////
  ////////////////// START GAME /////////////////////
  ///////////////////////////////////////////////////

  if ( phase == 0 ) {
    textSize(20);
    textAlign(CENTER);
    text("Player 1 : W,S  Player 2 : O,L", width/2, height / 2);
  }

  ///////////////////////////////////////////////////
  /////////////// PHASE 1 START /////////////////////
  ///////////////////////////////////////////////////


  if ( phase == 1 && millis()-mytimer > 1500 && millis()-mytimer < 3000 ) {
    textSize(50);
    textAlign(CENTER);
    text("PHASE 1", width/2, height / 3);
    a = 1;
    setPhase1();
  }

  if ( phase == 1 && millis()-mytimer > 3500 ) {

    increaseAndSendA();

    if ( ballcount <= 0 ) {
      mytimer = millis();
      phase = 2;
      isCalled = false;
    }
  }

  /////////////// PHASE 1 END ///////////////////////


  ///////////////////////////////////////////////////
  /////////////// PHASE 2 START /////////////////////
  ///////////////////////////////////////////////////

  if ( phase == 2 && millis()-mytimer > 1500 && millis()-mytimer < 3000 ) {
    textSize(50);
    textAlign(CENTER);
    text("PHASE 2", width/2, height / 3);
    a = 1;
    setPhase2();
  }

  if ( phase == 2 && millis()-mytimer > 3500 ) {

    increaseAndSendA();

    if ( ballcount <= 0 ) {
      mytimer = millis();
      phase = 3;
      isCalled = false;
    }
  }

  /////////////// PHASE 2 END ///////////////////////

  ///////////////////////////////////////////////////
  /////////////// PHASE 3 START /////////////////////
  ///////////////////////////////////////////////////

  if ( phase == 3 && millis()-mytimer > 1500 && millis()-mytimer < 3000 ) {
    textSize(50);
    textAlign(CENTER);
    text("PHASE 3", width/2, height / 3);
    a = 1;
    setPhase3();
  }

  if ( phase == 3 && millis()-mytimer > 3500 ) {

    increaseAndSendA();

    if ( ballcount <= 15 ) {
      mytimer = millis();
      phase = 4;
      isCalled = false;
    }
  }

  /////////////// PHASE 3 END ///////////////////////

  ///////////////////////////////////////////////////
  /////////////// PHASE 4 START /////////////////////
  ///////////////////////////////////////////////////

  if ( phase == 4 && millis()-mytimer > 1500 && millis()-mytimer < 3000 ) {
    textSize(50);
    textAlign(CENTER);
    text("PHASE 4", width/2, height / 3);
    a = 1;
    setPhase4();
  }

  if ( phase == 4 && millis()-mytimer > 3500 ) {

    increaseAndSendA();
    if ( ballcount <= 15 ) {
      mytimer = millis();
      phase = 5;
      isCalled = false;
    }
  }

  /////////////// PHASE 4 END ///////////////////////

  ///////////////////////////////////////////////////
  /////////////// PHASE 5 START /////////////////////
  ///////////////////////////////////////////////////

  if ( phase == 5 && millis()-mytimer > 1500 && millis()-mytimer < 3000 ) {
    textSize(50);
    textAlign(CENTER);
    text("PHASE 5", width/2, height / 3);
    a = 1;
    setPhase5();
  }

  if ( phase == 5 && millis()-mytimer > 3500 ) {

    increaseAndSendA();

    if ( ballcount <= 0 ) {
      mytimer = millis();
      phase = 6;
      isCalled = false;
    }
  }

  /////////////// PHASE 5 END ///////////////////////

  ///////////////////////////////////////////////////
  /////////////// PHASE 6 START /////////////////////
  ///////////////////////////////////////////////////

  if ( phase == 6 && millis()-mytimer > 1500 && millis()-mytimer < 3000 ) {
    textSize(50);
    textAlign(CENTER);
    text("PHASE 6", width/2, height / 3);
    a = 1;
    setPhase6();
  }

  if ( phase == 6 && millis()-mytimer > 3500 ) {

    increaseAndSendA();

    if ( ballcount <= 0 ) {
      mytimer = millis();
      phase = 999;
      isCalled = false;
    }
  }

  /////////////// PHASE 6 END ///////////////////////



  ///////////////////////////////////////////////////
  /////////////////// GAME OVER /////////////////////
  ///////////////////////////////////////////////////

  if ( phase == 999 )
  {
    textSize(50);
    textAlign(CENTER);
    if (score1 > score2)
      text("PLAYER 1 WIN!", width/2, height / 3);
    else if (score2 > score1)
      text("PLAYER 2 WIN!", width/2, height / 3);
    else
      text("DRAW!", width/2, height / 3);


    // Turn off MAX background music
    OscMessage hitPaddleMsg = new OscMessage("/start");
    hitPaddleMsg.add(0);
    oscP5.send(hitPaddleMsg, myRemoteLocation);

    textSize(20);
    textAlign(CENTER);
    text ("press R to restart", width/2, height / 2);
  }

  //draw net
  drawNet();
  drawScore();
}

