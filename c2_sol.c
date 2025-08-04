/*
 * Examples for "Formale Systeme 2 - Anwendung"
 * Lectures at KIT
 *
 * Mattias Ulbrich <ulbrich@kit.edu>, 2023
 * 
 */

#include <assert.h>
#include <stdio.h>

// --function test
// --function test --unwinding-assertions --unwind 33 --trace

extern int nondet_int();

/* This function should return the number of decimal digits of a non-negative argument. 
   See also c1.c */

int f(int x) {

  if(x == 0) return 1;

  int result = 0;
  
  while(x > 0) {
    result ++;
    x = x / 10;
  }

  return result;
  
}

int fopt(int n) {

  int result = 1;
  while(1 == 1) {
    if(n < 10) return result;
    if(n < 100) return result+1;
    if(n < 1000) return result+2;
    if(n < 10000) return result+3;
    n /= 10000; result += 4;
  }
  return result;
}

void test() {
  int x = nondet_int();

  if(x < 0) {
    return;
  }
  
  int a = f(x);
  int b = fopt(x);
  
  assert(a == b);
}

