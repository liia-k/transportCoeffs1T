program test_omp

    use constant_air5
    ! use specific_heat_sp
    ! use omega_integrals
    ! use bracket_integrals
    use transport_1t
    ! use transport_1t_simpl
    use defs_models

    use omp_lib !OMP_NUM_THREADS=5
    
    implicit none

    real :: M, ntot, press, T, rho

    real, dimension(5) :: y, x

    integer :: i, j, k, n

    type(transport_in), dimension(:), allocatable :: transport
    ! type(cv_out) :: cv
    ! type(omega_int) :: omega_test
    ! type(bracket_int) :: bracket_test
    type(transport_out), dimension(:), allocatable :: transport_coeff


    x(1)=0.77999
    x(2)=0.19999
    x(3)=0.01999
    x(4)=0.00086999
    x(5)=0.00099

    n = 10000

    allocate(transport(n))
    allocate(transport_coeff(n))

    ! y(1) = 0.756656E+00   
    ! y(2) = 0.221602E+00   
    ! y(3) = 0.207714E-01   
    ! y(4) = 0.421982E-03   
    ! y(5) = 0.548507E-03

    press = 100000

    
    !$OMP parallel
    ! !$OMP do

    do k = 500, n

        T = k * 1.
        ntot = press/kb/T
        rho = sum(MASS_SPCS*ntot*x)
        ! M = dot_product(X,MOLAR)
        ! rho = M*press/R/T
        
        y = (ntot/rho)*x*MASS_SPCS

        transport(k)%temp = T
        transport(k)%mass_fractions = y
        transport(k)%rho = rho

        
        !call SpHeat(transport(k), cv)
        !call OmegaInt(transport%temp, omega_test)
        !call BracketInt(transport%temp, x, omega_test, bracket_test)
        call Transport1T(transport(k), transport_coeff(k))

        write (6, *) 'Process num. ', OMP_GET_THREAD_NUM()

    end do

    ! !$OMP end do

    !$OMP end parallel

    !!$OMP CRITICAL

    open(6, file='air5_1Ttest.txt', status='unknown')

    do k = 500, N

        T = k * 1.

        write (6, *) 'INPUT DATA:'

        write (6, *)


        write (6, *) 'Temperature, K         ',T
        write (6, *) 'Pressure, Pa           ',press
        write (6, *) 'N2 molar fraction      ',x(1)
        write (6, *) 'O2 molar fraction      ',x(2)
        write (6, *) 'NO molar fraction      ',x(3)
        write (6, *) 'N molar fraction       ',x(4)
        write (6, *) 'O molar fraction       ',x(5)

        write (6, *)

        write (6, *) 'TRANSPORT COEFFICIENTS:'
        write (6, *)

        write (6, '(1x, A45, E13.5)') 'Shear viscosity coefficient, Pa.S             ', transport_coeff(k)%visc
        write (6, '(1x, A45, E13.5)') 'Bulk viscosity coefficient, Pa.s              ', transport_coeff(k)%bulk_visc
        write (6, '(1x, A45, E13.5)') 'Thermal cond. coef. lambda, W/m/K             ', transport_coeff(k)%ltot
        !write (6, '(1x, A45, E13.5)') 'Thermal cond. coef. lambda, tr , W/m/K        ', ltr
        !write (6, '(1x, A45, E13.5)') 'Thermal cond. coef. lambda, int , W/m/K       ', lint
        !write (6, '(1x, A45, E13.5)') 'Vibr. therm. cond. coef. lambda_N2, W/m/K     ', lvibr_n2
        !write (6, '(1x, A45, E13.5)') 'Vibr. therm. cond. coef. lambda_O2, W/m/K     ', lvibr_o2
        !write (6, '(1x, A45, E13.5)') 'Vibr. therm. cond. coef. lambda_NO, W/m/K     ', lvibr_no
        write (6, '(1x, A45, E13.5)') 'Thermal diffusion coef. of N2, m^2/s          ', transport_coeff(k)%THDIFF(1)
        write (6, '(1x, A45, E13.5)') 'Thermal diffusion coef. of O2, m^2/s          ', transport_coeff(k)%THDIFF(2)
        write (6, '(1x, A45, E13.5)') 'Thermal diffusion coef. of NO, m^2/s          ', transport_coeff(k)%THDIFF(3)
        write (6, '(1x, A45, E13.5)') 'Thermal diffusion coef. of N, m^2/s           ', transport_coeff(k)%THDIFF(4)
        write (6, '(1x, A45, E13.5)') 'Thermal diffusion coef. of O, m^2/s           ', transport_coeff(k)%THDIFF(5)

        write (6, *)
        write (6, *) 'DIFFUSION COEFFICIENTS D_ij, m^2/s'
        write (6, *)


        do i=1,5
            write (6, '(1x, 5E15.6)') (transport_coeff(k)%DIFF(i,j), j=1,5)
        end do

        write (6, *)

    end do

    close(6)

    !!$OMP END CRITICAL

end program