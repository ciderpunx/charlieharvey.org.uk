package invaders;
import java.util.*;
import javax.swing.*;
import java.awt.*;
import java.awt.event.*;
// An implementation of the Game Interface specifically 
// for playing space invaders. Probably needs to be 
// refactored at come point.

/*            Copyright (C) 2006 Charlie Harvey

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, 
MA  02110-1301, USA.*/
public class InvadersGame extends Game 
              implements ActionListener {
  String message; // to print score, etc
  Image gameOverImage, welcomeImage, levelImage; // images for states
  boolean paused, levelPause, intro; // game 'states' - playing st8 is in 
                                     // Game.java)
  
  public InvadersGame() {
    screen=new InvadersScreen();
    screen.addKeyListener(this);
    gameOverImage = InvaderImageStore.getInstance().getImage("gameover.gif");
    welcomeImage = InvaderImageStore.getInstance().getImage("welcome.gif");
    levelImage = InvaderImageStore.getInstance().getImage("level.gif");
    timer = new javax.swing.Timer(delay,this);
    intro=true;
    initialize();
    reset();
  }

  public void initialize() {
    maxX=350;
    maxY=400;
    level=1;
    lives=3;
    score=0;
    scoreStep=10;
    delayStep=4;
    message="LET'S GO!";
    playing=false;
    setSize(350,400);
    setBackground(Color.BLACK);
  }
  
  public void reset() {
    delay=250-(level*10);
    baddies=new InvaderBaddyCohort(this,4,7);
    ship=new InvaderShip(this,150,350);
    projectiles=new ArrayList();   
    screen.requestFocus();
    timer.setDelay(delay);
    timer.start();
   }
  
  public void baddyKilled(Baddy b){
    baddies.removeBaddy(b);
    score+=scoreStep;
    delay-=delayStep;
    message=("Level: "+level+" Score: " + score);
    if (delay<delayStep)
      delay=delayStep;
    timer.setDelay(delay);
    if (baddies.size()<1) {
      nextLevel(); 
    }
  }

  public void shipKilled(){
    if(lives-1>0){
      lives--;
      message="Dagnabbit! Lives Remaining: " + lives;
      pauseFor(1100);
    }
    else {
      gameOver();
    }
  }
  
  public void gameOver(){
    ScreenObject[] objArr = {
              new GenericScreenObject(this, 
                    gameOverImage, 70,80)
    };
    screen.setObjects(objArr); 
    setScreenMessage("Score " + score,
        150,170, 
        new Font("Monospaced", Font.BOLD, 20),
        Color.RED);
    screen.repaint();
    screen.requestFocus();
    intro=true;
    playing=false;
    pauseFor(5000);
  }
  
  public void showHighScore(){}
  
  public void nextLevel(){
    playing=false;
    levelPause=true;
    pauseFor(2500);
    setScreenMessage("Level " + level + " completed!",80,150,
        new Font("Monospaced", Font.BOLD, 17), Color.RED);
    screen.setObject(new GenericScreenObject(this, 
                      levelImage,50,80));
    level++;
    if(level>20) 
      level=20;
    reset();
  }
  
  public void start(){
    timer.setDelay(200);
    setScreenMessage("Invaders (cc) 2006 charlie harvey",110,360,
        new Font("Monospaced", Font.BOLD, 13), Color.WHITE);
    screen.setObject(new GenericScreenObject(this,
                      welcomeImage,70,80 ));
    screen.requestFocus();
    screen.repaint();
  }
  
  public void stop(){}
  
  public void pauseToggle(){
    paused=paused?false:true;
  }
  
  public void newGame(){
    paused=true;
    initialize();
    reset();
    paused=false;
    playing=true;
  }
  
  public void addProjectile(Projectile p){
      if(projectiles.size()<100)
        projectiles.add(p);
  }
  
  public void removeProjectile(Projectile p) {
      projectiles.remove(p);
  }

  public void draw() {
    ArrayList objects=new ArrayList();
    Baddy[]ba=baddies.getBaddies();
    for (int i=0;i<ba.length;i++) {
      if(ba[i]!=null) 
        objects.add(ba[i]);
    }
    Iterator it = projectiles.iterator();
    while(it.hasNext()) {
        Projectile bomb=(Projectile)it.next();
        if (bomb!=null)
          objects.add(bomb);
    }
    if(ship!=null) {
      objects.add(ship);
    }
    screen.setObjects((ScreenObject[])
        objects.toArray(new ScreenObject[objects.size()]));
  }

  public void setScreenMessage(String m, 
                               int x, int y, 
                               Font f, Color c) {
    screen.setMessage(m,x,y,f,c);
  }
  
  public void pauseFor(int ms) {
    paused=true;
    if(timer.isRunning()) {
      timer.stop();
      timer.setInitialDelay(ms);
      timer.restart();
    }
    else {
      timer.setInitialDelay(ms);
      timer.restart();
    }
    paused=false;
  }
  public void run(){
    try {
        baddies.move();
        if(projectiles.size()>0) {
          Projectile[] pr= (Projectile[])
            projectiles.toArray(new Projectile[projectiles.size()]);
          for (int i=0;i<pr.length;i++) {
            Projectile p = (Projectile)pr[i];
            p.move();
            if(p instanceof Laser) 
              baddies.checkForImpact(p);
            else if(p.collidesWith(ship)) {
              removeProjectile(p);
              shipKilled();
            } // this is a kludge and should be tidied!
            
          }
        }
        if (playing) {
          draw();
          setScreenMessage(message, 7, 20, 
              new Font("Sans-Serif", Font.BOLD, 15),
              Color.WHITE);
          screen.requestFocus();
        }
       } catch (Exception x) {
        x.printStackTrace();
      }
  }

 
  public void actionPerformed(ActionEvent ae) {
    screen.repaint();
    if(levelPause) {
      levelPause=false;
      playing=true;
    }
    else if (paused) 
      return;
    else if(playing)
      run();
    else if(intro)  
      start();
    }

  public void keyReleased(KeyEvent e){}
  public void keyTyped(KeyEvent e) {}
  public void keyPressed(KeyEvent e){
      if (e.getKeyChar()=='.' || e.getKeyChar()=='>')
        ship.goRight();
      if (e.getKeyChar()==',' || e.getKeyChar()=='<')
        ship.goLeft();
      if (e.getKeyChar()==' ' )
        ship.fire();
      if (e.getKeyChar()=='p' || e.getKeyChar()=='P') 
        pauseToggle();
      if (e.getKeyChar()=='n' || e.getKeyChar()=='N') 
        newGame();
      if (e.getKeyChar()=='q' || e.getKeyChar()=='Q') {
        playing=false;
        intro=true;
      }
  }
}
