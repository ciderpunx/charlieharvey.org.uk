package invaders;
import java.util.ArrayList;
import javax.swing.*;
import java.awt.*;
import java.awt.event.*;
// The Game object keeps track of where everything is,
// scores and stuff. This is the interface

/*Copyright (C) 2006 Charlie Harvey

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
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.*/

public abstract class Game 
                extends JPanel
                implements Runnable, KeyListener {
  int lives, score, scoreStep, delay, delayStep, maxX, maxY, level;
  boolean playing,paused;
  BaddyCohort baddies;
  ArrayList projectiles;
  Ship ship;
  Screen screen;
  javax.swing.Timer timer;
  
  public abstract void baddyKilled(Baddy b); 
  public abstract void shipKilled(); 
  public abstract void gameOver();
  public abstract void showHighScore();
  public abstract void nextLevel();
  public abstract void start();
  public abstract void stop();
  public abstract void pauseToggle();
  public abstract void newGame();
  public abstract void addProjectile(Projectile p);
  public abstract void removeProjectile(Projectile p);
  public abstract void run();
  
  public Screen getScreen() {
    return screen;
  }
  
  public int maxX() {
    return maxX;
  }
  
  public int maxY() {
    return maxY;
  }
  public void paintComponent(Graphics g) {
    super.paintComponent(g);
  }

}
