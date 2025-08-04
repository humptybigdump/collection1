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
		


		//setup the tokens on the board so that the game is in it's initial state
		//your code goes here
		/* Step 1: The same number of Tokens as playable spaces on the board should be created
		 * 
		 * Step 2: The game should be initialised. The methods checkValid() and update() from the class Token can be helpful here
		 * 
		 * Step 3: The tokens that were created should be displayed on the board. This can be done using the command Board.add() to add the JLabel token and the JButton action from the class Token.
		 * 
		 * Step 4: Ensure that the game opens and tokens (displayed as coloured circles) appear in a grid on the screen
		 * Hint: (tokenname).token.setVisible(true); is needed to ensure that the tokens appear on the screen instead of being invisible
		 */
	}


	//updates who's turn it is and determines whether the game has ended
	public static void turn(){
		//your code goes here
		/*
		 * turn() is run every time someone clicks on a token
		 * turn() should change who's turn it currently is and update the game state to display as such
		 * updating the game state should be done similarly to in the setup of the initial tokens, however the graphical elements (Board.add()) don't need to be run again
		 * 
		 * Once the game functions in it's most basic form, the turn() method should also be used in combination with the GameOver class to determine when the game has been completed
		 */
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
