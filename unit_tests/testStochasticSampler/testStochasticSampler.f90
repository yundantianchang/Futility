!++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++!
!                              Copyright (C) 2012                              !
!                   The Regents of the University of Michigan                  !
!              MPACT Development Group and Prof. Thomas J. Downar              !
!                             All rights reserved.                             !
!                                                                              !
! Copyright is reserved to the University of Michigan for purposes of          !
! controlled dissemination, commercialization through formal licensing, or     !
! other disposition. The University of Michigan nor any of their employees,    !
! makes any warranty, express or implied, or assumes any liability or          !
! responsibility for the accuracy, completeness, or usefulness of any          !
! information, apparatus, product, or process disclosed, or represents that    !
! its use would not infringe privately owned rights. Reference herein to any   !
! specific commercial products, process, or service by trade name, trademark,  !
! manufacturer, or otherwise, DOes not necessarily constitute or imply its     !
! enDOrsement, recommendation, or favoring by the University of Michigan.      !
!++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++!
PROGRAM testStochasticSampler
      
  USE IntrType
  USE StochasticSampling
  USE ISO_FORTRAN_ENV
  IMPLICIT NONE
  
  TYPE(StochasticSamplingType) :: myRNG
  TYPE(StochasticSamplingType) :: myRNG2
  REAL(SDK),ALLOCATABLE ::  y(:), z(:)
  INTEGER(SIK),ALLOCATABLE :: iii(:)
  REAL(SDK) :: mean, stdev, x
  INTEGER :: i,j,n
  
  INTERFACE
    FUNCTION linear(x)
      IMPORT :: SDK
      REAL(SDK),INTENT(IN) :: x
      REAL(SDK) :: linear
    ENDFUNCTION
  ENDINTERFACE
  
  WRITE(*,*) '==================================================='
  WRITE(*,*) 'TESTING STOCHASTIC SAMPLER...'
  WRITE(*,*) '==================================================='
  
  ! Test Manager Init
  CALL myRNG%init(3)
  ! Test Initialize
  IF (.NOT. myRNG%isInit) THEN
    WRITE(*,*) 'RNG did not initialize.  Test FAILED!'
    STOP 666
  ENDIF
  IF (myRNG%counter/=0) THEN
    WRITE(*,*) 'RNG did not initialize properly.  Test FAILED!'
    STOP 666
  ENDIF

  CALL TestRNG()
  
  CALL myRNG2%init(3)
  WRITE(*,*) "RNG 2 Preskip: ", myRNG2%rng()
  CALL myRNG2%clear()
  CALL myRNG2%init(3,skip=myRNG%counter)
  IF (.NOT. (myRNG%rng()==myRNG2%rng())) THEN
    WRITE(*,*) 'RNG did not skip ahead properly.  Test FAILED!'
    STOP 666
  ENDIF
  WRITE(*,*) "RNG 1:         ", myRNG%rng()
  WRITE(*,*) "RNG 2 Skipped: ", myRNG2%rng()
  CALL myRNG2%clear()
  
  n=1e6

  mean=0.0
  stdev=0.0
  DO i=1,n
    x=myRNG%rng()
    mean=mean+x
    stdev=stdev+x**2
  ENDDO
  
  WRITE(*,*) "Test RNG"
  WRITE(*,*) "COUNT:  ", myRNG%counter
  mean=mean/n
  WRITE(*,*) "MEAN:      ", mean
  WRITE(*,*) "MEAN TRUE: ", 0.5_SDK
  WRITE(*,*) "SDEV:      ", SQRT(stdev/n-mean**2)
  WRITE(*,*) "SDEV TRUE: ", 1.0/SQRT(12.0)
  
  WRITE(*,*)
  WRITE(*,*) "Test Uniform"
  mean=0.0
  stdev=0.0
  DO i=1,n
    x=myRNG%uniform(-8.0_SDK,9.0_SDK)
    mean=mean+x
    stdev=stdev+x**2
  ENDDO
  WRITE(*,*) "COUNT:  ", myRNG%counter
  mean=mean/n
  WRITE(*,*) "MEAN:      ", mean
  WRITE(*,*) "MEAN TRUE: ", (9.0_SDK+ (-8.0_SDK))/2.0_SDK
  WRITE(*,*) "SDEV:      ", SQRT(stdev/n-mean**2)
  WRITE(*,*) "SDEV TRUE: ", (9.0_SDK- (-8.0_SDK))/SQRT(12.0)
  
 WRITE(*,*)
  WRITE(*,*) "Test Exponential"
  mean=0.0
  stdev=0.0
  DO i=1,n
    x=myRNG%exponential(2.0_SDK)
    mean=mean+x
    stdev=stdev+x**2
  ENDDO
  WRITE(*,*) "COUNT:  ", myRNG%counter
  mean=mean/n
  WRITE(*,*) "MEAN:      ", mean
  WRITE(*,*) "MEAN TRUE: ", 1.0_SDK/2.0_SDK
  WRITE(*,*) "SDEV:      ", SQRT(stdev/n-mean**2)
  WRITE(*,*) "SDEV TRUE: ", 1.0_SDK/2.0_SDK
  
  WRITE(*,*)
  WRITE(*,*) "Test Normal"
  mean=0.0
  stdev=0.0
  DO i=1,n
    x=myRNG%normal(2.0_SDK,0.5_SDK)
    mean=mean+x
    stdev=stdev+x**2
  ENDDO
  WRITE(*,*) "COUNT:  ", myRNG%counter
  mean=mean/n
  WRITE(*,*) "MEAN:      ", mean
  WRITE(*,*) "MEAN TRUE: ", 2.0_SDK
  WRITE(*,*) "SDEV:      ", SQRT(stdev/n-mean**2)
  WRITE(*,*) "SDEV TRUE: ", 0.5_SDK

  
  WRITE(*,*)
  WRITE(*,*) "Test Log-Normal"
  mean=0.0
  stdev=0.0
  DO i=1,n
    x=myRNG%lognormal(2.0_SDK,0.5_SDK)
    mean=mean+x
    stdev=stdev+x**2
  ENDDO
  WRITE(*,*) "COUNT:  ", myRNG%counter
  mean=mean/n
  WRITE(*,*) "MEAN:      ", mean
  WRITE(*,*) "MEAN TRUE: ", EXP(2.0_SDK+0.5_SDK**2/2.0_SDK)
  WRITE(*,*) "SDEV:      ", SQRT(stdev/n-mean**2)
  WRITE(*,*) "SDEV TRUE: ", SQRT((EXP(0.5_SDK**2)-1.0_SDK)*EXP(2.0_SDK*2.0_SDK+0.5_SDK**2))

  CALL TestMaxwellian()
  CALL TestWatt()

  WRITE(*,*)
  WRITE(*,*) "Test Normalized Histogram"
  ALLOCATE(y(5))
  y=(/ 0.2, 0.4, 0.1, 0.05, 0.25 /)
  ALLOCATE(iii(5))
  iii=0
  DO i=1,n
    j=myRNG%histogram(y)
    iii(j)=iii(j)+1
  ENDDO
  WRITE(*,*) "COUNT:  ", myRNG%counter
  DO i=1,5
    WRITE(*,*) "           ", REAL(iii(i))/REAL(n)
  ENDDO

  WRITE(*,*)
  WRITE(*,*) "Test Unnormalized Histogram"
  y=(/ 0.2, 0.4, 0.1, 0.05, 0.25 /)
  iii=0
  DO i=1,n
    j=myRNG%unnormhistogram(y)
    iii(j)=iii(j)+1
  ENDDO
  WRITE(*,*) "COUNT:  ", myRNG%counter
  DO i=1,5
    WRITE(*,*) "           ", REAL(iii(i))/REAL(n)
  ENDDO

  WRITE(*,*)
  WRITE(*,*) "Test Normalized Continuous Histogram"
  y=(/ 0.2, 0.4, 0.1, 0.05, 0.25 /)
  allocate(z(6))
  z=(/ 1.0, 2.0, 3.0, 4.0, 5.0, 6.0 /)
  mean=0.0
  stdev=0.0
  DO i=1,n
    x=myRNG%conthistogram(y,z)
    mean=mean+x
    stdev=stdev+x**2
  ENDDO
  WRITE(*,*) "COUNT:  ", myRNG%counter
  mean=mean/n
  WRITE(*,*) "MEAN:      ", mean
  WRITE(*,*) "SDEV:      ", SQRT(stdev/n-mean**2)

  WRITE(*,*)
  WRITE(*,*) "Test Unormalized Continuous Histogram"
  y=2.0*y
  z=(/ 1.0, 2.0, 3.0, 4.0, 5.0, 6.0 /)
  mean=0.0
  stdev=0.0
  DO i=1,n
    x=myRNG%conthistogram(y,z)
    mean=mean+x
    stdev=stdev+x**2
  ENDDO
  WRITE(*,*) "COUNT:  ", myRNG%counter
  mean=mean/n
  WRITE(*,*) "MEAN:      ", mean
  WRITE(*,*) "SDEV:      ", SQRT(stdev/n-mean**2)

  WRITE(*,*)
  WRITE(*,*) "Test Normalized Piece-wise Linear"
  DEALLOCATE(y,z)
  ALLOCATE(y(3),z(3))
  y=(/ 0.0, 1.0, 0.0 /)
  z=(/ 0.0, 1.0, 2.0 /)
  mean=0.0
  stdev=0.0
  DO i=1,n
    x=myRNG%pwlinear(y,z)
    mean=mean+x
    stdev=stdev+x**2
  ENDDO
  WRITE(*,*) "COUNT:  ", myRNG%counter
  mean=mean/n
  WRITE(*,*) "MEAN:      ", mean
  WRITE(*,*) "MEAN TRUE: ", 1.0_SDK
  WRITE(*,*) "SDEV:      ", SQRT(stdev/n-mean**2)
  WRITE(*,*) "SDEV TRUE: ", 1.0_SDK/SQRT(6.0_SDK)

  WRITE(*,*)
  WRITE(*,*) "Test Unnormalized Piece-wise Linear"
  y=(/ 0.0, 2.0, 0.0 /)
  z=(/ 0.0, 1.0, 3.0 /)
  mean=0.0
  stdev=0.0
  DO i=1,n
    x=myRNG%unnormpwlinear(y,z)
    mean=mean+x
    stdev=stdev+x**2
  ENDDO
  WRITE(*,*) "COUNT:  ", myRNG%counter
  mean=mean/n
  WRITE(*,*) "MEAN:      ", mean
  WRITE(*,*) "MEAN TRUE: ", 4.0_SDK/3.0_SDK
  WRITE(*,*) "SDEV:      ", SQRT(stdev/n-mean**2)
  WRITE(*,*) "SDEV TRUE: ", SQRT(7.0_SDK)/SQRT(18.0_SDK)

  WRITE(*,*)
  WRITE(*,*) "Test Rejection Sampling"
  mean=0.0
  stdev=0.0
  DO i=1,n
    x=myRNG%rejection(linear,0.0_SDK,5.0_SDK,7.0_SDK)
    mean=mean+x
    stdev=stdev+x**2
  ENDDO
  WRITE(*,*) "COUNT:  ", myRNG%counter
  mean=mean/n
  WRITE(*,*) "MEAN:      ", mean
  WRITE(*,*) "MEAN TRUE: ", 10.0_SDK/3.0_SDK
  WRITE(*,*) "SDEV:      ", SQRT(stdev/n-mean**2)
  WRITE(*,*) "SDEV TRUE: ", 5.0_SDK/SQRT(18.0_SDK)
    
  WRITE(*,*) '==================================================='
  WRITE(*,*) 'TESTING STOCHASTIC SAMPLER PASSED!'
  WRITE(*,*) '==================================================='
