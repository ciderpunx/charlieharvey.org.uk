package invaders;
import java.awt.*;
import javax.swing.*;
// This is a laser projectile - it goes UP, never left, right,
// or down.

/*              Copyright (C) 2006 Charlie Harvey

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

public class Laser extends Projectile {
  private int minY;

  public Laser(Game g, int x,int y) {
    setImage(InvaderImageStore.getInstance().getImage("laser.gif"));
    minY=1;
    this.x=x;
    this.y=y;
    game=g;
  }
  public void goLeft(){}
  public void goRight(){}
  public void goDown(){}
  public void goUp() {
    if(exploded) return;
    if(y-height>minY)
      y-=height;
    else
      explode();
  }
 
  public void move() {
    goUp();
  }
  public void explode(){
    exploded=true;
    game.removeProjectile(this);
  }
}
