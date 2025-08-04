/*
 * Examples for "Formale Systeme 2 - Anwendung"
 * Lectures at KIT
 *
 * Mattias Ulbrich <ulbrich@kit.edu>, 2023
 * 
 */

#include <assert.h>
#include <stdio.h>

// cbmc -DN=6 --function test --unwinding-assertions --unwind 7 --trace --pointer-check

extern int nondet_int();


void swap(int *array, int i, int j) {
  int t = array[i];
  array[i] = array[j];
  array[j] = t;
}

void f(int *array, int n) {

  for(int i = 0; i < n; i++) {
    int s = i;
    for(int j = i+1; j < n; j++) {
      if(array[j] < array[s]) s = j;
    }
    swap(array, i, s);
  }
}

void test() {

  int n = N;

  int *array = malloc(n * sizeof(int));

  for(int i = 0; i < n; i++) {
    array[i] = nondet_int();
  }

  f(array, n);

  for(int i = 0; i < n-1; i++) {
    assert(array[i] <= array[i+1]);
  }

  free(array);
  
}

/*

$ time cbmc -DN=7 --function test --unwinding-assertions --unwind 8 c3.c --trace
real	0m35,593s
user	0m35,244s
sys	0m0,343s

$ time cbmc -DN=7 --function test --unwinding-assertions --unwind 8 c3.c --trace --external-sat-solver ./kissat
real	1m45,040s
user	1m44,463s
sys	0m0,716s

*/
