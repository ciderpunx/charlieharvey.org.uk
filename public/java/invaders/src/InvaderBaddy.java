package invaders; 
import java.awt.*;
import javax.swing.*;
import java.util.Random;
// Standard space invaders baddy

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
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, 
MA  02110-1301, USA.*/

public class InvaderBaddy extends Baddy {
  int maxY; 
  private Random rnd = new Random();
  private long lastFired=0;
  
  public InvaderBaddy(Game g, int x, int y) {
    setImage(InvaderImageStore.getInstance().getImage("invader.gif"));
    this.x=x;
    this.y=y;
    game=g;
    maxY=game.maxY();
  }
  
  public void goLeft(){
    x-=width/4;
    if(x<1) x=1;
  }
  
  // right hand returning is handled at the Cohort 
  // level
  public void goRight() {
    x+=width/4;
  }
  
  public void goUp() {
    y-=height/4;
    if(y<1) y=1;
  }
  
  public void goDown() {
    if(y+height<maxY-height*2)
      y+=height;
    else
      game.gameOver();
  }
  
  public void explode(){ 
    game.baddyKilled((Baddy)this);
  }

  public void fire() {
    game.addProjectile(new Bomb(game, (x+width/2),y));
  }
}
