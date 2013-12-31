package invaders;
import java.awt.*;
// This is the interface that all on screen objects implement

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

public abstract class ScreenObject {
  int x,y;  // co-ordinates
  int height,width; // size
  Rectangle me  = new Rectangle();
  Rectangle her = new Rectangle() ;
  public boolean exploded=false;
  Image image;
  Game game;
  public abstract void goLeft();
  public abstract void goRight();
  public abstract void goUp();
  public abstract void goDown();
  public abstract void explode();
  
  public void setImage(Image i) {
    image=i;
    height=image.getHeight(null);
    width=image.getWidth(null);
  }
  
  public int getX() {
    return x;
  }
  
  public int getY() {
    return y;
  }
  
  public Image getImage() {
    return image;
  }
  
  public boolean isAt(int x, int y) {
    return (this.x==x && this.y==y);
  }
  
  public int getHeight() {
    return height;
  }
  
  public int getWidth() {
    return width;
  }

  public boolean collidesWith(ScreenObject other) {
        if(other==null) 
          return false;
        me.setBounds((int) x, (int) y,
                      getWidth(), getHeight());
	her.setBounds((int) other.getX(),
                      (int) other.getY(),
                      other.getWidth(),
                      other.getHeight());
	return me.intersects(her);
  }
}
