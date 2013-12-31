package invaders;
import java.awt.*;
import javax.swing.ImageIcon;
import java.util.Hashtable;
// Image store singleton for Invaders

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
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
MA  02110-1301, USA.*/

public class InvaderImageStore extends ImageStore {
  
  private static InvaderImageStore me = new InvaderImageStore();

  InvaderImageStore() {
    images=new Hashtable(); 
    addImage("laser.gif");   
    addImage("welcome.gif");   
    addImage("gameover.gif");   
    addImage("invader.gif");   
    addImage("invaders_ship.gif");   
    addImage("bomb.gif");   
    addImage("level.gif");   
  }

  public static InvaderImageStore getInstance() {
    return me;
  }
}
