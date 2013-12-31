package invaders;
import java.util.*;
// A cohort of InvaderBaddies for space invaders

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

public class InvaderBaddyCohort extends BaddyCohort {
  private long lastFired=0;
  private int bombDelay;
  private Random rnd =new Random();
  private int maxRight;
  private int minLeft=20;
  private int maxUp;
  private int maxDown=60;
     
  public InvaderBaddyCohort(Game g,int col, int row) {
    game=g;
    cols=col;
    rows=row;
    goingRight=true; 
    goingLeft=false; 
    goingUp=false; 
    goingDown=false;
    bombDelay=650;
    maxRight=game.maxX();
    maxUp=game.maxY();

    baddies=new Baddy[rows][cols];
    size=rows*cols; 
    InvaderBaddy b = new InvaderBaddy(game,0,0);
    int w=b.getWidth();
    int h=b.getHeight();
    for (int x=0;x<row;x++) {
      for (int y=0;y<col;y++) {
        addBaddy(new InvaderBaddy(game, 10+x*w,y*h), x, y);
      }
    }
  }
  
  public void getPositions() {   
    boolean topSet = false;
    boolean leftSet = false;
    int x=0; int y=0;
    
    for (x=0;x<rows;x++) {
      for (y=0;y<cols;y++) {
        if(baddies[x][y]!=null) {
          if(rnd.nextInt(9999)%237==0 && 
              System.currentTimeMillis()-lastFired>bombDelay) {
            baddies[x][y].fire();
            lastFired=System.currentTimeMillis();
          }
          if(!leftSet) {
            left=baddies[x][y].getX();
            leftSet=true;
          }
          if(!topSet) { 
            top=baddies[x][y].getY();
            topSet=true;
          }
          bottom=baddies[x][y].getY();
          right=baddies[x][y].getX();
        }
      }
    } 
  }

  public Baddy[] getBaddies() {
    ArrayList allBaddies = new ArrayList();
    for (int x=0;x<rows;x++) {
      for (int y=0;y<cols;y++) {
        if (baddies[x][y]!=null) 
          allBaddies.add(baddies[x][y]);
      }
    }
    // eeeuch! 
    return (Baddy[])allBaddies.toArray(new Baddy[allBaddies.size()]);
  }

  public void checkForImpact(Projectile p) {
    boolean hit=false;
    for (int x=0;x<rows && !hit;x++) {
      for (int y=0;y<cols && !hit;y++) {
        if (p.collidesWith(baddies[x][y])) {
          baddies[x][y].explode();
          p.explode();
          hit=true;
        }            
      }
    }
  }
  
  public void goLeft() {
    Baddy[] b = getBaddies();
    for (int i=0;i<b.length;i++)
      b[i].goLeft();
  }

  public void goRight() {
    Baddy[] b = getBaddies();
    for (int i=0;i<b.length;i++) 
      b[i].goRight();
  }

  public void goUp(){/* dont need this! */}
  public void goDown(){
    Baddy[] b = getBaddies();
    for (int i=0;i<b.length;i++) 
      b[i].goDown();
  }
 
  public void move() {
    getPositions();
    
    if(goingRight) {
      if(right<maxRight)
        goRight();
      else {
        goDown();
        goingLeft=true;
        goingRight=false;
      }
    } 
    
    else if (goingLeft) {
      if(minLeft<left)
        goLeft();
      else {
        goDown();
        goingRight=true;
        goingLeft=false;
      }
    }
  }
  
  public void addBaddy(Baddy b, int row, int col) {
    if(baddies[row][col]==null && b!=null) 
      baddies[row][col]=b;
  }

  public void removeBaddy(int row, int col) {
    if(row>rows || row<0) return;
    if(col>cols || col<0) return;
    if(baddies[row][col]!=null) {
      baddies[row][col]=null;
      size--;
    }
  }
  
  public void removeBaddy(Baddy b) {
    for (int x=0;x<rows;x++) {
      for (int y=0;y<cols;y++) {
        if (baddies[x][y]!=null) {
          if (baddies[x][y].equals(b))  {
            baddies[x][y]=null;
            size--;
          }
        }
      }
    } 
  }
}
