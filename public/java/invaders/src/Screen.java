package invaders;
import java.awt.*;
import java.awt.image.*;
import javax.swing.*;
// The canvas onto which we draw our game
// This is just the interface

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

public abstract class Screen extends JPanel {
  ScreenObject[] objects;
  String message;
  Font msgFont;
  Color msgCol;
  int msgX,msgY;
  
  public void paintComponent(Graphics g) {
    super.paintComponent(g);
    for(int i=0;i<objects.length;i++) {
        g.drawImage(objects[i].getImage(),
                    objects[i].getX(),
                    objects[i].getY(), this);
    }
    if(message!=null) {
      g.setColor(msgCol);
      g.setFont(msgFont);
      g.drawString(message,msgX,msgY);
    }
  }

  public void setObjects(ScreenObject[] obj) {
    objects=obj;
  }

  public void setObject(ScreenObject obj) {
    objects=new ScreenObject[]{obj};
  }
  public void setMessage(String m) {
    setMessage(m,7,20,
          new Font("Arial",Font.BOLD,15),
          Color.WHITE);
  }
  public void setMessage(String m, int x, int y, Font f, Color c) {
    msgX=x;
    msgY=y;
    msgFont=f;
    msgCol=c;
    message=m;
  }

  public String getMessage() {
    return message;
  }
  
}
