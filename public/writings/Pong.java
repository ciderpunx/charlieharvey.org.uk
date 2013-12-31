import java.awt.*;
import java.awt.event.*;
import java.awt.geom.*;
import java.io.*;
import javax.swing.*;
import java.util.Random;
/**
 * Pong class: A Pong game object
 * @author charlie harvey
 * @modified 2005-05-16
 *
 */
//               Copyright (C)2005  Charlie Harvey
//
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation; either version 2
// of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place - Suite 330, Boston,
// MA  02111-1307, USA.
// Also available on line: http://www.gnu.org/copyleft/gpl.html

public class Pong extends JPanel implements ActionListener, KeyListener {
	private Bat lBat, rBat;
	private Ball ball;
	private int UNIT = 5; // unit of movement - how many pixels each thing moves at at a time
	private int MAX_DLY=1000;  // maximum delay (1 second)
	private int MIN_DLY=30; // minimum delay (30ms)
	private int height=400, width=400;
	private int delay=200;
	private Timer timer;
	private boolean playing=false;
	private Random rnd = new Random();
	
	public Pong() {
		setBackground(Color.BLACK);
		setForeground(Color.WHITE);
		setSize(400,400);
		lBat=new Bat(10,20,"Player One",height);
		rBat=new Bat(370,300,"Player Two",height);
		ball=new Ball(200,50,width,height);
		addKeyListener(this);
	}

	public void slower() {
		if(delay+50<MAX_DLY) {
			pause();
			delay+=50;
			timer.setDelay(delay);
			resume();
		}
	}

	public void faster() {
		if(delay-30>MIN_DLY) {
			pause();
			delay-=30;
			timer.setDelay(delay);
			resume();
		}
	}

	public String getScoreLeft() {
		return new String(""+lBat.getScore());
	}
	public String getScoreRight() {
		return new String(""+rBat.getScore());
	}

	public String getNameLeft() {
		return lBat.getName();
	}
	public String getNameRight() {
		return rBat.getName();
	}
	public void setNameLeft(String nu) {
		lBat.setName(nu);
	}
	public void setNameRight(String nu) {
		rBat.setName(nu);
	}
	public boolean isPaused() {
		return timer.isRunning();
	}
	
	public void pause() {
		if(timer.isRunning()) {
			timer.stop();
		}
	}

	public void resume() {
		if(!timer.isRunning() && playing){
			timer.restart();
		}
	}
	
	public void play() {	
		requestFocus();
		int startX = rnd.nextInt(width);
		if(startX<200) startX+=200;
		if(startX>width-200) startX-=200;
		int startY = rnd.nextInt(height);
		if(startY<200) startY+=200;
		if(startY>height-200) startY-=200;
		ball=new Ball(startX,startY,width,height);
		if(startX>(width/2)) {
			ball.goingLeft=true;
		}
		else {
			ball.goingRight=true;
		}
		if(startY>(height/2)) {
			ball.goingDown=true;
		}
		else {
			ball.goingUp=true;
		}
		timer = new Timer(delay, this);
 		timer.setInitialDelay(500);
		playing=true;
        	timer.start();
	}

	public void paintComponent(Graphics g) {
	    	clear(g);
		Graphics2D g2d = (Graphics2D)g;
		g2d.fill(ball);
		g2d.fill(lBat);
		g2d.fill(rBat);
		
	}

 	protected void clear(Graphics g) {
	          super.paintComponent(g);
	}

	public void gameOver(String winner) {
		playing=false;
		JOptionPane.showMessageDialog(this, "Game Over!\nThe winner was: " + winner);
		requestFocus();
	}

