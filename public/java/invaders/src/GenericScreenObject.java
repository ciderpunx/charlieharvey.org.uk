package invaders; 
import java.awt.*;
import javax.swing.*;
import java.util.Random;
// A generic object for displaying objects on our Screen

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

public class GenericScreenObject extends ScreenObject{
  int maxY; 
  
  public GenericScreenObject(Game g, Image i, int x, int y) {
    setImage(i);
    this.x=x;
    this.y=y;
    game=g;
    maxY=game.maxY();
  }
  
  public void goLeft(){
    x-=width/2;
    if(x<1) x=1;
  }
  
  public void goRight() {
    x+=width/2;
  }
  
  public void goUp() {
    y-=height/2;
    if(y<1) y=1;
  }
  
  public void goDown() {
    if(y+height<maxY)
      y+=height/2;
  }
  
  public void explode(){ 
  }

}
