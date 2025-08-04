/*
 * Examples for "Formale Systeme 2 - Anwendung"
 * Lectures at KIT
 *
 * Mattias Ulbrich <ulbrich@kit.edu>, 2023
 * 
 */

#include <assert.h>

// Try running:
// cbmc --function test c1.c
// cbmc --function test --unwinding-assertions --unwind 10 c1.c
// cbmc --function test --unwinding-assertions --unwind 33 c1.c

extern int nondet_int();

/* This function should return the number of decimal digits of a non-negative argument. */
/* (Problem is fixed here). */

int f(int x) {

  if(x == 0) return 1;

  int result = 0;

  while(x > 0) {
    result ++;
    x = x / 10;
  }

  return result;
  
}


void test() {
  int x = nondet_int();

  if(x < 0) {
    return;
  }
  
  int fx = f(x);
  
  assert( 1<=fx && fx<=10 );
}