	public void actionPerformed(ActionEvent aE) {
		if(ball.getMinY()>=(lBat.getMinY()-ball.getHeight()) && 
		   ball.getMaxY()<=(lBat.getMaxY()+ball.getHeight()) && 
		   ball.getMinX()<=lBat.getMaxX() ) {
			ball.goingLeft=false;ball.goingRight=true;
		}
		if(ball.getMinY()>=rBat.getMinY()-ball.getHeight() && 
		   ball.getMaxY()<=rBat.getMaxY()+ball.getHeight() && 
		   ball.getMaxX()>=rBat.getMinX() ) {
			ball.goingLeft=true;ball.goingRight=false;
		}
		if(ball.hitLeft){
			timer.stop();
			rBat.win();
			gameOver(rBat.getName());
		}
		if(ball.hitRight){
			timer.stop();
			lBat.win();
			gameOver(lBat.getName());
		}
		if(ball.goingRight){
			ball.right();
		}
		else if(ball.goingLeft){
			ball.left();
		}
		if(ball.goingUp){
			ball.up();
		}
		else if(ball.goingDown){
			ball.down();
		}
		repaint();
		requestFocus();
	}

	public void keyPressed(KeyEvent e){
		if (e.getKeyChar()=='/' || e.getKeyChar()=='?'){
			rBat.down();
		}
		else if (e.getKeyChar()=='@' || e.getKeyChar()=='\''){
			rBat.up();
		}
		else if (e.getKeyChar()=='z' || e.getKeyChar()=='Z'){
			lBat.down();
		}
		else if (e.getKeyChar()=='a' || e.getKeyChar()=='A'){
			lBat.up();
		}
		else if (e.getKeyChar()==' ') {
			if(!playing) {play();}
			else if(timer.isRunning()) {pause();}
			else if(!timer.isRunning()) {resume();}
		}
		else if (e.getKeyChar()=='\n') {
			faster();
		}
		else if (e.getKeyChar()=='\t') {
			slower();
		}
	}

	public void keyReleased(KeyEvent e){}
	public void keyTyped(KeyEvent e) {}

	public static void main(String argv[]) {
		JFrame jF=new JFrame("Pong");
		Pong p = new Pong();
		jF.getContentPane().add(p);
		jF.getContentPane().add(new JLabel("PONG"));
		p.play();
		jF.setSize(500,500);
		jF.setVisible(true);
	}
}

class Bat extends Rectangle2D.Double {
	private int x,y,maxY;
	private int score=0;
	private int w=20,h=40;
	private int UNIT = 10; // unit of movement - how many pixels each thing moves at at a time
	private String name;
	public Bat(int xIn, int yIn, String nameIn,int yMax) {
		x=xIn;
		y=yIn;
		maxY=yMax;
		this.setRect(x,y,w,h);
		name=nameIn;
	}

	public int getScore(){
		return score;
	}

	public void win() {
		score++;
	}
	public String getName() {
		return name;
	}

	public void setName(String nm) {
		name=nm;
	}
	
	public void up() {
		if(getMinY()>0){
			y-=UNIT;
		}
		this.setRect(x,y,w,h);
	}

	public void down() {
		if(getMaxY()<maxY){
			y+=UNIT;
		}
		this.setRect(x,y,w,h);
	}

}

class Ball extends Ellipse2D.Double {
	private int x,y,maxX,maxY;
	private int h=20,w=20;
	private int UNIT = 10; // unit of movement - how many pixels each thing moves at at a time
	public boolean goingLeft=false,goingRight=false,goingUp=false,goingDown=false;
	public boolean hitLeft=false,hitRight=false;	
	
	public Ball(int xIn, int yIn, int xMax,int yMax){
		x=xIn;
		y=yIn;
		maxX=xMax;
		maxY=yMax;
		setFrame(x,y,w,h);
	}
	
	public void up() {
		if(getMinY()>0){
			y-=UNIT;
		}
		else { 
			goingUp=false;goingDown=true;
		}
		this.setFrame(x,y,w,h);
	}

	public void down() {
		if(getMaxY()<maxY){
			y+=UNIT;
		}
		else {  
			goingUp=true;goingDown=false;
		}
		this.setFrame(x,y,w,h);
	}
	
	public void right() {
		if(getMaxX()<maxX){
			x+=UNIT;
		}
		else { 
			hitRight=true;
		}
		this.setFrame(x,y,w,h);
	}
	
	public void left() {
		if(getMinX()>0){
			x-=UNIT;
		}
		else { 
			hitLeft=true;
		}
		this.setFrame(x,y,w,h);
	}

}
