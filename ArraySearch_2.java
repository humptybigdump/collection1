import java.util.Random;

public class ArraySearch{
	
	public static void main(String[] args){
		
		int[] array;
		
		array = createArray(100);
		linearSearch(array, 93);
		binarySearch(array, 93);

		System.out.println();
		System.out.println("####################");
		System.out.println();
		
		array = createArray(10000);
		linearSearch(array, 93);
		binarySearch(array, 93);

		System.out.println();
		System.out.println("####################");
		System.out.println();
		
		array = createArray(1000000);
		linearSearch(array, 93);
		binarySearch(array, 93);
		
		//array = createArray(100000000);
		//linearSearch(array, 93);
		//binarySearch(array, 93);
		
	}

	private static int[] createArray(int size){
		Random random = new Random(1);
		int[] array = new int[size];
		array[0] = 0;
		for (int i = 1; i<array.length; i++){
			array[i] = array[i-1] + random.nextInt(20)+1;
			//if (array[i]<100){ System.out.print(array[i] + " - ");}
		}
		//System.out.println();
		return array;
	}
	
	private static void linearSearch(int[] array, int n){
		double startTime = (double)System.nanoTime() / 1e6;
		
		boolean found = false;
		for (int i=0; i<array.length && !found;i++){
			if (n == array[i]){
				found = true;
			}
		}
		
		double endTime = (double)System.nanoTime() / 1e6;
		
		if (found){
			System.out.println("Linear search found " + n + " in the array of size " + array.length);
			System.out.println("Time: " + (endTime - startTime) + " ms");
		}else{
			System.out.println("Linear search didn't find " + n + " in the array of size " + array.length); 
			System.out.println("Time: " + (endTime - startTime) + " ms");
		}
	}

	private static void binarySearch(int[] array, int n){
		
		double startTime = (double)System.nanoTime() / 1e6;
		
		boolean found = false;
		int minIndex = 0;
		int maxIndex = array.length - 1;
		while (!found && minIndex <= maxIndex){
			int i = (minIndex + maxIndex) / 2;
			if (n == array[i]){
				found = true;
			}else if (n < array[i]){
				maxIndex = i - 1;
			}else{
				minIndex = i + 1;
			}
		}
		
		double endTime = (double)System.nanoTime() / 1e6;
		
		if (found){
			System.out.println("Binary search found " + n + " in the array of size " + array.length);
			System.out.println("Time: " + (endTime - startTime) + " ms");
		}else{
			System.out.println("Binary search didn't find " + n + " in the array of size " + array.length);
			System.out.println("Time: " + (endTime - startTime) + " ms");
		}
	}
}