!
!===============================================================================
  CONTAINS
!
!-------------------------------------------------------------------------------
    SUBROUTINE TestRNG
      INTEGER(SLK) :: i,n, inicount
      REAL(SDK) :: x, mean, stdev
      
      WRITE(*,*) 'TESTING RNG'
      
      n=100000000
      
      inicount=myRNG%counter
      mean=0.0
      stdev=0.0
      DO i=1,n
        x=myRNG%rng()
        mean=mean+x/REAL(n)
        stdev=stdev+x**2/REAL(n)
      ENDDO

      IF (myRNG%counter-inicount /= n) THEN
        WRITE(*,*) 'counter increment FAILED!'
        STOP 666
      ENDIF
      
      IF (ABS(mean-0.5_SDK)>1.0_SDK/SQRT(REAL(n))) THEN
        WRITE(*,*) 'RNG mean DOes not meet criteria: RNG test FAILED!'
        STOP 666
      ENDIF
      
      IF (ABS(SQRT(stdev-mean**2)-1.0_SDK/SQRT(12.0_SDK))>1.0_SDK/SQRT(REAL(n))) THEN
        WRITE(*,*) 'RNG standard deviation DOes not meet criteria: RNG test FAILED!'
        STOP 666
      ELSE
        WRITE(*,*) 'RNG TEST PASSED!'
      ENDIF
    ENDSUBROUTINE TestRNG
