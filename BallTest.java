import org.junit.*;
import static org.junit.Assert.*;
import java.io.*;

public class BallTest
{	
	private static final ByteArrayOutputStream fromConsole = new ByteArrayOutputStream();

	@Test 
	public void createNewBallInstances(){
		Ball myBall = new Ball();
	}

	@Test 
	public void createNewBallInstanceWithValues(){
		int randomRow = ((int)(Math.random()*25));
		int randomColumn = ((int)(Math.random()*80));
		
		Ball myBall2 = new Ball(randomRow,randomColumn);
		assertTrue("constructor did not set correct Values or getRow()-Method is wrong",
					myBall2.getRow()==randomRow);
		assertTrue("constructor did not set correct Values or getColumn()-Method is wrong",
					myBall2.getColumn()==randomColumn);
	}

	@Test
	public void testSetRow(){
		Ball myBall = new Ball();
		int randomRow = ((int)(Math.random()*25));
		myBall.setRow(randomRow);
		assertTrue("setRow() did not set correct values or getRow()-Method is wrong",
					myBall.getRow()==randomRow);
	}

	@Test
	public void testSetColumn(){
		Ball myBall = new Ball();
		int randomColumn= ((int)(Math.random()*25));
		myBall.setColumn(randomColumn);
		assertTrue("setRow() did not set correct values or getRow()-Method is wrong",
					myBall.getColumn()==randomColumn);
	}

	@Test
	public void testCalculateNewPosition(){
		Ball myBall = new Ball(0,0);
		myBall.calculateNewPosition();
		assertTrue("New row of Ball at (0,0) after calculateNewPosition() should be 1", 
					myBall.getRow()==1);
		assertTrue("New column of Ball at (0,0) after calculateNewPosition() should be 1",
					myBall.getColumn()==1);

		myBall = new Ball(24,79);
		myBall.calculateNewPosition();
		assertTrue("New row of Ball at (24,79) after calculateNewPosition() should be 23", 
					myBall.getRow()==23);
		assertTrue("New column of Ball at (24,79) after calculateNewPosition() should be 78",
					myBall.getColumn()==78);
	}
}
