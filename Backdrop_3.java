import java.awt.*;
import javax.swing.*;
import Prog1Tools.IOTools;

public class Backdrop{

	private static int h = 4; // height of board
	private static int w = 4; // width of board
	private static int players = 2; // number of players
	
	//runs on startup
	public static void main(String[] args){
    	//creation and setup of a game window
		new Backdrop();
    }
	
	private JPanel board; // defines the area tokens can apear in on the gui
	
	public static Token[] tokenList = new Token[h*w]; // stores each individual token so that they can be referenced seperately from outside the token class, as well as within other instances of the token class
	
	private static int turn = players; // used to keep track of who's turn it is currently
	
	private static int pMoves = 0; // used to keep track of how many moves are available each turn
	
	private static JLabel current; // creates a label that will be used to display who's turn it is

	public Backdrop(){
		//creation and setup of a game window
		Window othello = new Window();
		current = new JLabel(Token.green);
		current.setBounds(910,10+100*(h-1)*8/h,90*8/h,90*8/h);
		board = new JPanel();
		board.setBounds(0,0,900,900);
		board.setLayout(null);
		othello.add(board);
		othello.add(current);
		current.setVisible(true);
		GameOver.setup();
		othello.add(GameOver.winner);
		othello.setIconImage(Token.green.getImage().getScaledInstance(200, 200, Image.SCALE_DEFAULT));
		


		//setup of tokens on the board and their initial states
		for (int i = 0; i<h*w;i++){
			tokenList[i] = new Token(i);
		}
		for (int i = 0; i<h*w;){
			tokenList[i].checkValid();
			tokenList[i].update();
			board.add(tokenList[i].token);
			board.add(tokenList[i].action);
			tokenList[i].token.setVisible(true);
			i++;
		}
		//initialise game
		turn();
	}


	//updates who's turn it is and determines whether the game has ended
	public static void turn(){
		pMoves = 0;
		if (turn == players){
			turn = 1;
		}
		else{
			turn++;
		}
		current.setIcon(Token.imageList[turn]);
		for (int i = 0; i<h*w;i++){
			tokenList[i].checkValid();
			tokenList[i].update();
		}
		if (pMoves > 0){
			GameOver.gameOver = 0;
		}
		else{
			GameOver.NoMoves();
			GameOver.GameOver();
		}
	}

	public static int getHeight(){
		return h;
	}

	public static int getWidth(){
		return w;
	}

	public static int getPlayers(){
		return players;
	}

	public static int getTurn(){
		return turn;
	}

	public static int getPMoves(){
		return pMoves;
	}

	public static void setPMoves(int pMoves){
		Backdrop.pMoves = pMoves;
	}
}
