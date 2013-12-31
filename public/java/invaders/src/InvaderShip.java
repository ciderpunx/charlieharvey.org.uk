package invaders;
import java.awt.*;
import javax.swing.*;
import java.util.Random;
// The goody ship for space invaders

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

public class InvaderShip extends Ship {
  private int maxX; // should be able to slurp this from game!
  private long lastFired = 0;
  private final int FIRE_DELAY = 500; //gap betwen laser bolts
  
  public InvaderShip(Game g,int x, int y) {
    setImage(InvaderImageStore.getInstance().getImage("invaders_ship.gif"));
    projectile = null;
    this.x=x;
    this.y=y;
    game=g;
    maxX=game.maxX();
  }

  public void goLeft(){
    if(x < width/4) return;
    x-=width/4;
  }
  
  public void goRight() {
    if(x > maxX ) return;
    x+=width/4;
  }
  
  public void goUp() { }
  
  public void goDown() { }
  
  public void explode(){ 
    game.shipKilled();
  }

  public void fire() { 
    if (System.currentTimeMillis()-lastFired>FIRE_DELAY) {
      projectile=new Laser(game,x+width/2,y-height/2);
      game.addProjectile(projectile);
      lastFired=System.currentTimeMillis();
    }
  }
  
}
