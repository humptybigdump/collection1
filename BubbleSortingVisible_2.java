import Prog1Tools.IOTools;

public class BubbleSortingVisible
{
    public static void main (String [] args)
    {    	
        int[] unsorted = {2,5,4,3,1,7,0,6};
        int[] sorted;

       	printOutIntArray(unsorted);
        sorted = bubbleSortVisible(unsorted);
    }

    public static int[] bubbleSortVisible(int[] sequenceToBeSorted)
    {
        // declaration and initialization of return and auxiluary variables
        int[] result = sequenceToBeSorted.clone();
        int n = 0;
        int temp = 0;
        boolean changedSomething = false;

        System.out.println("*********Demonstrating Bubble Sort********");
               
        // the actual sorting algorithm
        n = result.length - 1;
        do
        {
        	System.out.println("****Durchlauf innere Schleife****");
            changedSomething = false;
            for (int i = 0; i <= n - 1; i++)
            {
            	
            	boolean changedSomethingInForLoop = false;
                if (result[i] > result[i + 1])
                {
                     // Ringtausch
                     temp = result[i];
                     result[i] = result[i + 1];
                     result[i + 1] = temp;
                     changedSomething = true;
                     changedSomethingInForLoop = true;
                }

                if(changedSomethingInForLoop){ printOutIntArrayWithFocus(result,i);}
                else printOutIntArray(result);
                
                try{ Thread.sleep(1000);}catch(Exception e){}
            }
            n = n - 1;
            
        } while (changedSomething && (n >= 1));

		System.out.println("***BubbleSort beendet***");
        
        return result;
    }
    
    public static void printOutIntArray(int[] inputArray){
		System.out.print("( " );
		for (int i = 0; i < inputArray.length; i++){
			
			System.out.print(" " + inputArray[i] + " ");
		}
		System.out.println(" )" );
	}
	
	public static void printOutIntArrayWithFocus(int[] inputArray, int emp){
		System.out.print("( " );
		
		for (int i = 0; i < inputArray.length; i++){
			if(i == emp){System.out.print("[");}else{System.out.print(" ");}
			System.out.print(inputArray[i]);
			if(i == emp+1){System.out.print("]");}else{System.out.print(" ");}
		}
		
		System.out.print(" )" );
		IOTools.readLine("    Weiter?");
	}
   
}
