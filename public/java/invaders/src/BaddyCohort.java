package invaders;
// Interface for a collection of Baddies

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

public abstract class BaddyCohort {
  boolean goingLeft, goingRight, goingUp, goingDown;
  int top,bottom,left,right; // location of topleft 
                            // and bottomRight baddies
  int cols, rows; // columns and rows of baddies
  int size;       // number of baddies
  Baddy[][] baddies;
  Game game;
  
  public abstract void checkForImpact(Projectile p);
  public abstract void move();
  public abstract Baddy[] getBaddies();
  public abstract void addBaddy(Baddy b, int row, int col);
  public abstract void removeBaddy(Baddy b);
  public int size() {  return size;  }
}