!
!-------------------------------------------------------------------------------
    SUBROUTINE TestMaxwellian
      INTEGER(SLK) :: i,n,inicount
      REAL(SDK) :: x,mean,stdev,T
      n=1000000
      WRITE(*,*)
      WRITE(*,*) "Test Maxwellian"
      T=600.0_SDK
      mean=0.0
      stdev=0.0
      DO i=1,n
        x=myRNG%maxwellian(T)
        mean=mean+x/n
        stdev=stdev+x**2/n
      ENDDO
      WRITE(*,*) "COUNT:  ", myRNG%counter
      WRITE(*,*) "MEAN:      ", mean
      WRITE(*,*) "MEAN TRUE: ", 3.0_SDK/2.0_SDK*T
      WRITE(*,*) "SDEV:      ", SQRT(stdev-mean**2)
      WRITE(*,*) "SDEV TRUE: ", SQRT(3.0_SDK/2.0_SDK)*T
    ENDSUBROUTINE TestMaxwellian
!
!-------------------------------------------------------------------------------
    SUBROUTINE TestWatt
      INTEGER(SLK) :: i,n, inicount
      REAL(SDK) :: x, mean, stdev, a, b
      
      n=1e6
      
      WRITE(*,*)
      WRITE(*,*) "Test Watt Fission"
      a=2.0_SDK
      b=0.5_SDK
      
      mean=0.0
      stdev=0.0
      DO i=1,n
        x=myRNG%watt(a,b)
        mean=mean+x/n
        stdev=stdev+x**2/n
      ENDDO
      WRITE(*,*) "COUNT:  ", myRNG%counter
      WRITE(*,*) "MEAN:      ", mean
      WRITE(*,*) "MEAN TRUE: ", a**2.5*SQRT(b)*(6.0_SDK+a*b)/(4.0_SDK*SQRT(a**3*b))
      WRITE(*,*) "SDEV:      ", SQRT(stdev-mean**2)
      WRITE(*,*) "SDEV TRUE: ", SQRT((a**2*(-36.0*SQRT(a**3*b)+a*SQRT(b)*(12.0+a*b)* &
            (4.0*SQRT(a)+a**1.5*b-SQRT(b)*SQRT(a**3*b))))/SQRT(a**3*b))/(2.0*SQRT(2.0))
    ENDSUBROUTINE TestWatt
!
!-------------------------------------------------------------------------------
    FUNCTION lineararg(x,coef) RESULT(y)
      REAL(SDK),INTENT(IN) :: x
      REAL(SDK),INTENT(IN) :: coef(:)
      REAL(SDK) :: y
      y=coef(1)*x+coef(2)
    ENDFUNCTION lineararg
!
ENDPROGRAM testStochasticSampler

FUNCTION linear(x) RESULT(y)
  USE IntrType
  REAL(SDK),INTENT(IN) :: x
  REAL(SDK) :: y
      
  y=x
ENDFUNCTION
