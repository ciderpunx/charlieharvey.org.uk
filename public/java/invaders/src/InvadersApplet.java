package invaders;
import java.util.ArrayList;
import java.awt.*;
import javax.swing.*;
// simple applet to hold an instance of InvadersGame

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

public class InvadersApplet extends JApplet {
  private InvadersGame game;
  
  public void init() {
    //just a test harness
    game=new InvadersGame();
    setSize(400,400);
  }

  public void start() {
    getContentPane().add(game.getScreen());
    game.getScreen().requestFocus();
    setVisible(true);
  }

  public void stop() {}

  public void destroy() {}

}
