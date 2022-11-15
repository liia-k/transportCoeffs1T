!Test for calculation of all pre-required data: specific heats, omega and bracket integrals

PROGRAM test1

    USE CONSTANT
    USE SPECIFIC_HEAT
    USE OMEGA_INTEGRALS
    USE BRACKET_INTEGRALS
    
    
    IMPLICIT NONE

    INTEGER I,J,K,DELTA

!Matrices for the linear transport systems defining
!heat conductivity and thermal diffusion (LTH);
!bulk viscosity (BVISC);
!diffusion (LDIFF);
!shear viscisity (HVISC).

    REAL, DIMENSION(10,10) :: LTH 

    REAL, DIMENSION(8,8) :: BVISC 

    REAL, DIMENSION(5,5) ::  LDIFF, HVISC, b1

!Vectors of right hand terms

    REAL, DIMENSION(10,1) :: b

    REAL, DIMENSION(5,1) :: b2

    REAL, DIMENSION(8,1) :: b3


    REAL CU, CUT

    CALL ENERGY

    ee1=EN3(1,0,0)
    ee2=EN3(0,1,0)
    ee3=EN3(0,0,1)

! Input parameters: species molar fractions, temperatures,
! pressure


    x(1)=0.2
    x(2)=0.2
    x(3)=0.2
    x(4)=0.2
    x(5)=0.2

    T=1000
    T12=5000
    T3=5000
    TVO2=5000
    TVCO=5000

    press=101300

    ntot=press/kb/T

    rho=0
    do i=1,5
        rho=rho+x(i)*mass(i)*ntot
    end do


! Calculation of vibrational energy,
! partition functions and specific heats


    CALL PART_FUNC3(T12,T3)
    CALL PART_FUNC_O2(TVO2)
    CALL PART_FUNC_CO(TVCO)

    CALL S_HEAT3
    CALL S_HEAT_O2
    CALL S_HEAT_CO


! Calculation of bracket integrals

    CALL OMEGA
    CALL BRACKET

! Definition of matrix LTH for calculation of 
! thermal conductivity and thermal diffuaion coefficients
! The system has a form	(1)
! LTH times a = b, a is the vector of unknowns
    DO i=1,5
        DO j=1,5
            LTH(i,j)=Lambda00(i,j)
        END DO
    END DO
    
    DO i=1,5
        DO j=6,10
            LTH(i,j)=Lambda01(i,j-5)
        END DO
    END DO
    
    DO i=6,10
        DO j=1,5
            LTH(i,j)=LTH(j,i)
        END DO
    END DO
    
    DO i=6,10
        DO j=6,10
            LTH(i,j)=Lambda11(i-5,j-5)
        END DO
    END DO
    
    DO j=1,5
        LTH(1,j)=x(j)*mass(j)*ntot/rho
    END DO
    
    DO j=6,10
        LTH(1,j)=0.
    END DO
! End of matrix LTH definition


! Definition of matrix LDIFF for calculation of 
! diffuaion coefficients
! The system has a form	(2)
! LDIFF times D = B1, D a is the matrix of unknowns
     
    DO i=1,5
        DO j=1,5
          LDIFF(i,j)=LTH(i,j)
        END DO
    END DO
! End of matrix LDIFF definition


! Definition of matrix HVISC for calculation of 
! shear viscocity coefficient
! The system has a form	(3)
! HVISC times h = b2, h a is the vector of unknowns
     
    DO i=1,5
        DO j=1,5
          HVISC(i,j)=H00(i,j)
        END DO
    END DO
! End of matrix HVISC definition
    
    
! Definition of matrix BVISC for calculation of 
! bulk viscosity coefficients
! The system has a form	(4)
! BVISC times f = b3, f is the vector of unknowns
    DO i=1,5
        DO j=1,5
            BVISC(i,j)=beta11(i,j)
        END DO
    END DO
    
    DO i=1,5
        DO j=6,8
            BVISC(i,j)=beta01(i,j-5)
        END DO
    END DO
    
    DO i=6,8
        DO j=1,5
            BVISC(i,j)=BVISC(j,i)
        END DO
    END DO
    
    DO i=6,8
        DO j=6,8
            BVISC(i,j)=0
        END DO
    END DO
    
    BVISC(6,6)=beta0011(1)
    BVISC(7,7)=beta0011(2)
    BVISC(8,8)=beta0011(3)
    
    
    DO j=1,5
        BVISC(1,j)=x(j)*3./2.*kb*ntot/rho
    END DO
    
    DO j=6,6
        BVISC(1,j)=x(1)*kb/mass(1)
    END DO
    
    DO j=7,7
        BVISC(1,j)=x(2)*kb/mass(2)!*(1+c_v_o2)
    END DO
    
    DO j=8,8
        BVISC(1,j)=x(3)*kb/mass(3)!*(1+c_v_co)
    END DO
    
! End of matrix BVISC definition
    
    
! Definition of vector b (right hand side of system (1))
    DO i=1,5
        b(i,1)=0.
    END DO
    DO i=6,10
        b(i,1)=4./5./kb*x(i-5)
    END DO
! End of vector b definition
    
    
! Definition of matrix b1 (right hand side of system (2))
    DO i=1,5
        DO j=1,5
        if(i==j) then 
            delta=1
        else
            delta=0
        end if
        B1(i,j)=8./25./kb*(delta-mass(i)*x(i)*ntot/rho);
        END DO
    END DO
    
    DO j=1,5
        B1(1,j)=0
    END DO
! End of matrix b1 definition
    
! Definition of vector b2 (right hand side of system (3))
    DO i=1,5
        b2(i,1)=2./kb/t*x(i)
    END DO
