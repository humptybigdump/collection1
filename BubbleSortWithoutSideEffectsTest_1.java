import org.junit.*;
import static org.junit.Assert.*;
import java.io.*;

public class BubbleSortWithoutSideEffectsTest
{
	@Test
	public void runMainMethod(){
		String[] a = {""};
		BubbleSort.main(a);
	}

	@Test
	public void runGenerateRandomSequence(){
		try{
			int[] myRandomIntArray1 = BubbleSort.generateNewRandomArray(20);
			int[] myRandomIntArray2 = BubbleSort.generateNewRandomArray(20);
			int changes = 0;
			int numbersSame = 0;
			boolean direction = false;
			for(int i = 0; i<myRandomIntArray1.length-1; i++){
				if(direction){
					if(myRandomIntArray1[i]>=myRandomIntArray1[i+1]){
						direction = !direction;
						changes++;
					}
				}else{
					if(myRandomIntArray1[i]<=myRandomIntArray1[i+1]){
						direction = !direction;
						changes++;
					}
				}
				if(myRandomIntArray1[i]== myRandomIntArray2[i]) numbersSame++;
			}
			assertTrue("newly generated Array does not seem to be unsorted", (changes>4));
			assertTrue("Seems as if every time the same array is being created", (numbersSame<10));
		}catch(Exception e){
			throw new AssertionError("could not find or execute public method: " +
							"BubbleSort.generateNewRandomArray(10);");
		}
	}

	private static final ByteArrayOutputStream fromConsole = new ByteArrayOutputStream();
    private static PipedOutputStream outputToConsole;
	private static PipedInputStream inputOfConsole;
	private static String outputString;
	
	@Test
	public void runPrintArray(){
		try{
			outputToConsole = new PipedOutputStream();
        	inputOfConsole  = new PipedInputStream(outputToConsole);
			System.setIn(inputOfConsole);
			System.setOut(new PrintStream(fromConsole));
			
	        int[] a = {1,2,3,4,5,6};
	        BubbleSort.printArrayToConsole(a);
			outputString = fromConsole.toString();
			boolean printedOutA = false;
			if (outputString.contains("1") && outputString.contains("2") &&
				outputString.contains("3") && outputString.contains("4") &&
				outputString.contains("5") && outputString.contains("6")){
					printedOutA = true;
				}
			assertTrue("error with printArrayToConsole. Content was not printed to console",printedOutA);

			System.setOut(System.out);
    		System.setIn(System.in);
    	}catch(Exception e){
    		throw new AssertionError("could not find or execute method; " +
							"printArrayToConsole(...);");
		}
		
	}

	@Test
	public void runArraySortWithoutSideEffects(){
		boolean sortedWithoutSideEffects = true;
		boolean originalStillIntact = true;
		int[] newArray = g(10);
		int[] backUpArray = new int[10];
		for(int i = 0; i<newArray.length;i++){
			backUpArray[i] = newArray[i];
		}
		int[] sortedArray = {};
		try{
			sortedArray = BubbleSort.sortArray(newArray);
		}catch(Exception e){}
		
		for(int i = 0;(i<(sortedArray.length-1) && 
				sortedWithoutSideEffects == true);i = i+1){
			if (sortedArray[i]>sortedArray[i+1]){
				sortedWithoutSideEffects = false;
			}
		}
		for(int i = 0; i<newArray.length&&originalStillIntact;i++){
			if(backUpArray[i] != newArray[i]){
				originalStillIntact=false;
			}
		}
		
		assertTrue ("new random array was not sorted without side effects!",sortedWithoutSideEffects);
		assertTrue ("The original array must not changed!",originalStillIntact);
	}

 	public static int[] g (int lengthParameter)
    {
        int[] result = new int[lengthParameter];
        
        for(int i = 0; i< result.length;i++)
        {
            result[i] = (int)(Math.random()*1000)+1;
        }
        return result;
    }
}
