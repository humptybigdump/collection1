! Copyright (C)  2013-2014  Andrzej Niemunis
!
! the  set of modules sss, BasicTools, FEMTool, userdata, userMeshing and conjugate\_gradients
!  is free software; you can redistribute it and/or modify
! it under the terms of the GNU General Public License as published by
! the Free Software Foundation; either version 2 of the License, or
! (at your option) any later version.
!
! These modules are distributed in the hope that it will be useful,
! but WITHOUT ANY WARRANTY; without even the implied warranty of
! MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
! GNU General Public License for more details.

! You should have received a copy of the GNU General Public License
! along with this program; if not, write to the Free Software
! Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301,USA.

!> iterative equation solver:     CGsolver(..)  for  A.X = B  where A is a treated as a dense matrix   \n
!! two versions  CGSOLVER(n,A,B)  and  CGSOLVER(n,A,B,X0) without and with initial guess X0 are available
    
module conjugate_gradients
    implicit none

    real(8), parameter :: rhoToler = 1.0d-5  !< maximal value of square residuum  rho = r.r  (global variable)

!>  conjugated gradient solver function for the system  A.x == b of size n.    \n
!!   Usage: x = CGSOLVER(n,A,b,x0) or  x = CGSOLVER(n,A,b)                \n
!!  x0 is a predictor  (a good predictor may accelerate the solution)
    interface CGSOLVER
      module procedure  CGSOLVERwithoutX0  , CGSOLVERwithX0
    end interface

    private CGSOLVERwithoutX0 , CGSOLVERwithX0

    contains


!> CG solver after K.A.Hawick, K.Dincer, G.Robinson, G.C.Fox. Conjugate Gradient Algorithms in Fortran 90   \n
!! a verion without prescribed initial guess X0
function CGSOLVERwithoutX0(n,A,B)
implicit none
integer, intent(in) :: n                      !< size of the matrix A(n x n)
REAL(8), dimension(1:n,1:n), intent(in):: A   !< square matrix  from  A.X = B
REAL(8), dimension(1:n), intent(in) ::  B     !< RHS vector  from  A.X = B
real(8), dimension(n) ::  CGSOLVERwithoutX0
REAL(8), dimension(1:n) :: x, p, q, r,M
REAL(8) :: alpha, rho, rho0
integer :: i,k
integer :: Niter
logical :: stop_criterion

Niter =  n ! theoretically should be enough
! x(1:n) = 0.0 ! An initial guess
do i=1,n ; M(i)=A(i,i); enddo ! M is a preconditioning matrix from diagonal components of A
x = B/M ;   ! An initial guess
If(any(x > 1)) write(*,*) 'suspicious predictor B/M = x with components > 1' 

 10  continue  ! start of CG process
r(1:n) = b(1:n) - MATMUL( A(1:n,1:n), x(1:n) )  !residuum

p(1:n) = r(1:n)
rho = DOT_PRODUCT( r(1:n), r(1:n) )

 IF (   rho < rhoToler  ) then
     CGSOLVERwithoutX0 = x
     return    ! first predictor turns out to be  perfect
 Endif

q(1:n) = MATMUL( A(1:n,1:n), p(1:n) )
alpha = rho / DOT_PRODUCT( p(1:n), q(1:n) )
x(1:n) = x(1:n) + alpha * p(1:n) !saxpy
r(1:n) = r(1:n) - alpha * q(1:n) !saxpy

DO k = 2, Niter
 rho0 = rho
 rho = DOT_PRODUCT( r(1:n), r(1:n) )
 p(1:n) = r(1:n) + ( rho/rho0 ) * p(1:n)
 q(1:n) = MATMUL( A(1:n,1:n), p(1:n) )
 alpha = rho / DOT_PRODUCT( p(1:n) , q(1:n) )
 x(1:n) = x(1:n) + alpha * p(1:n) !saxpy
 r(1:n) = r(1:n) - alpha * q(1:n) !saxpy
 stop_criterion = ( rho < rhoToler )
 IF (   stop_criterion ) exit
END DO

 write(*,*) 'rho=', rho, '   k=',k ,'   of Niter=',Niter
 if (k >= Niter .and. .not. stop_criterion )   goto 10

 CGSOLVERwithoutX0(:) = x(:)

end function CGSOLVERwithoutX0


!> CG solver after K.A.Hawick, K.Dincer, G.Robinson, G.C.Fox. Conjugate Gradient Algorithms in Fortran 90 \n
!! a verion with prescribed initial guess X0
function CGSOLVERwithX0(n,A,B,X0)
implicit none
integer, intent(in) :: n                              !< size of the matrix A(n x n)
REAL(8), dimension(1:n,1:n), intent(in):: A           !< square matrix  from  A.X = B
REAL(8), dimension(1:n), intent(in) ::  B             !<  RHS vector  from  A.X = B
REAL(8), dimension(1:n), intent(in) ::  X0            !<  initial guess for the  solution  X

real(8), dimension(n) ::  CGSOLVERwithX0
REAL(8), dimension(1:n) :: x, p, q, r !,M
REAL(8) :: alpha, rho, rho0
integer :: i,k
integer :: Niter
logical :: stop_criterion

Niter =  n ! theoretically should be enough
! x(1:n) = 0.0 ! An initial guess
! do i=1,n ; M(i)=A(i,i); enddo ! M is a preconditioning matrix from diagonal components of A
x = X0 ;   !  initial guess

 10  continue  ! start of CG process
r(1:n) = b(1:n) - MATMUL( A(1:n,1:n), x(1:n) )  !residuum

p(1:n) = r(1:n)
rho = DOT_PRODUCT( r(1:n), r(1:n) )

IF (   rho < rhoToler  ) then
     CGSOLVERwithX0 = x
     return    ! first predictor turns out to be  perfect
 Endif

q(1:n) = MATMUL( A(1:n,1:n), p(1:n) )
alpha = rho / DOT_PRODUCT( p(1:n), q(1:n) )
x(1:n) = x(1:n) + alpha * p(1:n) !saxpy
r(1:n) = r(1:n) - alpha * q(1:n) !saxpy

DO k = 2, Niter
 rho0 = rho
 rho = DOT_PRODUCT( r(1:n), r(1:n) )
 p(1:n) = r(1:n) + ( rho/rho0 ) * p(1:n)
 q(1:n) = MATMUL( A(1:n,1:n), p(1:n) )
 alpha = rho / DOT_PRODUCT( p(1:n) , q(1:n) )
 x(1:n) = x(1:n) + alpha * p(1:n) !saxpy
 r(1:n) = r(1:n) - alpha * q(1:n) !saxpy
 stop_criterion = ( rho < rhoToler )
 IF (   stop_criterion ) exit
END DO

 write(*,*) 'rho=', rho, '   k=',k ,'   of Niter=',Niter
 if (k >= Niter .and. .not. stop_criterion ) goto 10

 CGSOLVERwithX0(:) = x(:)

end function CGSOLVERwithX0

end module conjugate_gradients
