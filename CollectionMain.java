package edu.kit.aifb.proksy.collectionTest;

import java.util.*;

/**
 * @version 1.0
 * @author ProkSy-Team
 *
 */
public class CollectionMain {
	
	public static void main(String[] args) {
		//HashSet
		HashSet<Integer> hashSet = new HashSet<Integer>();
		hashSet.add(17);
		hashSet.add(5);
		hashSet.add(7);
		hashSet.add(9);
		hashSet.add(10);
		hashSet.add(10);
		
		Iterator<Integer> it = hashSet.iterator();
		System.out.println("HashSet:");
		while(it.hasNext()) {
			int i = (int) it.next();
			System.out.println(i);
		}
		//TreeSet
		TreeSet<Integer> treeSet = new TreeSet<Integer>();
		treeSet.add(17);
		treeSet.add(5);
		treeSet.add(7);
		treeSet.add(9);
		treeSet.add(10);
		treeSet.add(10);
		
		it = treeSet.iterator();
		System.out.println("TreeSet:");
		while(it.hasNext()) {
			int i = (int) it.next();
			System.out.println(i);
		}
		//ArrayList
		ArrayList<Integer> arrayList = new ArrayList<Integer>();
		arrayList.add(17);
		arrayList.add(5);
		arrayList.add(7);
		arrayList.add(9);
		arrayList.add(10);
		arrayList.add(10);
		
		it = arrayList.iterator();
		System.out.println("ArrayList:");
		while(it.hasNext()) {
			int i = (int) it.next();
			System.out.println(i);
		}
		//LinkedList
		LinkedList<Integer> linkedList = new LinkedList<Integer>();
		linkedList.add(17);
		linkedList.add(5);
		linkedList.add(7);
		linkedList.add(9);
		linkedList.add(10);
		linkedList.add(10);
		Collections.sort(linkedList);
		
		it = linkedList.iterator();
		System.out.println("LinkedList:");
		while(it.hasNext()) {
			int i = (int) it.next();
			System.out.println(i);
		}
	}

}
