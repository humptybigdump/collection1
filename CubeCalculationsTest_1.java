import org.junit.*;
import static org.junit.Assert.*;
import java.io.*;
import Prog1Tools.GraphicScreen;

public class CubeCalculationsTest
{
    private static final ByteArrayOutputStream fromConsole = new ByteArrayOutputStream();
    private static PipedOutputStream outputToConsole;
	private static PipedInputStream inputOfConsole;
	private static TestInputThread inputThread;
	
    @BeforeClass
    public static void setUpTestCase ()
    {	
    	try{
			outputToConsole = new PipedOutputStream();
        	inputOfConsole  = new PipedInputStream(outputToConsole);
			System.setIn(inputOfConsole);
			System.setOut(new PrintStream(fromConsole));
    	}catch(Exception e){System.err.println("Could not setup Streams");}
    }

    @AfterClass
    public static void tearDownTestCase ()
    {
    	System.setOut(System.out);
    	System.setIn(System.in);
    }

    public static boolean testPassed;
    
    @Test
    public void InputOutputTest ()
    {	
    	testPassed = false;
    	
        String[] a = {""};
        inputThread = new TestInputThread(outputToConsole);
		inputThread.start();
        CubeCalculations.main(a);
		String myS  = fromConsole.toString();
        try{
        	boolean foundWeight = false;
        	boolean foundForce = false;
        	BufferedReader reader = new BufferedReader(new StringReader(myS));
			String line = reader.readLine();
	        while (line != null) {
	        	//System.err.println("--------");
	        	//System.err.println(line);
	        	//based upon the input of lenght 42 and material wood
	        	if(line.contains("1.1")){foundWeight = true;}
	        	if(line.contains("10.")){foundForce = true;}
	        	line = reader.readLine();
	        }
	        
	        if(foundWeight && foundForce){ testPassed = true;}
	       	else if (!foundWeight){throw new AssertionError("Could not find the calculated weight in output.");}
	       	else if (!foundForce){throw new AssertionError("Could not find the calculated force in output.");}
	       	
        }catch(Exception e){testPassed = false;}  

        
        assertTrue("Test was not Passed",testPassed);
    }
}

class TestInputThread extends Thread{
	PipedOutputStream byteStreamToConsole;
	
	public TestInputThread(PipedOutputStream byteStreamToConsole){
		this.byteStreamToConsole = byteStreamToConsole;
	}

	public void run()
  	{	
  		try 
      	{	
        	sleep(1);
        	
        	byteStreamToConsole.write("42".getBytes());
        	byteStreamToConsole.write(System.lineSeparator().getBytes());
        	sleep(1);
        	byteStreamToConsole.write("2".getBytes());
        	byteStreamToConsole.write(System.lineSeparator().getBytes());
        } 
      	catch (Exception e) {
      		System.err.println("Error in InputThread");
      		CubeCalculationsTest.testPassed = false;
      	} 
  	}
}
