 program Balken
 implicit none
 real(8), parameter :: EA = 1.0d5, EI=1.0d4 ,Ltotal = 9.0d0, Z = 0.0d0, GZ=1.0d15
 real(8), parameter :: kWinkler = 100.0d0
 real(8), parameter :: Pload = -100.0d0
 integer, parameter :: nelem = 3, nDOFn = 3
 integer, parameter :: nnods = nelem+1 , nDOFs  = nnods*nDOFn
 integer :: i,j,io,jo,it,jt,ielem, inode
 real(8) :: A,B,C,D,L
 integer :: topologie(nelem, 2), einInteger 
 real(8), dimension(3,3) :: K11, K22, K12, K21
 real(8), dimension(6,6) :: KK
 real(8), dimension(nDOFs, nDOFs) :: Kglob
 real(8), dimension(nDOFs) :: disp, load
 
 open(11, file='out.txt' )
 open(12, err=999, file='balken-input.txt',status='old')
  
 L = Ltotal /nelem
 A= EA/L
 B= 12*EI/L**3
 C= 6*EI/L**2
 D= 2*EI/L
 K11 = transpose(reshape([A,Z,Z, Z,B,C,  Z,C,2*D ], [3,3]) )
 K22 = transpose(reshape([A,Z,Z, Z,B,-C,  Z ,-C, 2*D ], [3,3]) )
 K12 = transpose(reshape([-A,Z,Z,  Z,-B,C,  Z ,-C, D ], [3,3]) )
 K21 = transpose( K12 )

 KK(:,:) = 0
 KK(1:3,1:3) = K11
 KK(1:3,4:6) = K12
 KK(4:6,1:3) = K21
 KK(4:6,4:6) = K22
 read(12,*,err=998) einInteger 
 Kglob(:,:) = 0
!  topologie = transpose( reshape( [1,2,  2,3,  3,4 ], [2, 3 ] )
 do i=1,nelem
 topologie(i,1) = i
 topologie(i,2) = i+1
 enddo

 do ielem=1,nelem
 i = topologie(ielem,1)
 j = topologie(ielem,2)
 io  = (i-1)*3 + 1
 it = io + 2
 jo  = (j-1)*3 + 1
 jt = jo + 2
 Kglob(io:it,io :it ) = Kglob(io:it,io :it ) +  K11(:,:)
 Kglob(io:it,jo :jt ) = Kglob(io:it,jo :jt ) +  K12(:,:)
 Kglob(jo:jt,io :it ) = Kglob(jo:jt,io :it ) +  K21(:,:)
 Kglob(jo:jt,jo :jt ) = Kglob(jo:jt,jo :jt ) +  K22(:,:)
 enddo
 ! modification of global stiffness  accounts for supports and Winkler bedding
   Kglob(1,1) =   Kglob(1,1) + GZ
   Do inode =1,nnods
   i= (inode -1)*3 + 2
       Kglob(i,i) = Kglob(i,i) + kWinkler
   enddo

 ! definition of load  Pload = 100
  load(:) = 0
  load(nDOFs-1) = Pload

  disp(:) = 0

 call symSolve(Kglob,load,disp, nDOFs )

 write(11,*) 'einInteger=', einInteger, 'analytisch: ', Pload*Ltotal**3/(3*EI), 'numerisch: ', disp(nDOFs -1)

 ! read(*,*) i
    stop 'finished successfully' 
999 stop ' cannot open the input file '
998 stop 'error in reading, probably trying to read beyond the EOF'
 end program Balken
 
 SUBROUTINE symSolve(gstiff,load,disp,n)
    IMPLICIT NONE
    REAL(8) :: a(n,n+1),gstiff(n,n),load(n),disp(n)
    REAL(8) :: c, d
    INTEGER :: i,j,k,m,n
    m = n+1
    a(1:n,1:n)=gstiff
    a(1:n,m) = load
    DO   i = 1, n
    c = a(i,i)
    if(abs(c) < 1.0d-10) write(*,*) '*** Warning in symSolve probably a singular matrix'
    a(i,i) = c - 1.0d0
    DO   k = i+1, m
    d = a(i,k) / c
    DO   j = 1, n
    a(j,k) = a(j,k) - d*a(j,i)
    enddo
    enddo 
    enddo     
    disp = a(1:n,m)
    RETURN
  END SUBROUTINE symSolve
  
  SUBROUTINE another_symSolve(gstiff,load,disp,n)
    IMPLICIT NONE
    REAL(8) :: a(n,n+1),gstiff(n,n),load(n),disp(n)
    REAL(8) :: c, d
    INTEGER :: i,j,k,m,n
    m = n+1
    a(1:n,1:n)=gstiff
    a(1:n,m) = load
    DO 1 i = 1, n
    c = a(i,i)
    if(abs(c) < 1.0d-10) write(*,*) '*** Warning in symSolve probably a singular matrix'
    a(i,i) = c - 1.0d0
    DO 1 k = i+1, m
    d = a(i,k) / c
    DO 1 j = 1, n
    a(j,k) = a(j,k) - d*a(j,i)
1   continue
    disp = a(1:n,m)
    RETURN
  END SUBROUTINE another_symSolve

