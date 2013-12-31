import java.awt.*;
import java.awt.event.*;
import javax.swing.*;
/*
 * PongApplet: puts a Pong object, and some controls into your web 
 * page. Will have comments soon...
 * 
 * @author     Charlie
 * @created    11 May 2005
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

public class PongApplet extends JApplet implements ActionListener {
	private JButton pause, play, faster, slower,nameSet;
	private JLabel rScore,lScore,status;
	private JTextField rName,lName;
	private JPanel top, bottom;
	private Pong pong;

	public void init() {
		getContentPane().setLayout(new BorderLayout());
		pong=new Pong();
		getContentPane().add(pong, BorderLayout.CENTER);
		
		lScore=new JLabel(pong.getScoreLeft());
		lName=new JTextField("Player 1");
		rScore=new JLabel(pong.getScoreRight());
		rName=new JTextField("Player 2");
		status=new JLabel("Waiting to play...");
		top=new JPanel();
		top.add(lName);
		top.add(lScore);
		top.add(status);
		top.add(rName);
		top.add(rScore);
		getContentPane().add(top, BorderLayout.NORTH);
		
		pause=new JButton("Pause");
		pause.addActionListener(this);
		play=new JButton("Play");
		play.addActionListener(this);
		faster=new JButton("Faster");
		faster.addActionListener(this);
		nameSet=new JButton("Update");
		nameSet.addActionListener(this);
		slower=new JButton("Slower");
		slower.addActionListener(this);
		bottom=new JPanel();
		bottom.add(pause);
		bottom.add(faster);
		bottom.add(nameSet);
		bottom.add(slower);
		bottom.add(play);
		getContentPane().add(bottom, BorderLayout.SOUTH);
	}

	public void actionPerformed(ActionEvent e) {
		if(e.getActionCommand()=="Play"){
			if(!pong.isVisible()) {
				pong.setVisible(true);
			}
			lScore.setText(pong.getScoreLeft());
			rScore.setText(pong.getScoreRight());
			status.setText("The Game Is On ...");
			pong.play();
		}
		else if(e.getActionCommand()=="Pause") {
			pause.setText("Resume");
			pong.pause();
		}
		else if(e.getActionCommand()=="Resume") {
			lScore.setText(pong.getScoreLeft());
			rScore.setText(pong.getScoreRight());
	      		pause.setText("Pause");
			pong.resume();
		}
		else if(e.getActionCommand()=="Faster") {
			pong.faster();
		}
		else if(e.getActionCommand()=="Slower") {
			pong.slower();
		}
		else if(e.getActionCommand()=="Update") {
	      		rScore.setText(pong.getScoreRight());
	      		lScore.setText(pong.getScoreLeft());
			pong.setNameLeft(lName.getText());
	      		pong.setNameRight(rName.getText());
			lScore.setText(pong.getScoreLeft());
			rScore.setText(pong.getScoreRight());
		}
	}
}