! End of vector b2 definition
    
    
! Definition of vector b3 (right hand side of system (4))
    
    !cu=kb*ntot/rho*(3./2.+x(1)+x(2)*(1+c_v_o2)+x(3)*(1+c_v_co))
    !cut=kb*ntot/rho*(x(1)+x(2)*(1+c_v_o2)+x(3)*(1+c_v_co))
    
    cu=kb*ntot/rho*(3./2.+x(1)+x(2)+x(3))
    cut=kb*ntot/rho*(x(1)+x(2)+x(3))
    
    DO i=1,5
        b3(i,1)=-x(i)*cut/cu
    END DO
    
    b3(6,1)=x(1)*ntot/rho*kb/cu
    
    b3(7,1)=x(2)*ntot/rho*kb/cu !*(1+c_v_O2)
    
    b3(8,1)=x(3)*ntot/rho*kb/cu !*(1+c_v_co)
    
    b3(1,1)=0
    
! End of vector b3 definition
    
    
! Linear system solution using the Gauss method
! The solutions a, d, h, f are written to b, b1, b2, b3, respectively 
    
    CALL gaussj(LTH,10,10,b,1,1)
    CALL gaussj(Ldiff,5,5,b1,5,5)
    CALL gaussj(HVISC,5,5,b2,1,1)
    CALL gaussj(BVISC,8,8,b3,1,1)
    
    
! Thermal diffusion coefficients THDIF(i)
    
    DO i=1,5
        thdif(i)=-1./2./ntot*b(i,1)
    END DO
    
    
! Thermal conductivity coefficient associated to translational
! energy, LTR 
    
    LTR=0
    DO i=6,10
        LTR=LTR+5./4.*kb*x(i-5)*b(i,1)
    END DO
    
    
! Thermal conductivity coefficients associated to internal energies 
    
    lrot_co2=3.*kb*t*x(1)/16./lambda_int(1)*kb
    lrot_o2=3.*kb*t*x(2)/16./lambda_int(2)*kb
    lrot_co=3.*kb*t*x(3)/16./lambda_int(3)*kb
    lvibr_o2=3.*kb*t*x(2)/16./lambda_int(2)*kb*(c_v_o2)
    lvibr_co=3.*kb*t*x(3)/16./lambda_int(3)*kb*(c_v_co)
    lvibr_12=3.*kb*t*x(1)/16./lambda_int(1)*kb*(c_v_t12) 
    lvibr_3=3.*kb*t*x(1)/16./lambda_int(1)*kb*(c_v_t3) 
    
! Total thermal conductivity coefficient at the translational temperature gradient
    
    ltot=ltr+lrot_co2+lrot_o2+lrot_co
    
    
!Diffusion coefficients	DIFF(i,j)
    
    DO i=1,5
        DO j=1,5
            diff(i,j)=1./2./ntot*b1(i,j)
        END DO
    END DO
    
    
!Shear viscosity coefficient VISC
    
    visc=0
    DO i=1,5
        visc=visc+kb*t/2.*b2(i,1)*x(i)
    END DO
    
!Bulk viscosity coefficient BULK_VISC
    
    bulk_visc=0
    DO i=1,5
        bulk_visc=bulk_visc-kb*t*b3(i,1)*x(i)
    END DO


! Output

    open(6,file='test1.txt',status='unknown')

    WRITE (6, *) 'INPUT DATA:'

    WRITE (6, *)


    WRITE (6, *) 'Temperature, K        ',t
    WRITE (6, *) 'Temperature T12, K    ',t12
    WRITE (6, *) 'Temperature T3, K     ',t3
    WRITE (6, *) 'Temperature TVO2, K   ',tVO2
    WRITE (6, *) 'Temperature TVCO, K   ',tVCO
    WRITE (6, *) 'Pressure, Pa          ',press
    WRITE (6, *) 'CO2 molar fraction     ',x(1)
    WRITE (6, *) 'O2 molar fraction      ',x(2)
    WRITE (6, *) 'CO molar fraction      ',x(3)
    WRITE (6, *) 'O molar fraction       ',x(4)
    WRITE (6, *) 'C molar fraction       ',x(5)

    WRITE (6, *)

    WRITE (6, *) 'Calculation parameters required:'
    WRITE (6, *)

    WRITE (6, '(1x, A45, E13.5)') 'Internal energy CO2, J             ', en_int(1)
    WRITE (6, '(1x, A45, E13.5)') 'Internal energy O2, J              ', en_int(2)
    WRITE (6, '(1x, A45, E13.5)') 'Internal energy CO, J              ', en_int(3)
    WRITE (6, '(1x, A45, E13.5)') 'Omega13_11, J                      ', Omega13(1,1)


    WRITE (6, *)

    WRITE (6, *) 'Omega Integrals Omega11_ij'

    WRITE (6, *)

    do i=1,5
        !WRITE (6, '(0x, 5e15.6)') (DIFF(i,j), j=1,5)
        WRITE (6, '(1x, 5E15.6)') (omega12(i,j), j=1,5)
    end do

    WRITE (6, *)

    WRITE (6, *) 'Backet integrals b01_ij'
    
    WRITE (6, *)

    do i=1,5
        !WRITE (6, '(0x, 5e15.6)') (DIFF(i,j), j=1,5)
        WRITE (6, '(1x, 5E15.6)') (beta01(i,j), j=1,5)
    end do

    WRITE (6, *)

    WRITE (6, *) 'Backet integrals b11_ij'
    
    WRITE (6, *)

    do i=1,5
        !WRITE (6, '(0x, 5e15.6)') (DIFF(i,j), j=1,5)
        WRITE (6, '(1x, 5E15.6)') (beta11(i,j), j=1,5)
    end do

END