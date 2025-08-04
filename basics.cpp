#include<stdio.h>

int main() {
    int someInt = 42;
    int *someIntPointer = &someInt;
    int anotherInt = *someIntPointer;    

    someInt++;
    printf("%d\n", someInt);//43
    printf("%d\n", *someIntPointer);//43
    printf("%d\n", anotherInt);//42   

    printf("\n");

        
    int array[] = {5, 6, 7, 8, 9, 10, 11, 12};
    int *intPointer = array; //!

    int anElement = array[2]; //7
    int anotherElement = *(intPointer + 2); //7

    printf("%d\n", anElement);
    printf("%d\n", anotherElement);   
    printf("\n");
    
    int someNumber = *((char*)(array + 3) + 4);
    printf("%d\n", someNumber);
}